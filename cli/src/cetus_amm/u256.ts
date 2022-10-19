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
export const moduleName = "u256";

export const ECAST_OVERFLOW : U64 = u64("0");
export const EDIV_BY_ZERO : U64 = u64("3");
export const EOVERFLOW : U64 = u64("2");
export const EQUAL : U8 = u8("0");
export const EVECTOR_LENGTH_NOT_32_BYTES : U64 = u64("4");
export const EWORDS_OVERFLOW : U64 = u64("1");
export const GREATER_THAN : U8 = u8("2");
export const LESS_THAN : U8 = u8("1");
export const U128_MAX : U128 = u128("340282366920938463463374607431768211455");
export const U64_MAX : U128 = u128("18446744073709551615");
export const WORDS : U64 = u64("4");


export class DU256 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "DU256";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "v0", typeTag: AtomicTypeTag.U64 },
  { name: "v1", typeTag: AtomicTypeTag.U64 },
  { name: "v2", typeTag: AtomicTypeTag.U64 },
  { name: "v3", typeTag: AtomicTypeTag.U64 },
  { name: "v4", typeTag: AtomicTypeTag.U64 },
  { name: "v5", typeTag: AtomicTypeTag.U64 },
  { name: "v6", typeTag: AtomicTypeTag.U64 },
  { name: "v7", typeTag: AtomicTypeTag.U64 }];

  v0: U64;
  v1: U64;
  v2: U64;
  v3: U64;
  v4: U64;
  v5: U64;
  v6: U64;
  v7: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.v0 = proto['v0'] as U64;
    this.v1 = proto['v1'] as U64;
    this.v2 = proto['v2'] as U64;
    this.v3 = proto['v3'] as U64;
    this.v4 = proto['v4'] as U64;
    this.v5 = proto['v5'] as U64;
    this.v6 = proto['v6'] as U64;
    this.v7 = proto['v7'] as U64;
  }

  static DU256Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : DU256 {
    const proto = $.parseStructProto(data, typeTag, repo, DU256);
    return new DU256(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "DU256", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }

}

export class U256 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName: string = "U256";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "v0", typeTag: AtomicTypeTag.U64 },
  { name: "v1", typeTag: AtomicTypeTag.U64 },
  { name: "v2", typeTag: AtomicTypeTag.U64 },
  { name: "v3", typeTag: AtomicTypeTag.U64 }];

  v0: U64;
  v1: U64;
  v2: U64;
  v3: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.v0 = proto['v0'] as U64;
    this.v1 = proto['v1'] as U64;
    this.v2 = proto['v2'] as U64;
    this.v3 = proto['v3'] as U64;
  }

  static U256Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : U256 {
    const proto = $.parseStructProto(data, typeTag, repo, U256);
    return new U256(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "U256", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }

}
export function add_ (
  a: U256,
  b: U256,
  $c: AptosDataCache,
): U256 {
  let a1, b1, carry, i, is_overflow, is_overflow1, is_overflow2, res, res1, res2, ret;
  ret = zero_($c);
  carry = u64("0");
  i = u64("0");
  while (($.copy(i)).lt($.copy(WORDS))) {
    {
      a1 = get_(a, $.copy(i), $c);
      b1 = get_(b, $.copy(i), $c);
      if (($.copy(carry)).neq(u64("0"))) {
        [res1, is_overflow1] = overflowing_add_($.copy(a1), $.copy(b1), $c);
        [res2, is_overflow2] = overflowing_add_($.copy(res1), $.copy(carry), $c);
        put_(ret, $.copy(i), $.copy(res2), $c);
        carry = u64("0");
        if (is_overflow1) {
          carry = ($.copy(carry)).add(u64("1"));
        }
        else{
        }
        if (is_overflow2) {
          carry = ($.copy(carry)).add(u64("1"));
        }
        else{
        }
      }
      else{
        [res, is_overflow] = overflowing_add_($.copy(a1), $.copy(b1), $c);
        put_(ret, $.copy(i), $.copy(res), $c);
        carry = u64("0");
        if (is_overflow) {
          carry = u64("1");
        }
        else{
        }
      }
      i = ($.copy(i)).add(u64("1"));
    }

  }if (!($.copy(carry)).eq((u64("0")))) {
    throw $.abortCode($.copy(EOVERFLOW));
  }
  return $.copy(ret);
}

