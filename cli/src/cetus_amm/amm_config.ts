import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache, AptosLocalCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag, SimpleStructTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient, AptosAccount} from "aptos";
import * as Stdlib from "../stdlib";
export const packageName = "Cetue-AMM";
export const moduleAddress = new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219");
export const moduleName = "amm_config";

export const ENOT_HAS_PRIVILEGE : U64 = u64("1001");
export const EPOOL_PAUSE : U64 = u64("1002");


export class PoolFeeConfig 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "PoolFeeConfig";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "trade_fee_numerator", typeTag: AtomicTypeTag.U64 },
  { name: "trade_fee_denominator", typeTag: AtomicTypeTag.U64 },
  { name: "protocol_fee_numerator", typeTag: AtomicTypeTag.U64 },
  { name: "protocol_fee_denominator", typeTag: AtomicTypeTag.U64 }];

  trade_fee_numerator: U64;
  trade_fee_denominator: U64;
  protocol_fee_numerator: U64;
  protocol_fee_denominator: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.trade_fee_numerator = proto['trade_fee_numerator'] as U64;
    this.trade_fee_denominator = proto['trade_fee_denominator'] as U64;
    this.protocol_fee_numerator = proto['protocol_fee_numerator'] as U64;
    this.protocol_fee_denominator = proto['protocol_fee_denominator'] as U64;
  }

  static PoolFeeConfigParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : PoolFeeConfig {
    const proto = $.parseStructProto(data, typeTag, repo, PoolFeeConfig);
    return new PoolFeeConfig(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, PoolFeeConfig, typeParams);
    return result as unknown as PoolFeeConfig;
  }
  static async loadByApp(app: $.AppType, address: HexString, typeParams: TypeTag[]) {
    const result = await app.repo.loadResource(app.client, address, PoolFeeConfig, typeParams);
    await result.loadFullState(app)
    return result as unknown as PoolFeeConfig;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "PoolFeeConfig", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }

}

export class PoolPauseStatus 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "PoolPauseStatus";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pause", typeTag: AtomicTypeTag.Bool }];

  pause: boolean;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pause = proto['pause'] as boolean;
  }

  static PoolPauseStatusParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : PoolPauseStatus {
    const proto = $.parseStructProto(data, typeTag, repo, PoolPauseStatus);
    return new PoolPauseStatus(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, PoolPauseStatus, typeParams);
    return result as unknown as PoolPauseStatus;
  }
  static async loadByApp(app: $.AppType, address: HexString, typeParams: TypeTag[]) {
    const result = await app.repo.loadResource(app.client, address, PoolPauseStatus, typeParams);
    await result.loadFullState(app)
    return result as unknown as PoolPauseStatus;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "PoolPauseStatus", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }

}
export function admin_address_ (
  $c: AptosDataCache,
): HexString {
  return new HexString("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219");
}

export function assert_admin_ (
  account: HexString,
  $c: AptosDataCache,
): void {
  if (!((Stdlib.Signer.address_of_(account, $c)).hex() === (admin_address_($c)).hex())) {
    throw $.abortCode(Stdlib.Error.permission_denied_($.copy(ENOT_HAS_PRIVILEGE), $c));
  }
  return;
}

export function assert_pause_ (
  $c: AptosDataCache,
): void {
  if (!!get_pool_pause_($c)) {
    throw $.abortCode(Stdlib.Error.unavailable_($.copy(EPOOL_PAUSE), $c));
  }
  return;
}

export function get_pool_pause_ (
  $c: AptosDataCache,
): boolean {
  return $.copy($c.borrow_global<PoolPauseStatus>(new SimpleStructTag(PoolPauseStatus), admin_address_($c)).pause);
}

export function get_protocol_fee_ (
  $c: AptosDataCache,
): [U64, U64] {
  let fee_config;
  fee_config = $c.borrow_global<PoolFeeConfig>(new SimpleStructTag(PoolFeeConfig), admin_address_($c));
  return [$.copy(fee_config.protocol_fee_numerator), $.copy(fee_config.protocol_fee_denominator)];
}

export function get_trade_fee_ (
  $c: AptosDataCache,
): [U64, U64] {
  let fee_config;
  fee_config = $c.borrow_global<PoolFeeConfig>(new SimpleStructTag(PoolFeeConfig), admin_address_($c));
  return [$.copy(fee_config.trade_fee_numerator), $.copy(fee_config.trade_fee_denominator)];
}

export function set_pool_fee_config_ (
  account: HexString,
  trade_fee_numerator: U64,
  trade_fee_denominator: U64,
  protocol_fee_numerator: U64,
  protocol_fee_denominator: U64,
  $c: AptosDataCache,
): void {
  let addr, fee_config;
  assert_admin_(account, $c);
  addr = Stdlib.Signer.address_of_(account, $c);
  if (!$c.exists(new SimpleStructTag(PoolFeeConfig), $.copy(addr))) {
    $c.move_to(new SimpleStructTag(PoolFeeConfig), account, new PoolFeeConfig({ trade_fee_numerator: $.copy(trade_fee_numerator), trade_fee_denominator: $.copy(trade_fee_denominator), protocol_fee_numerator: $.copy(protocol_fee_numerator), protocol_fee_denominator: $.copy(protocol_fee_denominator) }, new SimpleStructTag(PoolFeeConfig)));
  }
  else{
    fee_config = $c.borrow_global_mut<PoolFeeConfig>(new SimpleStructTag(PoolFeeConfig), $.copy(addr));
    fee_config.trade_fee_numerator = $.copy(trade_fee_numerator);
    fee_config.trade_fee_denominator = $.copy(trade_fee_denominator);
    fee_config.protocol_fee_numerator = $.copy(protocol_fee_numerator);
    fee_config.protocol_fee_denominator = $.copy(protocol_fee_denominator);
  }
  return;
}

export function set_pool_pause_ (
  account: HexString,
  pause: boolean,
  $c: AptosDataCache,
): void {
  let addr, status;
  assert_admin_(account, $c);
  addr = Stdlib.Signer.address_of_(account, $c);
  if (!$c.exists(new SimpleStructTag(PoolPauseStatus), $.copy(addr))) {
    $c.move_to(new SimpleStructTag(PoolPauseStatus), account, new PoolPauseStatus({ pause: pause }, new SimpleStructTag(PoolPauseStatus)));
  }
  else{
    status = $c.borrow_global_mut<PoolPauseStatus>(new SimpleStructTag(PoolPauseStatus), $.copy(addr));
    status.pause = pause;
  }
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219::amm_config::PoolFeeConfig", PoolFeeConfig.PoolFeeConfigParser);
  repo.addParser("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219::amm_config::PoolPauseStatus", PoolPauseStatus.PoolPauseStatusParser);
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
  get PoolFeeConfig() { return PoolFeeConfig; }
  async loadPoolFeeConfig(
    owner: HexString,
    loadFull=true,
  ) {
    const val = await PoolFeeConfig.load(this.repo, this.client, owner, [] as TypeTag[]);
    if (loadFull) {
      await val.loadFullState(this);
    }
    return val;
  }
  get PoolPauseStatus() { return PoolPauseStatus; }
  async loadPoolPauseStatus(
    owner: HexString,
    loadFull=true,
  ) {
    const val = await PoolPauseStatus.load(this.repo, this.client, owner, [] as TypeTag[]);
    if (loadFull) {
      await val.loadFullState(this);
    }
    return val;
  }
}

