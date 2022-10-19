import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache, AptosLocalCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag, SimpleStructTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient, AptosAccount} from "aptos";
import * as Stdlib from "../stdlib";
import * as Amm_config from "./amm_config";
import * as Amm_math from "./amm_math";
import * as Amm_swap from "./amm_swap";
import * as Amm_utils from "./amm_utils";
export const packageName = "Cetue-AMM";
export const moduleAddress = new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219");
export const moduleName = "amm_router";

export const EINVALID_COIN_PAIR : U64 = u64("3003");
export const ELIQUIDITY_ADD_LIQUIDITY_FAILED : U64 = u64("3007");
export const ELIQUIDITY_INSUFFICIENT_A_AMOUNT : U64 = u64("3006");
export const ELIQUIDITY_INSUFFICIENT_B_AMOUNT : U64 = u64("3004");
export const ELIQUIDITY_OVERLIMIT_X_DESIRED : U64 = u64("3005");
export const ESWAP_A_IN_OVER_LIMIT_MAX : U64 = u64("3002");
export const ESWAP_B_OUT_LESSTHAN_EXPECTED : U64 = u64("3001");

export function add_liquidity_ (
  account: HexString,
  amount_a_desired: U128,
  amount_b_desired: U128,
  amount_a_min: U128,
  amount_b_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  let order;
  Amm_config.assert_pause_($c);
  order = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
  if (!!Stdlib.Comparator.is_equal_(order, $c)) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(EINVALID_COIN_PAIR), $c));
  }
  if (Stdlib.Comparator.is_smaller_than_(order, $c)) {
    add_liquidity_internal_(account, $.copy(amount_a_desired), $.copy(amount_b_desired), $.copy(amount_a_min), $.copy(amount_b_min), $c, [$p[0], $p[1]]);
  }
  else{
    add_liquidity_internal_(account, $.copy(amount_b_desired), $.copy(amount_a_desired), $.copy(amount_b_min), $.copy(amount_a_min), $c, [$p[1], $p[0]]);
  }
  return;
}

