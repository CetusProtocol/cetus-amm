module cetus_amm::swap {
    use std::string;
    use std::error;
    use std::signer;

    use aptos_framework::account;
    use aptos_std::event::{Self, EventHandle};
    use aptos_framework::coin::{Self, Coin, BurnCapability, MintCapability};
    use aptos_framework::coins;
    use aptos_std::comparator;
    use cetus_amm::utils::{Self, assert_is_coin, compare_coin};
    use cetus_amm::config::{Self, assert_admin};


    //
    // Errors
    //

    const ESWAP_COINS_COMPARE_NOT_EQUIP_SMALLER: u64 = 4001;
    const ESWAP_ACCOUNT_NOT_EXISTED: u64 = 4002;

    struct PoolLiquidityCoin<phantom CoinTypeA, phantom CoinTypeB> {}

    struct Pool<phantom CoinTypeA, phantom CoinTypeB> has key {
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,

        mint_capability: MintCapability<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,
        burn_capability: BurnCapability<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,

        locked_liquidity: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>,

        protocol_fee_to: address,
    }


    struct InitPoolEvent has store, drop {

    }

    struct AddLiquidityEvent has store, drop {

    }

    struct RemoveLiquidityEvent has store, drop {

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

    
}