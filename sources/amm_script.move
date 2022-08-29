module cetus_amm::amm_script {
    use cetus_amm::amm_config;
    use cetus_amm::amm_swap;
    
    public entry fun init_fee_config() {

    }

    public entry fun register_pool<CoinTypeA, CoinTypeB>(account: signer) {

    }

    /// Add liquidity for user
    public entry fun add_liquidity<CoinTypeA, CoinTypeB>(
        signer: signer,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128) {
        amm_swap::add_liquidity<CoinTypeA, CoinTypeB>(
            &signer,
            amount_a_desired,
            amount_b_desired,
            amount_a_min,
            amount_b_min);
    }

    /// Remove liquidity for user
    public entry fun remove_liquidity<CoinTypeA, CoinTypeB>(
        signer: signer,
        liquidity: u128,
        amount_a_min: u128,
        amount_b_min: u128) {
        amm_swap::remove_liquidity<CoinTypeA, CoinTypeB>(
            &signer,
            liquidity,
            amount_a_min,
            amount_b_min);
    }

    public entry fun swap_exact_token_for_token<CoinTypeA, CoinTypeB>(
        signer: signer,
        amount_a_in: u128,
        amount_b_out_min: u128,
    ) {
        amm_swap::swap_exact_token_for_token<CoinTypeA, CoinTypeB>(
            &signer,
            amount_a_in,
            amount_b_out_min);
    }

    public entry fun swap_token_for_exact_token<CoinTypeX, CoinTypeY>(
        signer: signer,
        amount_a_in_max: u128,
        amount_b_out: u128,
    ) {
        amm_swap::swap_token_for_exact_token<CoinTypeX, CoinTypeY>(
            &signer,
            amount_a_in_max,
            amount_b_out);
    }

    public entry fun set_pause_status(status:bool) {

    }
}