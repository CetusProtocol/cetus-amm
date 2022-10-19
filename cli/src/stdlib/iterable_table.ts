import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache, AptosLocalCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag, SimpleStructTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient, AptosAccount} from "aptos";
import * as Option from "./option";
import * as Table_with_length from "./table_with_length";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "iterable_table";



export class IterableTable 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "IterableTable";
  static typeParameters: TypeParamDeclType[] = [
    { name: "K", isPhantom: false },
    { name: "V", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "inner", typeTag: new StructTag(new HexString("0x1"), "table_with_length", "TableWithLength", [new $.TypeParamIdx(0), new StructTag(new HexString("0x1"), "iterable_table", "IterableValue", [new $.TypeParamIdx(0), new $.TypeParamIdx(1)])]) },
  { name: "head", typeTag: new StructTag(new HexString("0x1"), "option", "Option", [new $.TypeParamIdx(0)]) },
  { name: "tail", typeTag: new StructTag(new HexString("0x1"), "option", "Option", [new $.TypeParamIdx(0)]) }];

  inner: Table_with_length.TableWithLength;
  head: Option.Option;
  tail: Option.Option;

  constructor(proto: any, public typeTag: TypeTag) {
    this.inner = proto['inner'] as Table_with_length.TableWithLength;
    this.head = proto['head'] as Option.Option;
    this.tail = proto['tail'] as Option.Option;
  }

  static IterableTableParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : IterableTable {
    const proto = $.parseStructProto(data, typeTag, repo, IterableTable);
    return new IterableTable(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "IterableTable", $p);
  }

  toTypedIterTable<K = any, V = any>() { return TypedIterableTable.fromIterableTable<K, V>(this); }

  async loadFullState(app: $.AppType) {
    const typedIterTable = this.toTypedIterTable();
    await typedIterTable.fetchAll(app.client, app.repo, app.cache);
    this.__app = app;
  }

}

export class IterableValue 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "IterableValue";
  static typeParameters: TypeParamDeclType[] = [
    { name: "K", isPhantom: false },
    { name: "V", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "val", typeTag: new $.TypeParamIdx(1) },
  { name: "prev", typeTag: new StructTag(new HexString("0x1"), "option", "Option", [new $.TypeParamIdx(0)]) },
  { name: "next", typeTag: new StructTag(new HexString("0x1"), "option", "Option", [new $.TypeParamIdx(0)]) }];

  val: any;
  prev: Option.Option;
  next: Option.Option;

  constructor(proto: any, public typeTag: TypeTag) {
    this.val = proto['val'] as any;
    this.prev = proto['prev'] as Option.Option;
    this.next = proto['next'] as Option.Option;
  }

  static IterableValueParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : IterableValue {
    const proto = $.parseStructProto(data, typeTag, repo, IterableValue);
    return new IterableValue(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "IterableValue", $p);
  }
  async loadFullState(app: $.AppType) {
    if (this.val.typeTag instanceof StructTag) {await this.val.loadFullState(app);}
    await this.prev.loadFullState(app);
    await this.next.loadFullState(app);
    this.__app = app;
  }

}
export function add_ (
  table: IterableTable,
  key: any,
  val: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  let k, wrapped_value;
  wrapped_value = new IterableValue({ val: val, prev: $.copy(table.tail), next: Option.none_($c, [$p[0]]) }, new SimpleStructTag(IterableValue, [$p[0], $p[1]]));
  Table_with_length.add_(table.inner, $.copy(key), wrapped_value, $c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]);
  if (Option.is_some_(table.tail, $c, [$p[0]])) {
    k = Option.borrow_(table.tail, $c, [$p[0]]);
    Table_with_length.borrow_mut_(table.inner, $.copy(k), $c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]).next = Option.some_($.copy(key), $c, [$p[0]]);
  }
  else{
    table.head = Option.some_($.copy(key), $c, [$p[0]]);
  }
  table.tail = Option.some_($.copy(key), $c, [$p[0]]);
  return;
}

export function append_ (
  v1: IterableTable,
  v2: IterableTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  let key, next, val;
  key = head_key_(v2, $c, [$p[0], $p[1]]);
  while (Option.is_some_(key, $c, [$p[0]])) {
    {
      [val, , next] = remove_iter_(v2, $.copy(Option.borrow_(key, $c, [$p[0]])), $c, [$p[0], $p[1]]);
      add_(v1, $.copy(Option.borrow_(key, $c, [$p[0]])), val, $c, [$p[0], $p[1]]);
      key = $.copy(next);
    }

  }return;
}

export function borrow_ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  return Table_with_length.borrow_(table.inner, $.copy(key), $c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]).val;
}

export function borrow_iter_ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): [any, Option.Option, Option.Option] {
  let v;
  v = Table_with_length.borrow_(table.inner, $.copy(key), $c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]);
  return [v.val, $.copy(v.prev), $.copy(v.next)];
}

export function borrow_iter_mut_ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): [any, Option.Option, Option.Option] {
  let v;
  v = Table_with_length.borrow_mut_(table.inner, $.copy(key), $c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]);
  return [v.val, $.copy(v.prev), $.copy(v.next)];
}

export function borrow_mut_ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  return Table_with_length.borrow_mut_(table.inner, $.copy(key), $c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]).val;
}

export function borrow_mut_with_default_ (
  table: IterableTable,
  key: any,
  default__: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  let temp$1, temp$2;
  [temp$1, temp$2] = [table, $.copy(key)];
  if (!contains_(temp$1, temp$2, $c, [$p[0], $p[1]])) {
    add_(table, $.copy(key), default__, $c, [$p[0], $p[1]]);
  }
  else{
  }
  return borrow_mut_(table, $.copy(key), $c, [$p[0], $p[1]]);
}