export function add_liquidity_internal_ (
  account: HexString,
  amount_a_desired: U128,
  amount_b_desired: U128,
  amount_a_min: U128,
  amount_b_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  let amount_a, amount_b, coinA, coinB, liquidity_token, sender;
  [amount_a, amount_b] = calculate_amount_for_liquidity_internal_($.copy(amount_a_desired), $.copy(amount_b_desired), $.copy(amount_a_min), $.copy(amount_b_min), $c, [$p[0], $p[1]]);
  coinA = Stdlib.Coin.withdraw_(account, u64($.copy(amount_a)), $c, [$p[0]]);
  coinB = Stdlib.Coin.withdraw_(account, u64($.copy(amount_b)), $c, [$p[1]]);
  liquidity_token = Amm_swap.mint_and_emit_event_(account, coinA, coinB, $.copy(amount_a_desired), $.copy(amount_b_desired), $.copy(amount_a_min), $.copy(amount_b_min), $c, [$p[0], $p[1]]);
  if (!(Stdlib.Coin.value_(liquidity_token, $c, [new StructTag(new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"), "amm_swap", "PoolLiquidityCoin", [$p[0], $p[1]])])).gt(u64("0"))) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(ELIQUIDITY_ADD_LIQUIDITY_FAILED), $c));
  }
  sender = Stdlib.Signer.address_of_(account, $c);
  if (!Stdlib.Coin.is_account_registered_($.copy(sender), $c, [new StructTag(new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"), "amm_swap", "PoolLiquidityCoin", [$p[0], $p[1]])])) {
    Stdlib.Coin.register_(account, $c, [new StructTag(new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"), "amm_swap", "PoolLiquidityCoin", [$p[0], $p[1]])]);
  }
  else{
  }
  Stdlib.Coin.deposit_($.copy(sender), liquidity_token, $c, [new StructTag(new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"), "amm_swap", "PoolLiquidityCoin", [$p[0], $p[1]])]);
  return;
}

export function calculate_amount_for_liquidity_internal_ (
  amount_a_desired: U128,
  amount_b_desired: U128,
  amount_a_min: U128,
  amount_b_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): [U128, U128] {
  let temp$1, amount_a_optimal, amount_b_optimal, reserve_a, reserve_b;
  [reserve_a, reserve_b] = Amm_swap.get_reserves_($c, [$p[0], $p[1]]);
  if (($.copy(reserve_a)).eq((u128("0")))) {
    temp$1 = ($.copy(reserve_b)).eq((u128("0")));
  }
  else{
    temp$1 = false;
  }
  if (temp$1) {
    return [$.copy(amount_a_desired), $.copy(amount_b_desired)];
  }
  else{
    amount_b_optimal = Amm_math.quote_($.copy(amount_a_desired), $.copy(reserve_a), $.copy(reserve_b), $c);
    if (($.copy(amount_b_optimal)).le($.copy(amount_b_desired))) {
      if (!($.copy(amount_b_optimal)).ge($.copy(amount_b_min))) {
        throw $.abortCode(Stdlib.Error.internal_($.copy(ELIQUIDITY_INSUFFICIENT_B_AMOUNT), $c));
      }
      return [$.copy(amount_a_desired), $.copy(amount_b_optimal)];
    }
    else{
      amount_a_optimal = Amm_math.quote_($.copy(amount_b_desired), $.copy(reserve_b), $.copy(reserve_a), $c);
      if (!($.copy(amount_a_optimal)).le($.copy(amount_a_desired))) {
        throw $.abortCode(Stdlib.Error.internal_($.copy(ELIQUIDITY_OVERLIMIT_X_DESIRED), $c));
      }
      if (!($.copy(amount_a_optimal)).ge($.copy(amount_a_min))) {
        throw $.abortCode(Stdlib.Error.internal_($.copy(ELIQUIDITY_INSUFFICIENT_A_AMOUNT), $c));
      }
      return [$.copy(amount_a_optimal), $.copy(amount_b_desired)];
    }
  }
}

export function compute_a_in_ (
  amount_b_out: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): U128 {
  let fee_denominator, fee_numerator, reserve_a, reserve_b;
  [fee_numerator, fee_denominator] = Amm_config.get_trade_fee_($c);
  [reserve_a, reserve_b] = Amm_swap.get_reserves_($c, [$p[0], $p[1]]);
  return Amm_utils.get_amount_in_($.copy(amount_b_out), $.copy(reserve_a), $.copy(reserve_b), $.copy(fee_numerator), $.copy(fee_denominator), $c);
}

export function compute_b_out_ (
  amount_a_in: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): U128 {
  let fee_denominator, fee_numerator, reserve_a, reserve_b;
  [fee_numerator, fee_denominator] = Amm_config.get_trade_fee_($c);
  [reserve_a, reserve_b] = Amm_swap.get_reserves_($c, [$p[0], $p[1]]);
  return Amm_utils.get_amount_out_($.copy(amount_a_in), u128($.copy(reserve_a)), u128($.copy(reserve_b)), $.copy(fee_numerator), $.copy(fee_denominator), $c);
}

export function get_amount_in_router2_ (
  amount_b_out: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeB>*/
): [U128, U128] {
  let a_in, fee_denominator, fee_numerator, reserve_a, reserve_b, reserve_x, reserve_x__1, x_in;
  [fee_numerator, fee_denominator] = Amm_config.get_trade_fee_($c);
  [reserve_x, reserve_b] = Amm_swap.get_reserves_($c, [$p[1], $p[2]]);
  x_in = Amm_utils.get_amount_in_($.copy(amount_b_out), $.copy(reserve_x), $.copy(reserve_b), $.copy(fee_numerator), $.copy(fee_denominator), $c);
  [reserve_a, reserve_x__1] = Amm_swap.get_reserves_($c, [$p[0], $p[1]]);
  a_in = Amm_utils.get_amount_in_($.copy(x_in), $.copy(reserve_a), $.copy(reserve_x__1), $.copy(fee_numerator), $.copy(fee_denominator), $c);
  return [$.copy(x_in), $.copy(a_in)];
}

export function get_amount_in_router3_ (
  amount_b_out: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>*/
): [U128, U128, U128] {
  let a_in, fee_denominator, fee_numerator, reserve_a, reserve_x, x_in, y_in;
  [y_in, x_in] = get_amount_in_router2_($.copy(amount_b_out), $c, [$p[1], $p[2], $p[3]]);
  [fee_numerator, fee_denominator] = Amm_config.get_trade_fee_($c);
  [reserve_a, reserve_x] = Amm_swap.get_reserves_($c, [$p[0], $p[1]]);
  a_in = Amm_utils.get_amount_in_($.copy(x_in), $.copy(reserve_a), $.copy(reserve_x), $.copy(fee_numerator), $.copy(fee_denominator), $c);
  return [$.copy(y_in), $.copy(x_in), $.copy(a_in)];
}

export function get_amount_out_router2_ (
  amount_a_in: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeB>*/
): [U128, U128] {
  let b_out, fee_denominator, fee_numerator, reserve_a, reserve_b, reserve_x, reserve_x__1, x_out;
  [fee_numerator, fee_denominator] = Amm_config.get_trade_fee_($c);
  [reserve_a, reserve_x] = Amm_swap.get_reserves_($c, [$p[0], $p[1]]);
  x_out = Amm_utils.get_amount_out_($.copy(amount_a_in), u128($.copy(reserve_a)), u128($.copy(reserve_x)), $.copy(fee_numerator), $.copy(fee_denominator), $c);
  [reserve_x__1, reserve_b] = Amm_swap.get_reserves_($c, [$p[1], $p[2]]);
  b_out = Amm_utils.get_amount_out_($.copy(x_out), u128($.copy(reserve_x__1)), u128($.copy(reserve_b)), $.copy(fee_numerator), $.copy(fee_denominator), $c);
  return [$.copy(x_out), $.copy(b_out)];
}

export function get_amount_out_router3_ (
  amount_a_in: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>*/
): [U128, U128, U128] {
  let b_out, fee_denominator, fee_numerator, reserve_b, reserve_y, x_out, y_out;
  [x_out, y_out] = get_amount_out_router2_($.copy(amount_a_in), $c, [$p[0], $p[1], $p[2]]);
  [fee_numerator, fee_denominator] = Amm_config.get_trade_fee_($c);
  [reserve_y, reserve_b] = Amm_swap.get_reserves_($c, [$p[2], $p[3]]);
  b_out = Amm_utils.get_amount_out_($.copy(y_out), u128($.copy(reserve_y)), u128($.copy(reserve_b)), $.copy(fee_numerator), $.copy(fee_denominator), $c);
  return [$.copy(x_out), $.copy(y_out), $.copy(b_out)];
}

export function init_pool_ (
  account: HexString,
  protocol_fee_to: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  let temp$1, temp$2;
  temp$1 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
  if (!!Stdlib.Comparator.is_equal_(temp$1, $c)) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(EINVALID_COIN_PAIR), $c));
  }
  temp$2 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
  if (Stdlib.Comparator.is_smaller_than_(temp$2, $c)) {
    Amm_swap.init_pool_(account, $.copy(protocol_fee_to), $c, [$p[0], $p[1]]);
  }
  else{
    Amm_swap.init_pool_(account, $.copy(protocol_fee_to), $c, [$p[1], $p[0]]);
  }
  return;
}

export function remove_liquidity_ (
  account: HexString,
  liquidity: U128,
  amount_a_min: U128,
  amount_b_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  let order;
  Amm_config.assert_pause_($c);
  order = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
  if (!!Stdlib.Comparator.is_equal_(order, $c)) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(EINVALID_COIN_PAIR), $c));
  }
  if (Stdlib.Comparator.is_smaller_than_(order, $c)) {
    remove_liquidity_internal_(account, $.copy(liquidity), $.copy(amount_a_min), $.copy(amount_b_min), $c, [$p[0], $p[1]]);
  }
  else{
    remove_liquidity_internal_(account, $.copy(liquidity), $.copy(amount_b_min), $.copy(amount_a_min), $c, [$p[1], $p[0]]);
  }
  return;
}

export function remove_liquidity_internal_ (
  account: HexString,
  liquidity: U128,
  amount_a_min: U128,
  amount_b_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  let liquidity_token, sender, token_a, token_b;
  liquidity_token = Stdlib.Coin.withdraw_(account, u64($.copy(liquidity)), $c, [new StructTag(new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"), "amm_swap", "PoolLiquidityCoin", [$p[0], $p[1]])]);
  [token_a, token_b] = Amm_swap.burn_and_emit_event_(account, liquidity_token, $.copy(amount_a_min), $.copy(amount_b_min), $c, [$p[0], $p[1]]);
  if (!(u128(Stdlib.Coin.value_(token_a, $c, [$p[0]]))).ge($.copy(amount_a_min))) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(ELIQUIDITY_INSUFFICIENT_A_AMOUNT), $c));
  }
  if (!(u128(Stdlib.Coin.value_(token_b, $c, [$p[1]]))).ge($.copy(amount_b_min))) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(ELIQUIDITY_INSUFFICIENT_B_AMOUNT), $c));
  }
  sender = Stdlib.Signer.address_of_(account, $c);
  Stdlib.Coin.deposit_($.copy(sender), token_a, $c, [$p[0]]);
  Stdlib.Coin.deposit_($.copy(sender), token_b, $c, [$p[1]]);
  return;
}

export function set_pause_status_ (
  account: HexString,
  pause: boolean,
  $c: AptosDataCache,
): void {
  Amm_config.set_pool_pause_(account, pause, $c);
  return;
}

export function set_pool_fee_config_ (
  account: HexString,
  trade_fee_numerator: U64,
  trade_fee_denominator: U64,
  protocol_fee_numerator: U64,
  protocol_fee_denominator: U64,
  $c: AptosDataCache,
): void {
  Amm_config.set_pool_fee_config_(account, $.copy(trade_fee_numerator), $.copy(trade_fee_denominator), $.copy(protocol_fee_numerator), $.copy(protocol_fee_denominator), $c);
  return;
}

export function swap_coin_for_exact_coin_ (
  account: HexString,
  amount_a_in_max: U128,
  amount_b_out: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  let temp$1, temp$2, a_in, coin_a, coin_a_fee, coin_a_out, coin_b_fee, coin_b_out, sender;
  temp$1 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
  if (!!Stdlib.Comparator.is_equal_(temp$1, $c)) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EINVALID_COIN_PAIR), $c));
  }
  sender = Stdlib.Signer.address_of_(account, $c);
  if (!Stdlib.Coin.is_account_registered_($.copy(sender), $c, [$p[1]])) {
    Stdlib.Coin.register_(account, $c, [$p[1]]);
  }
  else{
  }
  a_in = compute_a_in_($.copy(amount_b_out), $c, [$p[0], $p[1]]);
  if (!($.copy(a_in)).le($.copy(amount_a_in_max))) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(ESWAP_A_IN_OVER_LIMIT_MAX), $c));
  }
  coin_a = Stdlib.Coin.withdraw_(account, u64($.copy(a_in)), $c, [$p[0]]);
  temp$2 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
  if (Stdlib.Comparator.is_smaller_than_(temp$2, $c)) {
    [coin_a_out, coin_b_out, coin_a_fee, coin_b_fee] = Amm_swap.swap_and_emit_event_(account, coin_a, $.copy(amount_b_out), Stdlib.Coin.zero_($c, [$p[1]]), u128("0"), $c, [$p[0], $p[1]]);
  }
  else{
    [coin_b_out, coin_a_out, coin_b_fee, coin_a_fee] = Amm_swap.swap_and_emit_event_(account, Stdlib.Coin.zero_($c, [$p[1]]), u128("0"), coin_a, $.copy(amount_b_out), $c, [$p[1], $p[0]]);
  }
  Stdlib.Coin.destroy_zero_(coin_a_out, $c, [$p[0]]);
  Stdlib.Coin.deposit_($.copy(sender), coin_b_out, $c, [$p[1]]);
  Stdlib.Coin.destroy_zero_(coin_b_fee, $c, [$p[1]]);
  Amm_swap.handle_swap_protocol_fee_($.copy(sender), coin_a_fee, $c, [$p[0], $p[1]]);
  return;
}

