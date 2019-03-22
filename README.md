# ICONKit, ICON SDK for Swift

ICON supports SDK for 3rd party or user services development. You can integrate ICON SDK for your project and utilize ICON’s functionality.

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Swift Cocoa projects.

```
$ sudo gem install cocoapods
```

To integrate ICONKit into your project, specify it in your `Podfile`

```
target '<Your Target Name>' do
    use_frameworks!
    ...
    pod 'ICONKit', '~> 0.2.5'
    ...
end
```

Now install the ICONKit. 

```
$ pod install
```

## Result

ICONKit uses [Result](https://github.com/antitypical/Result) framework. All functions of ICONService returns Result<T, ICONResult>. `T` for successor, `ICONResult` for error.
Refer to [Result](https://github.com/antitypical/Result) for more detail.

## Quick start

A simple query of the block by height is as follows.

```Swift
// ICON Mainnet
let iconService = ICONService(provider: "https://ctz.solidwallet.io/api/v3", nid: "0x1")

// Gets a block matching the block height.
let request: Request<Response.Block> = iconService.getBlock(height: height)
let result = request.execute()

switch result {
case .success(let responseBlock):
    ...
case .failure(let error):
    ...
}
```

## ICONService

APIs called through `ICONService`.

It can be initialized as follows.

```Swift
let iconService = ICONService(provider: "https://ctz.solidwallet.io/api/v3", nid: "0x1")
```

## Queries

All queries are requested by a `Request<T>`.

#### Synchronous
`execute()` requests a query synchronously.

```Swift
let response = iconService.getLastBlock().execute()

switch response {
case .success(let responseBlock):
    print(responseBlock.blockHash)
    ...
case .failure(let error):
    print(error.errorDescription)
    ...
}
```

#### Asynchronous

You can request a query asynchronously using a `async` closure as below.

```swift
iconService.getLastBlock().async { (result) in
    switch result {
    case .success(let responseBlock):
      print(responseBlock.blockHash)
      ...
    case .failure(let error):
      print(err.errorDescription)
      ...
    }
}
```

The querying APIs are as follows.

```Swift
// Gets the block
let request: Request<Response.Block> = iconService.getBlock(height: height)
let request: Request<Response.Block> = iconService.getBlock(hash: "0x000...000")
let request: Request<Response.Block> = iconService.getLastBlock()

// Gets the balance of an given account
let request: Request<BigUInt> = iconService.getBalance(address: "hx000...1")

// Gets a list of ScoreAPI
let request: Request<Response.ScoreAPI> = iconService.getScoreAPI(scoreAddress: "cx000...1")

// Gets the total supply of ICX
let request: Request<BigUInt> = iconService.getTotalSupply()

// Gets a transaction matching the given transaction hash
let request: Request<Response.TransactionByHashResult> = iconService.getTransaction(hash: "0x000...000")

// Gets the result of the transaction matching the given transaction hash
let request: Request<Response.TransactionResult> = iconService.getTransactionResult(hash: "0x000...000")

// Calls a SCORE API just for reading
let call = Call(from: wallet.address, to: scoreAddress, method: "balanceOf", params: params)
let request: Request<Response.IntValue> = service.call(call)
```

## Sending transactions

Calling SCORE APIs to change states is requested as sending a transaction.

Before sending a transaction, the transaction should be signed.

#### Loading wallets and storing the Keystore

```Swift
// Generates a wallet.
let wallet = Wallet(privateKey: nil)

// OR

// Load a wallet from the private key.
let privateKey = PrivateKey(hex: data)
let wallet = Wallet(privateKey: privateKey)
```

#### Creating transactions

```Swift
// Sending ICX
let coinTransfer = Transaction()
    .from(wallet.address)
    .to(to)
    .value(BigUInt(15000000))
    .stepLimit(BigUInt(1000000))
    .nid(self.iconService.nid)
    .nonce("0x1")

// SCORE function call
let call = CallTransaction()
    .from(wallet.address)
    .to(scoreAddress)
    .stepLimit(BigUInt(1000000))
    .nid(self.iconService.nid)
    .nonce("0x1")
    .method("transfer")
    .params(["_to": to, "_value": "0x1234"])

// Message transfer
let transaction = Transaction()
    .from(wallet.address)
    .to(to)
    .value(BigUInt(15000000))
    .stepLimit(BigUInt(1000000))
    .nonce("0x1")
    .nid(self.iconService.nid)
    .message("Hello, ICON!")
```

#### Sending Requests

`SignedTransaction` object signs a transaction using the wallet.

And a request is executed as **Synchronized** or **Asynchronized** like a querying request.

**Synchronous request** 

```Swift

// Synchronous request
do {
    let signed = try SignedTransaction(transaction: coinTransfer, privateKey: privateKey)
    let request = iconService.sendTransaction(signedTransaction: signed)
    let response = request.execute()

    switch response {
    case .result(let result):
        print("SUCCESS: TXHash - \(result)")
        ...
    case .error(let error):
        print("FAIL: \(error.errorDescription)")
        ...
    }
} catch {
      print(error)
      ...
}
```

**Asynchronous request** 

```swift
do {
    let signed = try SignedTransaction(transaction: coinTransfer, privateKey: privateKey)  
    let request = iconService.sendTransaction(signedTransaction: signed)

    request.async { (result) in
        switch result {
        case .success(let result):
            print(result)
            ...
        case .failure(let error):
            print(error.errorDescription)
            ...
        }
    }
} catch {
	print(error)
}

// Asynchronous request
do {
    let signed = try SignedTransaction(transaction: transaction, privateKey: privateKey)

    service.sendTransaction(signedTransaction: signed) { response in
        switch response {
        case .success(let result):
            print("tx result - \(result)")
        
        case .failure(let error):
            // Error handling
            print("error")
        }
    }
} catch {
    // exception handling
}
```

## Reference

- [ICON JSON-RPC API v3](https://github.com/icon-project/icon-rpc-server/blob/master/docs/icon-json-rpc-v3.md)
- [ICON Network](https://github.com/icon-project/icon-project.github.io/blob/master/docs/icon_network.md)

## Version

0.2.5 (Beta)

## Requirement

- Xcode 10 or higher
- iOS 10 or higher
- Swift 4
- [Cocoapods](https://cocoapods.org)

## License

This project follows the Apache 2.0 License. Please refer to [LICENSE](https://www.apache.org/licenses/LICENSE-2.0) for details.
