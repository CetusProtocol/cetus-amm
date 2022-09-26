module cetus_amm::amm_script {
    use cetus_amm::amm_swap::{Pool,PoolLiquidityCoin};
    use cetus_amm::amm_config::{GlobalPauseStatus};
    use cetus_amm::amm_route;
    use sui::coin::{Coin};
    use sui::tx_context::{TxContext};

    entry fun add_liquidity<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext   
    ) {
        amm_route::add_liquidity(
            pool,
            coin_a,coin_b,
            amount_a_desired,
            amount_b_desired,
            amount_a_min,
            amount_b_min,
            ctx);
    }

    entry fun remove_liquidity<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &GlobalPauseStatus,
        lp: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext
    ) {
        amm_route::remove_liquidity(
            pool,
            lp,
            amount_a_min,
            amount_b_min,
            ctx
        );
    }

}