module cetus_amm::amm_swap {
    use sui::object::{Self, UID, ID};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Supply, Balance};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::math;
    use sui::tx_context::{Self, TxContext};
     use cetus_amm::amm_config;

    struct AdminCap has key {}

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
        is_a_to_b: bool,
        amount_a: u64,
        amount_b: u64,
    }

    fun init(ctx: &mut TxContext) {

    }

    fun init_pool<CoinTypeA, CoinTypeB>(
        _: AdminCap,
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64,
    ) {

    }

    fun add_liquidity<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &amm_config::GlobalPauseStatus,
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext
    ) {

    }

    fun remove_liquidity<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &amm_config::GlobalPauseStatus,
        lp: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        amount_a_min: u64,
        amount_b_min: u64,
        ctx: &mut TxContext
    ) {

    }

    fun swap_exact_coinA_for_coinB<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &amm_config::GlobalPauseStatus,
        coin_a: Coin<CoinTypeA>,
        amount_a_in: u64,
        amount_b_out_min: u64,
        ctx: &mut TxContext
    ) {

    }

    fun swap_exact_coinB_for_coinA<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &amm_config::GlobalPauseStatus,
        coin_b: Coin<CoinTypeB>,
        amount_b_in: u64,
        amount_a_out_min: u64,
        ctx: &mut TxContext
    ) {

    }

    fun swap_coinA_for_exact_coinB<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &amm_config::GlobalPauseStatus,
        coin_a: Coin<CoinTypeA>,
        amount_a_max: u64,
        amount_b_out: u64,
        ctx: &mut TxContext
    ) {

    }

    fun swap_coinB_for_exact_coinA<CoinTypeA, CoinTypeB>(
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        pause_status: &amm_config::GlobalPauseStatus,
        coin_b: Coin<CoinTypeB>,
        amount_b_max: u64,
        amount_a_out: u64,
        ctx: &mut TxContext
    ) {

    }

}