export function and_ (
  a: U256,
  b: U256,
  $c: AptosDataCache,
): U256 {
  let i, m, ret;
  ret = zero_($c);
  i = u64("0");
  while (($.copy(i)).lt($.copy(WORDS))) {
    {
      m = (get_(a, $.copy(i), $c)).and(get_(b, $.copy(i), $c));
      put_(ret, $.copy(i), $.copy(m), $c);
      i = ($.copy(i)).add(u64("1"));
    }

  }return $.copy(ret);
}

export function as_u128_ (
  a: U256,
  $c: AptosDataCache,
): U128 {
  let temp$1;
  if (($.copy(a.v2)).eq((u64("0")))) {
    temp$1 = ($.copy(a.v3)).eq((u64("0")));
  }
  else{
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode($.copy(ECAST_OVERFLOW));
  }
  return ((u128($.copy(a.v1))).shl(u8("64"))).add(u128($.copy(a.v0)));
}

export function as_u64_ (
  a: U256,
  $c: AptosDataCache,
): U64 {
  let temp$1, temp$2;
  if (($.copy(a.v1)).eq((u64("0")))) {
    temp$1 = ($.copy(a.v2)).eq((u64("0")));
  }
  else{
    temp$1 = false;
  }
  if (temp$1) {
    temp$2 = ($.copy(a.v3)).eq((u64("0")));
  }
  else{
    temp$2 = false;
  }
  if (!temp$2) {
    throw $.abortCode($.copy(ECAST_OVERFLOW));
  }
  return $.copy(a.v0);
}

export function bits_ (
  a: U256,
  $c: AptosDataCache,
): U64 {
  let a1, a1__1, i;
  i = u64("1");
  while (($.copy(i)).lt($.copy(WORDS))) {
    {
      a1 = get_(a, ($.copy(WORDS)).sub($.copy(i)), $c);
      if (($.copy(a1)).gt(u64("0"))) {
        return ((u64("64")).mul((($.copy(WORDS)).sub($.copy(i))).add(u64("1")))).sub(u64(leading_zeros_u64_($.copy(a1), $c)));
      }
      else{
      }
      i = ($.copy(i)).add(u64("1"));
    }

  }a1__1 = get_(a, u64("0"), $c);
  return (u64("64")).sub(u64(leading_zeros_u64_($.copy(a1__1), $c)));
}

export function compare_ (
  a: U256,
  b: U256,
  $c: AptosDataCache,
): U8 {
  let a1, b1, i;
  i = $.copy(WORDS);
  while (($.copy(i)).gt(u64("0"))) {
    {
      i = ($.copy(i)).sub(u64("1"));
      a1 = get_(a, $.copy(i), $c);
      b1 = get_(b, $.copy(i), $c);
      if (($.copy(a1)).neq($.copy(b1))) {
        if (($.copy(a1)).lt($.copy(b1))) {
          return $.copy(LESS_THAN);
        }
        else{
          return $.copy(GREATER_THAN);
        }
      }
      else{
      }
    }

  }return $.copy(EQUAL);
}

