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
import * as Amm_utils from "./amm_utils";
export const packageName = "Cetue-AMM";
export const moduleAddress = new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219");
export const moduleName = "amm_swap";

export const EACCOUNT_NOT_EXISTED : U64 = u64("4002");
export const ECOIN_INSUFFICIENT : U64 = u64("4005");
export const EINVALID_COIN_PAIR : U64 = u64("4001");
export const ELIQUIDITY_INSUFFICIENT_MINTED : U64 = u64("4003");
export const ELIQUIDITY_SWAP_BURN_CALC_INVALID : U64 = u64("4004");
export const EQUAL : U8 = u8("0");
export const ESWAPOUT_CALC_INVALID : U64 = u64("4006");
export const GREATER_THAN : U8 = u8("2");
export const LESS_THAN : U8 = u8("1");
export const MINIMUM_LIQUIDITY : U128 = u128("1000");


export class AddLiquidityEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "AddLiquidityEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "liquidity", typeTag: AtomicTypeTag.U128 },
  { name: "account", typeTag: AtomicTypeTag.Address },
  { name: "coin_a_info", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) },
  { name: "coin_b_info", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) },
  { name: "amount_a_desired", typeTag: AtomicTypeTag.U128 },
  { name: "amount_b_desired", typeTag: AtomicTypeTag.U128 },
  { name: "amount_a_min", typeTag: AtomicTypeTag.U128 },
  { name: "amount_b_min", typeTag: AtomicTypeTag.U128 }];

  liquidity: U128;
  account: HexString;
  coin_a_info: Stdlib.Type_info.TypeInfo;
  coin_b_info: Stdlib.Type_info.TypeInfo;
  amount_a_desired: U128;
  amount_b_desired: U128;
  amount_a_min: U128;
  amount_b_min: U128;

  constructor(proto: any, public typeTag: TypeTag) {
    this.liquidity = proto['liquidity'] as U128;
    this.account = proto['account'] as HexString;
    this.coin_a_info = proto['coin_a_info'] as Stdlib.Type_info.TypeInfo;
    this.coin_b_info = proto['coin_b_info'] as Stdlib.Type_info.TypeInfo;
    this.amount_a_desired = proto['amount_a_desired'] as U128;
    this.amount_b_desired = proto['amount_b_desired'] as U128;
    this.amount_a_min = proto['amount_a_min'] as U128;
    this.amount_b_min = proto['amount_b_min'] as U128;
  }

  static AddLiquidityEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : AddLiquidityEvent {
    const proto = $.parseStructProto(data, typeTag, repo, AddLiquidityEvent);
    return new AddLiquidityEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "AddLiquidityEvent", []);
  }
  async loadFullState(app: $.AppType) {
    await this.coin_a_info.loadFullState(app);
    await this.coin_b_info.loadFullState(app);
    this.__app = app;
  }

}

export class InitPoolEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "InitPoolEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "coin_a_info", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) },
  { name: "coin_b_info", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) },
  { name: "account", typeTag: AtomicTypeTag.Address },
  { name: "protocol_fee_to", typeTag: AtomicTypeTag.Address }];

  coin_a_info: Stdlib.Type_info.TypeInfo;
  coin_b_info: Stdlib.Type_info.TypeInfo;
  account: HexString;
  protocol_fee_to: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.coin_a_info = proto['coin_a_info'] as Stdlib.Type_info.TypeInfo;
    this.coin_b_info = proto['coin_b_info'] as Stdlib.Type_info.TypeInfo;
    this.account = proto['account'] as HexString;
    this.protocol_fee_to = proto['protocol_fee_to'] as HexString;
  }

  static InitPoolEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : InitPoolEvent {
    const proto = $.parseStructProto(data, typeTag, repo, InitPoolEvent);
    return new InitPoolEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "InitPoolEvent", []);
  }
  async loadFullState(app: $.AppType) {
    await this.coin_a_info.loadFullState(app);
    await this.coin_b_info.loadFullState(app);
    this.__app = app;
  }

}

