
import { AptosClient } from "aptos";
import { AptosParserRepo, AptosLocalCache } from "@manahippo/move-to-ts";
import * as Amm_config from './amm_config';
import * as Amm_math from './amm_math';
import * as Amm_router from './amm_router';
import * as Amm_script from './amm_script';
import * as Amm_swap from './amm_swap';
import * as Amm_utils from './amm_utils';
import * as U256 from './u256';

export * as Amm_config from './amm_config';
export * as Amm_math from './amm_math';
export * as Amm_router from './amm_router';
export * as Amm_script from './amm_script';
export * as Amm_swap from './amm_swap';
export * as Amm_utils from './amm_utils';
export * as U256 from './u256';


export function loadParsers(repo: AptosParserRepo) {
  Amm_config.loadParsers(repo);
  Amm_math.loadParsers(repo);
  Amm_router.loadParsers(repo);
  Amm_script.loadParsers(repo);
  Amm_swap.loadParsers(repo);
  Amm_utils.loadParsers(repo);
  U256.loadParsers(repo);
}

export function getPackageRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}

export type AppType = {
  client: AptosClient,
  repo: AptosParserRepo,
  cache: AptosLocalCache,
};

export class App {
  amm_config : Amm_config.App
  amm_math : Amm_math.App
  amm_router : Amm_router.App
  amm_script : Amm_script.App
  amm_swap : Amm_swap.App
  amm_utils : Amm_utils.App
  u256 : U256.App
  constructor(
    public client: AptosClient,
    public repo: AptosParserRepo,
    public cache: AptosLocalCache,
  ) {
    this.amm_config = new Amm_config.App(client, repo, cache);
    this.amm_math = new Amm_math.App(client, repo, cache);
    this.amm_router = new Amm_router.App(client, repo, cache);
    this.amm_script = new Amm_script.App(client, repo, cache);
    this.amm_swap = new Amm_swap.App(client, repo, cache);
    this.amm_utils = new Amm_utils.App(client, repo, cache);
    this.u256 = new U256.App(client, repo, cache);
  }
}
