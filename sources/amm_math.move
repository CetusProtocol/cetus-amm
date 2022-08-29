module cetus_amm::amm_math {
    use cetus_amm::u256::{Self, U256};
    use std::error;

    //
    // Errors
    //
    const EMATH_DIVIDE_BY_ZERO: u64 = 2001;

    public fun safe_compare_mul_u128(a1: u128, b1: u128, a2: u128, b2: u128): u8 {
        let left = u256::mul(u256::from_u128(a1), u256::from_u128(b1));
        let right = u256::mul(u256::from_u128(a2), u256::from_u128(b2));
        u256::compare(left, right)
    }

    public fun safe_mul_div_u128(x: u128, y: u128, z: u128): u128 {
        u256::as_u128(mul_div_u128(x, y, z))
    }

    public fun mul_div_u128(x: u128, y: u128, z: u128): U256 {
        if (z == 0) {
            abort error::invalid_argument(EMATH_DIVIDE_BY_ZERO)
        };

        let x_u256 = u256::from_u128(x);
        let y_u256 = u256::from_u128(y);
        let z_u256 = u256::from_u128(z);
        u256::div(u256::mul(x_u256, y_u256), z_u256)
    }
}