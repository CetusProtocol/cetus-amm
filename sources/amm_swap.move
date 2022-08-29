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
    use cetus_amm::utils::{Self, assert_is_coin, compare_coin};
    use cetus_amm::config::{Self, assert_admin};
    use cetus_amm::amm_math::{Self, quote, sqrt, min};


    const MINIMUM_LIQUIDITY: u64 = 1000;

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

    struct PoolLiquidityCoin<phantom CoinTypeA, phantom CoinTypeB> {}

    struct Pool<phantom CoinTypeA, phantom CoinTypeB> has key {
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,

        mint_capability: MintCapability<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        burn_capability: BurnCapability<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,

        locked_liquidity: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,

        protocol_fee_to: address
    }

    struct LiquidityTokenCapability<phantom X, phantom Y> has key, store {
        mint: MintCapability<PoolLiquidityCoin<X, Y>>,
        burn: BurnCapability<PoolLiquidityCoin<X, Y>>,
    }


    struct InitPoolEvent has store, drop {

    }

    struct AddLiquidityEvent has store, drop {
        liquidity: u128,
        signer: address,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128,
    }

    struct RemoveLiquidityEvent has store, drop {
        liquidity: u128,
        signer: address,
        amount_a_min: u128,
        amount_b_min: u128,
    }

    struct SwapEvent has store, drop {

    }

    struct PoolSwapEventHandle has key {
        init_pool_events: EventHandle<InitPoolEvent>,
        add_liquidity_events: EventHandle<AddLiquidityEvent>,
        remove_liquidity_events: EventHandle<RemoveLiquidityEvent>,
        swap_events: EventHandle<SwapEvent>,
    }

    public fun init_pool<CoinTypeA, CoinTypeB>(account: &signer, protocol_fee_to: address) {
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

        let(burn_capability, mint_capability) = register_liquidity_coin<CoinTypeA, CoinTypeB>(account);
        
        move_to(account,LiquidityTokenCapability{mint:mint_capability,burn:burn_capability});
    }

    public fun add_liquidity<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128) acquires Pool, PoolSwapEventHandle {
        assert!(
            comparator::is_smaller_than(&compare_coin<CoinTypeA, CoinTypeB>()),  
            error::invalid_argument(ESWAP_COINS_COMPARE_NOT_EQUIP_SMALLER));
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
        signer: &signer,
        coinA: Coin<CoinTypeA>, 
        coinB: Coin<CoinTypeB>,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128): Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>> acquires Pool, PoolSwapEventHandle {
        let liquidity_token = mint<CoinTypeA, CoinTypeB>(coinA,coinB);
        let event_handle = borrow_global_mut<PoolSwapEventHandle>(config::admin_address());
        event::emit_event(&mut event_handle.add_liquidity_events,AddLiquidityEvent{
            liquidity: (coin::value<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(&liquidity_token) as u128),
            signer: signer::address_of(signer),
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

        let pool = borrow_global_mut<Pool<CoinTypeA, CoinTypeB>>(config::admin_address());

        // get deposited amounts
        let amountA = (coin::value(&coinA) as u128);
        let amountB = (coin::value(&coinB) as u128);

        let total_supply = (*option::borrow(&coin::supply<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>()) as u128);
        let liquidity;
        if (total_supply == 0) {
            liquidity = (sqrt(amountA * amountB) as u64) - MINIMUM_LIQUIDITY;
            let locked_liquidity = coin::mint<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(MINIMUM_LIQUIDITY, &pool.mint_capability); // permanently lock the first MINIMUM_LIQUIDITY tokens
            coin::merge(&mut pool.locked_liquidity, locked_liquidity);
        } else {
            liquidity = (min(amountA * total_supply / reserve_a, amountB * total_supply / reserve_b) as u64);
        };

        assert!(liquidity > 0, error::invalid_argument(ERROR_LIQUIDITY_INSUFFICIENT_MINTED));

        coin::merge(&mut pool.coin_a, coinA);
        coin::merge(&mut pool.coin_b, coinB);

        coin::mint<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(liquidity, &pool.mint_capability)
    }

    public fun remove_liquidity<CoinTypeA, CoinTypeB>(
        account: &signer,
        liquidity: u128,
        amount_a_min: u128,
        amount_b_min: u128) acquires Pool,PoolSwapEventHandle {
        assert!(
            comparator::is_smaller_than(&compare_coin<CoinTypeA, CoinTypeB>()),  
            error::invalid_argument(ESWAP_COINS_COMPARE_NOT_EQUIP_SMALLER));
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
        signer: &signer,
        to_burn: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        amount_a_min: u128,
        amount_b_min: u128) : (Coin<CoinTypeA>, Coin<CoinTypeB>) acquires Pool, PoolSwapEventHandle {
        let liquidity = (coin::value<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(&to_burn) as u128);
        let (a_token, b_token) = burn<CoinTypeA, CoinTypeB>(to_burn);
        let event_handle = borrow_global_mut<PoolSwapEventHandle>(config::admin_address());
        event::emit_event(&mut event_handle.remove_liquidity_events, RemoveLiquidityEvent {
            liquidity,
            signer: signer::address_of(signer),
            amount_a_min,
            amount_b_min,
        });
        (a_token, b_token)
    }

    fun burn<CoinTypeA, CoinTypeB>(to_burn: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>): (Coin<CoinTypeA>, Coin<CoinTypeB>) acquires Pool {
        let to_burn_value = (coin::value(&to_burn) as u128);
        let pool = borrow_global_mut<Pool<CoinTypeA, CoinTypeB>>(config::admin_address());
        let reserveA = (coin::value(&pool.coin_a) as u128);
        let reserveB = (coin::value(&pool.coin_b) as u128);
        let total_supply = *option::borrow(&coin::supply<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>());
        let amount0 = (to_burn_value * reserveA / total_supply as u64);
        let amount1 = (to_burn_value * reserveB / total_supply as u64); 
        assert!(amount0 > 0 && amount1 > 0, error::invalid_argument(ERROR_LIQUIDITY_SWAP_BURN_CALC_INVALID)); 

        coin::burn(to_burn, &pool.burn_capability);
        
        (coin::extract(&mut pool.coin_a , amount0), coin::extract(&mut pool.coin_b, amount1))
    }

    public fun swap_exact_tokens_for_Tokens<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_in: u128,
        amount_b_out_min: u128,
    ) {

    }

    public fun swap_tokens_for_exact_tokens<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_in_max: u128,
        amount_b_out: u128
    )  {

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

    public fun get_reserves<CoinTypeA, CoinTypeB>(): (u128, u128) acquires Pool {
        let pool = borrow_global<Pool<CoinTypeA, CoinTypeB>>(config::admin_address());
        let a_reserve = (coin::value(&pool.coin_a) as u128);
        let b_reserve = (coin::value(&pool.coin_b) as u128);
        (a_reserve, b_reserve)
    }

}