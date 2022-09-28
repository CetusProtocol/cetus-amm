module cetus_amm::amm_script {
    use cetus_amm::amm_swap::{Pool,PoolLiquidityCoin, AdminCap};
    use cetus_amm::amm_config::{GlobalPauseStatus};
    use cetus_amm::amm_route;
    use sui::coin::{Coin};
    use sui::tx_context::{TxContext};

    entry fun init_pool<CoinTypeA, CoinTypeB>(
        _: &AdminCap,
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64,
        ctx: &mut TxContext
    ) {
        amm_route::init_pool<CoinTypeA, CoinTypeB>(
            trade_fee_numerator,
            trade_fee_denominator,
            protocol_fee_numerator,
            protocol_fee_denominator,
            ctx
        );
    }

    entry fun swap_exact_coinA_for_coinB<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_a: Coin<CoinTypeA>,
        amount_a_in: u64,
        amount_b_out_min: u64,
        ctx: &mut TxContext
    ) {
        amm_route::swap_exact_coinA_for_coinB(
            pool,
            pause_status,
            coin_a,
            amount_a_in,
            amount_b_out_min,
            ctx
        );
    }

    entry fun swap_exact_coinB_for_coinA<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_b: Coin<CoinTypeB>,
        amount_b_in: u64,
        amount_a_out_min: u64,
        ctx: &mut TxContext
    ) {
        amm_route::swap_exact_coinB_for_coinA(
            pool,
            pause_status,
            coin_b,
            amount_b_in,
            amount_a_out_min,
            ctx
        );
    }

    entry fun swap_coinA_for_exact_coinB<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_a: Coin<CoinTypeA>,
        amount_a_max: u64,
        amount_b_out: u64,
        ctx: &mut TxContext
    ) {
        amm_route::swap_coinA_for_exact_coinB(
            pool,
            pause_status,
            coin_a,
            amount_a_max,
            amount_b_out,
            ctx
        );
    }

    entry fun swap_coinB_for_exact_coinA<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_b: Coin<CoinTypeB>,
        amount_b_max: u64,
        amount_a_out: u64,
        ctx: &mut TxContext
    ) {
        amm_route::swap_coinB_for_exact_coinA(
            pool,
            pause_status,
            coin_b,
            amount_b_max,
            amount_a_out,
            ctx
        );
    }

    entry fun add_liquidity<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,
        amount_a_desired: u64,
        amount_b_desired: u64,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext   
    ) {
        amm_route::add_liquidity(
            pool,
            pause_status,
            coin_a,
            coin_b,
            amount_a_desired,
            amount_b_desired,
            amount_a_min,
            amount_b_min,
            ctx);
    }

    entry fun remove_liquidity<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_lp: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        amount_lp: u64,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext
    ) {
        amm_route::remove_liquidity(
            pool,
            pause_status,
            coin_lp,
            amount_lp,
            amount_a_min,
            amount_b_min,
            ctx
        );
    }

    entry fun set_global_pause_status(
        _: &AdminCap, 
        global_pause_status: &mut GlobalPauseStatus, 
        status: bool,
        ctx: &mut TxContext) {
        amm_route::set_global_pause_status(
            global_pause_status, 
            status,
            ctx);
    }

    entry fun set_fee_config<CoinTypeA, CoinTypeB>(
        _: &AdminCap,
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64,
        ctx: &mut TxContext
    ) {
        amm_route::set_fee_config(
            pool,
            trade_fee_numerator,
            trade_fee_denominator,
            protocol_fee_numerator,
            protocol_fee_denominator,
            ctx
        );
    }

    entry fun claim_fee<CoinTypeA, CoinTypeB>(
        _: &AdminCap,
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        ctx: &mut TxContext
    ) {
        amm_route::claim_fee(
            pool,
            ctx
        );
    }

}