export function div_ (
  a: U256,
  b: U256,
  $c: AptosDataCache,
): U256 {
  let temp$1, a_bits, b_bits, c, cmp, index, m, ret, shift;
  ret = zero_($c);
  a_bits = bits_(a, $c);
  b_bits = bits_(b, $c);
  if (!($.copy(b_bits)).neq(u64("0"))) {
    throw $.abortCode($.copy(EDIV_BY_ZERO));
  }
  if (($.copy(a_bits)).lt($.copy(b_bits))) {
    return $.copy(ret);
  }
  else{
  }
  shift = ($.copy(a_bits)).sub($.copy(b_bits));
  b = shl_($.copy(b), u8($.copy(shift)), $c);
  while (true) {
    cmp = compare_(a, b, $c);
    if (($.copy(cmp)).eq(($.copy(GREATER_THAN)))) {
      temp$1 = true;
    }
    else{
      temp$1 = ($.copy(cmp)).eq(($.copy(EQUAL)));
    }
    if (temp$1) {
      index = ($.copy(shift)).div(u64("64"));
      m = get_(ret, $.copy(index), $c);
      c = ($.copy(m)).or((u64("1")).shl(u8(($.copy(shift)).mod(u64("64")))));
      put_(ret, $.copy(index), $.copy(c), $c);
      a = sub_($.copy(a), $.copy(b), $c);
    }
    else{
    }
    b = shr_($.copy(b), u8("1"), $c);
    if (($.copy(shift)).eq((u64("0")))) {
      break;
    }
    else{
    }
    shift = ($.copy(shift)).sub(u64("1"));
  }
  return $.copy(ret);
}

export function du256_to_u256_ (
  a: DU256,
  $c: AptosDataCache,
): [U256, boolean] {
  let temp$1, temp$2, temp$3, b, overflow;
  b = new U256({ v0: $.copy(a.v0), v1: $.copy(a.v1), v2: $.copy(a.v2), v3: $.copy(a.v3) }, new SimpleStructTag(U256));
  overflow = false;
  if (($.copy(a.v4)).neq(u64("0"))) {
    temp$1 = true;
  }
  else{
    temp$1 = ($.copy(a.v5)).neq(u64("0"));
  }
  if (temp$1) {
    temp$2 = true;
  }
  else{
    temp$2 = ($.copy(a.v6)).neq(u64("0"));
  }
  if (temp$2) {
    temp$3 = true;
  }
  else{
    temp$3 = ($.copy(a.v7)).neq(u64("0"));
  }
  if (temp$3) {
    overflow = true;
  }
  else{
  }
  return [$.copy(b), overflow];
}

