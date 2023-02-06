//
//  AsyncCipher.swift
//  
//
//  Created by Gal Yedidovich on 04/02/2023.
//

import Foundation
import CryptoKit

public class AsyncCipher<AsyncSource: AsyncSequence>: AsyncSequence where AsyncSource.Element == UInt8 {
	public typealias Element = Data
	let cipher: AES.CBC.Cipher
	let source: AsyncSource
	
	public init(cipher: AES.CBC.Cipher, source: AsyncSource) {
		self.cipher = cipher
		self.source = source
	}
	
	public func makeAsyncIterator() -> AsyncCipherIterator {
		let chunkedBytes = source.chunked(upTo: 1024 * 32)
		return AsyncCipherIterator(cipher: cipher, sourceIterator: chunkedBytes.makeAsyncIterator())
	}
	
	public struct AsyncCipherIterator: AsyncIteratorProtocol {
		let cipher: AES.CBC.Cipher
		var sourceIterator: AsyncChunkedSequence<AsyncSource>.AsyncIterator
		var didFinalized = false
		
		public mutating func next() async throws -> Data? {
			if let batch = try await sourceIterator.next() {
				let batchData = Data(batch)
				let ciphered = try cipher.update(batchData)
				return ciphered
			}
			
			if !didFinalized {
				didFinalized = true
				return try cipher.finalize()
			}

			return nil
		}
	}
}

public extension AsyncSequence where Element == UInt8 {
	func ciphered(with cipher: AES.CBC.Cipher) -> AsyncCipher<Self> {
		AsyncCipher(cipher: cipher, source: self)
	}
}
