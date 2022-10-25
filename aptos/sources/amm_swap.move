module cetus_amm::amm_swap {
    use std::string;
    use std::error;
    use std::signer;
    use std::option;

    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::account::{Self, new_event_handle};
    use aptos_framework::coin::{Self, Coin, BurnCapability, MintCapability};
    use cetus_amm::amm_utils;
    use cetus_amm::amm_config::{Self, assert_admin};
    use cetus_amm::amm_math::{Self, sqrt, min};
    use aptos_std::type_info;

    friend cetus_amm::amm_router;

    const MINIMUM_LIQUIDITY: u128 = 10;

    //
    // Errors
    //

    const EINVALID_COIN_PAIR: u64 = 4001;
    const EACCOUNT_NOT_EXISTED: u64 = 4002;
    const ELIQUIDITY_INSUFFICIENT_MINTED: u64 = 4003;
    const ELIQUIDITY_SWAP_BURN_CALC_INVALID: u64 = 4004;
    const ECOIN_INSUFFICIENT: u64 = 4005;
    const ESWAPOUT_CALC_INVALID: u64 = 4006;
    const EPOOL_DOSE_NOT_EXIST: u64 = 4007;
    const EPOOL_ALREADY_EXISTS: u64 = 4008;
    const ELIQUIDITY_CALC_INVALID: u64 = 4009;
    const EFUNCTION_DEPRECATED: u64 = 4010;

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
        amount_a: u128,
        amount_b: u128,
    }

    struct RemoveLiquidityEvent has store, drop {
        liquidity: u128,
        account: address,
        coin_a_info: type_info::TypeInfo,
        coin_b_info: type_info::TypeInfo,
        amount_a: u128,
        amount_b: u128,
    }

    struct SwapEvent has store, drop {
        coin_a_info: type_info::TypeInfo,
        coin_b_info: type_info::TypeInfo,
        account: address,
        a_in: u128,
        a_out: u128,
        b_in: u128,
        b_out: u128,
    }

    struct SwapFeeEvent has store, drop {
        coin_a_info: type_info::TypeInfo,
        coin_b_info: type_info::TypeInfo,
        account: address,
        fee_address: address,
        fee_a_out: u128,
        fee_b_out: u128,
    }

    struct PoolSwapEventHandle has key {
        init_pool_events: EventHandle<InitPoolEvent>,
        add_liquidity_events: EventHandle<AddLiquidityEvent>,
        remove_liquidity_events: EventHandle<RemoveLiquidityEvent>,
        swap_events: EventHandle<SwapEvent>,
        swap_fee_events: EventHandle<SwapFeeEvent>,
    }

    public fun init_pool<CoinTypeA, CoinTypeB>(_account: &signer, _protocol_fee_to: address){   
        abort EFUNCTION_DEPRECATED
    }

    public(friend) fun init_pool_v2<CoinTypeA, CoinTypeB>(account: &signer, protocol_fee_to: address) acquires PoolSwapEventHandle {
        //check coin type
        amm_utils::assert_is_coin<CoinTypeA>();
        amm_utils::assert_is_coin<CoinTypeB>();

        assert!(!exists<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address()), EPOOL_ALREADY_EXISTS);
        assert!(!exists<Pool<CoinTypeB, CoinTypeA>>(amm_config::admin_address()), EPOOL_ALREADY_EXISTS);

        //check admin
        assert_admin(account);

        //check protocol_fee_to existed
        assert!(
             account::exists_at(protocol_fee_to),
             error::not_found(EACCOUNT_NOT_EXISTED));

         //reigister lp coin
        let(burn_capability, mint_capability) = register_liquidity_coin<CoinTypeA, CoinTypeB>(account);
        
        //make pool
        let pool = make_pool<CoinTypeA, CoinTypeB>(protocol_fee_to, burn_capability, mint_capability);
        move_to(account, pool);

        //init event handle
        init_event_handle(account);

        //emit init pool event
        emit_init_pool_event<CoinTypeA, CoinTypeB>(signer::address_of(account), protocol_fee_to);
    }

    public fun mint_and_emit_event<CoinTypeA, CoinTypeB>(
        _account: &signer,
        _coinA: Coin<CoinTypeA>, 
        _coinB: Coin<CoinTypeB>): Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>{
        abort EFUNCTION_DEPRECATED
    }

    public(friend) fun mint_and_emit_event_v2<CoinTypeA, CoinTypeB>(
        account: address,
        coinA: Coin<CoinTypeA>, 
        coinB: Coin<CoinTypeB>): Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>> acquires Pool, PoolSwapEventHandle {
        let amount_a = (coin::value(&coinA) as u128);
        let amount_b = (coin::value(&coinB) as u128);
        let liquidity_coin = mint<CoinTypeA, CoinTypeB>(coinA,coinB);
        let event_handle = borrow_global_mut<PoolSwapEventHandle>(amm_config::admin_address());
        event::emit_event(&mut event_handle.add_liquidity_events,AddLiquidityEvent{
            liquidity: (coin::value<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(&liquidity_coin) as u128),
            account: account,
            coin_a_info:type_info::type_of<CoinTypeA>(),
            coin_b_info:type_info::type_of<CoinTypeB>(),
            amount_a,
            amount_b
        });
        liquidity_coin
    }

    fun mint<CoinTypeA, CoinTypeB>(
        coinA: Coin<CoinTypeA>, 
        coinB: Coin<CoinTypeB>): Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>> acquires Pool {
        amm_config::assert_pause();
        
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
            assert!(amountB == amm_math::quote(amountA, reserve_a, reserve_b)
             || amountA == amm_math::quote(amountB, reserve_b, reserve_a), error::internal(ELIQUIDITY_CALC_INVALID));
            liquidity = min(amm_math::safe_mul_div_u128(amountA,total_supply,reserve_a), 
                            amm_math::safe_mul_div_u128(amountB,total_supply,reserve_b));
        };

        assert!(liquidity > 0, error::invalid_argument(ELIQUIDITY_INSUFFICIENT_MINTED));

        coin::merge(&mut pool.coin_a, coinA);
        coin::merge(&mut pool.coin_b, coinB);

        coin::mint<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>((liquidity as u64), &pool.mint_capability)
    }

    public fun burn_and_emit_event<CoinTypeA, CoinTypeB>(
        _account: &signer,
        _to_burn: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>) : (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        abort EFUNCTION_DEPRECATED
    }

    public(friend) fun burn_and_emit_event_v2<CoinTypeA, CoinTypeB>(
        account: address,
        to_burn: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>) : (Coin<CoinTypeA>, Coin<CoinTypeB>) acquires Pool, PoolSwapEventHandle {
        let liquidity = (coin::value<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(&to_burn) as u128);
        let (a_token, b_token) = burn<CoinTypeA, CoinTypeB>(to_burn);
        let event_handle = borrow_global_mut<PoolSwapEventHandle>(amm_config::admin_address());
        let amount_a = (coin::value<CoinTypeA>(&a_token) as u128);
        let amount_b = (coin::value<CoinTypeB>(&b_token) as u128);
        event::emit_event(&mut event_handle.remove_liquidity_events, RemoveLiquidityEvent {
            liquidity,
            account: account,
            coin_a_info:type_info::type_of<CoinTypeA>(),
            coin_b_info:type_info::type_of<CoinTypeB>(),
            amount_a,
            amount_b,
        });
        (a_token, b_token)
    }

    fun burn<CoinTypeA, CoinTypeB>(to_burn: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>): (Coin<CoinTypeA>, Coin<CoinTypeB>) acquires Pool {
        amm_config::assert_pause();

        let to_burn_value = (coin::value(&to_burn) as u128);
        let pool = borrow_global_mut<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        let reserve_a = (coin::value(&pool.coin_a) as u128);
        let reserve_b = (coin::value(&pool.coin_b) as u128);
        let total_supply = *option::borrow(&coin::supply<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>());
        let amount0 = (amm_math::safe_mul_div_u128(to_burn_value,reserve_a,total_supply) as u64);
        let amount1 = (amm_math::safe_mul_div_u128(to_burn_value,reserve_b,total_supply) as u64); 
        assert!(amount0 > 0 && amount1 > 0, error::internal(ELIQUIDITY_SWAP_BURN_CALC_INVALID)); 

        coin::burn(to_burn, &pool.burn_capability);
        
        (coin::extract(&mut pool.coin_a , amount0), coin::extract(&mut pool.coin_b, amount1))
    }

    public fun swap_and_emit_event<CoinTypeA, CoinTypeB>(
        _account: &signer,
        _coin_a_in: Coin<CoinTypeA>,
        _coin_b_out: u128,
        _coin_b_in: Coin<CoinTypeB>,
        _coin_a_out: u128
    ) :(Coin<CoinTypeA>, Coin<CoinTypeB>, Coin<CoinTypeA>, Coin<CoinTypeB>) {
        abort EFUNCTION_DEPRECATED
    }

    public(friend) fun swap_and_emit_event_v2<CoinTypeA, CoinTypeB>(
        account: address,
        coin_a_in: Coin<CoinTypeA>,
        coin_b_out: u128,
        coin_b_in: Coin<CoinTypeB>,
        coin_a_out: u128
    ) :(Coin<CoinTypeA>, Coin<CoinTypeB>, Coin<CoinTypeA>, Coin<CoinTypeB>) acquires Pool, PoolSwapEventHandle {
        let coin_a_in_value = (coin::value<CoinTypeA>(&coin_a_in) as u128);
        let coin_b_in_value = (coin::value<CoinTypeB>(&coin_b_in) as u128);
        let (coin_a_out, coin_b_out, coin_a_fee, coin_b_fee) = swap_v2<CoinTypeA, CoinTypeB>(coin_a_in, coin_b_out, coin_b_in, coin_a_out);
        let event_handle = borrow_global_mut<PoolSwapEventHandle>(amm_config::admin_address());
        event::emit_event<SwapEvent>(
            &mut event_handle.swap_events,
            SwapEvent {
                coin_a_info: type_info::type_of<CoinTypeA>(),
                coin_b_info: type_info::type_of<CoinTypeB>(),
                account: account,
                a_in: coin_a_in_value,
                a_out: (coin::value<CoinTypeA>(&coin_a_out) as u128),
                b_in: coin_b_in_value,
                b_out: (coin::value<CoinTypeB>(&coin_b_out) as u128) 
            }
        );
        (coin_a_out, coin_b_out, coin_a_fee, coin_b_fee)
    }

    public fun swap<CoinTypeA, CoinTypeB>(
        _coin_a_in: Coin<CoinTypeA>,
        _coin_b_out: u128,
        _coin_b_in: Coin<CoinTypeB>,
        _coin_a_out: u128, 
    ): (Coin<CoinTypeA>, Coin<CoinTypeB>, Coin<CoinTypeA>, Coin<CoinTypeB>) {
        abort EFUNCTION_DEPRECATED
    }

    fun swap_v2<CoinTypeA, CoinTypeB>(
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
            error::internal(ECOIN_INSUFFICIENT));

        let (a_reserve, b_reserve) = get_reserves<CoinTypeA, CoinTypeB>();
        let pool = borrow_global_mut<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        coin::merge(&mut pool.coin_a, coin_a_in);
        coin::merge(&mut pool.coin_b, coin_b_in);

        let coin_a_swapped = coin::extract(&mut pool.coin_a, (coin_a_out as u64));
        let coin_b_swapped = coin::extract(&mut pool.coin_b, (coin_b_out as u64));
        {
            let a_reserve_new = coin::value(&pool.coin_a);
            let b_reserve_new = coin::value(&pool.coin_b);
            let (fee_numerator, fee_denominator) = amm_config::get_trade_fee<CoinTypeA, CoinTypeB>();
            
            let (a_adjusted, b_adjusted) = new_reserves_adjusted(
                a_reserve_new, 
                b_reserve_new, 
                a_in_value, 
                b_in_value, 
                fee_numerator, 
                fee_denominator);

            
            assert_lp_value_incr(
                a_reserve,
                b_reserve,
                a_adjusted,
                b_adjusted,
                (fee_denominator as u128)
            );
        };

        let (protocol_fee_numberator, protocol_fee_denominator) = calc_swap_protocol_fee_rate<CoinTypeA, CoinTypeB>();
        let a_swap_fee = coin::extract(&mut pool.coin_a, (amm_math::safe_mul_div_u128((a_in_value as u128), protocol_fee_numberator, protocol_fee_denominator) as u64));
        let b_swap_fee = coin::extract(&mut pool.coin_b, (amm_math::safe_mul_div_u128((b_in_value as u128), protocol_fee_numberator, protocol_fee_denominator) as u64));

        (coin_a_swapped, coin_b_swapped, a_swap_fee, b_swap_fee)
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
        let name = string::utf8(b"LP-");
        string::append(&mut name, coin::name<CoinTypeA>());
        string::append_utf8(&mut name, b"-");
        string::append(&mut name, coin::name<CoinTypeB>());

        let (burn_capability, freeze_capability, mint_capability) = coin::initialize<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(
            account,
            name,
            string::utf8(b"CALP"),
            6,
            true,
        );

        coin::destroy_freeze_cap(freeze_capability);
        (burn_capability, mint_capability)
    }

    fun init_event_handle(account: &signer) {
        if (!exists<PoolSwapEventHandle>(signer::address_of(account))) {
            move_to(account, PoolSwapEventHandle {
                init_pool_events: new_event_handle<InitPoolEvent>(account),
                add_liquidity_events: new_event_handle<AddLiquidityEvent>(account),
                remove_liquidity_events: new_event_handle<RemoveLiquidityEvent>(account),
                swap_events: new_event_handle<SwapEvent>(account),
                swap_fee_events: new_event_handle<SwapFeeEvent>(account),
            });
        }
    }

    fun emit_init_pool_event<CoinTypeA, CoinTypeB>(
        account: address,
        protocol_fee_to: address
    ) acquires PoolSwapEventHandle {
        let event_handle = borrow_global_mut<PoolSwapEventHandle>(amm_config::admin_address());
        event::emit_event<InitPoolEvent>(
            &mut event_handle.init_pool_events,
            InitPoolEvent {
                coin_a_info: type_info::type_of<CoinTypeA>(),
                coin_b_info: type_info::type_of<CoinTypeB>(),
                account: account,
                protocol_fee_to: protocol_fee_to,
            }
        );
    }

    public fun get_reserves<CoinTypeA, CoinTypeB>(): (u128, u128) acquires Pool {
        let pool = borrow_global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        let a_reserve = (coin::value(&pool.coin_a) as u128);
        let b_reserve = (coin::value(&pool.coin_b) as u128);
        (a_reserve, b_reserve)
    }

    public fun calc_swap_protocol_fee_rate<CoinTypeA, CoinTypeB>() : (u128, u128) {
        let (fee_numerator, fee_denominator) = amm_config::get_trade_fee<CoinTypeA, CoinTypeB>();
        let (protocol_fee_numberator, protocol_fee_denominator) = amm_config::get_protocol_fee<CoinTypeA, CoinTypeB>();
         ((fee_numerator * protocol_fee_numberator as u128), (fee_denominator * protocol_fee_denominator as u128))
    }

    public fun handle_swap_protocol_fee<CoinTypeA, CoinTypeB>(
        _signer_address: address, 
        _token_a: Coin<CoinTypeA>, 
        _is_forward: bool) {
        abort EFUNCTION_DEPRECATED
    }

    public(friend) fun handle_swap_protocol_fee_v2<CoinTypeA, CoinTypeB>(signer_address: address, token_a: Coin<CoinTypeA>, is_forward: bool) acquires PoolSwapEventHandle, Pool {
        let protocol_fee_to: address;
        if(is_forward) {
             protocol_fee_to = borrow_global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address()).protocol_fee_to;
        } else {
             protocol_fee_to = borrow_global<Pool<CoinTypeB, CoinTypeA>>(amm_config::admin_address()).protocol_fee_to;
        };

        handle_swap_protocol_fee_internal<CoinTypeA, CoinTypeB>(signer_address, protocol_fee_to, token_a, is_forward);
    }

    fun handle_swap_protocol_fee_internal<CoinTypeA, CoinTypeB>(
        signer_address: address,
        fee_address: address,
        coin_a: Coin<CoinTypeA>,
        is_forward: bool
    ) acquires PoolSwapEventHandle, Pool {
        let (fee_handle, fee_out) = swap_fee_direct_deposit<CoinTypeA, CoinTypeB>(fee_address, coin_a, is_forward);
        if (fee_handle) { 
             if (is_forward) {
                emit_swap_fee_event<CoinTypeA, CoinTypeB>(signer_address, fee_address, fee_out, 0);
             } else {
                emit_swap_fee_event<CoinTypeB, CoinTypeA>(signer_address, fee_address, 0, fee_out);
             };
        }
    }

    fun swap_fee_direct_deposit<CoinTypeA, CoinTypeB>(
        fee_address: address,
        coin_a: Coin<CoinTypeA>,
        is_forward: bool): (bool, u128) acquires Pool {
          if (coin::is_account_registered<CoinTypeA>(fee_address)) {
            let a_value = coin::value(&coin_a);
            coin::deposit(fee_address, coin_a);
            (true, (a_value as u128))
         } else {
             if (is_forward) {
                return_back_to_lp_pool<CoinTypeA, CoinTypeB>(coin_a, coin::zero());
             } else {
                return_back_to_lp_pool<CoinTypeB, CoinTypeA>(coin::zero(), coin_a);
             };
             (false, (0 as u128))
         }
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
        fee_a_out: u128,
        fee_b_out: u128
    ) acquires PoolSwapEventHandle {
        let event_handle = borrow_global_mut<PoolSwapEventHandle>(amm_config::admin_address());
        event::emit_event<SwapFeeEvent>(
            &mut event_handle.swap_fee_events,
            SwapFeeEvent {
                coin_a_info: type_info::type_of<CoinTypeA>(),
                coin_b_info: type_info::type_of<CoinTypeB>(),
                account: signer_address,
                fee_address: fee_address,
                fee_a_out: fee_a_out,
                fee_b_out: fee_b_out,
            }
        );
    }

    public fun get_pool_direction<CoinTypeA, CoinTypeB>(): bool {
        if(exists<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address())) {
            true
        } else {
            assert!(exists<Pool<CoinTypeB, CoinTypeA>>(amm_config::admin_address()), EPOOL_DOSE_NOT_EXIST);
            false
        }
    }

    fun new_reserves_adjusted(
        a_reserve: u64,
        b_reserve: u64,
        a_in_val: u64,
        b_in_val: u64,
        fee_numerator: u64,
        fee_denominator: u64
    ) : (u128, u128) {
        let a_adjusted = (a_reserve as u128) * (fee_denominator as u128) - (a_in_val as u128) * (fee_numerator as u128);
        let b_adjusted = (b_reserve as u128) * (fee_denominator as u128) - (b_in_val as u128) * (fee_numerator as u128);
        (a_adjusted, b_adjusted)
    }

    fun assert_lp_value_incr(
        a_reserve: u128,
        b_reserve: u128,
        a_adjusted: u128,
        b_adjusted: u128,
        fee_denominator: u128
    ) {
        let cmp_order = amm_math::safe_compare_mul_u128(a_adjusted, b_adjusted, (a_reserve as u128) * (fee_denominator as u128), (b_reserve as u128) * (fee_denominator as u128));
        assert!(
            (EQUAL == cmp_order || GREATER_THAN == cmp_order), 
            error::internal(ESWAPOUT_CALC_INVALID));
    }
}