export class Pool 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "Pool";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinTypeA", isPhantom: true },
    { name: "CoinTypeB", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "coin_a", typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [new $.TypeParamIdx(0)]) },
  { name: "coin_b", typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [new $.TypeParamIdx(1)]) },
  { name: "mint_capability", typeTag: new StructTag(new HexString("0x1"), "coin", "MintCapability", [new StructTag(new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"), "amm_swap", "PoolLiquidityCoin", [new $.TypeParamIdx(0), new $.TypeParamIdx(1)])]) },
  { name: "burn_capability", typeTag: new StructTag(new HexString("0x1"), "coin", "BurnCapability", [new StructTag(new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"), "amm_swap", "PoolLiquidityCoin", [new $.TypeParamIdx(0), new $.TypeParamIdx(1)])]) },
  { name: "locked_liquidity", typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [new StructTag(new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"), "amm_swap", "PoolLiquidityCoin", [new $.TypeParamIdx(0), new $.TypeParamIdx(1)])]) },
  { name: "protocol_fee_to", typeTag: AtomicTypeTag.Address }];

  coin_a: Stdlib.Coin.Coin;
  coin_b: Stdlib.Coin.Coin;
  mint_capability: Stdlib.Coin.MintCapability;
  burn_capability: Stdlib.Coin.BurnCapability;
  locked_liquidity: Stdlib.Coin.Coin;
  protocol_fee_to: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.coin_a = proto['coin_a'] as Stdlib.Coin.Coin;
    this.coin_b = proto['coin_b'] as Stdlib.Coin.Coin;
    this.mint_capability = proto['mint_capability'] as Stdlib.Coin.MintCapability;
    this.burn_capability = proto['burn_capability'] as Stdlib.Coin.BurnCapability;
    this.locked_liquidity = proto['locked_liquidity'] as Stdlib.Coin.Coin;
    this.protocol_fee_to = proto['protocol_fee_to'] as HexString;
  }

  static PoolParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Pool {
    const proto = $.parseStructProto(data, typeTag, repo, Pool);
    return new Pool(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Pool, typeParams);
    return result as unknown as Pool;
  }
  static async loadByApp(app: $.AppType, address: HexString, typeParams: TypeTag[]) {
    const result = await app.repo.loadResource(app.client, address, Pool, typeParams);
    await result.loadFullState(app)
    return result as unknown as Pool;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "Pool", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.coin_a.loadFullState(app);
    await this.coin_b.loadFullState(app);
    await this.mint_capability.loadFullState(app);
    await this.burn_capability.loadFullState(app);
    await this.locked_liquidity.loadFullState(app);
    this.__app = app;
  }

}

export class PoolLiquidityCoin 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "PoolLiquidityCoin";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinTypeA", isPhantom: true },
    { name: "CoinTypeB", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static PoolLiquidityCoinParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : PoolLiquidityCoin {
    const proto = $.parseStructProto(data, typeTag, repo, PoolLiquidityCoin);
    return new PoolLiquidityCoin(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "PoolLiquidityCoin", $p);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }

}

export class PoolSwapEventHandle 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "PoolSwapEventHandle";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "init_pool_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"), "amm_swap", "InitPoolEvent", [])]) },
  { name: "add_liquidity_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"), "amm_swap", "AddLiquidityEvent", [])]) },
  { name: "remove_liquidity_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"), "amm_swap", "RemoveLiquidityEvent", [])]) },
  { name: "swap_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"), "amm_swap", "SwapEvent", [])]) },
  { name: "swap_fee_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219"), "amm_swap", "SwapFeeEvent", [])]) }];

  init_pool_events: Stdlib.Event.EventHandle;
  add_liquidity_events: Stdlib.Event.EventHandle;
  remove_liquidity_events: Stdlib.Event.EventHandle;
  swap_events: Stdlib.Event.EventHandle;
  swap_fee_events: Stdlib.Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.init_pool_events = proto['init_pool_events'] as Stdlib.Event.EventHandle;
    this.add_liquidity_events = proto['add_liquidity_events'] as Stdlib.Event.EventHandle;
    this.remove_liquidity_events = proto['remove_liquidity_events'] as Stdlib.Event.EventHandle;
    this.swap_events = proto['swap_events'] as Stdlib.Event.EventHandle;
    this.swap_fee_events = proto['swap_fee_events'] as Stdlib.Event.EventHandle;
  }

  static PoolSwapEventHandleParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : PoolSwapEventHandle {
    const proto = $.parseStructProto(data, typeTag, repo, PoolSwapEventHandle);
    return new PoolSwapEventHandle(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, PoolSwapEventHandle, typeParams);
    return result as unknown as PoolSwapEventHandle;
  }
  static async loadByApp(app: $.AppType, address: HexString, typeParams: TypeTag[]) {
    const result = await app.repo.loadResource(app.client, address, PoolSwapEventHandle, typeParams);
    await result.loadFullState(app)
    return result as unknown as PoolSwapEventHandle;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "PoolSwapEventHandle", []);
  }
  async loadFullState(app: $.AppType) {
    await this.init_pool_events.loadFullState(app);
    await this.add_liquidity_events.loadFullState(app);
    await this.remove_liquidity_events.loadFullState(app);
    await this.swap_events.loadFullState(app);
    await this.swap_fee_events.loadFullState(app);
    this.__app = app;
  }

}

