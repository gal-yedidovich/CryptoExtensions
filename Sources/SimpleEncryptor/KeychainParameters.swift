//
//  KeychainParameters.swift
//  SimpleEncryptor
//
//  Created by Gal Yedidovich on 05/08/2021.
//

import Foundation

public extension SimpleEncryptor {
	/// Configuration values for creation of new ``SimpleEncryptor``
	struct KeychainParameters {
		public var keyAccess: KeyAccess
		public var service: String //role
		public var account: String //login
		
		/// Create new instance of parameters
		/// - Parameters:
		///   - keyAccess: the permission for accessing the keychain, defaults to ``KeyAccess/afterFirstUnlock``
		///   - service: name of the service in the keychain
		///   - account: name of the account in the keychain
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
	/// Type of key access, this enum is a facade for constant values of keychain access (starts with `kSecAttrAccessible`)
	enum KeyAccess {
		///The data in the keychain item can be accessed only while the device is unlocked by the user.
		///represents `kSecAttrAccessibleWhenUnlocked`
		case whenUnlocked
		///The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
		///represents `kSecAttrAccessibleAfterFirstUnlock`
		case afterFirstUnlock
		///The data in the keychain item can be accessed only while the device is unlocked by the user.
		///represents `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
		case whenUnlockedThisDeviceOnly
		///The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
		///represents `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`
		case whenPasscodeSetThisDeviceOnly
		///The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
		///represents `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`
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
