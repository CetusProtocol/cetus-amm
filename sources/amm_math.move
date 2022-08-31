module cetus_amm::amm_math {
    use cetus_amm::u256::{Self, U256};
    use std::error;

    //
    // Errors
    //
    const EDIVIDE_BY_ZERO: u64 = 2001;
    const EPARAMETER_INVALID: u64 = 2001;

    public fun safe_compare_mul_u128(a1: u128, b1: u128, a2: u128, b2: u128): u8 {
        let left = u256::mul(u256::from_u128(a1), u256::from_u128(b1));
        let right = u256::mul(u256::from_u128(a2), u256::from_u128(b2));
        u256::compare(&left, &right)
    }

    public fun safe_mul_div_u128(x: u128, y: u128, z: u128): u128 {
        u256::as_u128(mul_div_u128(x, y, z))
    }

    public fun mul_div_u128(x: u128, y: u128, z: u128): U256 {
        if (z == 0) {
            abort error::aborted(EDIVIDE_BY_ZERO)
        };

        let x_u256 = u256::from_u128(x);
        let y_u256 = u256::from_u128(y);
        let z_u256 = u256::from_u128(z);
        u256::div(u256::mul(x_u256, y_u256), z_u256)
    }

    public fun quote(amount_a: u128, reserve_a: u128, reserve_b: u128): u128 {
        assert!(amount_a > 0, error::invalid_argument(EPARAMETER_INVALID));
        assert!(reserve_a > 0 && reserve_b> 0, error::invalid_argument(EPARAMETER_INVALID));
        let amount_y = safe_mul_div_u128(amount_a,reserve_b,reserve_a);
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