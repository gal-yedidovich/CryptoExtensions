//
//  ChaChaPolyService.swift
//  SimpleEncryptor
//
//  Created by Gal Yedidovich on 11/08/2021.
//

import Foundation
import CryptoKit

struct ChaChaPolyService: CryptoService {
	static let BUFFER_SIZE = 1024 * 32
	
	func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
		try ChaChaPoly.seal(data, using: key).combined
	}
	
	func decrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
		let box = try ChaChaPoly.SealedBox(combined: data)
		return try ChaChaPoly.open(box, using: key)
	}
	
	@available(macOS 12.0, iOS 15.0, *)
	func encrypt(file src: URL, to dest: URL, using key: SymmetricKey, onProgress: OnProgress?) async throws {
		try await process(file: src, to: dest, using: key, bufferSize: Self.BUFFER_SIZE,
						  operation: { try encrypt($0, using: key) },
						  onProgress: onProgress)
	}
	
	@available(macOS 12.0, iOS 15.0, *)
	func decrypt(file src: URL, to dest: URL, using key: SymmetricKey, onProgress: OnProgress?) async throws {
		try await process(file: src, to: dest, using: key, bufferSize: Self.BUFFER_SIZE + 28,
						  operation: { try decrypt($0, using: key) },
						  onProgress: onProgress)
	}
}