export class RemoveLiquidityEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "RemoveLiquidityEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "liquidity", typeTag: AtomicTypeTag.U128 },
  { name: "account", typeTag: AtomicTypeTag.Address },
  { name: "coin_a_info", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) },
  { name: "coin_b_info", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) },
  { name: "amount_a_min", typeTag: AtomicTypeTag.U128 },
  { name: "amount_b_min", typeTag: AtomicTypeTag.U128 }];

  liquidity: U128;
  account: HexString;
  coin_a_info: Stdlib.Type_info.TypeInfo;
  coin_b_info: Stdlib.Type_info.TypeInfo;
  amount_a_min: U128;
  amount_b_min: U128;

  constructor(proto: any, public typeTag: TypeTag) {
    this.liquidity = proto['liquidity'] as U128;
    this.account = proto['account'] as HexString;
    this.coin_a_info = proto['coin_a_info'] as Stdlib.Type_info.TypeInfo;
    this.coin_b_info = proto['coin_b_info'] as Stdlib.Type_info.TypeInfo;
    this.amount_a_min = proto['amount_a_min'] as U128;
    this.amount_b_min = proto['amount_b_min'] as U128;
  }

  static RemoveLiquidityEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : RemoveLiquidityEvent {
    const proto = $.parseStructProto(data, typeTag, repo, RemoveLiquidityEvent);
    return new RemoveLiquidityEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "RemoveLiquidityEvent", []);
  }
  async loadFullState(app: $.AppType) {
    await this.coin_a_info.loadFullState(app);
    await this.coin_b_info.loadFullState(app);
    this.__app = app;
  }

}

export class SwapEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "SwapEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "coin_a_info", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) },
  { name: "coin_b_info", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) },
  { name: "account", typeTag: AtomicTypeTag.Address },
  { name: "a_in", typeTag: AtomicTypeTag.U128 },
  { name: "b_out", typeTag: AtomicTypeTag.U128 }];

  coin_a_info: Stdlib.Type_info.TypeInfo;
  coin_b_info: Stdlib.Type_info.TypeInfo;
  account: HexString;
  a_in: U128;
  b_out: U128;

  constructor(proto: any, public typeTag: TypeTag) {
    this.coin_a_info = proto['coin_a_info'] as Stdlib.Type_info.TypeInfo;
    this.coin_b_info = proto['coin_b_info'] as Stdlib.Type_info.TypeInfo;
    this.account = proto['account'] as HexString;
    this.a_in = proto['a_in'] as U128;
    this.b_out = proto['b_out'] as U128;
  }

  static SwapEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : SwapEvent {
    const proto = $.parseStructProto(data, typeTag, repo, SwapEvent);
    return new SwapEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "SwapEvent", []);
  }
  async loadFullState(app: $.AppType) {
    await this.coin_a_info.loadFullState(app);
    await this.coin_b_info.loadFullState(app);
    this.__app = app;
  }

}

export class SwapFeeEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "SwapFeeEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "coin_a_info", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) },
  { name: "coin_b_info", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) },
  { name: "account", typeTag: AtomicTypeTag.Address },
  { name: "fee_address", typeTag: AtomicTypeTag.Address },
  { name: "fee_out", typeTag: AtomicTypeTag.U128 }];

  coin_a_info: Stdlib.Type_info.TypeInfo;
  coin_b_info: Stdlib.Type_info.TypeInfo;
  account: HexString;
  fee_address: HexString;
  fee_out: U128;

  constructor(proto: any, public typeTag: TypeTag) {
    this.coin_a_info = proto['coin_a_info'] as Stdlib.Type_info.TypeInfo;
    this.coin_b_info = proto['coin_b_info'] as Stdlib.Type_info.TypeInfo;
    this.account = proto['account'] as HexString;
    this.fee_address = proto['fee_address'] as HexString;
    this.fee_out = proto['fee_out'] as U128;
  }

  static SwapFeeEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : SwapFeeEvent {
    const proto = $.parseStructProto(data, typeTag, repo, SwapFeeEvent);
    return new SwapFeeEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "SwapFeeEvent", []);
  }
  async loadFullState(app: $.AppType) {
    await this.coin_a_info.loadFullState(app);
    await this.coin_b_info.loadFullState(app);
    this.__app = app;
  }

}
export function burn_ (
  to_burn: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): [Stdlib.Coin.Coin, Stdlib.Coin.Coin] {
  let temp$1, temp$2, amount0, amount1, pool, reserveA, reserveB, to_burn_value, total_supply;
  to_burn_value = u128(Stdlib.Coin.value_(to_burn, $c, [new SimpleStructTag(PoolLiquidityCoin, [$p[0], $p[1]])]));
  pool = $c.borrow_global_mut<Pool>(new SimpleStructTag(Pool, [$p[0], $p[1]]), Amm_config.admin_address_($c));
  reserveA = u128(Stdlib.Coin.value_(pool.coin_a, $c, [$p[0]]));
  reserveB = u128(Stdlib.Coin.value_(pool.coin_b, $c, [$p[1]]));
  temp$1 = Stdlib.Coin.supply_($c, [new SimpleStructTag(PoolLiquidityCoin, [$p[0], $p[1]])]);
  total_supply = $.copy(Stdlib.Option.borrow_(temp$1, $c, [AtomicTypeTag.U128]));
  amount0 = u64(Amm_math.safe_mul_div_u128_($.copy(to_burn_value), $.copy(reserveA), $.copy(total_supply), $c));
  amount1 = u64(Amm_math.safe_mul_div_u128_($.copy(to_burn_value), $.copy(reserveB), $.copy(total_supply), $c));
  if (($.copy(amount0)).gt(u64("0"))) {
    temp$2 = ($.copy(amount1)).gt(u64("0"));
  }
  else{
    temp$2 = false;
  }
  if (!temp$2) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(ELIQUIDITY_SWAP_BURN_CALC_INVALID), $c));
  }
  Stdlib.Coin.burn_(to_burn, pool.burn_capability, $c, [new SimpleStructTag(PoolLiquidityCoin, [$p[0], $p[1]])]);
  return [Stdlib.Coin.extract_(pool.coin_a, $.copy(amount0), $c, [$p[0]]), Stdlib.Coin.extract_(pool.coin_b, $.copy(amount1), $c, [$p[1]])];
}

