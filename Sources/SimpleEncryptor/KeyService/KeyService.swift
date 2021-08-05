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
		
		var item: CFTypeRef? //reference to the result
		let readStatus = SecItemCopyMatching(query as CFDictionary, &item)
		switch readStatus {
		case errSecSuccess: return SymmetricKey(data: item as! Data) // Convert back to a key.
		case errSecItemNotFound: return nil
		default: throw Errors.fetchKeyError(readStatus)
		}
	}
	
	func createKey() throws -> SymmetricKey {
		let newKey = SymmetricKey(size: .bits256) //create new key
		var query = param.queryDictionary
		query[kSecAttrAccessible] = param.keyAccess
		query[kSecValueData] = newKey.dataRepresentation //request to get the result (key) as data
		
		let status = SecItemAdd(query as CFDictionary, nil)
		guard status == errSecSuccess else {
			throw Errors.storeKeyError(status)
		}
		
		return newKey
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