export function from_bytes_ (
  a: U8[],
  $c: AptosDataCache,
): U256 {
  let ret;
  if (!(Stdlib.Vector.length_(a, $c, [AtomicTypeTag.U8])).eq((u64("32")))) {
    throw $.abortCode($.copy(EVECTOR_LENGTH_NOT_32_BYTES));
  }
  ret = zero_($c);
  put_(ret, u64("0"), ((((((((u64($.copy(Stdlib.Vector.borrow_(a, u64("0"), $c, [AtomicTypeTag.U8])))).shl(u8("7"))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("1"), $c, [AtomicTypeTag.U8])))).shl(u8("6")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("2"), $c, [AtomicTypeTag.U8])))).shl(u8("5")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("3"), $c, [AtomicTypeTag.U8])))).shl(u8("4")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("4"), $c, [AtomicTypeTag.U8])))).shl(u8("3")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("5"), $c, [AtomicTypeTag.U8])))).shl(u8("2")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("6"), $c, [AtomicTypeTag.U8])))).shl(u8("1")))).add(u64($.copy(Stdlib.Vector.borrow_(a, u64("7"), $c, [AtomicTypeTag.U8])))), $c);
  put_(ret, u64("1"), ((((((((u64($.copy(Stdlib.Vector.borrow_(a, u64("8"), $c, [AtomicTypeTag.U8])))).shl(u8("7"))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("9"), $c, [AtomicTypeTag.U8])))).shl(u8("6")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("10"), $c, [AtomicTypeTag.U8])))).shl(u8("5")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("11"), $c, [AtomicTypeTag.U8])))).shl(u8("4")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("12"), $c, [AtomicTypeTag.U8])))).shl(u8("3")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("13"), $c, [AtomicTypeTag.U8])))).shl(u8("2")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("14"), $c, [AtomicTypeTag.U8])))).shl(u8("1")))).add(u64($.copy(Stdlib.Vector.borrow_(a, u64("15"), $c, [AtomicTypeTag.U8])))), $c);
  put_(ret, u64("2"), ((((((((u64($.copy(Stdlib.Vector.borrow_(a, u64("16"), $c, [AtomicTypeTag.U8])))).shl(u8("7"))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("17"), $c, [AtomicTypeTag.U8])))).shl(u8("6")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("18"), $c, [AtomicTypeTag.U8])))).shl(u8("5")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("19"), $c, [AtomicTypeTag.U8])))).shl(u8("4")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("20"), $c, [AtomicTypeTag.U8])))).shl(u8("3")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("21"), $c, [AtomicTypeTag.U8])))).shl(u8("2")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("22"), $c, [AtomicTypeTag.U8])))).shl(u8("1")))).add(u64($.copy(Stdlib.Vector.borrow_(a, u64("23"), $c, [AtomicTypeTag.U8])))), $c);
  put_(ret, u64("3"), ((((((((u64($.copy(Stdlib.Vector.borrow_(a, u64("24"), $c, [AtomicTypeTag.U8])))).shl(u8("7"))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("25"), $c, [AtomicTypeTag.U8])))).shl(u8("6")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("26"), $c, [AtomicTypeTag.U8])))).shl(u8("5")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("27"), $c, [AtomicTypeTag.U8])))).shl(u8("4")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("28"), $c, [AtomicTypeTag.U8])))).shl(u8("3")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("29"), $c, [AtomicTypeTag.U8])))).shl(u8("2")))).add((u64($.copy(Stdlib.Vector.borrow_(a, u64("30"), $c, [AtomicTypeTag.U8])))).shl(u8("1")))).add(u64($.copy(Stdlib.Vector.borrow_(a, u64("31"), $c, [AtomicTypeTag.U8])))), $c);
  return $.copy(ret);
}

export function from_u128_ (
  val: U128,
  $c: AptosDataCache,
): U256 {
  let a1, a2;
  [a2, a1] = split_u128_($.copy(val), $c);
  return new U256({ v0: $.copy(a1), v1: $.copy(a2), v2: u64("0"), v3: u64("0") }, new SimpleStructTag(U256));
}

export function from_u64_ (
  val: U64,
  $c: AptosDataCache,
): U256 {
  return from_u128_(u128($.copy(val)), $c);
}

export function get_ (
  a: U256,
  i: U64,
  $c: AptosDataCache,
): U64 {
  let temp$1, temp$2, temp$3, temp$4;
  if (($.copy(i)).eq((u64("0")))) {
    temp$4 = $.copy(a.v0);
  }
  else{
    if (($.copy(i)).eq((u64("1")))) {
      temp$3 = $.copy(a.v1);
    }
    else{
      if (($.copy(i)).eq((u64("2")))) {
        temp$2 = $.copy(a.v2);
      }
      else{
        if (($.copy(i)).eq((u64("3")))) {
          temp$1 = $.copy(a.v3);
        }
        else{
          throw $.abortCode($.copy(EWORDS_OVERFLOW));
        }
        temp$2 = temp$1;
      }
      temp$3 = temp$2;
    }
    temp$4 = temp$3;
  }
  return temp$4;
}

