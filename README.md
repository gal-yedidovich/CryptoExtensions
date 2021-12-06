## CryptoExtensions
### Awesome encryption & decryption APIs, including:
* `SimpleEncryptor` class, great for convenience crypto operations (data & files), using keychain to store keys.
* `AES/CBC` implementation in Swift, on top of "Common Crypto" implementation.
* useful "crypto" extension methods.

#### SimpleEncryptor example (with CBC)
```swift
let data = Data("I am Groot!".utf8)
let encryptor = SimpleEncryptor(type: .cbc(iv: Data(...)))

do {
	let encrypted = try encryptor.encrypt(data) 
	let decrypted = try encryptor.decrypt(encrypted)

	print(String(decoding: decrypted, as: UTF8.self)) //"I am Groot!"
} catch {
	//handle cryptographic errors
}
```

`SimpleEncryptor` now supports these algorithms:
 - AES.CBC
 - AES.GCM
 - ChaChaPoly

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

#### CBC Chipering
```swift
let dataPartOne: Data = ... //data part 1 to encrypt
let dataPartTwo: Data = ... //data part 2 to encrypt
let iv: Data = ... //an initial verctor
let key: SymmetricKey = ... //encryption key

do {
	//Encryption example
	let cipher = try AES.CBC.Cipher(.encrypt, using: key, iv: iv)
	
	let encrypted1 = try cipher.update(dataPartOne)
	let encrypted2 = try cipher.update(dataPartTwo)
	let encrypted3 = try cipher.finalize()
	
	//Decryption example
	let cipher = try AES.CBC.Cipher(.decrypt, using: key, iv: iv)
	
	var decrypted = try cipher.update(encrypted1)
	decrypted += try cipher.update(encrypted2)
	decrypted += try cipher.update(encrypted3)
	decrypted += try cipher.finalize()
} catch {
	//handle cryptographic errors
}
```
