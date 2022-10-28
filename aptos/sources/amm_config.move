module cetus_amm::amm_config {
    use std::error;
    use std::signer;
    //
    // Errors
    //
    const ENOT_HAS_PRIVILEGE: u64 = 1001;
    const EPOOL_PAUSE: u64 = 1002;

    const DEFAULT_TRADE_FEE_NUMERATOR: u64 = 2;
    const DEFAULT_TRADE_FEE_DENOMINATOR: u64 = 1000;
    const DEFAULT_PROTOCOL_FEE_NUMERATOR: u64 = 2;
    const DEFAULT_PROTOCOL_FEE_DENOMINATOR: u64 = 10;

    struct PoolFeeConfig<phantom CoinTypeA, phantom CoinTypeB> has key {
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,

        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64,
    }

    struct PoolPauseStatus has key {
        pause: bool,
    }

    public fun set_pool_fee_config<CoinTypeA, CoinTypeB>(
        account: &signer,  
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64) acquires PoolFeeConfig {

        assert_admin(account);
        let addr = signer::address_of(account);
        if (!exists<PoolFeeConfig<CoinTypeA, CoinTypeB>>(addr)) {
            move_to(account, PoolFeeConfig<CoinTypeA, CoinTypeB>{
                trade_fee_numerator,
                trade_fee_denominator,
                protocol_fee_numerator,
                protocol_fee_denominator,
            });
        } else {
            let fee_config = borrow_global_mut<PoolFeeConfig<CoinTypeA, CoinTypeB>>(addr);
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

    public fun get_trade_fee<CoinTypeA, CoinTypeB>(): (u64, u64) acquires PoolFeeConfig {
         if (exists<PoolFeeConfig<CoinTypeA, CoinTypeB>>(admin_address())) {
            let fee_config = borrow_global<PoolFeeConfig<CoinTypeA, CoinTypeB>>(admin_address());
            (fee_config.trade_fee_numerator, fee_config.trade_fee_denominator)
         } else {
            (DEFAULT_TRADE_FEE_NUMERATOR, DEFAULT_TRADE_FEE_DENOMINATOR)
        }
    }

    public fun get_protocol_fee<CoinTypeA, CoinTypeB>(): (u64, u64) acquires PoolFeeConfig  {
         if (exists<PoolFeeConfig<CoinTypeA, CoinTypeB>>(admin_address())) {
            let fee_config = borrow_global<PoolFeeConfig<CoinTypeA, CoinTypeB>>(admin_address());
            (fee_config.protocol_fee_numerator, fee_config.protocol_fee_denominator)
        } else {
            (DEFAULT_PROTOCOL_FEE_NUMERATOR, DEFAULT_PROTOCOL_FEE_DENOMINATOR)
        }
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
            error::permission_denied(ENOT_HAS_PRIVILEGE));
    }

    public fun assert_pause() acquires PoolPauseStatus {
        assert!(
            !get_pool_pause(),
            error::unavailable(EPOOL_PAUSE));
    }
}