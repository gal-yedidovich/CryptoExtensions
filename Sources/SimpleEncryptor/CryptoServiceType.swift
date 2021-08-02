//
//  CryptoServiceType.swift
//  SimpleEncryptor
//
//  Created by Gal Yedidovich on 02/08/2021.
//

import Foundation

public enum CryptoServiceType {
	case cbc(iv: Data)
	case gcm
	
	internal var service: CryptoService {
		switch self {
		case .cbc(let iv):
			return CBCService(iv: iv)
		default:
			return GCMService()
		}
	}
}