export function burn_and_emit_event_ (
  account: HexString,
  to_burn: Stdlib.Coin.Coin,
  amount_a_min: U128,
  amount_b_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): [Stdlib.Coin.Coin, Stdlib.Coin.Coin] {
  let a_token, b_token, event_handle, liquidity;
  liquidity = u128(Stdlib.Coin.value_(to_burn, $c, [new SimpleStructTag(PoolLiquidityCoin, [$p[0], $p[1]])]));
  [a_token, b_token] = burn_(to_burn, $c, [$p[0], $p[1]]);
  event_handle = $c.borrow_global_mut<PoolSwapEventHandle>(new SimpleStructTag(PoolSwapEventHandle), Amm_config.admin_address_($c));
  Stdlib.Event.emit_event_(event_handle.remove_liquidity_events, new RemoveLiquidityEvent({ liquidity: $.copy(liquidity), account: Stdlib.Signer.address_of_(account, $c), coin_a_info: Stdlib.Type_info.type_of_($c, [$p[0]]), coin_b_info: Stdlib.Type_info.type_of_($c, [$p[1]]), amount_a_min: $.copy(amount_a_min), amount_b_min: $.copy(amount_b_min) }, new SimpleStructTag(RemoveLiquidityEvent)), $c, [new SimpleStructTag(RemoveLiquidityEvent)]);
  return [a_token, b_token];
}

export function calc_swap_protocol_fee_rate_ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): [U128, U128] {
  let fee_denominator, fee_numerator, protocol_fee_denominator, protocol_fee_numberator;
  [fee_numerator, fee_denominator] = Amm_config.get_trade_fee_($c);
  [protocol_fee_numberator, protocol_fee_denominator] = Amm_config.get_protocol_fee_($c);
  return [u128(($.copy(fee_numerator)).mul($.copy(protocol_fee_numberator))), u128(($.copy(fee_denominator)).mul($.copy(protocol_fee_denominator)))];
}

export function emit_init_pool_event_ (
  account: HexString,
  protocol_fee_to: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  let event_handle;
  event_handle = $c.borrow_global_mut<PoolSwapEventHandle>(new SimpleStructTag(PoolSwapEventHandle), Amm_config.admin_address_($c));
  Stdlib.Event.emit_event_(event_handle.init_pool_events, new InitPoolEvent({ coin_a_info: Stdlib.Type_info.type_of_($c, [$p[0]]), coin_b_info: Stdlib.Type_info.type_of_($c, [$p[1]]), account: Stdlib.Signer.address_of_(account, $c), protocol_fee_to: $.copy(protocol_fee_to) }, new SimpleStructTag(InitPoolEvent)), $c, [new SimpleStructTag(InitPoolEvent)]);
  return;
}

export function emit_swap_fee_event_ (
  signer_address: HexString,
  fee_address: HexString,
  fee_out: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  let event_handle;
  event_handle = $c.borrow_global_mut<PoolSwapEventHandle>(new SimpleStructTag(PoolSwapEventHandle), Amm_config.admin_address_($c));
  Stdlib.Event.emit_event_(event_handle.swap_fee_events, new SwapFeeEvent({ coin_a_info: Stdlib.Type_info.type_of_($c, [$p[0]]), coin_b_info: Stdlib.Type_info.type_of_($c, [$p[1]]), account: $.copy(signer_address), fee_address: $.copy(fee_address), fee_out: $.copy(fee_out) }, new SimpleStructTag(SwapFeeEvent)), $c, [new SimpleStructTag(SwapFeeEvent)]);
  return;
}

