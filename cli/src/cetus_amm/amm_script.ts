import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache, AptosLocalCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag, SimpleStructTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient, AptosAccount} from "aptos";
import * as Amm_router from "./amm_router";
export const packageName = "Cetue-AMM";
export const moduleAddress = new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219");
export const moduleName = "amm_script";


export function add_liquidity_ (
  account: HexString,
  amount_a_desired: U128,
  amount_b_desired: U128,
  amount_a_min: U128,
  amount_b_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  Amm_router.add_liquidity_(account, $.copy(amount_a_desired), $.copy(amount_b_desired), $.copy(amount_a_min), $.copy(amount_b_min), $c, [$p[0], $p[1]]);
  return;
}


export function buildPayload_add_liquidity (
  amount_a_desired: U128,
  amount_b_desired: U128,
  amount_a_min: U128,
  amount_b_min: U128,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"),
    "amm_script",
    "add_liquidity",
    typeParamStrings,
    [
      amount_a_desired,
      amount_b_desired,
      amount_a_min,
      amount_b_min,
    ]
  );

}

export function init_pool_ (
  account: HexString,
  protocol_fee_to: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  Amm_router.init_pool_(account, $.copy(protocol_fee_to), $c, [$p[0], $p[1]]);
  return;
}


export function buildPayload_init_pool (
  protocol_fee_to: HexString,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"),
    "amm_script",
    "init_pool",
    typeParamStrings,
    [
      protocol_fee_to,
    ]
  );

}

export function remove_liquidity_ (
  account: HexString,
  liquidity: U128,
  amount_a_min: U128,
  amount_b_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  Amm_router.remove_liquidity_(account, $.copy(liquidity), $.copy(amount_a_min), $.copy(amount_b_min), $c, [$p[0], $p[1]]);
  return;
}


export function buildPayload_remove_liquidity (
  liquidity: U128,
  amount_a_min: U128,
  amount_b_min: U128,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"),
    "amm_script",
    "remove_liquidity",
    typeParamStrings,
    [
      liquidity,
      amount_a_min,
      amount_b_min,
    ]
  );

}

export function set_pause_status_ (
  account: HexString,
  pause: boolean,
  $c: AptosDataCache,
): void {
  Amm_router.set_pause_status_(account, pause, $c);
  return;
}


export function buildPayload_set_pause_status (
  pause: boolean,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"),
    "amm_script",
    "set_pause_status",
    typeParamStrings,
    [
      pause,
    ]
  );

}

export function set_pool_fee_config_ (
  account: HexString,
  trade_fee_numerator: U64,
  trade_fee_denominator: U64,
  protocol_fee_numerator: U64,
  protocol_fee_denominator: U64,
  $c: AptosDataCache,
): void {
  Amm_router.set_pool_fee_config_(account, $.copy(trade_fee_numerator), $.copy(trade_fee_denominator), $.copy(protocol_fee_numerator), $.copy(protocol_fee_denominator), $c);
  return;
}


export function buildPayload_set_pool_fee_config (
  trade_fee_numerator: U64,
  trade_fee_denominator: U64,
  protocol_fee_numerator: U64,
  protocol_fee_denominator: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"),
    "amm_script",
    "set_pool_fee_config",
    typeParamStrings,
    [
      trade_fee_numerator,
      trade_fee_denominator,
      protocol_fee_numerator,
      protocol_fee_denominator,
    ]
  );

}

export function swap_coin_for_exact_coin_ (
  account: HexString,
  amount_a_in_max: U128,
  amount_b_out: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  Amm_router.swap_coin_for_exact_coin_(account, $.copy(amount_a_in_max), $.copy(amount_b_out), $c, [$p[0], $p[1]]);
  return;
}


export function buildPayload_swap_coin_for_exact_coin (
  amount_a_in_max: U128,
  amount_b_out: U128,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"),
    "amm_script",
    "swap_coin_for_exact_coin",
    typeParamStrings,
    [
      amount_a_in_max,
      amount_b_out,
    ]
  );

}

export function swap_coin_for_exact_coin_router2_ (
  account: HexString,
  amount_a_in_max: U128,
  amount_b_out: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeB>*/
): void {
  Amm_router.swap_coin_for_exact_coin_router2_(account, $.copy(amount_a_in_max), $.copy(amount_b_out), $c, [$p[0], $p[1], $p[2]]);
  return;
}


