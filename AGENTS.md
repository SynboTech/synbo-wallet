# Project Instructions

This is a Flutter multi-chain token wallet app.

## Product Scope: Phase 1

Only build the core wallet experience:
- Wallet
- Activity
- Me

Do not add or expose:
- DApp Browser
- Swap
- Bridge
- Buy / Sell
- Earn / Stake
- NFT list
- Portfolio standalone page
- Contacts

## Bottom Navigation

The bottom navigation must only include:
1. Wallet
2. Activity
3. Me

## UI Principles

The app should feel:
- clean
- premium
- lightweight
- financial-grade
- mobile-first
- secure

Do not copy MetaMask visuals.
Do not use fox imagery.
Do not use MetaMask orange as the main visual identity.

## Wallet Home

The wallet home must prioritize:
- current wallet
- current account address
- network switch
- total assets
- token list
- Send
- Receive
- Scan

## Safety

Transaction confirmation pages must clearly show:
- From
- To
- Network
- Token
- Amount
- Gas Fee
- Total
- Risk warning

Never hide critical transaction information for visual simplicity.

## Engineering Rules

Before finishing any task:
- run dart format
- run flutter analyze
- run flutter test if tests exist

Prefer small, safe changes.
Do not introduce unnecessary large dependencies.
Preserve future extension points for WalletConnect, DApp permissions, and multi-chain adapters.