export function get_reserves_ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): [U128, U128] {
  let temp$1, temp$5, temp$6, a_reserve, a_reserve__3, b_reserve, b_reserve__4, pool, pool__2;
  temp$1 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
  if (Stdlib.Comparator.is_smaller_than_(temp$1, $c)) {
    pool = $c.borrow_global<Pool>(new SimpleStructTag(Pool, [$p[0], $p[1]]), Amm_config.admin_address_($c));
    a_reserve = u128(Stdlib.Coin.value_(pool.coin_a, $c, [$p[0]]));
    b_reserve = u128(Stdlib.Coin.value_(pool.coin_b, $c, [$p[1]]));
    [temp$5, temp$6] = [$.copy(a_reserve), $.copy(b_reserve)];
  }
  else{
    pool__2 = $c.borrow_global<Pool>(new SimpleStructTag(Pool, [$p[1], $p[0]]), Amm_config.admin_address_($c));
    a_reserve__3 = u128(Stdlib.Coin.value_(pool__2.coin_a, $c, [$p[1]]));
    b_reserve__4 = u128(Stdlib.Coin.value_(pool__2.coin_b, $c, [$p[0]]));
    [temp$5, temp$6] = [$.copy(b_reserve__4), $.copy(a_reserve__3)];
  }
  return [temp$5, temp$6];
}

export function handle_swap_protocol_fee_ (
  signer_address: HexString,
  token_a: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  let pool;
  pool = $c.borrow_global<Pool>(new SimpleStructTag(Pool, [$p[0], $p[1]]), Amm_config.admin_address_($c));
  handle_swap_protocol_fee_internal_($.copy(signer_address), $.copy(pool.protocol_fee_to), token_a, $c, [$p[0], $p[1]]);
  return;
}

export function handle_swap_protocol_fee_internal_ (
  signer_address: HexString,
  fee_address: HexString,
  coin_a: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  let temp$1, temp$2, fee_handle, fee_out;
  [fee_handle, fee_out] = swap_fee_direct_deposit_($.copy(fee_address), coin_a, $c, [$p[0], $p[1]]);
  if (fee_handle) {
    temp$1 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
    if (!!Stdlib.Comparator.is_equal_(temp$1, $c)) {
      throw $.abortCode(Stdlib.Error.internal_($.copy(EINVALID_COIN_PAIR), $c));
    }
    temp$2 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
    if (Stdlib.Comparator.is_smaller_than_(temp$2, $c)) {
      emit_swap_fee_event_($.copy(signer_address), $.copy(fee_address), $.copy(fee_out), $c, [$p[0], $p[1]]);
    }
    else{
      emit_swap_fee_event_($.copy(signer_address), $.copy(fee_address), $.copy(fee_out), $c, [$p[1], $p[0]]);
    }
  }
  else{
  }
  return;
}

export function init_event_handle_ (
  account: HexString,
  $c: AptosDataCache,
): void {
  if (!$c.exists(new SimpleStructTag(PoolSwapEventHandle), Stdlib.Signer.address_of_(account, $c))) {
    $c.move_to(new SimpleStructTag(PoolSwapEventHandle), account, new PoolSwapEventHandle({ init_pool_events: Stdlib.Account.new_event_handle_(account, $c, [new SimpleStructTag(InitPoolEvent)]), add_liquidity_events: Stdlib.Account.new_event_handle_(account, $c, [new SimpleStructTag(AddLiquidityEvent)]), remove_liquidity_events: Stdlib.Account.new_event_handle_(account, $c, [new SimpleStructTag(RemoveLiquidityEvent)]), swap_events: Stdlib.Account.new_event_handle_(account, $c, [new SimpleStructTag(SwapEvent)]), swap_fee_events: Stdlib.Account.new_event_handle_(account, $c, [new SimpleStructTag(SwapFeeEvent)]) }, new SimpleStructTag(PoolSwapEventHandle)));
  }
  else{
  }
  return;
}

export function init_pool_ (
  account: HexString,
  protocol_fee_to: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  let burn_capability, mint_capability, pool;
  Amm_utils.assert_is_coin_($c, [$p[0]]);
  Amm_utils.assert_is_coin_($c, [$p[1]]);
  Amm_config.assert_admin_(account, $c);
  if (!Stdlib.Account.exists_at_($.copy(protocol_fee_to), $c)) {
    throw $.abortCode(Stdlib.Error.not_found_($.copy(EACCOUNT_NOT_EXISTED), $c));
  }
  [burn_capability, mint_capability] = register_liquidity_coin_(account, $c, [$p[0], $p[1]]);
  pool = make_pool_($.copy(protocol_fee_to), $.copy(burn_capability), $.copy(mint_capability), $c, [$p[0], $p[1]]);
  $c.move_to(new SimpleStructTag(Pool, [$p[0], $p[1]]), account, pool);
  init_event_handle_(account, $c);
  emit_init_pool_event_(account, $.copy(protocol_fee_to), $c, [$p[0], $p[1]]);
  return;
}

export function make_pool_ (
  protocol_fee_to: HexString,
  burn_capability: Stdlib.Coin.BurnCapability,
  mint_capability: Stdlib.Coin.MintCapability,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): Pool {
  return new Pool({ coin_a: Stdlib.Coin.zero_($c, [$p[0]]), coin_b: Stdlib.Coin.zero_($c, [$p[1]]), mint_capability: $.copy(mint_capability), burn_capability: $.copy(burn_capability), locked_liquidity: Stdlib.Coin.zero_($c, [new SimpleStructTag(PoolLiquidityCoin, [$p[0], $p[1]])]), protocol_fee_to: $.copy(protocol_fee_to) }, new SimpleStructTag(Pool, [$p[0], $p[1]]));
}