export function get_d_ (
  a: DU256,
  i: U64,
  $c: AptosDataCache,
): U64 {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8;
  if (($.copy(i)).eq((u64("0")))) {
    temp$8 = $.copy(a.v0);
  }
  else{
    if (($.copy(i)).eq((u64("1")))) {
      temp$7 = $.copy(a.v1);
    }
    else{
      if (($.copy(i)).eq((u64("2")))) {
        temp$6 = $.copy(a.v2);
      }
      else{
        if (($.copy(i)).eq((u64("3")))) {
          temp$5 = $.copy(a.v3);
        }
        else{
          if (($.copy(i)).eq((u64("4")))) {
            temp$4 = $.copy(a.v4);
          }
          else{
            if (($.copy(i)).eq((u64("5")))) {
              temp$3 = $.copy(a.v5);
            }
            else{
              if (($.copy(i)).eq((u64("6")))) {
                temp$2 = $.copy(a.v6);
              }
              else{
                if (($.copy(i)).eq((u64("7")))) {
                  temp$1 = $.copy(a.v7);
                }
                else{
                  throw $.abortCode($.copy(EWORDS_OVERFLOW));
                }
                temp$2 = temp$1;
              }
              temp$3 = temp$2;
            }
            temp$4 = temp$3;
          }
          temp$5 = temp$4;
        }
        temp$6 = temp$5;
      }
      temp$7 = temp$6;
    }
    temp$8 = temp$7;
  }
  return temp$8;
}

export function leading_zeros_u64_ (
  a: U64,
  $c: AptosDataCache,
): U8 {
  let temp$3, a1, a2, b, b__2, bit, bit__1;
  if (($.copy(a)).eq((u64("0")))) {
    return u8("64");
  }
  else{
  }
  a1 = ($.copy(a)).and(u64("4294967295"));
  a2 = ($.copy(a)).shr(u8("32"));
  if (($.copy(a2)).eq((u64("0")))) {
    bit = u8("32");
    while (($.copy(bit)).ge(u8("1"))) {
      {
        b = (($.copy(a1)).shr(($.copy(bit)).sub(u8("1")))).and(u64("1"));
        if (($.copy(b)).neq(u64("0"))) {
          break;
        }
        else{
        }
        bit = ($.copy(bit)).sub(u8("1"));
      }

    }temp$3 = ((u8("32")).sub($.copy(bit))).add(u8("32"));
  }
  else{
    bit__1 = u8("64");
    while (($.copy(bit__1)).ge(u8("1"))) {
      {
        b__2 = (($.copy(a)).shr(($.copy(bit__1)).sub(u8("1")))).and(u64("1"));
        if (($.copy(b__2)).neq(u64("0"))) {
          break;
        }
        else{
        }
        bit__1 = ($.copy(bit__1)).sub(u8("1"));
      }

    }temp$3 = (u8("64")).sub($.copy(bit__1));
  }
  return temp$3;
}

export function mul_ (
  a: U256,
  b: U256,
  $c: AptosDataCache,
): U256 {
  let temp$1, temp$3, temp$7, a1, b1, carry, existing_hi, existing_low, hi, hi__4, hi__5, hi__6, i, j, low, low__2, o, o0, o1, overflow, overflow__8, r, ret;
  ret = new DU256({ v0: u64("0"), v1: u64("0"), v2: u64("0"), v3: u64("0"), v4: u64("0"), v5: u64("0"), v6: u64("0"), v7: u64("0") }, new SimpleStructTag(DU256));
  i = u64("0");
  while (($.copy(i)).lt($.copy(WORDS))) {
    {
      carry = u64("0");
      b1 = get_(b, $.copy(i), $c);
      j = u64("0");
      while (($.copy(j)).lt($.copy(WORDS))) {
        {
          a1 = get_(a, $.copy(j), $c);
          if (($.copy(a1)).neq(u64("0"))) {
            temp$1 = true;
          }
          else{
            temp$1 = ($.copy(carry)).neq(u64("0"));
          }
          if (temp$1) {
            [hi, low] = split_u128_((u128($.copy(a1))).mul(u128($.copy(b1))), $c);
            existing_low = get_d_(ret, ($.copy(i)).add($.copy(j)), $c);
            [low__2, o] = overflowing_add_($.copy(low), $.copy(existing_low), $c);
            put_d_(ret, ($.copy(i)).add($.copy(j)), $.copy(low__2), $c);
            if (o) {
              temp$3 = u64("1");
            }
            else{
              temp$3 = u64("0");
            }
            overflow = temp$3;
            existing_hi = get_d_(ret, (($.copy(i)).add($.copy(j))).add(u64("1")), $c);
            hi__4 = ($.copy(hi)).add($.copy(overflow));
            [hi__5, o0] = overflowing_add_($.copy(hi__4), $.copy(carry), $c);
            [hi__6, o1] = overflowing_add_($.copy(hi__5), $.copy(existing_hi), $c);
            put_d_(ret, (($.copy(i)).add($.copy(j))).add(u64("1")), $.copy(hi__6), $c);
            if ((o0 || o1)) {
              temp$7 = u64("1");
            }
            else{
              temp$7 = u64("0");
            }
            carry = temp$7;
          }
          else{
          }
          j = ($.copy(j)).add(u64("1"));
        }

      }i = ($.copy(i)).add(u64("1"));
    }

  }[r, overflow__8] = du256_to_u256_($.copy(ret), $c);
  if (!!overflow__8) {
    throw $.abortCode($.copy(EOVERFLOW));
  }
  return $.copy(r);
}

