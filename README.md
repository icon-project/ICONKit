# ICONKit, ICON SDK for Swift

<p align="left">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-4.x-orange.svg">
  <img alt="ICONKit-license" src="https://img.shields.io/github/license/icon-project/ICONKit.svg">
  <a href="https://cocoapods.org/pods/ICONKit" target="_blank">
    <img alt="CocoaPods" src="https://img.shields.io/cocoapods/v/ICONKit.svg">
  </a>
  <a href="https://github.com/icon-project/ICONKit" target="_blank">
    <img alt="Platform" src="https://img.shields.io/cocoapods/p/ICONKit.svg">
  </a>
</p>

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
    pod 'ICONKit', '~> 0.3.1'
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

# Queries

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

## Querying API

The querying APIs are as follows.

* [getLastBlock](#getLastBlock)
* [getBlock(height)](#getblock(height))
* [getBlock(hash)](#getBlock(hash))
* [call](#call)
* [getBalance](#getBalance)
* [getScoreAPI](#getScoreAPI)
* [getTotalSupply](#getTotalSupply)
* [getTransaction](#getTransaction)
* [getTransactionResult](#getTransactionResult)
* [sendTransaction](#Sending-transactions)

### getLastBlock

Gets the last block information.

```swift
let request: Request<Response.Block> = iconService.getLastBlock()
```

### getBlock(height)

Gets block information by block height. 

```swift
let request: Request<Response.Block> = iconService.getBlock(height: height)
```

### getBlock(hash)

Gets block information by block hash.

```swift
let request: Request<Response.Block> = iconService.getBlock(hash: "0x000...000")
```

### call

Calls a SCORE API.
Use the return type of method's outputs you want to call in generic type.
For example, the type of output that is `String` use `String`.

```swift
let call = Call<String>(from: wallet.address, to: scoreAddress, method: "name", params: params)
let request: Request<String> = iconService.call(call) 
let response: Result<String, ICError> = request.execute()
```

If the output type of method is hex String (ex. `"0x56bc75e2d63100000"`), you can use `String` and `BigUInt` too! 
Just input `BigUInt` at generic type, then ICONKit convert the output value to BigUInt.
If you want to use hex `String`, use `String`.

```swift
// Using `BigUInt`
let call = Call<BigUInt>(from: wallet.address, to: scoreAddress, method: "balanceOf", params: params)
let request: Request<BigUInt> = iconService.call(call)
let response: Result<BigUInt, ICError> = request.execute() // return 100000000000000000000 or ICError

// Using `String`
let call = Call<String>(from: wallet.address, to: scoreAddress, method: "balanceOf", params: params)
let request: Request<String> = iconService.call(call)
let response: Result<String, ICError> = request.execute() // return "0x56bc75e2d63100000" or ICError
```

### getBalance

Gets the balance of an given account.

```swift
let request: Request<BigUInt> = iconService.getBalance(address: "hx000...1")
```

### getScoreAPI

Gets a list of ScoreAPI.

```swift
let request: Request<Response.ScoreAPI> = iconService.getScoreAPI(scoreAddress: "cx000...1")
```

### getTotalSupply

Gets the total supply of ICX.

```swift
let request: Request<BigUInt> = iconService.getTotalSupply()
```

### getTransaction

Gets a transaction matching the given transaction hash.

```Swift
let request: Request<Response.TransactionByHashResult> = iconService.getTransaction(hash: "0x000...000")
```

### getTransactionResult

Gets the transaction result requested by transaction hash.

```swift
let request: Request<Response.TransactionResult> = iconService.getTransactionResult(hash: "0x000...000")
```

### Sending transactions

Calling SCORE APIs to change states is requested as sending a transaction.

Before sending a transaction, the transaction should be signed.

#### Loading wallets and storing the Keystore

```Swift
// Generates a wallet.
let wallet = Wallet(privateKey: nil)

// Load a wallet from the private key.
let privateKey = PrivateKey(hex: data)
let wallet = Wallet(privateKey: privateKey)

// Save wallet keystore.
let wallet = Wallet(privateKey: nil)
do {
    try wallet.generateKeystore(password: "YOUR_WALLET_PASSWORD")
    try wallet.save(filepath: "YOUR_STORAGE_PATH")
} catch {
    // handle errors
}
// Load a wallet from the keystore.
do {
    let jsonData: Data = try Data(contentsOf: "YOUR_KEYSTORE_PATH")
    let decoder = JSONDecoder()
    let keystore = try decoder.decoder(Keystore.self, from: jsonData)
    let wallet = Wallet(keystore: keystore, password: "YOUR_WALLET_PASSWORD")
} catch {
    // handle errors
}
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
let transaction = MessageTransaction()
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
```

#### Estimate step

It is important to set a proper `stepLimit` value in your transaction to make the submitted transaction executed successfully.

`estimateStep` API provides a way to **estimate** the Step usage of a given transaction. Using the method, you can get an estimated Step usage before sending your transaction then make a `SignedTransaction` with the `stepLimit` based on the estimation.

```swift
// Make a raw transaction without the stepLimit
let message = MessageTransaction()
    .from(fromAddress)
    .to(toAddress)
    .nid(self.iconService.nid)
    .message("Hello, ICON!")

// Estimate step
let estimateStepResponse = iconService.estimateStep(transaction: message).execute()
if let estimatedStepCost = try? estimateStepResponse.get() {
    // Add some margin to estimated step
    let stepLimit = estimatedStepCost + 10000
    message.stepLimit(estimatedStepCost)
}

// Send transaction
do {
    let signed = try SignedTransaction(transaction: message, privateKey: yourPrivateKey)
    let response = self.iconService.sendTransaction(signedTransaction: signed).execute()
  
    switch response {
    case .success(let result):
        print("Message tx result - \(result)")
    case .failure(let error):
        print(error)
    }
} catch {
    print(error)
}
```

Note that the estimation can be smaller or larger than the actual amount of step to be used by the transaction, so it is recommended to add some margin to the estimation when you set the `stepLimit` of the `SignedTransaction`.

### Converter

ICONKit supports converter functions.

```swift
// Convert ICX or gLoop to loop.
let balance: BigUInt = 100
let ICXToLoop: BigUInt = balance.convert() // 100000000000000000000
let gLoopToLoop: BigUInt = balance.convert(unit: .gLoop) // 100000000000

// Convert `BigUInt` value to HEX `String`.
let hexString: String = ICXToLoop.toHexString() // 0x56bc75e2d63100000

// Convert HEX `String` to `BigUInt`.
let hexBigUInt: BigUInt = hexString.hexToBigUInt()! // 100000000000000000000

// Convert HEX `String` to `Date`
let timestamp: String = "0x5850adcbaa178"
let confirmedDate: Date = timestamp.hexToDate()! // 2019-03-27 03:16:22 +0000
```



## Reference

- [ICON JSON-RPC API v3](https://github.com/icon-project/icon-rpc-server/blob/master/docs/icon-json-rpc-v3.md)
- [ICON Network](https://github.com/icon-project/icon-project.github.io/blob/master/docs/icon_network.md)

## Version

0.3.1 (Beta)

## Requirement

- Xcode 10 or higher
- iOS 10 or higher
- Swift 4
- [Cocoapods](https://cocoapods.org)

## License

This project follows the Apache 2.0 License. Please refer to [LICENSE](https://www.apache.org/licenses/LICENSE-2.0) for details.
