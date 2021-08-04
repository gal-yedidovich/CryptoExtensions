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
	
	@available(macOS 12.0, iOS 15.0, *)
	func encrypt(file src: URL, to dest: URL, using key: SymmetricKey, onProgress: OnProgress?) async throws
	@available(macOS 12.0, iOS 15.0, *)
	func decrypt(file src: URL, to dest: URL, using key: SymmetricKey, onProgress: OnProgress?) async throws
}

public typealias OnProgress = (Int) -> Void
