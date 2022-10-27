module cetus_amm::amm_math {
    use cetus_amm::u256::{Self, U256};
    use std::error;

    //
    // Errors
    //
    const EDIVIDE_BY_ZERO: u64 = 2001;
    const EPARAMETER_INVALID: u64 = 2001;
    const U128_MAX:u128 = 340282366920938463463374607431768211455;
    const U64_MAX: u128 = 18446744073709551615;

    public fun safe_compare_mul_u128(a1: u128, b1: u128, a2: u128, b2: u128): u8 {
        let left = u256::mul(u256::from_u128(a1), u256::from_u128(b1));
        let right = u256::mul(u256::from_u128(a2), u256::from_u128(b2));
        u256::compare(&left, &right)
    }

    public fun safe_mul_div_u128(x: u128, y: u128, z: u128): u128 {
        assert!(z != 0, EDIVIDE_BY_ZERO);
        assert!(x <= U64_MAX, EPARAMETER_INVALID);
        assert!(y <= U64_MAX, EPARAMETER_INVALID);
        x * y / z
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
        let amount_b = safe_mul_div_u128(amount_a,reserve_b,reserve_a);
        amount_b
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

    #[test]
    public entry fun test_safe_mul_div_u128() {
        let x: u128 = 9446744073709551615;
        let y: u128 = 1009855555;
        let z: u128 = 3979;
        let _r_expected:u128 = 2397548876476230247541334;
        let r = Self::safe_mul_div_u128(x, y, z);
        assert!(r == _r_expected, 3001);
    }

    #[test]
    public entry fun test_sqrt_by_max_u128() {
        let _r_expected:u128 = 18446744073709551615;
        let r = Self::sqrt(U128_MAX);
        assert!(r == _r_expected, 3004);
    }
}