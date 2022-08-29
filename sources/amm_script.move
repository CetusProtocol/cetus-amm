module cetus_amm::amm_script {
    use cetus_amm::amm_config;
    use cetus_amm::amm_swap;
    
    public entry fun init_fee_config() {

    }

    public entry fun register_pool<CoinTypeX, CoinTypeY>(account: signer) {

    }

    public entry fun add_liquidity<CoinTypeX, CoinTypeY>(
        signer: signer,
        amount_x_desired: u128,
        amount_y_desired: u128,
        amount_x_min: u128,
        amount_y_min: u128) {

    }

    public entry fun remove_liquidity<CoinTypeX, CoinTypeY>(
        signer: signer,
        liquidity: u128,
        amount_x_min: u128,
        amount_y_min: u128) {

    }

    public entry fun swap_exact_token_for_token<CoinTypeX, CoinTypeY>(
        signer: signer,
        amount_x_in: u128,
        amount_y_out_min: u128,
    ) {
        
    }

    public entry fun swap_token_for_exact_token<CoinTypeX, CoinTypeY>(
        signer: signer,
        amount_x_in_max: u128,
        amount_y_out: u128,
    ) {

    }

    public entry fun set_pause_status(status:bool) {

    }
}