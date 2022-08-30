module cetus_amm::amm_swap {
    use std::string;
    use std::error;
    use std::signer;
    use std::option;

    use aptos_framework::account;
    use aptos_std::event::{Self, EventHandle};
    use aptos_framework::coin::{Self, Coin, BurnCapability, MintCapability};
    use aptos_framework::coins;
    use aptos_std::comparator;
    use cetus_amm::amm_utils::{Self, assert_is_coin, compare_coin, get_amount_out, get_amount_in};
    use cetus_amm::amm_config::{Self, assert_admin};
    use cetus_amm::amm_math::{Self, quote, sqrt, min};
    use aptos_std::type_info;


    const MINIMUM_LIQUIDITY: u128 = 1000;

    //
    // Errors
    //

    const ESWAP_COINS_COMPARE_NOT_EQUIP_SMALLER: u64 = 4001;
    const ESWAP_ACCOUNT_NOT_EXISTED: u64 = 4002;
    const ERROR_LIQUIDITY_INSUFFICIENT_B_AMOUNT: u64 = 4003;
    const ERROR_LIQUIDITY_OVERLIMIT_X_DESIRED: u64 = 4004;
    const ERROR_LIQUIDITY_INSUFFICIENT_A_AMOUNT: u64 = 4005;
    const ERROR_LIQUIDITY_INSUFFICIENT_MINTED: u64 = 4006;
    const ERROR_LIQUIDITY_ADD_LIQUIDITY_FAILED: u64 = 4007;
    const ERROR_LIQUIDITY_SWAP_BURN_CALC_INVALID: u64 = 4008;
    const ESWAP_COIN_INSUFFICIENT: u64 = 4009;
    const ESWAP_SWAPOUT_CALC_INVALID: u64 = 4010;
    const ESWAP_B_OUT_LESSTHAN_EXPECTED: u64 = 4011;
    const ESWAP_INVALID_COIN_PAIR: u64 = 4012;
    const ESWAP_A_IN_OVER_LIMIT_MAX: u64 = 4013;

    const EQUAL: u8 = 0;
    const LESS_THAN: u8 = 1;
    const GREATER_THAN: u8 = 2;

    struct PoolLiquidityCoin<phantom CoinTypeA, phantom CoinTypeB> {}

    struct Pool<phantom CoinTypeA, phantom CoinTypeB> has key {
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,

        mint_capability: MintCapability<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        burn_capability: BurnCapability<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,

        locked_liquidity: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,

        protocol_fee_to: address
    }

    struct InitPoolEvent has store, drop {
        coin_a_info: type_info::TypeInfo,
        coin_b_info: type_info::TypeInfo,
        account: address,
        protocol_fee_to: address,
    }

    struct AddLiquidityEvent has store, drop {
        liquidity: u128,
        account: address,
        coin_a_info: type_info::TypeInfo,
        coin_b_info: type_info::TypeInfo,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128,
    }

    struct RemoveLiquidityEvent has store, drop {
        liquidity: u128,
        account: address,
        coin_a_info: type_info::TypeInfo,
        coin_b_info: type_info::TypeInfo,
        amount_a_min: u128,
        amount_b_min: u128,
    }

    struct SwapEvent has store, drop {
        coin_a_info: type_info::TypeInfo,
        coin_b_info: type_info::TypeInfo,
        account: address,
        a_in: u128,
        b_out: u128,
    }

    struct SwapFeeEvent has store, drop {
        coin_a_info: type_info::TypeInfo,
        coin_b_info: type_info::TypeInfo,
        account: address,
        fee_address: address,
        fee_out: u128,
    }

    struct PoolSwapEventHandle has key {
        init_pool_events: EventHandle<InitPoolEvent>,
        add_liquidity_events: EventHandle<AddLiquidityEvent>,
        remove_liquidity_events: EventHandle<RemoveLiquidityEvent>,
        swap_events: EventHandle<SwapEvent>,
        swap_fee_events: EventHandle<SwapFeeEvent>,
    }

    public fun init_pool<CoinTypeA, CoinTypeB>(account: &signer, protocol_fee_to: address) acquires PoolSwapEventHandle {
        //check coin type
        assert_is_coin<CoinTypeA>();
        assert_is_coin<CoinTypeB>();

        //check admin
        assert_admin(account);

        //check protocol_fee_to existed
        assert!(
             account::exists_at(protocol_fee_to),
             error::invalid_argument(ESWAP_ACCOUNT_NOT_EXISTED));

        //compare coins
        assert!(
            comparator::is_smaller_than(&compare_coin<CoinTypeA, CoinTypeB>()),  
            error::invalid_argument(ESWAP_COINS_COMPARE_NOT_EQUIP_SMALLER));

        //reigister lp coin
        let(burn_capability, mint_capability) = register_liquidity_coin<CoinTypeA, CoinTypeB>(account);
        
        //make pool
        let pool = make_pool<CoinTypeA, CoinTypeB>(protocol_fee_to, burn_capability, mint_capability);
        move_to(account, pool);

        //init event handle
        init_event_handle(account);

        //emit init pool event
        emit_init_pool_event<CoinTypeA, CoinTypeB>(account, protocol_fee_to);
    }

    public fun add_liquidity<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128) acquires Pool, PoolSwapEventHandle {

        amm_config::assert_pause();

        let order = compare_coin<CoinTypeA, CoinTypeB>();
        assert!(
            !comparator::is_equal(&order),  
            error::invalid_argument(ESWAP_COINS_COMPARE_NOT_EQUIP_SMALLER));
        if (comparator::is_smaller_than(&order)) {
            intra_add_liquidity<CoinTypeA, CoinTypeB>(
                account,
                amount_a_desired,
                amount_b_desired,
                amount_a_min,
                amount_b_min,
            );
        } else {
            intra_add_liquidity<CoinTypeB, CoinTypeA>(
                account,
                amount_b_desired,
                amount_a_desired,
                amount_b_min,
                amount_a_min,
            );
        }
    }

    fun intra_add_liquidity<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128) acquires Pool, PoolSwapEventHandle {
        let (amount_a, amount_b) = intra_calculate_amount_for_liquidity<CoinTypeA, CoinTypeB>(
            amount_a_desired,
            amount_b_desired,
            amount_a_min,
            amount_b_min);
        let coinA = coin::withdraw<CoinTypeA>(account,(amount_a as u64));
        let coinB = coin::withdraw<CoinTypeB>(account,(amount_b as u64));
        let liquidity_token = mint_and_emit_event<CoinTypeA, CoinTypeB>(
                account,
                coinA,
                coinB,
                amount_a_desired,
                amount_b_desired,
                amount_a_min,
                amount_b_min);
        assert!(coin::value(&liquidity_token) > 0, error::invalid_argument(ERROR_LIQUIDITY_ADD_LIQUIDITY_FAILED));
        let sender = signer::address_of(account);
        if (!coin::is_account_registered<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(sender)) coins::register_internal<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(account);
        coin::deposit(sender,liquidity_token);
    }

    fun intra_calculate_amount_for_liquidity<CoinTypeA, CoinTypeB>(
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128,): (u128, u128) acquires Pool {
        let (reserve_a, reserve_b) = get_reserves<CoinTypeA, CoinTypeB>();
        if (reserve_a == 0 && reserve_b == 0) {
            return (amount_a_desired, amount_b_desired)
        } else {
            let amount_b_optimal = quote(amount_a_desired, reserve_a, reserve_b);
            if (amount_b_optimal <= amount_b_desired) {
                assert!(amount_b_optimal >= amount_b_min, ERROR_LIQUIDITY_INSUFFICIENT_B_AMOUNT);
                return (amount_a_desired, amount_b_optimal)
            } else {
                let amount_a_optimal = quote(amount_b_desired, reserve_b, reserve_a);
                assert!(amount_a_optimal <= amount_a_desired, ERROR_LIQUIDITY_OVERLIMIT_X_DESIRED);
                assert!(amount_a_optimal >= amount_a_min, ERROR_LIQUIDITY_INSUFFICIENT_A_AMOUNT);
                return (amount_a_optimal, amount_b_desired)
            }
        }
    }

    fun mint_and_emit_event<CoinTypeA, CoinTypeB>(
        account: &signer,
        coinA: Coin<CoinTypeA>, 
        coinB: Coin<CoinTypeB>,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128): Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>> acquires Pool, PoolSwapEventHandle {
        let liquidity_token = mint<CoinTypeA, CoinTypeB>(coinA,coinB);
        let event_handle = borrow_global_mut<PoolSwapEventHandle>(amm_config::admin_address());
        event::emit_event(&mut event_handle.add_liquidity_events,AddLiquidityEvent{
            liquidity: (coin::value<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(&liquidity_token) as u128),
            account: signer::address_of(account),
            coin_a_info:type_info::type_of<CoinTypeA>(),
            coin_b_info:type_info::type_of<CoinTypeB>(),
            amount_a_desired,
            amount_b_desired,
            amount_a_min,
            amount_b_min,
        });
        liquidity_token
    }

    fun mint<CoinTypeA, CoinTypeB>(
        coinA: Coin<CoinTypeA>, 
        coinB: Coin<CoinTypeB>): Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>> acquires Pool {

        let (reserve_a, reserve_b) = get_reserves<CoinTypeA, CoinTypeB>();

        let pool = borrow_global_mut<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());

        // get deposited amounts
        let amountA = (coin::value(&coinA) as u128);
        let amountB = (coin::value(&coinB) as u128);

        let total_supply = (*option::borrow(&coin::supply<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>()) as u128);
        let liquidity : u128;
        if (total_supply == 0) {
            liquidity = sqrt(amountA * amountB) - MINIMUM_LIQUIDITY;
            let locked_liquidity = coin::mint<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>((MINIMUM_LIQUIDITY as u64), &pool.mint_capability); // permanently lock the first MINIMUM_LIQUIDITY tokens
            coin::merge(&mut pool.locked_liquidity, locked_liquidity);
        } else {
            liquidity = min(amm_math::safe_mul_div_u128(amountA,total_supply,reserve_a), 
                            amm_math::safe_mul_div_u128(amountB,total_supply,reserve_b));
        };

        assert!(liquidity > 0, error::invalid_argument(ERROR_LIQUIDITY_INSUFFICIENT_MINTED));

        coin::merge(&mut pool.coin_a, coinA);
        coin::merge(&mut pool.coin_b, coinB);

        coin::mint<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>((liquidity as u64), &pool.mint_capability)
    }

    public fun remove_liquidity<CoinTypeA, CoinTypeB>(
        account: &signer,
        liquidity: u128,
        amount_a_min: u128,
        amount_b_min: u128) acquires Pool,PoolSwapEventHandle {

        amm_config::assert_pause();

        let order = compare_coin<CoinTypeA, CoinTypeB>();
        assert!(
            !comparator::is_equal(&order),  
            error::invalid_argument(ESWAP_COINS_COMPARE_NOT_EQUIP_SMALLER));
        if (comparator::is_smaller_than(&order)) {
            intra_remove_liquidity<CoinTypeA, CoinTypeB>(
                account,
                liquidity,
                amount_a_min,
                amount_b_min);
        } else {
            intra_remove_liquidity<CoinTypeB, CoinTypeA>(
                account,
                liquidity,
                amount_b_min,
                amount_a_min);
        }
    }

    fun intra_remove_liquidity<CoinTypeA, CoinTypeB>(
        account: &signer,
        liquidity: u128,
        amount_a_min: u128,
        amount_b_min: u128) acquires Pool,PoolSwapEventHandle {
        let liquidity_token = coin::withdraw<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(account,(liquidity as u64));
        let (token_a, token_b) = burn_and_emit_event(
            account,
            liquidity_token,
            amount_a_min,
            amount_b_min);
        assert!((coin::value(&token_a) as u128) >= amount_a_min, ERROR_LIQUIDITY_INSUFFICIENT_A_AMOUNT);
        assert!((coin::value(&token_b) as u128) >= amount_b_min, ERROR_LIQUIDITY_INSUFFICIENT_B_AMOUNT);
        let sender = signer::address_of(account);
        coin::deposit(sender,token_a);
        coin::deposit(sender,token_b);
    }


    fun burn_and_emit_event<CoinTypeA, CoinTypeB>(
        account: &signer,
        to_burn: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        amount_a_min: u128,
        amount_b_min: u128) : (Coin<CoinTypeA>, Coin<CoinTypeB>) acquires Pool, PoolSwapEventHandle {
        let liquidity = (coin::value<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(&to_burn) as u128);
        let (a_token, b_token) = burn<CoinTypeA, CoinTypeB>(to_burn);
        let event_handle = borrow_global_mut<PoolSwapEventHandle>(amm_config::admin_address());
        event::emit_event(&mut event_handle.remove_liquidity_events, RemoveLiquidityEvent {
            liquidity,
            account: signer::address_of(account),
            coin_a_info:type_info::type_of<CoinTypeA>(),
            coin_b_info:type_info::type_of<CoinTypeB>(),
            amount_a_min,
            amount_b_min,
        });
        (a_token, b_token)
    }

    fun burn<CoinTypeA, CoinTypeB>(to_burn: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>): (Coin<CoinTypeA>, Coin<CoinTypeB>) acquires Pool {
        let to_burn_value = (coin::value(&to_burn) as u128);
        let pool = borrow_global_mut<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        let reserveA = (coin::value(&pool.coin_a) as u128);
        let reserveB = (coin::value(&pool.coin_b) as u128);
        let total_supply = *option::borrow(&coin::supply<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>());
        let amount0 = (amm_math::safe_mul_div_u128(to_burn_value,reserveA,total_supply) as u64);
        let amount1 = (amm_math::safe_mul_div_u128(to_burn_value,reserveB,total_supply) as u64); 
        assert!(amount0 > 0 && amount1 > 0, error::invalid_argument(ERROR_LIQUIDITY_SWAP_BURN_CALC_INVALID)); 

        coin::burn(to_burn, &pool.burn_capability);
        
        (coin::extract(&mut pool.coin_a , amount0), coin::extract(&mut pool.coin_b, amount1))
    }

    public fun swap_and_emit_event<CoinTypeA, CoinTypeB>(
        account: &signer,
        coin_a_in: Coin<CoinTypeA>,
        coin_b_out: u128,
        coin_b_in: Coin<CoinTypeB>,
        coin_a_out: u128
    ) :(Coin<CoinTypeA>, Coin<CoinTypeB>, Coin<CoinTypeA>, Coin<CoinTypeB>) acquires Pool, PoolSwapEventHandle {
        let (coin_a_out, coin_b_out, coin_a_fee, coin_b_fee) = swap<CoinTypeA, CoinTypeB>(coin_a_in, coin_b_out, coin_b_in, coin_a_out);
        let event_handle = borrow_global_mut<PoolSwapEventHandle>(amm_config::admin_address());
        event::emit_event<SwapEvent>(
            &mut event_handle.swap_events,
            SwapEvent {
                coin_a_info: type_info::type_of<CoinTypeA>(),
                coin_b_info: type_info::type_of<CoinTypeB>(),
                account: signer::address_of(account),
                a_in: (coin::value<CoinTypeA>(&coin_a_out) as u128),
                b_out: (coin::value<CoinTypeB>(&coin_b_out) as u128) 
            }
        );
        (coin_a_out, coin_b_out, coin_a_fee, coin_b_fee)
    }

    public fun swap<CoinTypeA, CoinTypeB>(
        coin_a_in: Coin<CoinTypeA>,
        coin_b_out: u128,
        coin_b_in: Coin<CoinTypeB>,
        coin_a_out: u128, 
    ): (Coin<CoinTypeA>, Coin<CoinTypeB>, Coin<CoinTypeA>, Coin<CoinTypeB>) acquires Pool{
        amm_config::assert_pause();

        let a_in_value = coin::value(&coin_a_in);
        let b_in_value = coin::value(&coin_b_in);
        assert!(
            a_in_value > 0 || b_in_value > 0,  
            error::invalid_argument(ESWAP_COIN_INSUFFICIENT));

        let (a_reserve, b_reserve) = get_reserves<CoinTypeA, CoinTypeB>();
        let pool = borrow_global_mut<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        coin::merge(&mut pool.coin_a, coin_a_in);
        coin::merge(&mut pool.coin_b, coin_b_in);

        let coin_a_swapped = coin::extract(&mut pool.coin_a, (coin_a_out as u64));
        let coin_b_swapped = coin::extract(&mut pool.coin_b, (coin_b_out as u64));
        {
            let a_reserve_new = coin::value(&pool.coin_a);
            let b_reserve_new = coin::value(&pool.coin_b);
            let (fee_numerator, fee_denominator) = amm_config::get_trade_fee();
            
            let a_adjusted = (a_reserve_new as u128) * (fee_denominator as u128) - (a_in_value as u128) * (fee_numerator as u128);
            let b_adjusted = (b_reserve_new as u128) * (fee_denominator as u128) - (b_in_value as u128) * (fee_numerator as u128);

            let cmp_order = amm_math::safe_compare_mul_u128(a_adjusted, b_adjusted, (a_reserve as u128), (b_reserve as u128));
             assert!(
                (EQUAL == cmp_order || GREATER_THAN == cmp_order), 
                 error::invalid_argument(ESWAP_SWAPOUT_CALC_INVALID));
        };

        let (protocol_fee_numberator, protocol_fee_denominator) = calc_swap_protocol_fee_rate<CoinTypeA, CoinTypeB>();
        let a_swap_fee = coin::extract(&mut pool.coin_a, (amm_math::safe_mul_div_u128((a_in_value as u128), protocol_fee_numberator, protocol_fee_denominator) as u64));
        let b_swap_fee = coin::extract(&mut pool.coin_b, (amm_math::safe_mul_div_u128((b_in_value as u128), protocol_fee_numberator, protocol_fee_denominator) as u64));

        (coin_a_swapped, coin_b_swapped, a_swap_fee, b_swap_fee)
    }

    public fun swap_exact_coin_for_coin<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_in: u128,
        amount_b_out_min: u128,
    )  acquires Pool, PoolSwapEventHandle {
         assert!(
            !comparator::is_equal(&compare_coin<CoinTypeA, CoinTypeB>()),  
            error::invalid_argument(ESWAP_INVALID_COIN_PAIR));

        let sender = signer::address_of(account);
        if (!coin::is_account_registered<CoinTypeB>(sender)) coins::register_internal<CoinTypeB>(account);

        let b_out = compute_b_out<CoinTypeA, CoinTypeB>(amount_a_in);
        assert!(b_out >= amount_b_out_min, 
            error::invalid_argument(ESWAP_B_OUT_LESSTHAN_EXPECTED));

        let coin_a = coin::withdraw<CoinTypeA>(account, (amount_a_in as u64));
        let (coin_a_out, coin_b_out);
        let (coin_a_fee, coin_b_fee);
        if (comparator::is_smaller_than(&compare_coin<CoinTypeA, CoinTypeB>())) {
            (coin_a_out, coin_b_out, coin_a_fee, coin_b_fee) = swap_and_emit_event<CoinTypeA, CoinTypeB>(account, coin_a, b_out, coin::zero(), 0);
        } else {
            (coin_b_out, coin_a_out, coin_b_fee, coin_a_fee) = swap_and_emit_event<CoinTypeB, CoinTypeA>(account, coin::zero(), 0, coin_a, b_out);
        };

        coin::destroy_zero(coin_a_out);
        coin::deposit(sender, coin_b_out);
        coin::destroy_zero(coin_b_fee);

        handle_swap_protocol_fee<CoinTypeA, CoinTypeB>(sender, coin_a_fee);
    }

    public fun swap_coin_for_exact_coin<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_in_max: u128,
        amount_b_out: u128
    ) acquires Pool, PoolSwapEventHandle {
         assert!(
            !comparator::is_equal(&compare_coin<CoinTypeA, CoinTypeB>()),  
            error::invalid_argument(ESWAP_INVALID_COIN_PAIR));

        let sender = signer::address_of(account);
        if (!coin::is_account_registered<CoinTypeB>(sender)) coins::register_internal<CoinTypeB>(account);

        let a_in = compute_a_in<CoinTypeA, CoinTypeB>(amount_b_out);
        assert!(a_in <= amount_a_in_max, 
            error::invalid_argument(ESWAP_A_IN_OVER_LIMIT_MAX));

        let coin_a = coin::withdraw<CoinTypeA>(account, (a_in as u64));
        let (coin_a_out, coin_b_out);
        let (coin_a_fee, coin_b_fee);
        if (comparator::is_smaller_than(&compare_coin<CoinTypeA, CoinTypeB>())) {
            (coin_a_out, coin_b_out, coin_a_fee, coin_b_fee) = swap_and_emit_event<CoinTypeA, CoinTypeB>(account, coin_a, amount_b_out, coin::zero(), 0);
        } else {
            (coin_b_out, coin_a_out, coin_b_fee, coin_a_fee) = swap_and_emit_event<CoinTypeB, CoinTypeA>(account, coin::zero(), 0, coin_a, amount_b_out);
        };

        coin::destroy_zero(coin_a_out);
        coin::deposit(sender, coin_b_out);
        coin::destroy_zero(coin_b_fee);

        handle_swap_protocol_fee<CoinTypeA, CoinTypeB>(sender, coin_a_fee);
    }

    fun make_pool<CoinTypeA, CoinTypeB>(
        protocol_fee_to: address,
        burn_capability: BurnCapability<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        mint_capability: MintCapability<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
    ): Pool<CoinTypeA, CoinTypeB> {
        Pool<CoinTypeA, CoinTypeB> {
            coin_a: coin::zero<CoinTypeA>(),
            coin_b: coin::zero<CoinTypeB>(),
            mint_capability: mint_capability,
            burn_capability: burn_capability,
            locked_liquidity: coin::zero<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(),
            protocol_fee_to: protocol_fee_to,
        }
    }

    fun register_liquidity_coin<CoinTypeA, CoinTypeB>(
        account: &signer
        ) :(BurnCapability<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>, MintCapability<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>){
        let (burn_capability, freeze_capability, mint_capability) = coin::initialize<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(
            account,
            string::utf8(b"CETUS AMM LP"),
            string::utf8(b"CALP"),
            18,
            true,
        );

        coin::destroy_freeze_cap(freeze_capability);
        (burn_capability, mint_capability)
    }

    fun init_event_handle(account: &signer) {
        if (!exists<PoolSwapEventHandle>(signer::address_of(account))) {
            move_to(account, PoolSwapEventHandle {
                init_pool_events: event::new_event_handle<InitPoolEvent>(account),
                add_liquidity_events: event::new_event_handle<AddLiquidityEvent>(account),
                remove_liquidity_events: event::new_event_handle<RemoveLiquidityEvent>(account),
                swap_events: event::new_event_handle<SwapEvent>(account),
                swap_fee_events: event::new_event_handle<SwapFeeEvent>(account),
            });
        }
    }

    fun emit_init_pool_event<CoinTypeA, CoinTypeB>(
        account: &signer,
        protocol_fee_to: address
    ) acquires PoolSwapEventHandle {
        let event_handle = borrow_global_mut<PoolSwapEventHandle>(amm_config::admin_address());
        event::emit_event<InitPoolEvent>(
            &mut event_handle.init_pool_events,
            InitPoolEvent {
                coin_a_info: type_info::type_of<CoinTypeA>(),
                coin_b_info: type_info::type_of<CoinTypeB>(),
                account: signer::address_of(account),
                protocol_fee_to: protocol_fee_to,
            }
        );
    }

    public fun get_reserves<CoinTypeA, CoinTypeB>(): (u128, u128) acquires Pool {
         if (comparator::is_smaller_than(&compare_coin<CoinTypeA, CoinTypeB>())) {
            let pool = borrow_global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
            let a_reserve = (coin::value(&pool.coin_a) as u128);
            let b_reserve = (coin::value(&pool.coin_b) as u128);
            (a_reserve, b_reserve)
         } else {
            let pool = borrow_global<Pool<CoinTypeB, CoinTypeA>>(amm_config::admin_address());
            let a_reserve = (coin::value(&pool.coin_a) as u128);
            let b_reserve = (coin::value(&pool.coin_b) as u128);
            (b_reserve, a_reserve)
         }
    }

    public fun calc_swap_protocol_fee_rate<CoinTypeA, CoinTypeB>() : (u128, u128) {
        let (fee_numerator, fee_denominator) = amm_config::get_trade_fee();
        let (protocol_fee_numberator, protocol_fee_denominator) = amm_config::get_protocol_fee();
         ((fee_numerator * protocol_fee_numberator as u128), (fee_denominator * protocol_fee_denominator as u128))
    }

    public fun compute_b_out<CoinTypeA, CoinTypeB>(amount_a_in: u128): u128 acquires Pool{
        let (fee_numerator, fee_denominator) = amm_config::get_trade_fee();
        let (reserve_a, reserve_b) = get_reserves<CoinTypeA, CoinTypeB>();
        get_amount_out(amount_a_in, (reserve_a as u128), (reserve_b as u128), fee_numerator, fee_denominator)
    }

    public fun compute_a_in<CoinTypeA, CoinTypeB>(amount_b_out: u128): u128 acquires Pool {
        let (fee_numerator, fee_denominator) = amm_config::get_trade_fee();
        let (reserve_a, reserve_b) = get_reserves<CoinTypeA, CoinTypeB>();
        get_amount_in(amount_b_out, reserve_a, reserve_b, fee_numerator, fee_denominator)
    }

    public fun handle_swap_protocol_fee<CoinTypeA, CoinTypeB>(signer_address: address, token_a: Coin<CoinTypeA>) acquires PoolSwapEventHandle, Pool {
         let pool = borrow_global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        intra_handle_swap_protocol_fee<CoinTypeA, CoinTypeB>(signer_address, pool.protocol_fee_to, token_a);
    }

    fun intra_handle_swap_protocol_fee<CoinTypeA, CoinTypeB>(
        signer_address: address,
        fee_address: address,
        coin_a: Coin<CoinTypeA>
    ) acquires PoolSwapEventHandle, Pool {
        let (fee_handle, fee_out) = swap_fee_direct_deposit<CoinTypeA, CoinTypeB>(fee_address, coin_a);
        if (fee_handle) {
            assert!(
                !comparator::is_equal(&compare_coin<CoinTypeA, CoinTypeB>()),  
                 error::invalid_argument(ESWAP_INVALID_COIN_PAIR));
            
             if (comparator::is_smaller_than(&compare_coin<CoinTypeA, CoinTypeB>())) {
                emit_swap_fee_event<CoinTypeA, CoinTypeB>(signer_address, fee_address, fee_out);
             } else {
                emit_swap_fee_event<CoinTypeB, CoinTypeA>(signer_address, fee_address, fee_out);
             };
        }
         
    }

    fun swap_fee_direct_deposit<CoinTypeA, CoinTypeB>(
        fee_address: address,
        coin_a: Coin<CoinTypeA>): (bool, u128) acquires Pool {
          if (!coin::is_account_registered<CoinTypeA>(fee_address)) {
            let a_value = coin::value(&coin_a);
            coin::deposit(fee_address, coin_a);
            return (true, (a_value as u128))
         } else {
             assert!(
                !comparator::is_equal(&compare_coin<CoinTypeA, CoinTypeB>()),  
                 error::invalid_argument(ESWAP_INVALID_COIN_PAIR));
            
             if (comparator::is_smaller_than(&compare_coin<CoinTypeA, CoinTypeB>())) {
                return_back_to_lp_pool<CoinTypeA, CoinTypeB>(coin_a, coin::zero());
             } else {
                return_back_to_lp_pool<CoinTypeB, CoinTypeA>(coin::zero(), coin_a);
             };
         };
        (true, (0 as u128))
    }

    fun return_back_to_lp_pool<CoinTypeA, CoinTypeB>(
        a_in: coin::Coin<CoinTypeA>,
        b_in: coin::Coin<CoinTypeB>,
    ) acquires Pool {
        let pool = borrow_global_mut<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        coin::merge(&mut pool.coin_a, a_in);
        coin::merge(&mut pool.coin_b, b_in);
    }

    fun emit_swap_fee_event<CoinTypeA, CoinTypeB> (
        signer_address: address,
        fee_address: address,
        fee_out: u128
    ) acquires PoolSwapEventHandle {
        let event_handle = borrow_global_mut<PoolSwapEventHandle>(amm_config::admin_address());
        event::emit_event<SwapFeeEvent>(
            &mut event_handle.swap_fee_events,
            SwapFeeEvent {
                coin_a_info: type_info::type_of<CoinTypeA>(),
                coin_b_info: type_info::type_of<CoinTypeB>(),
                account: signer_address,
                fee_address: fee_address,
                fee_out: fee_out,
            }
        );
    }
}