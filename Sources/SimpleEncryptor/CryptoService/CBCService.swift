//
//  CBCService.swift
//  SimpleEncryptor
//
//  Created by Gal Yedidovich on 02/08/2021.
//

import Foundation
import CryptoKit
import CBC
import Util

struct CBCService: CryptoService {
	let iv: Data
	
	func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
		try AES.CBC.encrypt(data, using: key, iv: iv)
	}
	
	func decrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
		try AES.CBC.decrypt(data, using: key, iv: iv)
	}
	
	func encrypt(file src: URL, to dest: URL, using key: SymmetricKey, onProgress: OnProgress?) throws {
		let cipher = try AES.CBC.Cipher(.encrypt, using: key, iv: iv)
		try process(file: src, to: dest, using: key,
						operation: cipher.update(_:), finalOperation: cipher.finalize,
						onProgress: onProgress)
	}
	
	func decrypt(file src: URL, to dest: URL, using key: SymmetricKey, onProgress: OnProgress?) throws {
		let cipher = try AES.CBC.Cipher(.decrypt, using: key, iv: iv)
		try process(file: src, to: dest, using: key,
						operation: cipher.update(_:), finalOperation: cipher.finalize,
						onProgress: onProgress)
	}
}
