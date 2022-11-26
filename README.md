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

#### CBC Ciphering
```swift
let input: InputStream = ... // data input
let iv: Data = ... //an initial verctor
let key: SymmetricKey = ... //encryption key

do {
	let cipher = try AES.CBC.Cipher(.encrypt, using: key, iv: iv)
	
	var buffer = [UInt8](repeating: 0, count: 1024 * 32)
	var encrypted = Data()
	while input.hasBytesAvailable {
		let bytesRead = input.read(&buffer, maxLength: buffer.count)
		let batch = Data(bytes: buffer, count: bytesRead)
		encrypted += try cipher.update(batch)
	}
	encrypted += try cipher.finalize()
} catch {
	//handle cryptographic errors
}
```
