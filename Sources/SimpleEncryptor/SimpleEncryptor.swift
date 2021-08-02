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
	
	public static let defaultKeychainQuery: [CFString : Any] = [
		kSecClass: kSecClassGenericPassword,
		kSecAttrService: "encryption key", //role
		kSecAttrAccount: "SwiftStorage", //login
	]
	
	private let keyAccess: CFString
	private let keychainQuery: [CFString : Any]
	private let service: CryptoService
	private var key: SymmetricKey?
	
	/// Initialize new SimpleEncryptor
	/// - Parameters:
	///   - strategy: the cipher implementation, can be either GCM or CBC.
	///   - keyAccess: control when the encryption key is accessible, default is `AfterFirstUnlock`.
	///   - keychainQuery: A Dictionary, representing keychain query params. it is used to store & fetch the encryption key.
	public init(type: CryptoServiceType,
				keyAccess: CFString = kSecAttrAccessibleAfterFirstUnlock,
				keychainQuery: [CFString: Any] = defaultKeychainQuery) {
		self.service = type.service
		self.keyAccess = keyAccess
		self.keychainQuery = keychainQuery
	}
	
	/// Encrypt data with CGM encryption, and returns the encrypted data in result
	/// - Parameter data: the data to encrypt
	/// - Returns: encrypted data
	public func encrypt(data: Data) throws -> Data {
		let key = try getKey()
		return try service.encrypt(data, using: key)
	}
	
	/// Deccrypt data with CGM decryption, and returns the original (clear-text) data in result
	/// - Parameter data: Encrypted data to decipher.
	/// - Throws: check exception
	/// - Returns: original, Clear-Text data
	public func decrypt(data: Data) throws -> Data {
		let key = try getKey()
		return try service.decrypt(data, using: key)
	}
	
	/// Encrypt a file and save the encrypted content in a different file, this function let you encrypt scaleable chunck of content without risking memory to run out
	/// - Parameters:
	///   - src: source file to encrypt
	///   - dest: destination file to save the encrypted content
	///   - onProgress: a progress event to track the progress of the writing
	public func encrypt(file src: URL, to dest: URL, onProgress: OnProgress? = nil) throws {
		let key = try getKey()
		try service.encrypt(file: src, to: dest, using: key, onProgress: onProgress)
	}
	
	/// Decrypt a file and save the "clear text" content in a different file, this function let you decrypt scaleable chunck of content without risking memory to run out
	/// - Parameters:
	///   - src: An encrypted, source file to decrypt
	///   - dest: destination file to save the decrypted content
	///   - onProgress: a progress event to track the progress of the writing
	public func decrypt(file src: URL, to dest: URL, onProgress: OnProgress? = nil) throws {
		let key = try getKey()
		try service.decrypt(file: src, to: dest, using: key, onProgress: onProgress)
	}
	
	/// Encryption key for cipher operations, lazy loaded, it will get the current key in Keychain or will generate new one.
	private func getKey() throws -> SymmetricKey {
		if let key = key { return key }
		
		var query = keychainQuery
		query[kSecReturnData] = true
		
		var item: CFTypeRef? //reference to the result
		let readStatus = SecItemCopyMatching(query as CFDictionary, &item)
		switch readStatus {
		case errSecSuccess: return SymmetricKey(data: item as! Data) // Convert back to a key.
		case errSecItemNotFound: return try storeNewKey()
		default: throw Errors.fetchKeyError(readStatus)
		}
	}
	
	/// Generate a new Symmetric encryption key and stores it in the Keychain
	/// - Returns: newly created encryption key.
	private func storeNewKey() throws -> SymmetricKey {
		let key = SymmetricKey(size: .bits256) //create new key
		var query = keychainQuery
		query[kSecAttrAccessible] = keyAccess
		query[kSecValueData] = key.dataRepresentation //request to get the result (key) as data
		
		let status = SecItemAdd(query as CFDictionary, nil)
		guard status == errSecSuccess else {
			throw Errors.storeKeyError(status)
		}
		
		return key
	}
	
	private enum Errors: LocalizedError {
		case fetchKeyError(OSStatus)
		case storeKeyError(OSStatus)
		
		var errorDescription: String? {
			switch self {
			case .fetchKeyError(let status):
				return "unable to fetch key, os-status: '\(status)'"
			case .storeKeyError(let status):
				return "Unable to store key, os-status: '\(status)'"
			}
		}
	}
}