export function mint_ (
  coinA: Stdlib.Coin.Coin,
  coinB: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): Stdlib.Coin.Coin {
  let temp$1, amountA, amountB, liquidity, locked_liquidity, pool, reserve_a, reserve_b, total_supply;
  [reserve_a, reserve_b] = get_reserves_($c, [$p[0], $p[1]]);
  pool = $c.borrow_global_mut<Pool>(new SimpleStructTag(Pool, [$p[0], $p[1]]), Amm_config.admin_address_($c));
  amountA = u128(Stdlib.Coin.value_(coinA, $c, [$p[0]]));
  amountB = u128(Stdlib.Coin.value_(coinB, $c, [$p[1]]));
  temp$1 = Stdlib.Coin.supply_($c, [new SimpleStructTag(PoolLiquidityCoin, [$p[0], $p[1]])]);
  total_supply = u128($.copy(Stdlib.Option.borrow_(temp$1, $c, [AtomicTypeTag.U128])));
  if (($.copy(total_supply)).eq((u128("0")))) {
    liquidity = (Amm_math.sqrt_(($.copy(amountA)).mul($.copy(amountB)), $c)).sub($.copy(MINIMUM_LIQUIDITY));
    locked_liquidity = Stdlib.Coin.mint_(u64($.copy(MINIMUM_LIQUIDITY)), pool.mint_capability, $c, [new SimpleStructTag(PoolLiquidityCoin, [$p[0], $p[1]])]);
    Stdlib.Coin.merge_(pool.locked_liquidity, locked_liquidity, $c, [new SimpleStructTag(PoolLiquidityCoin, [$p[0], $p[1]])]);
  }
  else{
    liquidity = Amm_math.min_(Amm_math.safe_mul_div_u128_($.copy(amountA), $.copy(total_supply), $.copy(reserve_a), $c), Amm_math.safe_mul_div_u128_($.copy(amountB), $.copy(total_supply), $.copy(reserve_b), $c), $c);
  }
  if (!($.copy(liquidity)).gt(u128("0"))) {
    throw $.abortCode(Stdlib.Error.invalid_argument_($.copy(ELIQUIDITY_INSUFFICIENT_MINTED), $c));
  }
  Stdlib.Coin.merge_(pool.coin_a, coinA, $c, [$p[0]]);
  Stdlib.Coin.merge_(pool.coin_b, coinB, $c, [$p[1]]);
  return Stdlib.Coin.mint_(u64($.copy(liquidity)), pool.mint_capability, $c, [new SimpleStructTag(PoolLiquidityCoin, [$p[0], $p[1]])]);
}

export function mint_and_emit_event_ (
  account: HexString,
  coinA: Stdlib.Coin.Coin,
  coinB: Stdlib.Coin.Coin,
  amount_a_desired: U128,
  amount_b_desired: U128,
  amount_a_min: U128,
  amount_b_min: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): Stdlib.Coin.Coin {
  let event_handle, liquidity_token;
  liquidity_token = mint_(coinA, coinB, $c, [$p[0], $p[1]]);
  event_handle = $c.borrow_global_mut<PoolSwapEventHandle>(new SimpleStructTag(PoolSwapEventHandle), Amm_config.admin_address_($c));
  Stdlib.Event.emit_event_(event_handle.add_liquidity_events, new AddLiquidityEvent({ liquidity: u128(Stdlib.Coin.value_(liquidity_token, $c, [new SimpleStructTag(PoolLiquidityCoin, [$p[0], $p[1]])])), account: Stdlib.Signer.address_of_(account, $c), coin_a_info: Stdlib.Type_info.type_of_($c, [$p[0]]), coin_b_info: Stdlib.Type_info.type_of_($c, [$p[1]]), amount_a_desired: $.copy(amount_a_desired), amount_b_desired: $.copy(amount_b_desired), amount_a_min: $.copy(amount_a_min), amount_b_min: $.copy(amount_b_min) }, new SimpleStructTag(AddLiquidityEvent)), $c, [new SimpleStructTag(AddLiquidityEvent)]);
  return liquidity_token;
}

export function register_liquidity_coin_ (
  account: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): [Stdlib.Coin.BurnCapability, Stdlib.Coin.MintCapability] {
  let burn_capability, freeze_capability, mint_capability;
  [burn_capability, freeze_capability, mint_capability] = Stdlib.Coin.initialize_(account, Stdlib.String.utf8_([u8("67"), u8("69"), u8("84"), u8("85"), u8("83"), u8("32"), u8("65"), u8("77"), u8("77"), u8("32"), u8("76"), u8("80")], $c), Stdlib.String.utf8_([u8("67"), u8("65"), u8("76"), u8("80")], $c), u8("18"), true, $c, [new SimpleStructTag(PoolLiquidityCoin, [$p[0], $p[1]])]);
  Stdlib.Coin.destroy_freeze_cap_($.copy(freeze_capability), $c, [new SimpleStructTag(PoolLiquidityCoin, [$p[0], $p[1]])]);
  return [$.copy(burn_capability), $.copy(mint_capability)];
}

