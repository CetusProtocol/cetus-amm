
import { AptosClient } from "aptos";
import { AptosParserRepo, AptosLocalCache } from "@manahippo/move-to-ts";
import * as cetus_amm from './cetus_amm';
import * as stdlib from './stdlib';

export * as cetus_amm from './cetus_amm';
export * as stdlib from './stdlib';


export function getProjectRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  cetus_amm.loadParsers(repo);
  stdlib.loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}

export class App {
  parserRepo: AptosParserRepo;
  cache: AptosLocalCache;
  cetus_amm : cetus_amm.App
  stdlib : stdlib.App
  constructor(
    public client: AptosClient,
  ) {
    this.parserRepo = getProjectRepo();
    this.cache = new AptosLocalCache();
    this.cetus_amm = new cetus_amm.App(client, this.parserRepo, this.cache);
    this.stdlib = new stdlib.App(client, this.parserRepo, this.cache);
  }
}