export function or_ (
  a: U256,
  b: U256,
  $c: AptosDataCache,
): U256 {
  let i, m, ret;
  ret = zero_($c);
  i = u64("0");
  while (($.copy(i)).lt($.copy(WORDS))) {
    {
      m = (get_(a, $.copy(i), $c)).or(get_(b, $.copy(i), $c));
      put_(ret, $.copy(i), $.copy(m), $c);
      i = ($.copy(i)).add(u64("1"));
    }

  }return $.copy(ret);
}

export function overflowing_add_ (
  a: U64,
  b: U64,
  $c: AptosDataCache,
): [U64, boolean] {
  let temp$1, temp$2, a128, b128, overflow, r;
  a128 = u128($.copy(a));
  b128 = u128($.copy(b));
  r = ($.copy(a128)).add($.copy(b128));
  if (($.copy(r)).gt($.copy(U64_MAX))) {
    overflow = (($.copy(r)).sub($.copy(U64_MAX))).sub(u128("1"));
    [temp$1, temp$2] = [u64($.copy(overflow)), true];
  }
  else{
    [temp$1, temp$2] = [u64(($.copy(a128)).add($.copy(b128))), false];
  }
  return [temp$1, temp$2];
}

export function overflowing_sub_ (
  a: U64,
  b: U64,
  $c: AptosDataCache,
): [U64, boolean] {
  let temp$1, temp$2, r;
  if (($.copy(a)).lt($.copy(b))) {
    r = ($.copy(b)).sub($.copy(a));
    [temp$1, temp$2] = [((u64($.copy(U64_MAX))).sub($.copy(r))).add(u64("1")), true];
  }
  else{
    [temp$1, temp$2] = [($.copy(a)).sub($.copy(b)), false];
  }
  return [temp$1, temp$2];
}

export function put_ (
  a: U256,
  i: U64,
  val: U64,
  $c: AptosDataCache,
): void {
  if (($.copy(i)).eq((u64("0")))) {
    a.v0 = $.copy(val);
  }
  else{
    if (($.copy(i)).eq((u64("1")))) {
      a.v1 = $.copy(val);
    }
    else{
      if (($.copy(i)).eq((u64("2")))) {
        a.v2 = $.copy(val);
      }
      else{
        if (($.copy(i)).eq((u64("3")))) {
          a.v3 = $.copy(val);
        }
        else{
          throw $.abortCode($.copy(EWORDS_OVERFLOW));
        }
      }
    }
  }
  return;
}