export function swap_coin_for_exact_coin_router2_ (
  account: HexString,
  amount_a_in_max: U128,
  amount_b_out: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeB>*/
): void {
  let temp$1, temp$2, a_in, x_in;
  temp$1 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
  if (!!Stdlib.Comparator.is_equal_(temp$1, $c)) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EINVALID_COIN_PAIR), $c));
  }
  temp$2 = Amm_utils.compare_coin_($c, [$p[1], $p[2]]);
  if (!!Stdlib.Comparator.is_equal_(temp$2, $c)) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EINVALID_COIN_PAIR), $c));
  }
  [x_in, a_in] = get_amount_in_router2_($.copy(amount_b_out), $c, [$p[0], $p[1], $p[2]]);
  if (!($.copy(a_in)).le($.copy(amount_a_in_max))) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(ESWAP_A_IN_OVER_LIMIT_MAX), $c));
  }
  swap_coin_for_exact_coin_(account, $.copy(amount_a_in_max), $.copy(x_in), $c, [$p[0], $p[1]]);
  swap_coin_for_exact_coin_(account, $.copy(x_in), $.copy(amount_b_out), $c, [$p[1], $p[2]]);
  return;
}

export function swap_coin_for_exact_coin_router3_ (
  account: HexString,
  amount_a_in_max: U128,
  amount_b_out: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>*/
): void {
  let temp$1, temp$2, temp$3, a_in, x_in, y_in;
  temp$1 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
  if (!!Stdlib.Comparator.is_equal_(temp$1, $c)) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EINVALID_COIN_PAIR), $c));
  }
  temp$2 = Amm_utils.compare_coin_($c, [$p[1], $p[2]]);
  if (!!Stdlib.Comparator.is_equal_(temp$2, $c)) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EINVALID_COIN_PAIR), $c));
  }
  temp$3 = Amm_utils.compare_coin_($c, [$p[2], $p[3]]);
  if (!!Stdlib.Comparator.is_equal_(temp$3, $c)) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EINVALID_COIN_PAIR), $c));
  }
  [y_in, x_in, a_in] = get_amount_in_router3_($.copy(amount_b_out), $c, [$p[0], $p[1], $p[2], $p[3]]);
  if (!($.copy(a_in)).le($.copy(amount_a_in_max))) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(ESWAP_A_IN_OVER_LIMIT_MAX), $c));
  }
  swap_coin_for_exact_coin_(account, $.copy(amount_a_in_max), $.copy(x_in), $c, [$p[0], $p[1]]);
  swap_coin_for_exact_coin_(account, $.copy(x_in), $.copy(y_in), $c, [$p[1], $p[2]]);
  swap_coin_for_exact_coin_(account, $.copy(y_in), $.copy(amount_b_out), $c, [$p[2], $p[3]]);
  return;
}

