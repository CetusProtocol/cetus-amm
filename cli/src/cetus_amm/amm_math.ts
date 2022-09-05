import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache, AptosLocalCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag, SimpleStructTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient, AptosAccount} from "aptos";
import * as Stdlib from "../stdlib";
import * as U256 from "./u256";
export const packageName = "Cetue-AMM";
export const moduleAddress = new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219");
export const moduleName = "amm_math";

export const EDIVIDE_BY_ZERO : U64 = u64("2001");
export const EPARAMETER_INVALID : U64 = u64("2001");

export function min_ (
  x: U128,
  y: U128,
  $c: AptosDataCache,
): U128 {
  let temp$1;
  if (($.copy(x)).lt($.copy(y))) {
    temp$1 = $.copy(x);
  }
  else{
    temp$1 = $.copy(y);
  }
  return temp$1;
}

export function mul_div_u128_ (
  x: U128,
  y: U128,
  z: U128,
  $c: AptosDataCache,
): U256.U256 {
  let x_u256, y_u256, z_u256;
  if (($.copy(z)).eq((u128("0")))) {
    throw $.abortCode(Stdlib.Error.aborted_($.copy(EDIVIDE_BY_ZERO), $c));
  }
  else{
  }
  x_u256 = U256.from_u128_($.copy(x), $c);
  y_u256 = U256.from_u128_($.copy(y), $c);
  z_u256 = U256.from_u128_($.copy(z), $c);
  return U256.div_(U256.mul_($.copy(x_u256), $.copy(y_u256), $c), $.copy(z_u256), $c);
}

export function quote_ (
  amount_a: U128,
  reserve_a: U128,
  reserve_b: U128,
  $c: AptosDataCache,
): U128 {
  let temp$1, amount_y;
  if (!($.copy(amount_a)).gt(u128("0"))) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EPARAMETER_INVALID), $c));
  }
  if (($.copy(reserve_a)).gt(u128("0"))) {
    temp$1 = ($.copy(reserve_b)).gt(u128("0"));
  }
  else{
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EPARAMETER_INVALID), $c));
  }
  amount_y = safe_mul_div_u128_($.copy(amount_a), $.copy(reserve_b), $.copy(reserve_a), $c);
  return $.copy(amount_y);
}

export function safe_compare_mul_u128_ (
  a1: U128,
  b1: U128,
  a2: U128,
  b2: U128,
  $c: AptosDataCache,
): U8 {
  let left, right;
  left = U256.mul_(U256.from_u128_($.copy(a1), $c), U256.from_u128_($.copy(b1), $c), $c);
  right = U256.mul_(U256.from_u128_($.copy(a2), $c), U256.from_u128_($.copy(b2), $c), $c);
  return U256.compare_(left, right, $c);
}

export function safe_mul_div_u128_ (
  x: U128,
  y: U128,
  z: U128,
  $c: AptosDataCache,
): U128 {
  return U256.as_u128_(mul_div_u128_($.copy(x), $.copy(y), $.copy(z), $c), $c);
}

export function sqrt_ (
  y: U128,
  $c: AptosDataCache,
): U128 {
  let temp$1, x, z;
  if (($.copy(y)).gt(u128("3"))) {
    z = $.copy(y);
    x = (($.copy(y)).div(u128("2"))).add(u128("1"));
    while (($.copy(x)).lt($.copy(z))) {
      {
        z = $.copy(x);
        x = ((($.copy(y)).div($.copy(x))).add($.copy(x))).div(u128("2"));
      }

    }return $.copy(z);
  }
  else{
  }
  if (($.copy(y)).gt(u128("0"))) {
    temp$1 = u128("1");
  }
  else{
    temp$1 = u128("0");
  }
  return temp$1;
}

export function loadParsers(repo: AptosParserRepo) {
}
export class App {
  constructor(
    public client: AptosClient,
    public repo: AptosParserRepo,
    public cache: AptosLocalCache,
  ) {
  }
  get moduleAddress() {{ return moduleAddress; }}
  get moduleName() {{ return moduleName; }}
}