export function put_d_ (
  a: DU256,
  i: U64,
  val: U64,
  $c: AptosDataCache,
): void {
  if (($.copy(i)).eq((u64("0")))) {
    a.v0 = $.copy(val);
  }
  else{
    if (($.copy(i)).eq((u64("1")))) {
      a.v1 = $.copy(val);
    }
    else{
      if (($.copy(i)).eq((u64("2")))) {
        a.v2 = $.copy(val);
      }
      else{
        if (($.copy(i)).eq((u64("3")))) {
          a.v3 = $.copy(val);
        }
        else{
          if (($.copy(i)).eq((u64("4")))) {
            a.v4 = $.copy(val);
          }
          else{
            if (($.copy(i)).eq((u64("5")))) {
              a.v5 = $.copy(val);
            }
            else{
              if (($.copy(i)).eq((u64("6")))) {
                a.v6 = $.copy(val);
              }
              else{
                if (($.copy(i)).eq((u64("7")))) {
                  a.v7 = $.copy(val);
                }
                else{
                  throw $.abortCode($.copy(EWORDS_OVERFLOW));
                }
              }
            }
          }
        }
      }
    }
  }
  return;
}

export function shl_ (
  a: U256,
  shift: U8,
  $c: AptosDataCache,
): U256 {
  let bit_shift, i, j, m, m__1, ret, word_shift;
  ret = zero_($c);
  word_shift = (u64($.copy(shift))).div(u64("64"));
  bit_shift = (u64($.copy(shift))).mod(u64("64"));
  i = $.copy(word_shift);
  while (($.copy(i)).lt($.copy(WORDS))) {
    {
      m = (get_(a, ($.copy(i)).sub($.copy(word_shift)), $c)).shl(u8($.copy(bit_shift)));
      put_(ret, $.copy(i), $.copy(m), $c);
      i = ($.copy(i)).add(u64("1"));
    }

  }if (($.copy(bit_shift)).gt(u64("0"))) {
    j = ($.copy(word_shift)).add(u64("1"));
    while (($.copy(j)).lt($.copy(WORDS))) {
      {
        m__1 = (get_(ret, $.copy(j), $c)).add((get_(a, (($.copy(j)).sub(u64("1"))).sub($.copy(word_shift)), $c)).shr((u8("64")).sub(u8($.copy(bit_shift)))));
        put_(ret, $.copy(j), $.copy(m__1), $c);
        j = ($.copy(j)).add(u64("1"));
      }

    }}
  else{
  }
  return $.copy(ret);
}

export function shr_ (
  a: U256,
  shift: U8,
  $c: AptosDataCache,
): U256 {
  let bit_shift, i, j, m, m__1, ret, word_shift;
  ret = zero_($c);
  word_shift = (u64($.copy(shift))).div(u64("64"));
  bit_shift = (u64($.copy(shift))).mod(u64("64"));
  i = $.copy(word_shift);
  while (($.copy(i)).lt($.copy(WORDS))) {
    {
      m = (get_(a, $.copy(i), $c)).shr(u8($.copy(bit_shift)));
      put_(ret, ($.copy(i)).sub($.copy(word_shift)), $.copy(m), $c);
      i = ($.copy(i)).add(u64("1"));
    }

  }if (($.copy(bit_shift)).gt(u64("0"))) {
    j = ($.copy(word_shift)).add(u64("1"));
    while (($.copy(j)).lt($.copy(WORDS))) {
      {
        m__1 = (get_(ret, (($.copy(j)).sub($.copy(word_shift))).sub(u64("1")), $c)).add((get_(a, $.copy(j), $c)).shl((u8("64")).sub(u8($.copy(bit_shift)))));
        put_(ret, (($.copy(j)).sub($.copy(word_shift))).sub(u64("1")), $.copy(m__1), $c);
        j = ($.copy(j)).add(u64("1"));
      }

    }}
  else{
  }
  return $.copy(ret);
}

export function split_u128_ (
  a: U128,
  $c: AptosDataCache,
): [U64, U64] {
  let a1, a2;
  a1 = u64(($.copy(a)).shr(u8("64")));
  a2 = u64(($.copy(a)).and(u128("18446744073709551615")));
  return [$.copy(a1), $.copy(a2)];
}

