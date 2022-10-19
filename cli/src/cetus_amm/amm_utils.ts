import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache, AptosLocalCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag, SimpleStructTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient, AptosAccount} from "aptos";
import * as Stdlib from "../stdlib";
import * as Amm_math from "./amm_math";
export const packageName = "Cetue-AMM";
export const moduleAddress = new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219");
export const moduleName = "amm_utils";

export const EPARAMETER_INVALID : U64 = u64("5002");
export const ESWAP_COIN_NOT_EXISTS : U64 = u64("5001");

export function assert_is_coin_ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): boolean {
  if (!Stdlib.Coin.is_coin_initialized_($c, [$p[0]])) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(ESWAP_COIN_NOT_EXISTS), $c));
  }
  return true;
}

export function compare_coin_ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): Stdlib.Comparator.Result {
  let type_info_a, type_info_b;
  type_info_a = Stdlib.Type_info.type_of_($c, [$p[0]]);
  type_info_b = Stdlib.Type_info.type_of_($c, [$p[1]]);
  return Stdlib.Comparator.compare_(type_info_a, type_info_b, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", [])]);
}

export function get_amount_in_ (
  amount_out: U128,
  reserve_in: U128,
  reserve_out: U128,
  fee_numerator: U64,
  fee_denumerator: U64,
  $c: AptosDataCache,
): U128 {
  let temp$1, temp$2, denominator;
  if (!($.copy(amount_out)).gt(u128("0"))) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(EPARAMETER_INVALID), $c));
  }
  if (($.copy(reserve_in)).gt(u128("0"))) {
    temp$1 = ($.copy(reserve_out)).gt(u128("0"));
  }
  else{
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(EPARAMETER_INVALID), $c));
  }
  if (($.copy(fee_denumerator)).gt(u64("0"))) {
    temp$2 = ($.copy(fee_numerator)).gt(u64("0"));
  }
  else{
    temp$2 = false;
  }
  if (!temp$2) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(EPARAMETER_INVALID), $c));
  }
  if (!($.copy(fee_denumerator)).gt($.copy(fee_numerator))) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(EPARAMETER_INVALID), $c));
  }
  if (!($.copy(reserve_out)).gt($.copy(amount_out))) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(EPARAMETER_INVALID), $c));
  }
  denominator = (($.copy(reserve_out)).sub($.copy(amount_out))).mul(u128(($.copy(fee_denumerator)).sub($.copy(fee_numerator))));
  return (Amm_math.safe_mul_div_u128_(($.copy(amount_out)).mul(u128($.copy(fee_denumerator))), $.copy(reserve_in), $.copy(denominator), $c)).add(u128("1"));
}

export function get_amount_out_ (
  amount_in: U128,
  reserve_in: U128,
  reserve_out: U128,
  fee_numerator: U64,
  fee_denumerator: U64,
  $c: AptosDataCache,
): U128 {
  let temp$1, temp$2, amount_in_with_fee, denominator;
  if (!($.copy(amount_in)).gt(u128("0"))) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(EPARAMETER_INVALID), $c));
  }
  if (($.copy(reserve_in)).gt(u128("0"))) {
    temp$1 = ($.copy(reserve_out)).gt(u128("0"));
  }
  else{
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(EPARAMETER_INVALID), $c));
  }
  if (($.copy(fee_denumerator)).gt(u64("0"))) {
    temp$2 = ($.copy(fee_numerator)).gt(u64("0"));
  }
  else{
    temp$2 = false;
  }
  if (!temp$2) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(EPARAMETER_INVALID), $c));
  }
  if (!($.copy(fee_denumerator)).gt($.copy(fee_numerator))) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(EPARAMETER_INVALID), $c));
  }
  amount_in_with_fee = ($.copy(amount_in)).mul(u128(($.copy(fee_denumerator)).sub($.copy(fee_numerator))));
  denominator = (($.copy(reserve_in)).mul(u128($.copy(fee_denumerator)))).add($.copy(amount_in_with_fee));
  return Amm_math.safe_mul_div_u128_($.copy(amount_in_with_fee), $.copy(reserve_out), $.copy(denominator), $c);
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