export function return_back_to_lp_pool_ (
  a_in: Stdlib.Coin.Coin,
  b_in: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): void {
  let pool;
  pool = $c.borrow_global_mut<Pool>(new SimpleStructTag(Pool, [$p[0], $p[1]]), Amm_config.admin_address_($c));
  Stdlib.Coin.merge_(pool.coin_a, a_in, $c, [$p[0]]);
  Stdlib.Coin.merge_(pool.coin_b, b_in, $c, [$p[1]]);
  return;
}

export function swap_ (
  coin_a_in: Stdlib.Coin.Coin,
  coin_b_out: U128,
  coin_b_in: Stdlib.Coin.Coin,
  coin_a_out: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): [Stdlib.Coin.Coin, Stdlib.Coin.Coin, Stdlib.Coin.Coin, Stdlib.Coin.Coin] {
  let temp$1, temp$2, a_adjusted, a_in_value, a_reserve, a_reserve_new, a_swap_fee, b_adjusted, b_in_value, b_reserve, b_reserve_new, b_swap_fee, cmp_order, coin_a_swapped, coin_b_swapped, fee_denominator, fee_numerator, pool, protocol_fee_denominator, protocol_fee_numberator;
  Amm_config.assert_pause_($c);
  a_in_value = Stdlib.Coin.value_(coin_a_in, $c, [$p[0]]);
  b_in_value = Stdlib.Coin.value_(coin_b_in, $c, [$p[1]]);
  if (($.copy(a_in_value)).gt(u64("0"))) {
    temp$1 = true;
  }
  else{
    temp$1 = ($.copy(b_in_value)).gt(u64("0"));
  }
  if (!temp$1) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(ECOIN_INSUFFICIENT), $c));
  }
  [a_reserve, b_reserve] = get_reserves_($c, [$p[0], $p[1]]);
  pool = $c.borrow_global_mut<Pool>(new SimpleStructTag(Pool, [$p[0], $p[1]]), Amm_config.admin_address_($c));
  Stdlib.Coin.merge_(pool.coin_a, coin_a_in, $c, [$p[0]]);
  Stdlib.Coin.merge_(pool.coin_b, coin_b_in, $c, [$p[1]]);
  coin_a_swapped = Stdlib.Coin.extract_(pool.coin_a, u64($.copy(coin_a_out)), $c, [$p[0]]);
  coin_b_swapped = Stdlib.Coin.extract_(pool.coin_b, u64($.copy(coin_b_out)), $c, [$p[1]]);
  a_reserve_new = Stdlib.Coin.value_(pool.coin_a, $c, [$p[0]]);
  b_reserve_new = Stdlib.Coin.value_(pool.coin_b, $c, [$p[1]]);
  [fee_numerator, fee_denominator] = Amm_config.get_trade_fee_($c);
  a_adjusted = ((u128($.copy(a_reserve_new))).mul(u128($.copy(fee_denominator)))).sub((u128($.copy(a_in_value))).mul(u128($.copy(fee_numerator))));
  b_adjusted = ((u128($.copy(b_reserve_new))).mul(u128($.copy(fee_denominator)))).sub((u128($.copy(b_in_value))).mul(u128($.copy(fee_numerator))));
  cmp_order = Amm_math.safe_compare_mul_u128_($.copy(a_adjusted), $.copy(b_adjusted), u128($.copy(a_reserve)), u128($.copy(b_reserve)), $c);
  if (($.copy(EQUAL)).eq(($.copy(cmp_order)))) {
    temp$2 = true;
  }
  else{
    temp$2 = ($.copy(GREATER_THAN)).eq(($.copy(cmp_order)));
  }
  if (!temp$2) {
    throw $.abortCode(Stdlib.Error.internal_($.copy(ESWAPOUT_CALC_INVALID), $c));
  }
  [protocol_fee_numberator, protocol_fee_denominator] = calc_swap_protocol_fee_rate_($c, [$p[0], $p[1]]);
  a_swap_fee = Stdlib.Coin.extract_(pool.coin_a, u64(Amm_math.safe_mul_div_u128_(u128($.copy(a_in_value)), $.copy(protocol_fee_numberator), $.copy(protocol_fee_denominator), $c)), $c, [$p[0]]);
  b_swap_fee = Stdlib.Coin.extract_(pool.coin_b, u64(Amm_math.safe_mul_div_u128_(u128($.copy(b_in_value)), $.copy(protocol_fee_numberator), $.copy(protocol_fee_denominator), $c)), $c, [$p[1]]);
  return [coin_a_swapped, coin_b_swapped, a_swap_fee, b_swap_fee];
}

