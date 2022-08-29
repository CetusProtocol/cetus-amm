module cetus_amm::amm_swap {

    use std::string;
    use std::error;
    use std::signer;

    use aptos_std::event::{Self, EventHandle};
    use aptos_framework::coin::{Self, Coin, BurnCapability, MintCapability};
    use aptos_framework::coins;



    struct PoolLiquidityCoin<phantom CoinTypeA, phantom CoinTypeB> {}

    struct Pool<phantom CoinTypeA, phantom CoinTypeB> has key {
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,

        mint_capability: MintCapability<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        burn_capability: BurnCapability<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,

        locked_liquidity: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>,

        protocol_fee_to: address
    }


    struct InitPoolEvent has stroe, drop {

    }

    struct AddLiquidityEvent has stroe, drop {

    }

    struct RemoveLiquidityEvent has stroe, drop {

    }

    struct SwapEvent has stroe, drop {

    }

    struct PoolSwapEventHandle has key {
        init_pool_events: EventHandle<InitPoolEvent>,
        add_liquidity_events: EventHandle<AddLiquidityEvent>,
        remove_liquidity_events: EventHandle<RemoveLiquidityEvent>,
        swap_events: EventHandle<SwapEvent>,
    }

    public fun init_pool<CoinTypeA, CoinTypeB>(account: &signer) {

    }

    public fun add_liquidity<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128) acquires Pool {

    }

    public fun remove_liquidity<CoinTypeA, CoinTypeB>(
        account: &signer,
        liquidity: u128,
        amount_a_min: u128,
        amount_b_min: u128) acquires Pool {

    }

    public fun swap_exact_tokens_for_Tokens<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_in: u128,
        amount_b_out_min: u128,
    ) acquires Pool {

    }

    public fun swap_tokens_for_exact_tokens<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_in_max: u128,
        amount_b_out: u128
    ) acquires Pool {

    }
}