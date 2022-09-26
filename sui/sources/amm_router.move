module cetus_amm::amm_route {
    use cetus_amm::amm_swap::{Pool,PoolLiquidityCoin};
    use cetus_amm::amm_config::{GlobalPauseStatus};
    use sui::coin::{Coin};
    use sui::tx_context::{TxContext};

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
    }

    public fun remove_liquidity<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        lp: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext) {

    }

}