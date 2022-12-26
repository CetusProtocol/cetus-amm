module cetus_amm::amm_router {
    use cetus_amm::amm_swap::{Self, Pool,PoolLiquidityCoin, AdminCap};
    use cetus_amm::amm_config::{Self, GlobalPauseStatus};
    use cetus_amm::amm_utils;
    use sui::coin::{Self,Coin};
    use sui::tx_context::{Self, TxContext};
    use sui::balance::{Self, Balance};
    use sui::transfer;

    const ENotEnough: u64 = 1;
    const ESwapOutLessthanExpected: u64 = 2;
    const ESwapInOverLimitMax: u64 = 3;
    const EWrongFee: u64 = 4;
    const ELiquidityInsufficientBAmount: u64 = 5;
    const ELiquidityInsufficientAAmount: u64 = 6;
    const ELiquidityOverLimitADesired: u64 = 7;
    const ELiquidityAddLiquidityFailed: u64 = 8;

    public fun add_liquidity<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,
        amount_a_desired: u64,
        amount_b_desired: u64,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext) {

        assert!(coin::value(&coin_a) >= amount_a_desired, ENotEnough);
        assert!(coin::value(&coin_b) >= amount_b_desired, ENotEnough);
        amm_config::assert_pause(pause_status);

        add_liquidity_internal(
            pool,
            coin_a,
            coin_b,
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
        amount_a_desired: u64,
        amount_b_desired: u64,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext) {
        let (amount_a, amount_b) = calculate_amount_for_liquidity_internal<CoinTypeA, CoinTypeB>(
            pool,
            amount_a_desired,
            amount_b_desired,
            amount_a_min,
            amount_b_min
        );

        let balance_a = coin::into_balance(coin_a);
        let to_add_a = balance::split(&mut balance_a, amount_a);
        let balance_b = coin::into_balance(coin_b);
        let to_add_b = balance::split(&mut balance_b, amount_b);
        let coin_liquidity = amm_swap::mint_and_emit_event(
            pool,
            to_add_a,
            to_add_b,
            amount_a,
            amount_b,
            ctx
        );
        assert!(coin::value(&coin_liquidity) > 0, ELiquidityAddLiquidityFailed);
        amm_utils::keep(coin_liquidity, ctx);

        reture_back_or_delete(balance_a, ctx);
        reture_back_or_delete(balance_b, ctx);
    }

    fun calculate_amount_for_liquidity_internal<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        amount_a_desired: u64,
        amount_b_desired: u64,
        amount_a_min: u64,
        amount_b_min: u64): (u64, u64) {
        let (reserve_a, reserve_b) = amm_swap::get_reserves(pool);
        if(reserve_a == 0 && reserve_b == 0) {
            (amount_a_desired, amount_b_desired)
        } else {
            let amount_b_optimal = amm_utils::quote(amount_a_desired, reserve_a, reserve_b);
            if (amount_b_optimal <= amount_b_desired) {
                assert!(amount_b_optimal >= amount_b_min, ELiquidityInsufficientBAmount);
                (amount_a_desired, amount_b_optimal)
            } else {
                let amount_a_optimal = amm_utils::quote(amount_b_desired, reserve_b, reserve_a);
                assert!(amount_a_optimal <= amount_a_desired, ELiquidityOverLimitADesired);
                assert!(amount_a_optimal >= amount_a_min, ELiquidityInsufficientAAmount);
                (amount_a_optimal, amount_b_desired)
            } 
        }
    }

    public fun remove_liquidity<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_lp: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        amount_lp: u64,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext) {
        assert!(coin::value(&coin_lp) >= amount_lp, ENotEnough);
        amm_config::assert_pause(pause_status);

        remove_liquidity_internal(
            pool,
            coin_lp,
            amount_lp,
            amount_a_min,
            amount_b_min,
            ctx
        );
    }

    fun remove_liquidity_internal<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        coin_lp: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        amount_lp: u64,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext) {
            let balance_lp = coin::into_balance(coin_lp);
            let to_burn = balance::split(&mut balance_lp, amount_lp);
            let (coin_a, coin_b) = amm_swap::burn_and_emit_event(
                pool,
                to_burn,
                ctx
            );

            assert!(coin::value(&coin_a) >= amount_a_min, ELiquidityInsufficientAAmount);
            assert!(coin::value(&coin_b) >= amount_b_min, ELiquidityInsufficientBAmount);
            amm_utils::keep(coin_a, ctx);
            amm_utils::keep(coin_b, ctx);
            reture_back_or_delete(balance_lp, ctx);
        }

    public fun init_pool<CoinTypeA, CoinTypeB>(
        _: &AdminCap,
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
        coin_a: Coin<CoinTypeA>,
        amount_a_in: u64,
        amount_b_out_min: u64,
        ctx: &mut TxContext
    ) {
        assert!(coin::value(&coin_a) >= amount_a_in, ENotEnough);
        amm_config::assert_pause(pause_status);

        let b_out = compute_out<CoinTypeA, CoinTypeB>(pool, amount_a_in, true);
        assert!(b_out >= amount_b_out_min, ESwapOutLessthanExpected);
        let balance_a = coin::into_balance(coin_a);
        let balance_a_in = balance::split(&mut balance_a, amount_a_in);
        let (balance_a_out, balance_b_out, balance_a_fee, balance_b_fee) = 
            amm_swap::swap_and_emit_event(
                pool, 
                balance_a_in, 
                b_out, 
                balance::zero(), 
                0,
                ctx);

        balance::destroy_zero(balance_a_out);
        amm_utils::keep(coin::from_balance(balance_b_out, ctx), ctx);
        amm_swap::handle_swap_protocol_fee(pool, balance_a_fee, balance::zero());
        balance::destroy_zero(balance_b_fee);

        reture_back_or_delete(balance_a, ctx);
    } 

    public fun swap_exact_coinB_for_coinA<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_b: Coin<CoinTypeB>,
        anount_b_in: u64,
        amount_a_out_min: u64,
        ctx: &mut TxContext
    ) {
        assert!(coin::value(&coin_b) >= anount_b_in, ENotEnough);
        amm_config::assert_pause(pause_status);

        let a_out = compute_out(pool, anount_b_in, false);
        assert!(a_out >= amount_a_out_min, ESwapOutLessthanExpected);
        let balance_b = coin::into_balance(coin_b);
        let balance_b_in = balance::split(&mut balance_b, anount_b_in);

        let (balance_a_out, balance_b_out, balance_a_fee, balance_b_fee) = 
            amm_swap::swap_and_emit_event(
                pool, 
                balance::zero(), 
                0, 
                balance_b_in, 
                a_out,
                ctx);

        balance::destroy_zero(balance_b_out);
        amm_utils::keep(coin::from_balance(balance_a_out, ctx), ctx);
        amm_swap::handle_swap_protocol_fee(pool, balance::zero(), balance_b_fee);
        balance::destroy_zero(balance_a_fee);

        reture_back_or_delete(balance_b, ctx);
    }

    public fun swap_coinA_for_exact_coinB<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_a: Coin<CoinTypeA>,
        amount_a_max: u64,
        amount_b_out: u64,
        ctx: &mut TxContext
    ) {
        assert!(coin::value(&coin_a) >= amount_a_max, ENotEnough);
        amm_config::assert_pause(pause_status);

        let a_in = compute_in(pool, amount_b_out, true);
        assert!(a_in <= amount_a_max, ESwapInOverLimitMax);

        let balance_a = coin::into_balance(coin_a);
        let balance_a_in = balance::split(&mut balance_a, a_in);

        let (balance_a_out, balance_b_out, balance_a_fee, balance_b_fee) = 
            amm_swap::swap_and_emit_event(
                pool, 
                balance_a_in, 
                amount_b_out, 
                balance::zero(), 
                0,
                ctx);

        balance::destroy_zero(balance_a_out);
        amm_utils::keep(coin::from_balance(balance_b_out, ctx), ctx);
        amm_swap::handle_swap_protocol_fee(pool, balance_a_fee, balance::zero());
        balance::destroy_zero(balance_b_fee);

        reture_back_or_delete(balance_a, ctx);
    }

    public fun swap_coinB_for_exact_coinA<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_b: Coin<CoinTypeB>,
        amount_b_max: u64,
        amount_a_out: u64,
        ctx: &mut TxContext
    ) {
        assert!(coin::value(&coin_b) >= amount_b_max, ENotEnough);
        amm_config::assert_pause(pause_status);

        let b_in = compute_in(pool, amount_a_out, false);
        assert!(b_in <= amount_b_max, ESwapInOverLimitMax);

        let balance_b = coin::into_balance(coin_b);
        let balance_b_in = balance::split(&mut balance_b, b_in);

        let (balance_a_out, balance_b_out, balance_a_fee, balance_b_fee) = 
            amm_swap::swap_and_emit_event(
                pool, 
                balance::zero(), 
                0, 
                balance_b_in, 
                amount_a_out, 
                ctx);

        balance::destroy_zero(balance_b_out);
        amm_utils::keep(coin::from_balance(balance_a_out, ctx), ctx);
        amm_swap::handle_swap_protocol_fee(pool, balance::zero(), balance_b_fee);
        balance::destroy_zero(balance_a_fee);

        reture_back_or_delete(balance_b, ctx);
    }

    public fun set_global_pause_status(
        _: &AdminCap,
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
        let (reserve_a, reserve_b) = amm_swap::get_reserves(pool);

        if (is_a_to_b) {
            amm_utils::get_amount_out(amount_in, reserve_a, reserve_b, fee_numerator, fee_denominator)
        } else {
            amm_utils::get_amount_out(amount_in, reserve_b, reserve_a, fee_numerator, fee_denominator)
        }

    }

    fun compute_in<CoinTypeA, CoinTypeB>(pool: &Pool<CoinTypeA, CoinTypeB>, amount_out: u64, is_a_to_b: bool): u64 {
        let (fee_numerator, fee_denominator) = amm_swap::get_trade_fee(pool);
        let (reserve_a, reserve_b) = amm_swap::get_reserves(pool);

        if (is_a_to_b) {
            amm_utils::get_amount_in(amount_out, reserve_a, reserve_b, fee_numerator, fee_denominator)
        } else {
            amm_utils::get_amount_in(amount_out, reserve_b, reserve_a, fee_numerator, fee_denominator)
        }
    }

    public fun set_fee_config<CoinTypeA, CoinTypeB>(
        _: &AdminCap,
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
        _: &AdminCap,
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        ctx: &mut TxContext
    ) {
        amm_swap::claim_fee(pool, ctx);
    }

    fun reture_back_or_delete<CoinType>(
        balance: Balance<CoinType>,
        ctx: &mut TxContext
    ) {
        if(balance::value(&balance) > 0) {
            transfer::transfer(coin::from_balance(balance , ctx), tx_context::sender(ctx));
        } else {
            balance::destroy_zero(balance);
        }
    }

}