export function sub_ (
  a: U256,
  b: U256,
  $c: AptosDataCache,
): U256 {
  let a1, b1, carry, i, is_overflow, is_overflow1, is_overflow2, res, res1, res2, ret;
  ret = zero_($c);
  carry = u64("0");
  i = u64("0");
  while (($.copy(i)).lt($.copy(WORDS))) {
    {
      a1 = get_(a, $.copy(i), $c);
      b1 = get_(b, $.copy(i), $c);
      if (($.copy(carry)).neq(u64("0"))) {
        [res1, is_overflow1] = overflowing_sub_($.copy(a1), $.copy(b1), $c);
        [res2, is_overflow2] = overflowing_sub_($.copy(res1), $.copy(carry), $c);
        put_(ret, $.copy(i), $.copy(res2), $c);
        carry = u64("0");
        if (is_overflow1) {
          carry = ($.copy(carry)).add(u64("1"));
        }
        else{
        }
        if (is_overflow2) {
          carry = ($.copy(carry)).add(u64("1"));
        }
        else{
        }
      }
      else{
        [res, is_overflow] = overflowing_sub_($.copy(a1), $.copy(b1), $c);
        put_(ret, $.copy(i), $.copy(res), $c);
        carry = u64("0");
        if (is_overflow) {
          carry = u64("1");
        }
        else{
        }
      }
      i = ($.copy(i)).add(u64("1"));
    }

  }if (!($.copy(carry)).eq((u64("0")))) {
    throw $.abortCode($.copy(EOVERFLOW));
  }
  return $.copy(ret);
}

export function to_bytes_ (
  a: U256,
  $c: AptosDataCache,
): U8[] {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8, ret;
  ret = Stdlib.Vector.empty_($c, [AtomicTypeTag.U8]);
  temp$2 = ret;
  temp$1 = get_(a, u64("0"), $c);
  Stdlib.Vector.append_(temp$2, Stdlib.Bcs.to_bytes_(temp$1, $c, [AtomicTypeTag.U64]), $c, [AtomicTypeTag.U8]);
  temp$4 = ret;
  temp$3 = get_(a, u64("1"), $c);
  Stdlib.Vector.append_(temp$4, Stdlib.Bcs.to_bytes_(temp$3, $c, [AtomicTypeTag.U64]), $c, [AtomicTypeTag.U8]);
  temp$6 = ret;
  temp$5 = get_(a, u64("2"), $c);
  Stdlib.Vector.append_(temp$6, Stdlib.Bcs.to_bytes_(temp$5, $c, [AtomicTypeTag.U64]), $c, [AtomicTypeTag.U8]);
  temp$8 = ret;
  temp$7 = get_(a, u64("3"), $c);
  Stdlib.Vector.append_(temp$8, Stdlib.Bcs.to_bytes_(temp$7, $c, [AtomicTypeTag.U64]), $c, [AtomicTypeTag.U8]);
  return $.copy(ret);
}

export function xor_ (
  a: U256,
  b: U256,
  $c: AptosDataCache,
): U256 {
  let i, m, ret;
  ret = zero_($c);
  i = u64("0");
  while (($.copy(i)).lt($.copy(WORDS))) {
    {
      m = (get_(a, $.copy(i), $c)).xor(get_(b, $.copy(i), $c));
      put_(ret, $.copy(i), $.copy(m), $c);
      i = ($.copy(i)).add(u64("1"));
    }

  }return $.copy(ret);
}

export function zero_ (
  $c: AptosDataCache,
): U256 {
  return new U256({ v0: u64("0"), v1: u64("0"), v2: u64("0"), v3: u64("0") }, new SimpleStructTag(U256));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219::u256::DU256", DU256.DU256Parser);
  repo.addParser("0x23f2032cdea2fd00e53834a1e6c488b9ee7dac3e5591a4ea30646e4ff1afc219::u256::U256", U256.U256Parser);
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
  get DU256() { return DU256; }
  get U256() { return U256; }
}

