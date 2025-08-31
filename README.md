# Bitcoin Asia — MIDL's regtest replica

This repository is a replication of the current MIDL `bitcoind` regtest setup. It provides a ready-to-run regtest `bitcoind` and an auxiliary container that periodically mines blocks (creates UTXOs) so you can develop and test a UTXO indexer locally.

## Files of interest

- `docker-compose.yaml` — starts `bitcoind` (regtest) and an `automine` service that periodically runs `bitcoin-cli generatetoaddress`.
- `bitcoin/` — mounted into the containers as `/home/bitcoin/.bitcoin` and contains `bitcoin.conf`, chainstate, and blocks used by the regtest node.

## Quick start

Download the regtest data (chainstate, blocks, indexes) from the latest GitHub release:

```sh
DATA_URL="https://github.com/midl-xyz/bitcoin-asia-bitcoind/releases/download/v1.1/bitcoin-regtest-data-106480.tar.gz" ./scripts/download_data.sh ./
```


Build and start the services (foreground):

```fish
docker compose up --build
```

Start the daemon in background and leave automining running (recommended for development):

```fish
docker compose up --build -d bitcoind automine
```

View logs:

```fish
docker compose logs -f bitcoind
```

Restart the automine loop after edits:

```fish
docker compose restart automine
```

## Verify RPC and UTXOs

There is a regtest address in this repository that contains multiple UTXOs:

bcrt1q2sufppgjc3tdgrmwgsvgct92qrjs75nsnjyfu0

To verify the UTXOs (runs against the node RPC on localhost:8332 with the built-in credentials `1:1`):

```sh
curl --user 1:1 \
  --data-binary '{
    "jsonrpc": "1.0",
    "id": "utxos",
    "method": "scantxoutset",
    "params": [
      "start",
      [
        { "desc": "addr(bcrt1q2sufppgjc3tdgrmwgsvgct92qrjs75nsnjyfu0)" }
      ]
    ]
  }' \
  -H 'content-type: text/plain;' \
  http://127.0.0.1:8332/
```

If the node is running in Docker and `8332` is published (the default in `docker-compose.yaml`), the curl command above will hit the RPC endpoint. If using a different host or port, update the URL and credentials accordingly.

## Maestro Symphony

Runs a local indexer for Bitcoin Runes using Maestro Symphony. The service is defined in `docker-compose.yaml` and connects to the `bitcoind` regtest node. You can access the Symphony web interface by navigating to `http://localhost:8080` in your web browser.

### Get rune balance by address

```
curl http://localhost:8080/addresses/bcrt1pqa434kh784hx9ey769g7c53w9js794c6js46z3td6h9zre4aj97s3etsdy/runes/balances
```



## Notes & assumptions

- The `docker-compose.yaml` in this repo mounts your local `./bitcoin` folder into the container at `/home/bitcoin/.bitcoin` so existing regtest data (blocks, chainstate, wallet, config) is preserved.
- The compose file expects the `Dockerfile` in the repo to provide `bitcoind` and `bitcoin-cli`. If your `Dockerfile` doesn't include those binaries, switch the services to use an official image (I can update the compose to use `ruimarinho/bitcoin-core` or similar on request).
- The `automine` service periodically calls `bitcoin-cli generatetoaddress` to ensure there are spendable UTXOs for development.

## Purpose

This repo is intended as a bootstrap for developing an indexer that scans, indexes, and serves Bitcoin UTXO data from a regtest node.

## Troubleshooting

- If RPC calls fail, verify the node is healthy and listening on `8332` and credentials in `bitcoin/bitcoin.conf` match `1:1` (the compose file starts `bitcoind` with `-rpcuser=1 -rpcpassword=1`).
- If `bitcoin-cli` is not found inside containers, ensure the `Dockerfile` installs the Bitcoin Core binaries or change the services to use a prebuilt image.

