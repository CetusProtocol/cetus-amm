module cetus_amm::amm_math {
    use std::error;

    const ERROR_ROUTER_PARAMETER_INVALID: u64 = 1001;

    public fun quote(amount_a: u128, reserve_a: u128, reserve_b: u128): u128 {
        assert!(amount_a > 0, error::invalid_argument(ERROR_ROUTER_PARAMETER_INVALID));
        assert!(reserve_a > 0 && reserve_b> 0, error::invalid_argument(ERROR_ROUTER_PARAMETER_INVALID));
        let amount_y = amount_a * reserve_b / reserve_a;
        amount_y
    }

    public fun sqrt(y: u128): u128 {
        if (y > 3) {
            let z = y;
            let x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            };
            return z
        };
        if (y > 0) 1 else 0
    }

    public fun min(x: u128, y: u128): u128 {
        if (x < y) x else y
    }
}