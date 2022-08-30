module cetus_amm::amm_script {
    use cetus_amm::config;
    use cetus_amm::amm_swap;
    
    public entry fun set_pool_fee_config(
        account: signer,
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64
    ) {
        config::set_pool_fee_config(
            &account,
            trade_fee_numerator,
            trade_fee_denominator,
            protocol_fee_numerator,
            protocol_fee_denominator,
        )
    }

    public entry fun init_pool<CoinTypeA, CoinTypeB>(account: signer,  protocol_fee_to: address) {
        amm_swap::init_pool<CoinTypeA, CoinTypeB> (
            &account,
            protocol_fee_to,     
        )
    }

    /// Add liquidity for user
    public entry fun add_liquidity<CoinTypeA, CoinTypeB>(
        account: signer,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128) {
        amm_swap::add_liquidity<CoinTypeA, CoinTypeB>(
            &account,
            amount_a_desired,
            amount_b_desired,
            amount_a_min,
            amount_b_min);
    }

    /// Remove liquidity for user
    public entry fun remove_liquidity<CoinTypeA, CoinTypeB>(
        account: signer,
        liquidity: u128,
        amount_a_min: u128,
        amount_b_min: u128) {
        amm_swap::remove_liquidity<CoinTypeA, CoinTypeB>(
            &account,
            liquidity,
            amount_a_min,
            amount_b_min);
    }

    public entry fun swap_exact_coin_for_coin<CoinTypeA, CoinTypeB>(
        account: signer,
        amount_a_in: u128,
        amount_b_out_min: u128,
    ) {
        amm_swap::swap_exact_tokens_for_Tokens<CoinTypeA, CoinTypeB> (
            &account,
            amount_a_in,
            amount_b_out_min,
        )
    }

    public entry fun swap_coin_for_exact_coin<CoinTypeA, CoinTypeB>(
        account: signer,
        amount_a_in_max: u128,
        amount_b_out: u128,
    ) {
        amm_swap::swap_tokens_for_exact_tokens<CoinTypeA, CoinTypeB> (
            &account,
            amount_a_in_max,
            amount_b_out,
        )
    }

    public entry fun set_pause_status(account: signer, pause:bool) {
        config::set_pool_pause(&account, pause)
    }
}