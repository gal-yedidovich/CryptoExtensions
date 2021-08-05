//
//  KeychainParameters.swift
//  SimpleEncryptor
//
//  Created by Gal Yedidovich on 05/08/2021.
//

import Foundation

public extension SimpleEncryptor {
	struct KeychainParameters {
		public var keyAccess: KeyAccess
		public var service: String //role
		public var account: String //login
		
		public init(keyAccess: KeyAccess = .afterFirstUnlock,
					service: String = "encryption key",
					account: String = "SwiftStorage") {
			self.keyAccess = keyAccess
			self.service = service
			self.account = account
		}
		
		var queryDictionary: [CFString : Any] {
			return [
				kSecClass: kSecClassGenericPassword,
				kSecAttrService: service,
				kSecAttrAccount: account,
			]
		}
	}
}

public extension SimpleEncryptor.KeychainParameters {
	enum KeyAccess {
		case whenUnlocked
		case afterFirstUnlock
		case whenUnlockedThisDeviceOnly
		case whenPasscodeSetThisDeviceOnly
		case afterFirstUnlockThisDeviceOnly
		
		var value: CFString {
			switch self {
			case .whenUnlocked:
				return kSecAttrAccessibleWhenUnlocked
			case .afterFirstUnlock:
				return kSecAttrAccessibleAfterFirstUnlock
			case .whenUnlockedThisDeviceOnly:
				return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
			case .whenPasscodeSetThisDeviceOnly:
				return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
			case .afterFirstUnlockThisDeviceOnly:
				return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
			}
		}
	}
}
