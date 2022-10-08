//
//  SimpleEncryptor.swift
//  SimpleEncryptor
//
//  Created by Gal Yedidovich on 01/08/2021.
//

import Foundation
import CryptoKit

/// An interface to cipher sensetive infomation.
///
/// The `SimpleEncryptor` class provides basic cipher (encryption & decryption) operations on `Data` or files, using the `CryptoKit` framework.
/// All cipher operations are using a Symmetric key that is stored in the device's KeyChain.
public class SimpleEncryptor {
	private let cryptoService: CryptoService
	private let keyService: KeyService
	private var key: SymmetricKey?
	
	/// Initialize new SimpleEncryptor
	/// - Parameters:
	///   - type: the cipher implementation, can be either GCM or CBC.
	///   - keyAccess: control when the encryption key is accessible, default is `AfterFirstUnlock`.
	///   - keychainQuery: A Dictionary, representing keychain query params. it is used to store & fetch the encryption key.
	public convenience init(type: CryptoServiceType, keychasinQuery query: KeychainParameters = .init()) {
		let keyService = KeychainKeyService(param: query)
		self.init(type: type, keyService: keyService)
	}
	
	/// Initialize new SimpleEncryptor
	/// - Parameters:
	///   - type: the cipher implementation, can be either GCM or CBC.
	///   - keyService: the key store service, that provides encryption keys
	internal init(type: CryptoServiceType, keyService: KeyService) {
		self.cryptoService = type.service
		self.keyService = keyService
	}
	
	/// Encrypt data with CGM encryption, and returns the encrypted data in result
	/// - Parameter data: the data to encrypt
	/// - Returns: encrypted data
	public func encrypt(data: Data) throws -> Data {
		let key = try getKey()
		return try cryptoService.encrypt(data, using: key)
	}
	
	/// Deccrypt data with CGM decryption, and returns the original (clear-text) data in result
	/// - Parameter data: Encrypted data to decipher.
	/// - Returns: original, Clear-Text data
	public func decrypt(data: Data) throws -> Data {
		let key = try getKey()
		return try cryptoService.decrypt(data, using: key)
	}
	
	/// Encrypt a file and save the encrypted content in a different file, this function let you encrypt scaleable chunck of content without risking memory to run out
	/// - Parameters:
	///   - src: source file to encrypt
	///   - dest: destination file to save the encrypted content
	///   - onProgress: a progress event to track the progress of the writing
	@available(macOS 12.0, iOS 15.0, *)
	public func encrypt(file src: URL, to dest: URL, onProgress: OnProgress? = nil) async throws {
		let key = try getKey()
		try await cryptoService.encrypt(file: src, to: dest, using: key, onProgress: onProgress)
	}
	
	/// Decrypt a file and save the "clear text" content in a different file, this function let you decrypt scaleable chunck of content without risking memory to run out
	/// - Parameters:
	///   - src: An encrypted, source file to decrypt
	///   - dest: destination file to save the decrypted content
	///   - onProgress: a progress event to track the progress of the writing
	@available(macOS 12.0, iOS 15.0, *)
	public func decrypt(file src: URL, to dest: URL, onProgress: OnProgress? = nil) async throws {
		let key = try getKey()
		try await cryptoService.decrypt(file: src, to: dest, using: key, onProgress: onProgress)
	}
	
	/// Encryption key for cipher operations, lazy loaded, it will get the current key in Keychain or will generate new one.
	private func getKey() throws -> SymmetricKey {
		if let key = key { return key }
		
		let storedKey = try keyService.fetchKey() ?? keyService.createKey()
		self.key = storedKey
		return storedKey
	}
}
