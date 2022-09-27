module cetus_amm::amm_swap {
    use sui::object::{Self, UID, ID};
    use sui::coin;
    use sui::balance::{Self, Supply, Balance};
    use sui::transfer;
    use sui::event;
    use sui::tx_context::{Self, TxContext};
    use cetus_amm::amm_config::{new_global_pause_status};
    use cetus_amm::amm_math;

    const ECoinInsufficient: u64 = 0;
    const ESwapoutCalcInvalid: u64 = 1;

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

        let global_paulse_status = new_global_pause_status(ctx);
        let id = object::id(&global_paulse_status);
        transfer::share_object (global_paulse_status);
        event::emit(InitEvent{
            sender: tx_context::sender(ctx),
            global_paulse_status_id: id
        });
    }

    public fun init_pool<CoinTypeA, CoinTypeB>(
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

    public fun swap_and_emit_event<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        coin_a_in: Balance<CoinTypeA>,
        coin_b_out: u64,
        coin_b_in: Balance<CoinTypeB>,
        coin_a_out: u64,
        ctx: &mut TxContext
    ):(Balance<CoinTypeA>, Balance<CoinTypeB>, Balance<CoinTypeA>, Balance<CoinTypeB>) {
        let coin_a_in_value = balance::value(&coin_a_in);
        let coin_b_in_value = balance::value(&coin_b_in);

        let (coin_a_out, coin_b_out, coin_a_fee, con_b_fee) = swap(pool, coin_a_in, coin_b_out, coin_b_in, coin_a_out);
        event::emit(SwapEvent{
            sender: tx_context::sender(ctx),
            pool_id: object::id(pool),
            amount_a_in: coin_a_in_value,
            amount_a_out: balance::value(&coin_a_out),
            amount_b_in: coin_b_in_value,
            amount_b_out: balance::value(&coin_b_out),
        });
        (coin_a_out, coin_b_out, coin_a_fee, con_b_fee)
    }

    fun swap<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        coin_a_in: Balance<CoinTypeA>,
        coin_b_out: u64,
        coin_b_in: Balance<CoinTypeB>,
        coin_a_out: u64
    ):(Balance<CoinTypeA>, Balance<CoinTypeB>, Balance<CoinTypeA>, Balance<CoinTypeB>) {
        let a_in_value = balance::value(&coin_a_in);
        let b_in_value = balance::value(&coin_b_in);
        assert!(
            a_in_value > 0 || b_in_value > 0,
            ECoinInsufficient
        );


        balance::join(&mut pool.coin_a, coin_a_in);
        balance::join(&mut pool.coin_b, coin_b_in);
        let (a_reserve, b_reserve) = get_reserves<CoinTypeA, CoinTypeB>(pool);

        let coin_a_swapped = balance::split(&mut pool.coin_a, coin_a_out);
        let coin_b_swapped = balance::split(&mut pool.coin_b, coin_b_out);

        {
            let a_reserve_new = balance::value(&pool.coin_a);
            let b_reserve_new = balance::value(&pool.coin_b);
            let (fee_numerator, fee_denominator) = get_trade_fee<CoinTypeA, CoinTypeB>(pool);
            
            let a_adjusted = a_reserve_new * fee_denominator - a_in_value * fee_numerator;
            let b_adjusted = b_reserve_new * fee_denominator - b_in_value * fee_numerator;

            assert!(
                amm_math::safe_compare_mul_u64(a_adjusted, b_adjusted, a_reserve, b_reserve), 
                ESwapoutCalcInvalid);
        };

        let (protocol_fee_numberator, protocol_fee_denominator) = calc_swap_protocol_fee_rate(pool);
        let a_swap_fee = balance::split(&mut pool.coin_a, amm_math::safe_mul_div_u64(a_in_value, protocol_fee_numberator, protocol_fee_denominator));
        let b_swap_fee = balance::split(&mut pool.coin_b, amm_math::safe_mul_div_u64(b_in_value, protocol_fee_numberator, protocol_fee_denominator));
        (coin_a_swapped, coin_b_swapped, a_swap_fee, b_swap_fee)
    }

    fun calc_swap_protocol_fee_rate<CoinTypeA, CoinTypeB>(pool: &Pool<CoinTypeA, CoinTypeB>): (u64, u64) {
        let (fee_numerator, fee_denominator) = get_trade_fee(pool);
        let (protocol_fee_numerator, protocol_fee_denominator) = get_protocol_fee(pool);
        (amm_math::safe_mul_u64(fee_numerator, protocol_fee_numerator), amm_math::safe_mul_u64(fee_denominator, protocol_fee_denominator))
    }

    public fun handle_swap_protocol_fee<CoinTypeA, CoinTypeB>(pool: &mut Pool<CoinTypeA, CoinTypeB>, fee_a: Balance<CoinTypeA>, fee_b: Balance<CoinTypeB>) {
        balance::join(&mut pool.coin_a_admin, fee_a);
        balance::join(&mut pool.coin_b_admin, fee_b);
    }

    public fun set_fee_and_emit_event<CoinTypeA, CoinTypeB>(
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

    public fun claim_fee<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        ctx: &mut TxContext
    ) {
        let a_fee_value = balance::value(&pool.coin_a_admin);
        let b_fee_value = balance::value(&pool.coin_b_admin);

        assert!(
            a_fee_value > 0 || b_fee_value > 0,
            ECoinInsufficient
        );

        let a_fee_balance = balance::split(&mut pool.coin_a_admin, a_fee_value);
        let b_fee_balance = balance::split(&mut pool.coin_b_admin, b_fee_value);

        coin::keep(coin::from_balance(a_fee_balance, ctx), ctx);
        coin::keep(coin::from_balance(b_fee_balance, ctx), ctx);

        event::emit(ClaimFeeEvent{
            sender: tx_context::sender(ctx),
            pool_id: object::id(pool),
            amount_a: a_fee_value,
            amount_b: b_fee_value,
        });
    }

}