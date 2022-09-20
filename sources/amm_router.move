module cetus_amm::amm_router {
    use std::error;
    use std::signer;
    use cetus_amm::amm_config;
    use cetus_amm::amm_swap::{PoolLiquidityCoin,Self};
    use cetus_amm::amm_utils;
    use aptos_framework::coin;
    use aptos_std::comparator;
    use cetus_amm::amm_math::{Self, quote};


    const ESWAP_B_OUT_LESSTHAN_EXPECTED: u64 = 3001;
    const ESWAP_A_IN_OVER_LIMIT_MAX: u64 = 3002;
    const EINVALID_COIN_PAIR: u64 = 3003;
    const ELIQUIDITY_INSUFFICIENT_B_AMOUNT: u64 = 3004;
    const ELIQUIDITY_OVERLIMIT_X_DESIRED: u64 = 3005;
    const ELIQUIDITY_INSUFFICIENT_A_AMOUNT: u64 = 3006;
    const ELIQUIDITY_ADD_LIQUIDITY_FAILED: u64 = 3007;

    public fun set_pool_fee_config<CoinTypeA, CoinTypeB>(
        account: &signer,
        trade_fee_numerator: u64,
        trade_fee_denominator: u64,
        protocol_fee_numerator: u64,
        protocol_fee_denominator: u64
    ) {
        //compare coins
        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeA, CoinTypeB>()),  
            error::internal(EINVALID_COIN_PAIR));
        if (comparator::is_smaller_than(&amm_utils::compare_coin<CoinTypeA, CoinTypeB>())) {
            amm_config::set_pool_fee_config<CoinTypeA, CoinTypeB>(
                account,
                trade_fee_numerator,
                trade_fee_denominator,
                protocol_fee_numerator,
                protocol_fee_denominator);
        } else {
            amm_config::set_pool_fee_config<CoinTypeB, CoinTypeA>(
                account,
                trade_fee_numerator,
                trade_fee_denominator,
                protocol_fee_numerator,
                protocol_fee_denominator);
        }
    }

    public fun set_pause_status(account: &signer, pause:bool) {
        amm_config::set_pool_pause(account, pause);
    }

    public fun init_pool<CoinTypeA, CoinTypeB>(account: &signer,  protocol_fee_to: address) {
        //compare coins
        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeA, CoinTypeB>()),  
            error::internal(EINVALID_COIN_PAIR));

        if (comparator::is_smaller_than(&amm_utils::compare_coin<CoinTypeA, CoinTypeB>())) {
            amm_swap::init_pool<CoinTypeA, CoinTypeB> (
            account,
            protocol_fee_to);
        } else {
            amm_swap::init_pool<CoinTypeB, CoinTypeA> (
            account,
            protocol_fee_to);
        }
    }

    /// Add liquidity for user
    public fun add_liquidity<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128) {
        amm_config::assert_pause();

        let order = amm_utils::compare_coin<CoinTypeA, CoinTypeB>();
        assert!(
            !comparator::is_equal(&order),  
            error::internal(EINVALID_COIN_PAIR));
        if (comparator::is_smaller_than(&order)) {
            add_liquidity_internal<CoinTypeA, CoinTypeB>(
                account,
                amount_a_desired,
                amount_b_desired,
                amount_a_min,
                amount_b_min,
            );
        } else {
            add_liquidity_internal<CoinTypeB, CoinTypeA>(
                account,
                amount_b_desired,
                amount_a_desired,
                amount_b_min,
                amount_a_min,
            );
        }
    }

    fun add_liquidity_internal<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128) {
        let (amount_a, amount_b) = calculate_amount_for_liquidity_internal<CoinTypeA, CoinTypeB>(
            amount_a_desired,
            amount_b_desired,
            amount_a_min,
            amount_b_min);
        let coinA = coin::withdraw<CoinTypeA>(account,(amount_a as u64));
        let coinB = coin::withdraw<CoinTypeB>(account,(amount_b as u64));
        let liquidity_token = amm_swap::mint_and_emit_event<CoinTypeA, CoinTypeB>(
                account,
                coinA,
                coinB,
                amount_a_desired,
                amount_b_desired,
                amount_a_min,
                amount_b_min);
        assert!(coin::value(&liquidity_token) > 0, error::invalid_argument(ELIQUIDITY_ADD_LIQUIDITY_FAILED));
        let sender = signer::address_of(account);
        if (!coin::is_account_registered<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(sender)) coin::register<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(account);
        coin::deposit(sender,liquidity_token);
    }

    fun calculate_amount_for_liquidity_internal<CoinTypeA, CoinTypeB>(
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128,): (u128, u128) {
        let (reserve_a, reserve_b) = amm_swap::get_reserves<CoinTypeA, CoinTypeB>();
        if (reserve_a == 0 && reserve_b == 0) {
            return (amount_a_desired, amount_b_desired)
        } else {
            let amount_b_optimal = amm_math::quote(amount_a_desired, reserve_a, reserve_b);
            if (amount_b_optimal <= amount_b_desired) {
                assert!(amount_b_optimal >= amount_b_min, error::internal(ELIQUIDITY_INSUFFICIENT_B_AMOUNT));
                return (amount_a_desired, amount_b_optimal)
            } else {
                let amount_a_optimal = quote(amount_b_desired, reserve_b, reserve_a);
                assert!(amount_a_optimal <= amount_a_desired, error::internal(ELIQUIDITY_OVERLIMIT_X_DESIRED));
                assert!(amount_a_optimal >= amount_a_min, error::internal(ELIQUIDITY_INSUFFICIENT_A_AMOUNT));
                return (amount_a_optimal, amount_b_desired)
            }
        }
    }

    /// Remove liquidity for user
    public fun remove_liquidity<CoinTypeA, CoinTypeB>(
        account: &signer,
        liquidity: u128,
        amount_a_min: u128,
        amount_b_min: u128) {
        amm_config::assert_pause();

        let order = amm_utils::compare_coin<CoinTypeA, CoinTypeB>();
        assert!(
            !comparator::is_equal(&order),  
            error::internal(EINVALID_COIN_PAIR));
        if (comparator::is_smaller_than(&order)) {
            remove_liquidity_internal<CoinTypeA, CoinTypeB>(
                account,
                liquidity,
                amount_a_min,
                amount_b_min);
        } else {
            remove_liquidity_internal<CoinTypeB, CoinTypeA>(
                account,
                liquidity,
                amount_b_min,
                amount_a_min);
        }
    }

    fun remove_liquidity_internal<CoinTypeA, CoinTypeB>(
        account: &signer,
        liquidity: u128,
        amount_a_min: u128,
        amount_b_min: u128) {
        let liquidity_token = coin::withdraw<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>(account,(liquidity as u64));
        let (token_a, token_b) = amm_swap::burn_and_emit_event(
            account,
            liquidity_token,
            amount_a_min,
            amount_b_min);
        assert!((coin::value(&token_a) as u128) >= amount_a_min, error::internal(ELIQUIDITY_INSUFFICIENT_A_AMOUNT));
        assert!((coin::value(&token_b) as u128) >= amount_b_min, error::internal(ELIQUIDITY_INSUFFICIENT_B_AMOUNT));
        let sender = signer::address_of(account);
        coin::deposit(sender,token_a);
        coin::deposit(sender,token_b);
    }

    public fun swap_exact_coin_for_coin<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_in: u128,
        amount_b_out_min: u128,
    ) {
        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeA, CoinTypeB>()),  
            error::invalid_argument(EINVALID_COIN_PAIR));
        
        let sender = signer::address_of(account);
        if (!coin::is_account_registered<CoinTypeB>(sender)) coin::register<CoinTypeB>(account);
        let b_out = compute_b_out<CoinTypeA, CoinTypeB>(amount_a_in);
        assert!(b_out >= amount_b_out_min, 
            error::internal(ESWAP_B_OUT_LESSTHAN_EXPECTED));
        let coin_a = coin::withdraw<CoinTypeA>(account, (amount_a_in as u64));
        let (coin_a_out, coin_b_out);
        let (coin_a_fee, coin_b_fee);
        if (comparator::is_smaller_than(&amm_utils::compare_coin<CoinTypeA, CoinTypeB>())) {
            (coin_a_out, coin_b_out, coin_a_fee, coin_b_fee) = amm_swap::swap_and_emit_event<CoinTypeA, CoinTypeB>(account, coin_a, b_out, coin::zero(), 0);
        } else {
            (coin_b_out, coin_a_out, coin_b_fee, coin_a_fee) = amm_swap::swap_and_emit_event<CoinTypeB, CoinTypeA>(account, coin::zero(), 0, coin_a, b_out);
        };

        coin::destroy_zero(coin_a_out);
        coin::deposit(sender, coin_b_out);
        coin::destroy_zero(coin_b_fee);

        amm_swap::handle_swap_protocol_fee<CoinTypeA, CoinTypeB>(sender, coin_a_fee);
    }

    public fun swap_exact_coin_for_coin_router2<CoinTypeA, CoinTypeX, CoinTypeB>(
        account: &signer,
        amount_a_in: u128,
        amount_b_out_min: u128,
    ) {
        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeA, CoinTypeX>()),  
            error::invalid_argument(EINVALID_COIN_PAIR));

        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeX, CoinTypeB>()),  
            error::invalid_argument(EINVALID_COIN_PAIR));

        let (x_out, b_out) = get_amount_out_router2<CoinTypeA, CoinTypeX, CoinTypeB>(amount_a_in);
        assert!(b_out >= amount_b_out_min, error::internal(ESWAP_B_OUT_LESSTHAN_EXPECTED));

        swap_exact_coin_for_coin<CoinTypeA, CoinTypeX>(account, amount_a_in, x_out);
        swap_exact_coin_for_coin<CoinTypeX, CoinTypeB>(account, x_out, amount_b_out_min);
    }

    public fun swap_exact_coin_for_coin_router3<CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>(
        account: &signer,
        amount_a_in: u128,
        amount_b_out_min: u128
    ) {
        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeA, CoinTypeX>()),  
            error::invalid_argument(EINVALID_COIN_PAIR));

        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeX, CoinTypeY>()),  
            error::invalid_argument(EINVALID_COIN_PAIR));
        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeY, CoinTypeB>()),  
            error::invalid_argument(EINVALID_COIN_PAIR));

        let (x_out, y_out, b_out) = get_amount_out_router3<CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>(amount_a_in);
        assert!(b_out >= amount_b_out_min, error::internal(ESWAP_B_OUT_LESSTHAN_EXPECTED));
        swap_exact_coin_for_coin<CoinTypeA, CoinTypeX>(account, amount_a_in, x_out);
        swap_exact_coin_for_coin<CoinTypeX, CoinTypeY>(account, x_out, y_out);
        swap_exact_coin_for_coin<CoinTypeY, CoinTypeB>(account, y_out, amount_b_out_min);
    }

    public fun swap_coin_for_exact_coin<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_in_max: u128,
        amount_b_out: u128,
    ) {
        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeA, CoinTypeB>()),  
            error::invalid_argument(EINVALID_COIN_PAIR));

        let sender = signer::address_of(account);
        if (!coin::is_account_registered<CoinTypeB>(sender)) coin::register<CoinTypeB>(account);
        let a_in = compute_a_in<CoinTypeA, CoinTypeB>(amount_b_out);
        assert!(a_in <= amount_a_in_max, 
            error::internal(ESWAP_A_IN_OVER_LIMIT_MAX));
        let coin_a = coin::withdraw<CoinTypeA>(account, (a_in as u64));
        let (coin_a_out, coin_b_out);
        let (coin_a_fee, coin_b_fee);
        if (comparator::is_smaller_than(&amm_utils::compare_coin<CoinTypeA, CoinTypeB>())) {
            (coin_a_out, coin_b_out, coin_a_fee, coin_b_fee) = amm_swap::swap_and_emit_event<CoinTypeA, CoinTypeB>(account, coin_a, amount_b_out, coin::zero(), 0);
        } else {
            (coin_b_out, coin_a_out, coin_b_fee, coin_a_fee) = amm_swap::swap_and_emit_event<CoinTypeB, CoinTypeA>(account, coin::zero(), 0, coin_a, amount_b_out);
        };

        coin::destroy_zero(coin_a_out);
        coin::deposit(sender, coin_b_out);
        coin::destroy_zero(coin_b_fee);

        amm_swap::handle_swap_protocol_fee<CoinTypeA, CoinTypeB>(sender, coin_a_fee);
    }

    public fun swap_coin_for_exact_coin_router2<CoinTypeA, CoinTypeX, CoinTypeB>(
        account: &signer,
        amount_a_in_max: u128,
        amount_b_out: u128
    ) {
        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeA, CoinTypeX>()),  
            error::invalid_argument(EINVALID_COIN_PAIR));

        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeX, CoinTypeB>()),  
            error::invalid_argument(EINVALID_COIN_PAIR));

        let(x_in, a_in) = get_amount_in_router2<CoinTypeA, CoinTypeX, CoinTypeB>(amount_b_out);
        assert!(a_in <= amount_a_in_max, error::internal(ESWAP_A_IN_OVER_LIMIT_MAX));

        swap_coin_for_exact_coin<CoinTypeA, CoinTypeX> (account,amount_a_in_max,x_in);
        swap_coin_for_exact_coin<CoinTypeX, CoinTypeB> (account,x_in,amount_b_out);
    }

    public fun swap_coin_for_exact_coin_router3<CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>(
        account: &signer,
        amount_a_in_max: u128,
        amount_b_out: u128
    ) {
        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeA, CoinTypeX>()),  
            error::invalid_argument(EINVALID_COIN_PAIR));

        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeX, CoinTypeY>()),  
            error::invalid_argument(EINVALID_COIN_PAIR));
        assert!(
            !comparator::is_equal(&amm_utils::compare_coin<CoinTypeY, CoinTypeB>()),  
            error::invalid_argument(EINVALID_COIN_PAIR));

        let(y_in, x_in, a_in) = get_amount_in_router3<CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>(amount_b_out);
         assert!(a_in <= amount_a_in_max, error::internal(ESWAP_A_IN_OVER_LIMIT_MAX));

         swap_coin_for_exact_coin<CoinTypeA, CoinTypeX> (account,amount_a_in_max,x_in);
         swap_coin_for_exact_coin<CoinTypeX, CoinTypeY> (account,x_in,y_in);
         swap_coin_for_exact_coin<CoinTypeY, CoinTypeB> (account,y_in,amount_b_out);
    }

    public fun compute_b_out<CoinTypeA, CoinTypeB>(amount_a_in: u128): u128 {
        let (fee_numerator, fee_denominator) = amm_config::get_trade_fee<CoinTypeA, CoinTypeB>();
        let (reserve_a, reserve_b) = amm_swap::get_reserves<CoinTypeA, CoinTypeB>();
        amm_utils::get_amount_out(amount_a_in, (reserve_a as u128), (reserve_b as u128), fee_numerator, fee_denominator)
    }

    public fun compute_a_in<CoinTypeA, CoinTypeB>(amount_b_out: u128): u128 {
        let (fee_numerator, fee_denominator) = amm_config::get_trade_fee<CoinTypeA, CoinTypeB>();
        let (reserve_a, reserve_b) = amm_swap::get_reserves<CoinTypeA, CoinTypeB>();
        amm_utils::get_amount_in(amount_b_out, reserve_a, reserve_b, fee_numerator, fee_denominator)
    }

    public fun get_amount_out_router2<CoinTypeA, CoinTypeX, CoinTypeB>(amount_a_in: u128): (u128, u128) {
        let (fee_numerator, fee_denominator) = amm_config::get_trade_fee<CoinTypeA, CoinTypeX>();
        let (reserve_a, reserve_x) = amm_swap::get_reserves<CoinTypeA, CoinTypeX>();
        let x_out = amm_utils::get_amount_out(amount_a_in, (reserve_a as u128), (reserve_x as u128), fee_numerator, fee_denominator);
        let (fee_numerator, fee_denominator) = amm_config::get_trade_fee<CoinTypeX, CoinTypeB>();
        let (reserve_x, reserve_b) = amm_swap::get_reserves<CoinTypeX, CoinTypeB>();
        let b_out =  amm_utils::get_amount_out(x_out, (reserve_x as u128), (reserve_b as u128), fee_numerator, fee_denominator);
        (x_out, b_out)
    }

    public fun get_amount_in_router2<CoinTypeA, CoinTypeX, CoinTypeB>(amount_b_out: u128): (u128, u128) {
        let (fee_numerator, fee_denominator) = amm_config::get_trade_fee<CoinTypeX, CoinTypeB>();
        let (reserve_x, reserve_b) = amm_swap::get_reserves<CoinTypeX, CoinTypeB>();
        let x_in = amm_utils::get_amount_in(amount_b_out, reserve_x, reserve_b, fee_numerator, fee_denominator);
        let (fee_numerator, fee_denominator) = amm_config::get_trade_fee<CoinTypeA, CoinTypeX>();
        let (reserve_a, reserve_x) = amm_swap::get_reserves<CoinTypeA, CoinTypeX>();
        let a_in = amm_utils::get_amount_in(x_in, reserve_a, reserve_x, fee_numerator, fee_denominator);
        (x_in, a_in)
    }

    public fun get_amount_out_router3<CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>(amount_a_in: u128): (u128, u128, u128) {
        let (x_out, y_out) = get_amount_out_router2<CoinTypeA, CoinTypeX, CoinTypeY>(amount_a_in);

        let (fee_numerator, fee_denominator) = amm_config::get_trade_fee<CoinTypeY, CoinTypeB>();
        let (reserve_y, reserve_b) = amm_swap::get_reserves<CoinTypeY, CoinTypeB>();
        let b_out =  amm_utils::get_amount_out(y_out, (reserve_y as u128), (reserve_b as u128), fee_numerator, fee_denominator);
        (x_out, y_out, b_out)
    } 

    public fun get_amount_in_router3<CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>(amount_b_out: u128): (u128, u128, u128) {
        let (y_in, x_in) = get_amount_in_router2<CoinTypeX, CoinTypeY, CoinTypeB>(amount_b_out);

        let (fee_numerator, fee_denominator) = amm_config::get_trade_fee<CoinTypeA, CoinTypeX>();
        let (reserve_a, reserve_x) = amm_swap::get_reserves<CoinTypeA, CoinTypeX>();
        let a_in = amm_utils::get_amount_in(x_in, reserve_a, reserve_x, fee_numerator, fee_denominator);
        (y_in, x_in, a_in)
    }


}