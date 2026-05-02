# SYNBO Production Readiness

This checklist tracks what is already aligned with Phase 1 scope and what still needs to be completed before a production release.

## Done in the current codebase

- Bottom navigation is limited to `Wallet`, `Activity`, and `Me`.
- Wallet home prioritizes wallet identity, address, network switcher, total assets, token list, and `Send` / `Receive` / `Scan`.
- Transaction confirmation shows `From`, `To`, `Network`, `Token`, `Amount`, `Gas Fee`, `Total`, and a visible risk warning.
- Activity scope is now limited to transaction and transfer records for Phase 1.
- Unlock no longer accepts any non-empty input; it validates the configured wallet password.
- Password hash and wallet security preferences are now persisted through a security repository backed by secure storage.
- App lifecycle locking, manual lock, biometric unlock, and sensitive-action re-auth are wired into the current shell.
- Seed wallet state now flows through repository interfaces instead of being embedded directly inside the UI state object.
- Wallet metadata, selected wallet/network, token visibility, and activity snapshot now persist through a durable local repository.
- Transfer preparation and wallet import now run through gateway interfaces, ready for real chain adapters and signers.
- The EVM read model is now split into a dedicated chain-read gateway for balances, ERC20 metadata, receipt polling, and tracked token log sync.
- Wallet refresh now pulls live native balances, ERC20 `name` / `symbol` / `decimals` / `balanceOf`, and syncs pending transaction receipts into activity status.
- Android release signing now supports a real `key.properties` + keystore setup instead of assuming debug signing only.

## Must complete before production release

- Replace remaining seeded wallet, token, network, and activity fixtures with real repositories and environment-specific data sources.
- Gate sensitive actions behind real password re-auth or biometrics:
  `backup mnemonic`, `export private key`, `delete wallet`, `switch security settings`.
  The current implementation covers the UI flows, but production should move these checks to a hardened vault/session layer.
- Extend screenshot/privacy protection beyond Android and validate behavior on iOS task switcher snapshots.
- Implement real wallet creation and import:
  mnemonic generation, mnemonic validation, encrypted key storage, account derivation, chain adapter boundaries.
- Implement real transfer preparation:
  address checksum validation, amount precision handling, gas estimation, nonce handling, RPC failure states, and submission retries.
- Add full transaction policy parity for production:
  EIP-1559 fee policy, replacement / speed-up / cancel flows, receipt backoff strategy, and block-timestamp-backed activity ordering.
- Expand chain-read coverage beyond tracked transfers:
  native transfer history, ERC20 allowance surfaces, approval revoke flows, and multi-account scoped activity indexing.
- Replace mock authorization data with real connected-app permissions and approval revocation flows.
- Add app lifecycle lock behavior:
  unlock throttling, failed-attempt protection, and device-bound session material.
- Localize product copy consistently. The current build still mixes Chinese and English strings.
- Add analytics/crash strategy only after privacy policy, consent, and sensitive-data filtering are defined.

## Engineering tasks for the next implementation rounds

1. Introduce repository interfaces for wallet vault, networks, assets, activity, and transaction signing.
2. Move seed fixtures behind development-only build wiring so release builds cannot ship with mock wallet state.
3. Replace the demo import and transfer gateways with real onboarding, signing, and RPC adapters:
   create wallet, import wallet, backup verification, and first-password setup.
4. Add release build lanes for `apk` and `appbundle`, then verify signing, versioning, and package identifiers.
5. Expand tests beyond widget smoke tests:
   state unit tests, validation tests, route tests, and high-risk transaction-confirmation scenarios.