export function swap_and_emit_event_ (
  account: HexString,
  coin_a_in: Stdlib.Coin.Coin,
  coin_b_out: U128,
  coin_b_in: Stdlib.Coin.Coin,
  coin_a_out: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): [Stdlib.Coin.Coin, Stdlib.Coin.Coin, Stdlib.Coin.Coin, Stdlib.Coin.Coin] {
  let coin_a_fee, coin_a_out__1, coin_b_fee, coin_b_out__2, event_handle;
  [coin_a_out__1, coin_b_out__2, coin_a_fee, coin_b_fee] = swap_(coin_a_in, $.copy(coin_b_out), coin_b_in, $.copy(coin_a_out), $c, [$p[0], $p[1]]);
  event_handle = $c.borrow_global_mut<PoolSwapEventHandle>(new SimpleStructTag(PoolSwapEventHandle), Amm_config.admin_address_($c));
  Stdlib.Event.emit_event_(event_handle.swap_events, new SwapEvent({ coin_a_info: Stdlib.Type_info.type_of_($c, [$p[0]]), coin_b_info: Stdlib.Type_info.type_of_($c, [$p[1]]), account: Stdlib.Signer.address_of_(account, $c), a_in: u128(Stdlib.Coin.value_(coin_a_out__1, $c, [$p[0]])), b_out: u128(Stdlib.Coin.value_(coin_b_out__2, $c, [$p[1]])) }, new SimpleStructTag(SwapEvent)), $c, [new SimpleStructTag(SwapEvent)]);
  return [coin_a_out__1, coin_b_out__2, coin_a_fee, coin_b_fee];
}

export function swap_fee_direct_deposit_ (
  fee_address: HexString,
  coin_a: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinTypeA, CoinTypeB>*/
): [boolean, U128] {
  let temp$1, temp$2, a_value;
  if (!Stdlib.Coin.is_account_registered_($.copy(fee_address), $c, [$p[0]])) {
    a_value = Stdlib.Coin.value_(coin_a, $c, [$p[0]]);
    Stdlib.Coin.deposit_($.copy(fee_address), coin_a, $c, [$p[0]]);
    return [true, u128($.copy(a_value))];
  }
  else{
    temp$1 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
    if (!!Stdlib.Comparator.is_equal_(temp$1, $c)) {
      throw $.abortCode(Stdlib.Error.internal_($.copy(EINVALID_COIN_PAIR), $c));
    }
    temp$2 = Amm_utils.compare_coin_($c, [$p[0], $p[1]]);
    if (Stdlib.Comparator.is_smaller_than_(temp$2, $c)) {
      return_back_to_lp_pool_(coin_a, Stdlib.Coin.zero_($c, [$p[1]]), $c, [$p[0], $p[1]]);
    }
    else{
      return_back_to_lp_pool_(Stdlib.Coin.zero_($c, [$p[1]]), coin_a, $c, [$p[1], $p[0]]);
    }
  }
  return [true, u128(u64("0"))];
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219::amm_swap::AddLiquidityEvent", AddLiquidityEvent.AddLiquidityEventParser);
  repo.addParser("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219::amm_swap::InitPoolEvent", InitPoolEvent.InitPoolEventParser);
  repo.addParser("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219::amm_swap::Pool", Pool.PoolParser);
  repo.addParser("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219::amm_swap::PoolLiquidityCoin", PoolLiquidityCoin.PoolLiquidityCoinParser);
  repo.addParser("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219::amm_swap::PoolSwapEventHandle", PoolSwapEventHandle.PoolSwapEventHandleParser);
  repo.addParser("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219::amm_swap::RemoveLiquidityEvent", RemoveLiquidityEvent.RemoveLiquidityEventParser);
  repo.addParser("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219::amm_swap::SwapEvent", SwapEvent.SwapEventParser);
  repo.addParser("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219::amm_swap::SwapFeeEvent", SwapFeeEvent.SwapFeeEventParser);
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
  get AddLiquidityEvent() { return AddLiquidityEvent; }
  get InitPoolEvent() { return InitPoolEvent; }
  get Pool() { return Pool; }
  async loadPool(
    owner: HexString,
    $p: TypeTag[], /* <CoinTypeA, CoinTypeB> */
    loadFull=true,
  ) {
    const val = await Pool.load(this.repo, this.client, owner, $p);
    if (loadFull) {
      await val.loadFullState(this);
    }
    return val;
  }
  get PoolLiquidityCoin() { return PoolLiquidityCoin; }
  get PoolSwapEventHandle() { return PoolSwapEventHandle; }
  async loadPoolSwapEventHandle(
    owner: HexString,
    loadFull=true,
  ) {
    const val = await PoolSwapEventHandle.load(this.repo, this.client, owner, [] as TypeTag[]);
    if (loadFull) {
      await val.loadFullState(this);
    }
    return val;
  }
  get RemoveLiquidityEvent() { return RemoveLiquidityEvent; }
  get SwapEvent() { return SwapEvent; }
  get SwapFeeEvent() { return SwapFeeEvent; }
}