export function buildPayload_swap_coin_for_exact_coin_router2 (
  amount_a_in_max: U128,
  amount_b_out: U128,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeB>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"),
    "amm_script",
    "swap_coin_for_exact_coin_router2",
    typeParamStrings,
    [
      amount_a_in_max,
      amount_b_out,
    ]
  );

}

export function swap_coin_for_exact_coin_router3_ (
  account: HexString,
  amount_a_in_max: U128,
  amount_b_out: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>*/
): void {
  Amm_router.swap_coin_for_exact_coin_router3_(account, $.copy(amount_a_in_max), $.copy(amount_b_out), $c, [$p[0], $p[1], $p[2], $p[3]]);
  return;
}


export function buildPayload_swap_coin_for_exact_coin_router3 (
  amount_a_in_max: U128,
  amount_b_out: U128,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"),
    "amm_script",
    "swap_coin_for_exact_coin_router3",
    typeParamStrings,
    [
      amount_a_in_max,
      amount_b_out,
    ]
  );

}

export function swap_exact_coin_for_coin_ (
  account: HexString,
  amount_a_in: U128,
  amount_b_out_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  Amm_router.swap_exact_coin_for_coin_(account, $.copy(amount_a_in), $.copy(amount_b_out_min), $c, [$p[0], $p[1]]);
  return;
}


export function buildPayload_swap_exact_coin_for_coin (
  amount_a_in: U128,
  amount_b_out_min: U128,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"),
    "amm_script",
    "swap_exact_coin_for_coin",
    typeParamStrings,
    [
      amount_a_in,
      amount_b_out_min,
    ]
  );

}

export function swap_exact_coin_for_coin_router2_ (
  account: HexString,
  amount_a_in: U128,
  amount_b_out_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeB>*/
): void {
  Amm_router.swap_exact_coin_for_coin_router2_(account, $.copy(amount_a_in), $.copy(amount_b_out_min), $c, [$p[0], $p[1], $p[2]]);
  return;
}


export function buildPayload_swap_exact_coin_for_coin_router2 (
  amount_a_in: U128,
  amount_b_out_min: U128,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeB>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"),
    "amm_script",
    "swap_exact_coin_for_coin_router2",
    typeParamStrings,
    [
      amount_a_in,
      amount_b_out_min,
    ]
  );

}

export function swap_exact_coin_for_coin_router3_ (
  account: HexString,
  amount_a_in: U128,
  amount_b_out_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>*/
): void {
  Amm_router.swap_exact_coin_for_coin_router3_(account, $.copy(amount_a_in), $.copy(amount_b_out_min), $c, [$p[0], $p[1], $p[2], $p[3]]);
  return;
}


