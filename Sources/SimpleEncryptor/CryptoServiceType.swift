//
//  CryptoServiceType.swift
//  SimpleEncryptor
//
//  Created by Gal Yedidovich on 02/08/2021.
//

import Foundation

/// Cryptographic implementation type, this enum represent the internal algorithm that is used by the ``SimpleEncryptor``
public enum CryptoServiceType {
	///`AES/CBC` implementation with a static initial vector
	case cbc(iv: Data)
	///`AES/GCM` implementation
	case gcm
	///`ChaChaPoly` implementation
	case chachaPoly
	
	internal var service: CryptoService {
		switch self {
		case .cbc(let iv):
			return CBCService(iv: iv)
		case .chachaPoly:
			return ChaChaPolyService()
		case .gcm:
			return GCMService()
		}
	}
}
