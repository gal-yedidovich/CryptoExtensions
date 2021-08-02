//
//  CryptoService.swift
//  SimpleEncryptor
//
//  Created by Gal Yedidovich on 02/08/2021.
//

import Foundation
import CryptoKit

protocol CryptoService {
	func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data
	func decrypt(_ data: Data, using key: SymmetricKey) throws -> Data
	
	func encrypt(file src: URL, to dest: URL, using key: SymmetricKey, onProgress: OnProgress?) throws
	func decrypt(file src: URL, to dest: URL, using key: SymmetricKey, onProgress: OnProgress?) throws
}

public typealias OnProgress = (Int) -> Void