export function contains_ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): boolean {
  return Table_with_length.contains_(table.inner, $.copy(key), $c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]);
}

export function destroy_empty_ (
  table: IterableTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  if (!empty_(table, $c, [$p[0], $p[1]])) {
    throw $.abortCode(u64("0"));
  }
  if (!Option.is_none_(table.head, $c, [$p[0]])) {
    throw $.abortCode(u64("0"));
  }
  if (!Option.is_none_(table.tail, $c, [$p[0]])) {
    throw $.abortCode(u64("0"));
  }
  let { inner: inner } = table;
  Table_with_length.destroy_empty_(inner, $c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]);
  return;
}

export function empty_ (
  table: IterableTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): boolean {
  return Table_with_length.empty_(table.inner, $c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]);
}

export function head_key_ (
  table: IterableTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): Option.Option {
  return $.copy(table.head);
}

export function length_ (
  table: IterableTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): U64 {
  return Table_with_length.length_(table.inner, $c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]);
}

export function new___ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): IterableTable {
  return new IterableTable({ inner: Table_with_length.new___($c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]), head: Option.none_($c, [$p[0]]), tail: Option.none_($c, [$p[0]]) }, new SimpleStructTag(IterableTable, [$p[0], $p[1]]));
}

export function remove_ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  let val;
  [val, , ] = remove_iter_(table, $.copy(key), $c, [$p[0], $p[1]]);
  return val;
}

export function remove_iter_ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): [any, Option.Option, Option.Option] {
  let key__1, key__2, val;
  val = Table_with_length.remove_(table.inner, $.copy(key), $c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]);
  if (Option.contains_(table.tail, key, $c, [$p[0]])) {
    table.tail = $.copy(val.prev);
  }
  else{
  }
  if (Option.contains_(table.head, key, $c, [$p[0]])) {
    table.head = $.copy(val.next);
  }
  else{
  }
  if (Option.is_some_(val.prev, $c, [$p[0]])) {
    key__1 = Option.borrow_(val.prev, $c, [$p[0]]);
    Table_with_length.borrow_mut_(table.inner, $.copy(key__1), $c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]).next = $.copy(val.next);
  }
  else{
  }
  if (Option.is_some_(val.next, $c, [$p[0]])) {
    key__2 = Option.borrow_(val.next, $c, [$p[0]]);
    Table_with_length.borrow_mut_(table.inner, $.copy(key__2), $c, [$p[0], new SimpleStructTag(IterableValue, [$p[0], $p[1]])]).prev = $.copy(val.prev);
  }
  else{
  }
  let { val: val__3, prev: prev, next: next } = val;
  return [val__3, $.copy(prev), $.copy(next)];
}

export function tail_key_ (
  table: IterableTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): Option.Option {
  return $.copy(table.tail);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::iterable_table::IterableTable", IterableTable.IterableTableParser);
  repo.addParser("0x1::iterable_table::IterableValue", IterableValue.IterableValueParser);
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
  get IterableTable() { return IterableTable; }
  get IterableValue() { return IterableValue; }
}

export class TypedIterableTable<K=any, V=any> {
  static fromIterableTable<K=any, V=any>(table: IterableTable): TypedIterableTable<K, V> {
    const tag = table.typeTag;
    if (!(tag instanceof StructTag)) {
      throw new Error();
    }
    if (tag.getParamlessName() !== '0x1::iterable_table::IterableTable') {
      throw new Error();
    }
    if (tag.typeParams.length !== 2) {
      throw new Error();
    }
    const [keyTag, valueTag] = tag.typeParams;
    return new TypedIterableTable<K, V>(table, keyTag, valueTag);
  }

  iterValueTag: StructTag;
  constructor(
    public table: IterableTable,
    public keyTag: TypeTag,
    public valueTag: TypeTag
  ) {
    this.iterValueTag = new StructTag(moduleAddress, moduleName, "IterableValue", [keyTag, valueTag])
  }

  async loadEntryRaw(client: AptosClient, key: K): Promise<any> {
    return await client.getTableItem(this.table.inner.inner.handle.toString(), {
      key_type: $.getTypeTagFullname(this.keyTag),
      value_type: $.getTypeTagFullname(this.iterValueTag),
      key: $.moveValueToOpenApiObject(key, this.keyTag),
    });
  }

  async loadEntry(client: AptosClient, repo: AptosParserRepo, key: K): Promise<IterableValue> {
    const rawVal = await this.loadEntryRaw(client, key);
    return repo.parse(rawVal, this.iterValueTag) as IterableValue;
  }

  async fetchAll(client: AptosClient, repo: AptosParserRepo, cache: AptosLocalCache | null = null): Promise<[K, V][]> {
    const result: [K, V][] = [];
    const dummyCache = new $.DummyCache();
    let next = this.table.head;
    while(next && await Option.is_some_(next, dummyCache, [this.keyTag])) {
      const key = await Option.borrow_(next, dummyCache, [this.keyTag]) as K;
      const iterVal = await this.loadEntry(client, repo, key);
      const value = iterVal.val as V;
      result.push([key, value]);
      next = iterVal.next;
      if (cache) {
        const $p = [this.keyTag, this.valueTag];
        Table_with_length.add_(
          this.table.inner,
          $.copy(key),
          iterVal,
          cache,
          [$p[0], iterVal.typeTag]
        );
      }
    }
    return result;
  }
}