export function swap_exact_coin_for_coin_ (
  account: HexString,
  amount_a_in: U128,
  amount_b_out_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  let temp$1, temp$2, b_out, coin_a, coin_a_fee, coin_a_out, coin_b_fee, coin_b_out, sender;
  temp$1 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
  if (!!Stdlib.Comparator.is_equal_(temp$1, $c)) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EINVALID_COIN_PAIR), $c));
  }
  sender = Stdlib.Signer.address_of_(account, $c);
  if (!Stdlib.Coin.is_account_registered_($.copy(sender), $c, [$p[1]])) {
    Stdlib.Coin.register_(account, $c, [$p[1]]);
  }
  else{
  }
  b_out = compute_b_out_($.copy(amount_a_in), $c, [$p[0], $p[1]]);
  if (!($.copy(b_out)).ge($.copy(amount_b_out_min))) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(ESWAP_B_OUT_LESSTHAN_EXPECTED), $c));
  }
  coin_a = Stdlib.Coin.withdraw_(account, u64($.copy(amount_a_in)), $c, [$p[0]]);
  temp$2 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
  if (Stdlib.Comparator.is_smaller_than_(temp$2, $c)) {
    [coin_a_out, coin_b_out, coin_a_fee, coin_b_fee] = Amm_swap.swap_and_emit_event_(account, coin_a, $.copy(b_out), Stdlib.Coin.zero_($c, [$p[1]]), u128("0"), $c, [$p[0], $p[1]]);
  }
  else{
    [coin_b_out, coin_a_out, coin_b_fee, coin_a_fee] = Amm_swap.swap_and_emit_event_(account, Stdlib.Coin.zero_($c, [$p[1]]), u128("0"), coin_a, $.copy(b_out), $c, [$p[1], $p[0]]);
  }
  Stdlib.Coin.destroy_zero_(coin_a_out, $c, [$p[0]]);
  Stdlib.Coin.deposit_($.copy(sender), coin_b_out, $c, [$p[1]]);
  Stdlib.Coin.destroy_zero_(coin_b_fee, $c, [$p[1]]);
  Amm_swap.handle_swap_protocol_fee_($.copy(sender), coin_a_fee, $c, [$p[0], $p[1]]);
  return;
}

