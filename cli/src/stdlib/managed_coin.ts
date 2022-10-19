import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache, AptosLocalCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag, SimpleStructTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient, AptosAccount} from "aptos";
import * as Coin from "./coin";
import * as Error from "./error";
import * as Signer from "./signer";
import * as String from "./string";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "managed_coin";

export const ENO_CAPABILITIES : U64 = u64("1");


export class Capabilities 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "Capabilities";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "burn_cap", typeTag: new StructTag(new HexString("0x1"), "coin", "BurnCapability", [new $.TypeParamIdx(0)]) },
  { name: "freeze_cap", typeTag: new StructTag(new HexString("0x1"), "coin", "FreezeCapability", [new $.TypeParamIdx(0)]) },
  { name: "mint_cap", typeTag: new StructTag(new HexString("0x1"), "coin", "MintCapability", [new $.TypeParamIdx(0)]) }];

  burn_cap: Coin.BurnCapability;
  freeze_cap: Coin.FreezeCapability;
  mint_cap: Coin.MintCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.burn_cap = proto['burn_cap'] as Coin.BurnCapability;
    this.freeze_cap = proto['freeze_cap'] as Coin.FreezeCapability;
    this.mint_cap = proto['mint_cap'] as Coin.MintCapability;
  }

  static CapabilitiesParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Capabilities {
    const proto = $.parseStructProto(data, typeTag, repo, Capabilities);
    return new Capabilities(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Capabilities, typeParams);
    return result as unknown as Capabilities;
  }
  static async loadByApp(app: $.AppType, address: HexString, typeParams: TypeTag[]) {
    const result = await app.repo.loadResource(app.client, address, Capabilities, typeParams);
    await result.loadFullState(app)
    return result as unknown as Capabilities;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "Capabilities", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.burn_cap.loadFullState(app);
    await this.freeze_cap.loadFullState(app);
    await this.mint_cap.loadFullState(app);
    this.__app = app;
  }

}
export function burn_ (
  account: HexString,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): void {
  let account_addr, capabilities, to_burn;
  account_addr = Signer.address_of_(account, $c);
  if (!$c.exists(new SimpleStructTag(Capabilities, [$p[0]]), $.copy(account_addr))) {
    throw $.abortCode(Error.not_found_($.copy(ENO_CAPABILITIES), $c));
  }
  capabilities = $c.borrow_global<Capabilities>(new SimpleStructTag(Capabilities, [$p[0]]), $.copy(account_addr));
  to_burn = Coin.withdraw_(account, $.copy(amount), $c, [$p[0]]);
  Coin.burn_(to_burn, capabilities.burn_cap, $c, [$p[0]]);
  return;
}


export function buildPayload_burn (
  amount: U64,
  $p: TypeTag[], /* <CoinType>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x1"),
    "managed_coin",
    "burn",
    typeParamStrings,
    [
      amount,
    ]
  );

}
export function initialize_ (
  account: HexString,
  name: U8[],
  symbol: U8[],
  decimals: U8,
  monitor_supply: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): void {
  let burn_cap, freeze_cap, mint_cap;
  [burn_cap, freeze_cap, mint_cap] = Coin.initialize_(account, String.utf8_($.copy(name), $c), String.utf8_($.copy(symbol), $c), $.copy(decimals), monitor_supply, $c, [$p[0]]);
  $c.move_to(new SimpleStructTag(Capabilities, [$p[0]]), account, new Capabilities({ burn_cap: $.copy(burn_cap), freeze_cap: $.copy(freeze_cap), mint_cap: $.copy(mint_cap) }, new SimpleStructTag(Capabilities, [$p[0]])));
  return;
}


export function buildPayload_initialize (
  name: U8[],
  symbol: U8[],
  decimals: U8,
  monitor_supply: boolean,
  $p: TypeTag[], /* <CoinType>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x1"),
    "managed_coin",
    "initialize",
    typeParamStrings,
    [
      name,
      symbol,
      decimals,
      monitor_supply,
    ]
  );

}
export function mint_ (
  account: HexString,
  dst_addr: HexString,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): void {
  let account_addr, capabilities, coins_minted;
  account_addr = Signer.address_of_(account, $c);
  if (!$c.exists(new SimpleStructTag(Capabilities, [$p[0]]), $.copy(account_addr))) {
    throw $.abortCode(Error.not_found_($.copy(ENO_CAPABILITIES), $c));
  }
  capabilities = $c.borrow_global<Capabilities>(new SimpleStructTag(Capabilities, [$p[0]]), $.copy(account_addr));
  coins_minted = Coin.mint_($.copy(amount), capabilities.mint_cap, $c, [$p[0]]);
  Coin.deposit_($.copy(dst_addr), coins_minted, $c, [$p[0]]);
  return;
}


export function buildPayload_mint (
  dst_addr: HexString,
  amount: U64,
  $p: TypeTag[], /* <CoinType>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x1"),
    "managed_coin",
    "mint",
    typeParamStrings,
    [
      dst_addr,
      amount,
    ]
  );

}
export function register_ (
  account: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): void {
  Coin.register_(account, $c, [$p[0]]);
  return;
}


export function buildPayload_register (
  $p: TypeTag[], /* <CoinType>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x1"),
    "managed_coin",
    "register",
    typeParamStrings,
    []
  );

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::managed_coin::Capabilities", Capabilities.CapabilitiesParser);
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
  get Capabilities() { return Capabilities; }
  async loadCapabilities(
    owner: HexString,
    $p: TypeTag[], /* <CoinType> */
    loadFull=true,
  ) {
    const val = await Capabilities.load(this.repo, this.client, owner, $p);
    if (loadFull) {
      await val.loadFullState(this);
    }
    return val;
  }
  payload_burn(
    amount: U64,
    $p: TypeTag[], /* <CoinType>*/
  ) {
    return buildPayload_burn(amount, $p);
  }
  async burn(
    _account: AptosAccount,
    amount: U64,
    $p: TypeTag[], /* <CoinType>*/
    _maxGas = 1000,
  ) {
    const payload = buildPayload_burn(amount, $p);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
  payload_initialize(
    name: U8[],
    symbol: U8[],
    decimals: U8,
    monitor_supply: boolean,
    $p: TypeTag[], /* <CoinType>*/
  ) {
    return buildPayload_initialize(name, symbol, decimals, monitor_supply, $p);
  }
  async initialize(
    _account: AptosAccount,
    name: U8[],
    symbol: U8[],
    decimals: U8,
    monitor_supply: boolean,
    $p: TypeTag[], /* <CoinType>*/
    _maxGas = 1000,
  ) {
    const payload = buildPayload_initialize(name, symbol, decimals, monitor_supply, $p);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
  payload_mint(
    dst_addr: HexString,
    amount: U64,
    $p: TypeTag[], /* <CoinType>*/
  ) {
    return buildPayload_mint(dst_addr, amount, $p);
  }
  async mint(
    _account: AptosAccount,
    dst_addr: HexString,
    amount: U64,
    $p: TypeTag[], /* <CoinType>*/
    _maxGas = 1000,
  ) {
    const payload = buildPayload_mint(dst_addr, amount, $p);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
  payload_register(
    $p: TypeTag[], /* <CoinType>*/
  ) {
    return buildPayload_register($p);
  }
  async register(
    _account: AptosAccount,
    $p: TypeTag[], /* <CoinType>*/
    _maxGas = 1000,
  ) {
    const payload = buildPayload_register($p);
    return $.sendPayloadTx(this.client, _account, payload, _maxGas);
  }
}

