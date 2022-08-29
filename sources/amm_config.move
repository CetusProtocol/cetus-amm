module cetus_amm::config {
    use std::error;
    use std::signer;

    //
    // Errors
    //

    const ECONFIG_NOT_HAS_PRIVILEGE: u64 = 1001;

    struct PoolFeeConfig has key {
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,

        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64,
    }

    struct PoolPauseStatus has key {
        pause: bool,
    }

    public fun set_pool_fee_config(
        account: &signer,  
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64) acquires PoolFeeConfig {

        assert_admin(account);
        let addr = signer::address_of(account);
        if (!exists<PoolFeeConfig>(addr)) {
            move_to(account, PoolFeeConfig{
                trade_fee_numerator,
                trade_fee_denominator,
                protocol_fee_numerator,
                protocol_fee_denominator,
            });
        } else {
            let fee_config = borrow_global_mut<PoolFeeConfig>(addr);
            fee_config.trade_fee_numerator = trade_fee_numerator;
            fee_config.trade_fee_denominator = trade_fee_denominator;
            fee_config.protocol_fee_numerator = protocol_fee_numerator;
            fee_config.protocol_fee_denominator = protocol_fee_denominator;
        }

    }

    public fun set_pool_pause(
        account: &signer,
        pause: bool) acquires PoolPauseStatus {

        assert_admin(account);
        let addr = signer::address_of(account);
        if (!exists<PoolPauseStatus>(addr)) {
            move_to(account, PoolPauseStatus{ pause });
        } else {
            let status = borrow_global_mut<PoolPauseStatus>(addr);
            status.pause = pause;
        }
    }

    public fun get_trade_fee(): (u64, u64) acquires PoolFeeConfig {
        let fee_config = borrow_global<PoolFeeConfig>(admin_address());
        (fee_config.trade_fee_numerator, fee_config.trade_fee_denominator)
    }

    public fun get_protocol_fee(): (u64, u64) acquires PoolFeeConfig  {
        let fee_config = borrow_global<PoolFeeConfig>(admin_address());
        (fee_config.protocol_fee_numerator, fee_config.protocol_fee_denominator)
    }

    public fun get_pool_pause(): bool acquires PoolPauseStatus {
        borrow_global<PoolPauseStatus>(admin_address()).pause
    }

    public fun admin_address(): address {
        @cetus_amm
    }

    public fun assert_admin(account: &signer) {
        assert!(
            signer::address_of(account) == admin_address(), 
            error::invalid_argument(ECONFIG_NOT_HAS_PRIVILEGE));
    }


}