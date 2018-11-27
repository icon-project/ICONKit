# ICONKit, ICON SDK for Swift
ICON supports SDK for 3rd party or user services development. You can integrate ICON SDK for your project and utilize ICON’s functionality.

## Quick start
A simple query of the block by height is as follows.
```swift
let service = ICONService(provider: "https://wallet.icon.foundation", nid: nid)

// Gets a block matching the block height.
let request: Request<Response.Block> = service.getBlock(height: height)
let result = request.execute()

switch result {
case: .success(let responseBlock):
    ...
case: .failure(let error):
    print(error)
}
```
## ICONService
APIs called through `ICONService`.

It can be initialized as follows.
```swift
let iconService = ICONService(provider: "https://wallet.icon.foundation", nid: nid)
```

## Queries
All queries are requested by a `Request`.

Its requests are executed as **Synchronized**.
(*will supports asynchronized version soon.*)

```swift
let request: Request<Response.Block> = service.getBlock(height: height)
let result = request.execute()

switch result {
case: .success(let responseBlock):
    ...
case: .failure(let error):
    print(error)
}
```
The querying APIs are as follows.
```swift
// Gets the block
let request: Request<Response.Block> = service.getBlock(height: height)
let request: Request<Response.Block> = service.getBlock(hash: "0x000...000")
let request: Request<Response.Block> = service.getLastBlock()

// Gets the balance of an given account
let request: Request<Response.Value> = service.getBalance(address: "hx000...000")

// Gets a list of ScoreAPI
let request: Request<Response.ScoreAPI> = service.getScoreAPI(scoreAddress: "cx000...000")

// Gets the total supply of ICX
let request: Request<Response.Value> = service.getTotalSupply()

// Gets a transaction matching the given transaction hash
let request: Request<Response.Transaction> = service.getTransaction(hash: "0x000...000")

// Gets the result of the transaction matching the given transaction hash
let request: Request<Response.TransactionResult> = service.getTransactionResult(hash: "0x000...000")

// Calls a SCORE API just for reading
let call = Call(from: wallet.address, to: scoreAddress, method: "balanceOf", params: params)
let request: Request<Response.Value> = service.call(call)
```
## Sending transactions
Calling SCORE APIs to change states is requested as sending a transaction.

Before sending a transaction, the transaction should be signed.

### Creating transactions
```swift
// Sending ICX
let transaction = Transaction()
    .from(wallet.address)
    .to(to)
    .value(BigUInt(15000000))
    .stepLimit(BigUInt(1000000))
    .nonce("0x1")
    .nid(service.nid)

// Call
let transaction = Transaction()
    .from(wallet.address)
    .to(scoreAddress)
    .stepLimit(BigUInt(1000000))
    .call("transfer")
    .nonce("0x1")
    .nid(service.nid)
    .params(["_to": to, "_value": "0x1234"])

// Message
let transaction = Transaction()
    .from(wallet.address)
    .to(to)
    .value(BigUInt(15000000))
    .stepLimit(BigUInt(1000000))
    .message("Hello, World!")
    .nonce("0x1")
    .nid(service.nid)
```
`SignedTransaction` object signs a transaction using the `private key`.

And a request is executed as **Synchronized** like a querying request.

```swift
do {
    let signed = try SignedTransaction(transaction: transaction, privateKey: privateKey)

    let request = Request<Response.TxHash> = service.sendTransaction(signedTransaction: signed)
    ...
} catch {
    print(error)
    ...
}
```
## Reference
- [ICON JSON-RPC API v3](https://github.com/icon-project/icon-rpc-server/blob/master/docs/icon-json-rpc-v3.md)
- [ICON Network](https://github.com/icon-project/icon-project.github.io/blob/master/docs/icon_network.md)

## Version
0.2.1 (Beta)

## Support
- Xcode 10.x
- iOS 10 or higher
- Swift 4
- [Cocoapods](https://cocoapods.org)

### Cocoapods
[Cocoapods](https://cocoapods.org) is a dependency manager for Swift Cocoa projects.
