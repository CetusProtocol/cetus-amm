module cetus_amm::amm_utils {
    use std::error;
    use aptos_framework::coin;
    use aptos_std::type_info;
    use aptos_std::comparator;
    use cetus_amm::amm_math;
    
    //
    // Errors
    //

    const ESWAP_COIN_NOT_EXISTS: u64 = 5001;
    const EPARAMETER_INVALID: u64 = 5002;

    public fun assert_is_coin<CoinType>() : bool {
        assert!(coin::is_coin_initialized<CoinType>(), error::internal(ESWAP_COIN_NOT_EXISTS));
        true
    }

    public fun compare_coin<CoinTypeA, CoinTypeB>(): comparator::Result {
        let type_info_a = type_info::type_of<CoinTypeA>();
        let type_info_b = type_info::type_of<CoinTypeB>();

        comparator::compare<type_info::TypeInfo>(&type_info_a, &type_info_b)
    }

    public fun get_amount_in(
        amount_out: u128,
        reserve_in: u128,
        reserve_out: u128,
        fee_numerator: u64,
        fee_denumerator: u64): u128 {
        assert!(amount_out > 0, error::internal(EPARAMETER_INVALID));
        assert!(reserve_in > 0 && reserve_out > 0, error::internal(EPARAMETER_INVALID));
        assert!(fee_denumerator > 0 && fee_numerator > 0, error::internal(EPARAMETER_INVALID));
        assert!(fee_denumerator > fee_numerator, error::internal(EPARAMETER_INVALID));
        assert!(reserve_out > amount_out, error::internal(EPARAMETER_INVALID));

        let denominator = (reserve_out - amount_out) * ((fee_denumerator - fee_numerator) as u128);
        amm_math::safe_mul_div_u128(amount_out * (fee_denumerator as u128), reserve_in, denominator) + 1
    }

    public fun get_amount_out(
        amount_in: u128,
        reserve_in: u128,
        reserve_out: u128,
        fee_numerator: u64,
        fee_denumerator: u64
    ): u128 {
        assert!(amount_in > 0, error::internal(EPARAMETER_INVALID));
        assert!(reserve_in > 0 && reserve_out > 0, error::internal(EPARAMETER_INVALID));

        assert!(fee_denumerator > 0 && fee_numerator > 0, error::internal(EPARAMETER_INVALID));
        assert!(fee_denumerator > fee_numerator, error::internal(EPARAMETER_INVALID));

        let amount_in_with_fee = amount_in * ((fee_denumerator - fee_numerator) as u128);
        let denominator = reserve_in * (fee_denumerator as u128) + amount_in_with_fee;
        amm_math::safe_mul_div_u128(amount_in_with_fee, reserve_out, denominator)
    }

    #[test]
    public entry fun test_get_amount_out() {
        let amount_in:u128 = 999999;
        let reserve_in: u128 = 10000010001;
        let reserve_out: u128 = 1971498032450;
        let out = get_amount_out(amount_in, reserve_in, reserve_out, 2, 1000);
        debug::print(&out);
        assert!(out == 196735475, 3004);
    }
}