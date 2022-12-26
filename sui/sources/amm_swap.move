module cetus_amm::amm_swap {
    friend cetus_amm::amm_router;
    use sui::object::{Self, UID, ID};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Supply, Balance};
    use sui::transfer;
    use sui::event;
    use sui::math;
    use sui::tx_context::{Self, TxContext};
    use cetus_amm::amm_config::{new_global_pause_status_and_shared};
    use cetus_amm::amm_math;
    use cetus_amm::amm_utils;

    const MINIMUM_LIQUIDITY: u64 = 10;

    const ECoinInsufficient: u64 = 0;
    const ESwapoutCalcInvalid: u64 = 1;
    const ELiquidityInsufficientMinted: u64 = 2;
    const ELiquiditySwapBurnCalcInvalid: u64 = 3;

    struct AdminCap has key {
        id: UID,
    }

    struct PoolLiquidityCoin<phantom CoinTypeA, phantom CoinTypeB> has drop{}

    struct Pool<phantom CoinTypeA, phantom CoinTypeB> has key {
        id: UID,

        coin_a: Balance<CoinTypeA>,
        coin_b: Balance<CoinTypeB>,
        coin_a_admin: Balance<CoinTypeA>,
        coin_b_admin: Balance<CoinTypeB>,

        lp_locked: Balance<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        lp_supply: Supply<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,

        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64,
    }

    struct InitEvent has copy, drop {
        sender: address,
        global_paulse_status_id: ID
    }

    struct InitPoolEvent has copy, drop {
        sender: address,
        pool_id: ID,
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64,
    }

    struct LiquidityEvent has copy, drop {
        sender: address,
        pool_id: ID,
        is_add_liquidity: bool,
        liquidity: u64,
        amount_a: u64,
        amount_b: u64,
    }

    struct SwapEvent has copy, drop {
        sender: address,
        pool_id: ID,
        amount_a_in: u64,
        amount_a_out: u64,
        amount_b_in: u64,
        amount_b_out: u64,
    }

    struct SetFeeEvent has copy, drop {
        sender: address,
        pool_id: ID,
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64,
    }

    struct ClaimFeeEvent has copy, drop {
        sender: address,
        pool_id: ID,
        amount_a: u64,
        amount_b: u64,
    }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            AdminCap{
                id: object::new(ctx)
            },
            tx_context::sender(ctx)
        );

        let id = new_global_pause_status_and_shared(ctx);
        event::emit(InitEvent{
            sender: tx_context::sender(ctx),
            global_paulse_status_id: id
        });
    }

    public(friend) fun init_pool<CoinTypeA, CoinTypeB>(
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64,
        ctx: &mut TxContext
    ) {
        let pool = make_pool<CoinTypeA,CoinTypeB>(
            trade_fee_numerator,
            trade_fee_denominator,
            protocol_fee_numerator,
            protocol_fee_denominator,
            ctx);
        let pool_id = object::id(&pool); 
        transfer::share_object(pool);

        event::emit(InitPoolEvent{
            sender: tx_context::sender(ctx),
            pool_id,
            trade_fee_numerator,
            trade_fee_denominator,
            protocol_fee_numerator,
            protocol_fee_denominator
        });
    }

    fun make_pool<CoinTypeA, CoinTypeB>(
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64,
        ctx: &mut TxContext
    ): Pool<CoinTypeA, CoinTypeB> {

        let lp_supply = balance::create_supply(PoolLiquidityCoin<CoinTypeA, CoinTypeB>{});

        Pool<CoinTypeA, CoinTypeB> {
            id: object::new(ctx),
            coin_a: balance::zero<CoinTypeA>(),
            coin_b: balance::zero<CoinTypeB>(),
            coin_a_admin: balance::zero<CoinTypeA>(),
            coin_b_admin: balance::zero<CoinTypeB>(),
            lp_locked: balance::zero<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(),
            lp_supply,
            trade_fee_numerator,
            trade_fee_denominator,
            protocol_fee_numerator,
            protocol_fee_denominator
        }
    }

    public fun get_trade_fee<CoinTypeA, CoinTypeB>(pool: &Pool<CoinTypeA, CoinTypeB>): (u64, u64) {
        (pool.trade_fee_numerator, pool.trade_fee_denominator)
    }

    public fun get_protocol_fee<CoinTypeA, CoinTypeB>(pool: &Pool<CoinTypeA, CoinTypeB>): (u64, u64) {
        (pool.protocol_fee_numerator, pool.protocol_fee_denominator)
    }

    public fun get_reserves<CoinTypeA, CoinTypeB>(pool: &Pool<CoinTypeA, CoinTypeB>): (u64, u64) {
        (balance::value(&pool.coin_a), balance::value(&pool.coin_b))
    }

    public(friend) fun swap_and_emit_event<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        balance_a_in: Balance<CoinTypeA>,
        b_out: u64,
        balance_b_in: Balance<CoinTypeB>,
        a_out: u64,
        ctx: &mut TxContext
    ):(Balance<CoinTypeA>, Balance<CoinTypeB>, Balance<CoinTypeA>, Balance<CoinTypeB>) {
        let balance_a_in_value = balance::value(&balance_a_in);
        let balance_b_in_value = balance::value(&balance_b_in);

        let (balance_a_out, balance_b_out, balance_a_fee, balance_b_fee) = swap(pool, balance_a_in, b_out, balance_b_in, a_out);
        event::emit(SwapEvent{
            sender: tx_context::sender(ctx),
            pool_id: object::id(pool),
            amount_a_in: balance_a_in_value,
            amount_a_out: balance::value(&balance_a_out),
            amount_b_in: balance_b_in_value,
            amount_b_out: balance::value(&balance_b_out),
        });
        (balance_a_out, balance_b_out, balance_a_fee, balance_b_fee)
    }

    fun swap<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        balance_a_in: Balance<CoinTypeA>,
        b_out: u64,
        balance_b_in: Balance<CoinTypeB>,
        a_out: u64
    ):(Balance<CoinTypeA>, Balance<CoinTypeB>, Balance<CoinTypeA>, Balance<CoinTypeB>) {
        let balance_a_in_value = balance::value(&balance_a_in);
        let balance_b_in_value = balance::value(&balance_b_in);
        assert!(
            balance_a_in_value > 0 || balance_b_in_value > 0,
            ECoinInsufficient
        );

        let (a_reserve, b_reserve) = get_reserves<CoinTypeA, CoinTypeB>(pool);
        balance::join(&mut pool.coin_a, balance_a_in);
        balance::join(&mut pool.coin_b, balance_b_in);


        let balance_a_swapped = balance::split(&mut pool.coin_a, a_out);
        let balance_b_swapped = balance::split(&mut pool.coin_b, b_out);

        {
            let a_reserve_new = balance::value(&pool.coin_a);
            let b_reserve_new = balance::value(&pool.coin_b);
            let (fee_numerator, fee_denominator) = get_trade_fee<CoinTypeA, CoinTypeB>(pool);
            
            let (a_adjusted, b_adjusted) = new_reserves_adjusted(
                a_reserve_new, 
                b_reserve_new, 
                balance_a_in_value, 
                balance_b_in_value, 
                fee_numerator, 
                fee_denominator);

            
            assert_lp_value_incr(
                a_reserve,
                b_reserve,
                a_adjusted,
                b_adjusted,
                fee_denominator
            );
        };

        let (protocol_fee_numberator, protocol_fee_denominator) = calc_swap_protocol_fee_rate(pool);
        let a_swap_fee = balance::split(&mut pool.coin_a, amm_math::safe_mul_div_u64(balance_a_in_value, protocol_fee_numberator, protocol_fee_denominator));
        let b_swap_fee = balance::split(&mut pool.coin_b, amm_math::safe_mul_div_u64(balance_b_in_value, protocol_fee_numberator, protocol_fee_denominator));
        (balance_a_swapped, balance_b_swapped, a_swap_fee, b_swap_fee)
    }

    fun calc_swap_protocol_fee_rate<CoinTypeA, CoinTypeB>(pool: &Pool<CoinTypeA, CoinTypeB>): (u64, u64) {
        let (fee_numerator, fee_denominator) = get_trade_fee(pool);
        let (protocol_fee_numerator, protocol_fee_denominator) = get_protocol_fee(pool);
        (amm_math::safe_mul_u64(fee_numerator, protocol_fee_numerator), amm_math::safe_mul_u64(fee_denominator, protocol_fee_denominator))
    }

    public(friend) fun handle_swap_protocol_fee<CoinTypeA, CoinTypeB>(pool: &mut Pool<CoinTypeA, CoinTypeB>, fee_a: Balance<CoinTypeA>, fee_b: Balance<CoinTypeB>) {
        balance::join(&mut pool.coin_a_admin, fee_a);
        balance::join(&mut pool.coin_b_admin, fee_b);
    }

    public(friend) fun set_fee_and_emit_event<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64,
        ctx: &mut TxContext
    ) {
        pool.trade_fee_numerator = trade_fee_numerator;
        pool.trade_fee_denominator = trade_fee_denominator;
        pool.protocol_fee_numerator = protocol_fee_numerator;
        pool.protocol_fee_denominator = protocol_fee_denominator;

        event::emit(SetFeeEvent{
            sender: tx_context::sender(ctx),
            pool_id: object::id(pool),
            trade_fee_numerator,
            trade_fee_denominator,
            protocol_fee_numerator,
            protocol_fee_denominator
        });
    }

    public(friend) fun claim_fee<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        ctx: &mut TxContext
    ) {
        let a_fee_value = balance::value(&pool.coin_a_admin);
        let b_fee_value = balance::value(&pool.coin_b_admin);

        assert!(
            a_fee_value > 0 || b_fee_value > 0,
            ECoinInsufficient
        );

        let balance_a_fee = balance::split(&mut pool.coin_a_admin, a_fee_value);
        let balance_b_fee = balance::split(&mut pool.coin_b_admin, b_fee_value);

        amm_utils::keep(coin::from_balance(balance_a_fee, ctx), ctx);
        amm_utils::keep(coin::from_balance(balance_b_fee, ctx), ctx);

        event::emit(ClaimFeeEvent{
            sender: tx_context::sender(ctx),
            pool_id: object::id(pool),
            amount_a: a_fee_value,
            amount_b: b_fee_value,
        });
    }

    public(friend) fun mint_and_emit_event<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        balance_a: Balance<CoinTypeA>,
        balance_b: Balance<CoinTypeB>,
        amount_a_desired: u64,
        amount_b_desired: u64,
        ctx: &mut TxContext
    ): Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>> {
        let coin_liquidity = mint(pool, balance_a, balance_b, ctx);
        event::emit(LiquidityEvent{
            sender: tx_context::sender(ctx),
            pool_id: object::id(pool),
            is_add_liquidity: true,
            liquidity: coin::value(&coin_liquidity),
            amount_a: amount_a_desired,
            amount_b: amount_b_desired,
        });
        coin_liquidity
    }

    fun mint<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        balance_a: Balance<CoinTypeA>,
        balance_b: Balance<CoinTypeB>,
        ctx: &mut TxContext
    ): Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>> {
        let (reserve_a, reserve_b) = get_reserves(pool);

        let amount_a = balance::value(&balance_a);
        let amonut_b = balance::value(&balance_b);

        let total_supply = balance::supply_value(&pool.lp_supply);
        let liquidity: u64;
        if (total_supply == 0) {
            liquidity = math::sqrt(amount_a * amonut_b) - MINIMUM_LIQUIDITY;
            let balance_lp_locked = balance::increase_supply(&mut pool.lp_supply, MINIMUM_LIQUIDITY);
            balance::join(&mut pool.lp_locked, balance_lp_locked);
        } else {
            liquidity = math::min(
                amm_math::safe_mul_div_u64(amount_a, total_supply, reserve_a),
                amm_math::safe_mul_div_u64(amonut_b, total_supply, reserve_b));
        };

        assert!(liquidity > 0, ELiquidityInsufficientMinted);

        balance::join(&mut pool.coin_a, balance_a);
        balance::join(&mut pool.coin_b, balance_b);

        coin::from_balance(
            balance::increase_supply(
                &mut pool.lp_supply,
                liquidity
            ), ctx)
    }

    public(friend) fun burn_and_emit_event<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        to_burn: Balance<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        ctx:  &mut TxContext
    ): (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        let to_burn_value = balance::value(&to_burn);
        let (coin_a, coin_b) = burn(pool, to_burn, ctx);

        event::emit(LiquidityEvent{
            sender: tx_context::sender(ctx),
            pool_id: object::id(pool),
            is_add_liquidity: false,
            liquidity: to_burn_value,
            amount_a: coin::value(&coin_a),
            amount_b: coin::value(&coin_b),
        });

        (coin_a, coin_b)
    }

    fun burn<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        to_burn: Balance<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        ctx:  &mut TxContext
    ): (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        let to_burn_value = balance::value(&to_burn);

        let (reserve_a, reserve_b) = get_reserves(pool);
        let total_supply = balance::supply_value(&pool.lp_supply);

        let amount_a = amm_math::safe_mul_div_u64(to_burn_value, reserve_a, total_supply);
        let amount_b = amm_math::safe_mul_div_u64(to_burn_value, reserve_b, total_supply);
        assert!(amount_a > 0 && amount_b > 0, ELiquiditySwapBurnCalcInvalid);

        balance::decrease_supply(&mut pool.lp_supply, to_burn);

        let coin_a = coin::from_balance(balance::split(&mut pool.coin_a, amount_a), ctx);
        let coin_b = coin::from_balance(balance::split(&mut pool.coin_b, amount_b), ctx);
        (coin_a, coin_b)
    }

    fun new_reserves_adjusted(
        a_reserve: u64,
        b_reserve: u64,
        a_in_val: u64,
        b_in_val: u64,
        fee_numerator: u64,
        fee_denominator: u64
    ) : (u64, u64) {
        let a_adjusted = a_reserve * fee_denominator - a_in_val * fee_numerator;
        let b_adjusted = b_reserve * fee_denominator - b_in_val * fee_numerator;
        (a_adjusted, b_adjusted)
    }

    fun assert_lp_value_incr(
        a_reserve: u64,
        b_reserve: u64,
        a_adjusted: u64,
        b_adjusted: u64,
        fee_denominator: u64
    ) {
        assert!(
                amm_math::safe_compare_mul_u64(a_adjusted, b_adjusted, a_reserve * fee_denominator, b_reserve * fee_denominator), 
                ESwapoutCalcInvalid);
    }

}