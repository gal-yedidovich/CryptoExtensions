//
//  KeyService.swift
//  SimpleEncryptor
//
//  Created by Gal Yedidovich on 04/08/2021.
//

import Foundation
import CryptoKit

protocol KeyService {
	func fetchKey() throws -> SymmetricKey?
	func createKey() throws -> SymmetricKey
}

struct KeychainKeyService: KeyService {
	let param: SimpleEncryptor.KeychainParameters
	
	func fetchKey() throws -> SymmetricKey? {
		var query = param.queryDictionary
		query[kSecReturnData] = true
		
		var item: CFTypeRef? // Reference to the result
		let readStatus = SecItemCopyMatching(query as CFDictionary, &item)
		switch readStatus {
		case errSecSuccess: return SymmetricKey(data: item as! Data) // Convert back to a key.
		case errSecItemNotFound: return nil
		default: throw KeychainError.fetchKeyError(readStatus)
		}
	}
	
	func createKey() throws -> SymmetricKey {
		let newKey = SymmetricKey(size: .bits256) // Create new key
		var query = param.queryDictionary
		query[kSecAttrAccessible] = param.keyAccess.value
		query[kSecValueData] = newKey.dataRepresentation // Request to get the result (key) as data
		
		let status = SecItemAdd(query as CFDictionary, nil)
		guard status == errSecSuccess else {
			throw KeychainError.storeKeyError(status)
		}
		
		return newKey
	}
}

enum KeychainError: LocalizedError {
	case fetchKeyError(OSStatus)
	case storeKeyError(OSStatus)
	
	var errorDescription: String? {
		switch self {
		case .fetchKeyError(let status):
			let msg = SecCopyErrorMessageString(status, nil) as? String ?? ""
			return "Unable to fetch key, os-status: '\(status)'. \(msg)"
		case .storeKeyError(let status):
			let msg = SecCopyErrorMessageString(status, nil) as? String ?? ""
			return "Unable to store key, os-status: '\(status)'. \(msg)"
		}
	}
}
