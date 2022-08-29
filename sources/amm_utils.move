module cetus_amm::utils {
    use std::error;
    use std::bsc;
    use aptos_framework::coin::{Self, Coin};
    use aptos_std::type_info;
    use aptos_std::comparator;

    //
    // Errors
    //

    const EUTIL_SWAP_COIN_NOT_EXISTS: u64 = 5001;

    public fun assert_is_coin<CoinType>() : bool {
        assert!(is_coin_initialized<CoinType>(), error::invalid_argument(EUTIL_SWAP_COIN_NOT_EXISTS));
        true
    }

    public fun compare_coin<CoinTypeA, CoinTypeB>(): comparator::Result {
        let type_info_a = type_info::type_of<CoinTypeA>();
        let type_info_b = type_info::type_of<CoinTypeB>();

        comparator::compare<type_info::TypeInfo>(&type_info_a, &type_info_b)
    }
}