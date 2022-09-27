module cetus_amm::amm_route {
    use cetus_amm::amm_swap::{Self, Pool,PoolLiquidityCoin};
    use cetus_amm::amm_config::{Self, GlobalPauseStatus};
    use cetus_amm::amm_utils;
    use sui::coin::{Self,Coin};
    use sui::tx_context::{TxContext};
    use sui::balance;

    const ENotEnough: u64 = 1;
    const EPOOLPAUSE: u64 = 2;
    const ESwapOutLessthanExpected: u64 = 3;
    const ESwapInOverLimitMax: u64 = 4;
    const EWrongFee: u64 = 5;

    public fun add_liquidity<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext) {
        add_liquidity_internal(
            pool,
            coin_a,coin_b,
            amount_a_desired,
            amount_b_desired,
            amount_a_min,
            amount_b_min,
            ctx
        );
    }

    fun add_liquidity_internal<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext) {
        let (amount_a, amount_b) = calculate_amount_for_liquidity_internal<CoinTypeA, CoinTypeB>(
            pool,
            coin_a,coin_b,
            amount_a_desired,
            amount_b_desired,
            amount_a_min,
            amount_b_min
        );

    }

    fun calculate_amount_for_liquidity_internal<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u64,
        amount_b_min: u64): (u64, u64) {
            (0,0)
    }

    public fun remove_liquidity<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        lp: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext) {

    }

    public fun init_pool<CoinTypeA, CoinTypeB>(
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64,
        ctx: &mut TxContext
    ) {
        assert!(trade_fee_numerator > 0 && trade_fee_denominator > 0, EWrongFee);
        assert!(protocol_fee_numerator > 0 && protocol_fee_denominator > 0, EWrongFee);

        amm_swap::init_pool<CoinTypeA, CoinTypeB>(
            trade_fee_numerator,
            trade_fee_denominator,
            protocol_fee_numerator,
            protocol_fee_denominator,
            ctx
        );
    }

    public fun swap_exact_coinA_for_coinB<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_a: &mut Coin<CoinTypeA>,
        amount_a_in: u64,
        amount_b_out_min: u64,
        ctx: &mut TxContext
    ) {
        assert!(amm_config::get_pause_status(pause_status) == false, EPOOLPAUSE);
        assert!(coin::value(coin_a) >= amount_a_in, ENotEnough);

        let b_out = compute_out<CoinTypeA, CoinTypeB>(pool, amount_a_in, true);
        assert!(b_out >= amount_b_out_min, ESwapOutLessthanExpected);
        let balance_a = coin::balance_mut(coin_a);
        let balance_a_in = balance::split(balance_a, amount_a_in);

        let (balance_a_out, balance_b_out, balance_a_fee, balance_b_fee) = 
            amm_swap::swap_and_emit_event(
                pool, 
                balance_a_in, 
                b_out, 
                balance::zero(), 
                0,
                ctx);

        balance::destroy_zero(balance_a_out);
        coin::keep(coin::from_balance(balance_b_out, ctx), ctx);
        amm_swap::handle_swap_protocol_fee(pool, balance_a_fee, balance::zero());
        balance::destroy_zero(balance_b_fee);
    } 

    public fun swap_exact_coinB_for_coinA<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_b: &mut Coin<CoinTypeB>,
        anount_b_in: u64,
        amount_a_out_min: u64,
        ctx: &mut TxContext
    ) {
        assert!(amm_config::get_pause_status(pause_status) == false, EPOOLPAUSE);
        assert!(coin::value(coin_b) >= anount_b_in, ENotEnough);

        let a_out = compute_out(pool, anount_b_in, true);
        assert!(a_out >= amount_a_out_min, ESwapOutLessthanExpected);
        let balance_b = coin::balance_mut(coin_b);
        let balance_b_in = balance::split(balance_b, anount_b_in);

        let (balance_a_out, balance_b_out, balance_a_fee, balance_b_fee) = 
            amm_swap::swap_and_emit_event(
                pool, 
                balance::zero(), 
                0, 
                balance_b_in, 
                a_out,
                ctx);

        balance::destroy_zero(balance_b_out);
        coin::keep(coin::from_balance(balance_a_out, ctx), ctx);
        amm_swap::handle_swap_protocol_fee(pool, balance::zero(), balance_b_fee);
        balance::destroy_zero(balance_a_fee);
    }

    public fun swap_coinA_for_exact_coinB<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_a: &mut Coin<CoinTypeA>,
        amount_a_max: u64,
        amount_b_out: u64,
        ctx: &mut TxContext
    ) {
        assert!(amm_config::get_pause_status(pause_status) == false, EPOOLPAUSE);
        assert!(coin::value(coin_a) >= amount_a_max, ENotEnough);

        let a_in = compute_in(pool, amount_b_out, true);
        assert!(a_in <= amount_a_max, ESwapInOverLimitMax);

        let balance_a = coin::balance_mut(coin_a);
        let balance_a_in = balance::split(balance_a, a_in);

        let (balance_a_out, balance_b_out, balance_a_fee, balance_b_fee) = 
            amm_swap::swap_and_emit_event(
                pool, 
                balance_a_in, 
                amount_b_out, 
                balance::zero(), 
                0,
                ctx);

        balance::destroy_zero(balance_a_out);
        coin::keep(coin::from_balance(balance_b_out, ctx), ctx);
        amm_swap::handle_swap_protocol_fee(pool, balance_a_fee, balance::zero());
        balance::destroy_zero(balance_b_fee);

    }

    public fun swap_coinB_for_exact_coinA<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_b: &mut Coin<CoinTypeB>,
        amount_b_max: u64,
        amount_a_out: u64,
        ctx: &mut TxContext
    ) {
        assert!(amm_config::get_pause_status(pause_status) == false, EPOOLPAUSE);
        assert!(coin::value(coin_b) >= amount_b_max, ENotEnough);

        let b_in = compute_in(pool, amount_a_out, false);
        assert!(b_in <= amount_b_max, ESwapInOverLimitMax);

        let balance_b = coin::balance_mut(coin_b);
        let balance_b_in = balance::split(balance_b, b_in);

        let (balance_a_out, balance_b_out, balance_a_fee, balance_b_fee) = 
            amm_swap::swap_and_emit_event(
                pool, 
                balance::zero(), 
                0, 
                balance_b_in, 
                amount_a_out, 
                ctx);

        balance::destroy_zero(balance_b_out);
        coin::keep(coin::from_balance(balance_a_out, ctx), ctx);
        amm_swap::handle_swap_protocol_fee(pool, balance::zero(), balance_b_fee);
        balance::destroy_zero(balance_a_fee);
    }

    public fun set_global_pause_status(
        global_pause_status: &mut GlobalPauseStatus, 
        status: bool,
        ctx: &mut TxContext) {
        amm_config::set_status_and_emit_event(
            global_pause_status,
            status,
            ctx
        );
    }

    fun compute_out<CoinTypeA, CoinTypeB>(pool: &Pool<CoinTypeA, CoinTypeB>, amount_in: u64, is_a_to_b: bool): u64 {
        let (fee_numerator, fee_denominator) = amm_swap::get_trade_fee(pool);
        let (reserve_a, reserve_b) = amm_swap::get_trade_fee(pool);

        if (is_a_to_b) {
            amm_utils::get_amount_out(amount_in, reserve_a, reserve_b, fee_numerator, fee_denominator)
        } else {
            amm_utils::get_amount_out(amount_in, reserve_b, reserve_a, fee_numerator, fee_denominator)
        }

    }

    fun compute_in<CoinTypeA, CoinTypeB>(pool: &Pool<CoinTypeA, CoinTypeB>, amount_out: u64, is_a_to_b: bool): u64 {
        let (fee_numerator, fee_denominator) = amm_swap::get_trade_fee(pool);
        let (reserve_a, reserve_b) = amm_swap::get_trade_fee(pool);

        if (is_a_to_b) {
            amm_utils::get_amount_in(amount_out, reserve_a, reserve_b, fee_numerator, fee_denominator)
        } else {
            amm_utils::get_amount_in(amount_out, reserve_b, reserve_a, fee_numerator, fee_denominator)
        }
    }

    public fun set_fee_config<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64,
        ctx: &mut TxContext
    ) {
        assert!(trade_fee_numerator > 0 && trade_fee_denominator > 0, EWrongFee);
        assert!(protocol_fee_numerator > 0 && protocol_fee_denominator > 0, EWrongFee);

        amm_swap::set_fee_and_emit_event(
            pool,
            trade_fee_numerator,
            trade_fee_denominator,
            protocol_fee_numerator,
            protocol_fee_denominator,
            ctx
        );
    }

    public fun claim_fee<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        ctx: &mut TxContext
    ) {
        amm_swap::claim_fee(pool, ctx);
    }

}