export function swap_exact_coin_for_coin_router2_ (
  account: HexString,
  amount_a_in: U128,
  amount_b_out_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeB>*/
): void {
  let temp$1, temp$2, b_out, x_out;
  temp$1 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
  if (!!Stdlib.Comparator.is_equal_(temp$1, $c)) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EINVALID_COIN_PAIR), $c));
  }
  temp$2 = Amm_utils.compare_coin_($c, [$p[1], $p[2]]);
  if (!!Stdlib.Comparator.is_equal_(temp$2, $c)) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EINVALID_COIN_PAIR), $c));
  }
  [x_out, b_out] = get_amount_out_router2_($.copy(amount_a_in), $c, [$p[0], $p[1], $p[2]]);
  if (!($.copy(b_out)).ge($.copy(amount_b_out_min))) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(ESWAP_B_OUT_LESSTHAN_EXPECTED), $c));
  }
  swap_exact_coin_for_coin_(account, $.copy(amount_a_in), $.copy(x_out), $c, [$p[0], $p[1]]);
  swap_exact_coin_for_coin_(account, $.copy(x_out), $.copy(amount_b_out_min), $c, [$p[1], $p[2]]);
  return;
}

export function swap_exact_coin_for_coin_router3_ (
  account: HexString,
  amount_a_in: U128,
  amount_b_out_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>*/
): void {
  let temp$1, temp$2, temp$3, b_out, x_out, y_out;
  temp$1 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
  if (!!Stdlib.Comparator.is_equal_(temp$1, $c)) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EINVALID_COIN_PAIR), $c));
  }
  temp$2 = Amm_utils.compare_coin_($c, [$p[1], $p[2]]);
  if (!!Stdlib.Comparator.is_equal_(temp$2, $c)) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EINVALID_COIN_PAIR), $c));
  }
  temp$3 = Amm_utils.compare_coin_($c, [$p[2], $p[3]]);
  if (!!Stdlib.Comparator.is_equal_(temp$3, $c)) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(EINVALID_COIN_PAIR), $c));
  }
  [x_out, y_out, b_out] = get_amount_out_router3_($.copy(amount_a_in), $c, [$p[0], $p[1], $p[2], $p[3]]);
  if (!($.copy(b_out)).ge($.copy(amount_b_out_min))) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(ESWAP_B_OUT_LESSTHAN_EXPECTED), $c));
  }
  swap_exact_coin_for_coin_(account, $.copy(amount_a_in), $.copy(x_out), $c, [$p[0], $p[1]]);
  swap_exact_coin_for_coin_(account, $.copy(x_out), $.copy(y_out), $c, [$p[1], $p[2]]);
  swap_exact_coin_for_coin_(account, $.copy(y_out), $.copy(amount_b_out_min), $c, [$p[2], $p[3]]);
  return;
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

