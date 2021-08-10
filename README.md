## CryptoExtensions
### Awesome encryption & decryption APIs, including:
* `SimpleEncryptor` class, great for convenience crypto operations (data and/or big files), using keychain to store keys.
* `AES/CBC` implementation in Swift, on top of "Common Crypto" implementation.
* useful "crypto" extension methods.

#### SimpleEncryptor example (with CBC)
```swift
let data = Data("I am Groot!".utf8)
let encryptor = SimpleEncryptor(strategy: .cbc(iv: Data(...)))

do {
	let encrypted = try encryptor.encrypt(data) 
	let decrypted = try encryptor.decrypt(encrypted)

	print(String(decoding: decrypted, as: UTF8.self)) //"I am Groot!"
} catch {
	//handle cryptographic errors
}
```

#### Basic CBC cryptographic example:
```swift
let data: Data = ... //some data to encrypt
let iv: Data = ... //an initial verctor
let key: SymmetricKey = ... //encryption key

do {
	let encrypted = try AES.CBC.encrypt(data, using: key, iv: iv)
	let decrypted = try AES.CBC.decrypt(encrypted, using: key, iv: iv)
} catch {
	//handle cryptographic errors
}
```