export function buildPayload_swap_exact_coin_for_coin_router3 (
  amount_a_in: U128,
  amount_b_out_min: U128,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"),
    "amm_script",
    "swap_exact_coin_for_coin_router3",
    typeParamStrings,
    [
      amount_a_in,
      amount_b_out_min,
    ]
  );

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
  payload_add_liquidity(
    amount_a_desired: U128,
    amount_b_desired: U128,
    amount_a_min: U128,
    amount_b_min: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
  ) {
    return buildPayload_add_liquidity(amount_a_desired, amount_b_desired, amount_a_min, amount_b_min, $p);
  }
  async add_liquidity(
    _account: AptosAccount,
    amount_a_desired: U128,
    amount_b_desired: U128,
    amount_a_min: U128,
    amount_b_min: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
    _maxGas = 1000,
  ) {
    const payload = buildPayload_add_liquidity(amount_a_desired, amount_b_desired, amount_a_min, amount_b_min, $p);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
  payload_init_pool(
    protocol_fee_to: HexString,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
  ) {
    return buildPayload_init_pool(protocol_fee_to, $p);
  }
  async init_pool(
    _account: AptosAccount,
    protocol_fee_to: HexString,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
    _maxGas = 1000,
  ) {
    const payload = buildPayload_init_pool(protocol_fee_to, $p);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
  payload_remove_liquidity(
    liquidity: U128,
    amount_a_min: U128,
    amount_b_min: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
  ) {
    return buildPayload_remove_liquidity(liquidity, amount_a_min, amount_b_min, $p);
  }
  async remove_liquidity(
    _account: AptosAccount,
    liquidity: U128,
    amount_a_min: U128,
    amount_b_min: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
    _maxGas = 1000,
  ) {
    const payload = buildPayload_remove_liquidity(liquidity, amount_a_min, amount_b_min, $p);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
  payload_set_pause_status(
    pause: boolean,
  ) {
    return buildPayload_set_pause_status(pause);
  }
  async set_pause_status(
    _account: AptosAccount,
    pause: boolean,
    _maxGas = 1000,
  ) {
    const payload = buildPayload_set_pause_status(pause);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
  payload_set_pool_fee_config(
    trade_fee_numerator: U64,
    trade_fee_denominator: U64,
    protocol_fee_numerator: U64,
    protocol_fee_denominator: U64,
  ) {
    return buildPayload_set_pool_fee_config(trade_fee_numerator, trade_fee_denominator, protocol_fee_numerator, protocol_fee_denominator);
  }
  async set_pool_fee_config(
    _account: AptosAccount,
    trade_fee_numerator: U64,
    trade_fee_denominator: U64,
    protocol_fee_numerator: U64,
    protocol_fee_denominator: U64,
    _maxGas = 1000,
  ) {
    const payload = buildPayload_set_pool_fee_config(trade_fee_numerator, trade_fee_denominator, protocol_fee_numerator, protocol_fee_denominator);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
  payload_swap_coin_for_exact_coin(
    amount_a_in_max: U128,
    amount_b_out: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
  ) {
    return buildPayload_swap_coin_for_exact_coin(amount_a_in_max, amount_b_out, $p);
  }
  async swap_coin_for_exact_coin(
    _account: AptosAccount,
    amount_a_in_max: U128,
    amount_b_out: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
    _maxGas = 1000,
  ) {
    const payload = buildPayload_swap_coin_for_exact_coin(amount_a_in_max, amount_b_out, $p);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
  payload_swap_coin_for_exact_coin_router2(
    amount_a_in_max: U128,
    amount_b_out: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeB>*/
  ) {
    return buildPayload_swap_coin_for_exact_coin_router2(amount_a_in_max, amount_b_out, $p);
  }
  async swap_coin_for_exact_coin_router2(
    _account: AptosAccount,
    amount_a_in_max: U128,
    amount_b_out: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeB>*/
    _maxGas = 1000,
  ) {
    const payload = buildPayload_swap_coin_for_exact_coin_router2(amount_a_in_max, amount_b_out, $p);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
  payload_swap_coin_for_exact_coin_router3(
    amount_a_in_max: U128,
    amount_b_out: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>*/
  ) {
    return buildPayload_swap_coin_for_exact_coin_router3(amount_a_in_max, amount_b_out, $p);
  }
  async swap_coin_for_exact_coin_router3(
    _account: AptosAccount,
    amount_a_in_max: U128,
    amount_b_out: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>*/
    _maxGas = 1000,
  ) {
    const payload = buildPayload_swap_coin_for_exact_coin_router3(amount_a_in_max, amount_b_out, $p);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
  payload_swap_exact_coin_for_coin(
    amount_a_in: U128,
    amount_b_out_min: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
  ) {
    return buildPayload_swap_exact_coin_for_coin(amount_a_in, amount_b_out_min, $p);
  }
  async swap_exact_coin_for_coin(
    _account: AptosAccount,
    amount_a_in: U128,
    amount_b_out_min: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
    _maxGas = 1000,
  ) {
    const payload = buildPayload_swap_exact_coin_for_coin(amount_a_in, amount_b_out_min, $p);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
  payload_swap_exact_coin_for_coin_router2(
    amount_a_in: U128,
    amount_b_out_min: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeB>*/
  ) {
    return buildPayload_swap_exact_coin_for_coin_router2(amount_a_in, amount_b_out_min, $p);
  }
  async swap_exact_coin_for_coin_router2(
    _account: AptosAccount,
    amount_a_in: U128,
    amount_b_out_min: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeB>*/
    _maxGas = 1000,
  ) {
    const payload = buildPayload_swap_exact_coin_for_coin_router2(amount_a_in, amount_b_out_min, $p);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
  payload_swap_exact_coin_for_coin_router3(
    amount_a_in: U128,
    amount_b_out_min: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>*/
  ) {
    return buildPayload_swap_exact_coin_for_coin_router3(amount_a_in, amount_b_out_min, $p);
  }
  async swap_exact_coin_for_coin_router3(
    _account: AptosAccount,
    amount_a_in: U128,
    amount_b_out_min: U128,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeX, CoinTypeY, CoinTypeB>*/
    _maxGas = 1000,
  ) {
    const payload = buildPayload_swap_exact_coin_for_coin_router3(amount_a_in, amount_b_out_min, $p);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
}

