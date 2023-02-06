//
//  AsynCipherTests.swift
//  
//
//  Created by Gal Yedidovich on 04/02/2023.
//

import Foundation

import XCTest
import CryptoKit
import CBC

class AsynCipherTests: XCTestCase {
	private let iv = randomData(length: 16)
	private let key = SymmetricKey(size: .bits128)
	private let inputData = randomData(length: 100_000)
	private lazy var asyncInput = AsyncStream<UInt8> { continuation in
		for byte in inputData.bytes {
			continuation.yield(byte)
		}
		continuation.finish()
	}
	
	func testShouldIterateCipherSuccess() async throws {
		//Given
		let encryptCipher = try AES.CBC.Cipher(.encrypt, using: key, iv: iv)
		let encryptedBytes = AsyncCipher(cipher: encryptCipher, source: asyncInput)
		var encrypted = Data()
		
		//When
		for try await batch in encryptedBytes {
			encrypted += batch
		}
		
		//Then
		let decrypted = try AES.CBC.decrypt(encrypted, using: key, iv: iv)
		XCTAssertEqual(decrypted, inputData)
	}
	
	@available(macOS 12.0, iOS 15.0, *)
	func testShouldIterateCipherSuccess_withUrl() async throws {
		//Given
		let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(#function)
		try inputData.write(to: fileUrl)
		defer {
			try? FileManager.default.removeItem(at: fileUrl)
		}
		let encryptCipher = try AES.CBC.Cipher(.encrypt, using: key, iv: iv)
		let encryptedBytes = AsyncCipher(cipher: encryptCipher, source: fileUrl.resourceBytes)
		let encryptedByes = fileUrl.resourceBytes.ciphered(with: encryptCipher)
		var encrypted = Data()
		
		//When
		for try await batch in encryptedBytes {
			encrypted += batch
		}
		
		//Then
		let decrypted = try AES.CBC.decrypt(encrypted, using: key, iv: iv)
		XCTAssertEqual(decrypted, inputData)
	}
	
	func testShouldThrowError_whenCipherIsFinalizedPrematurely() async throws {
		//Given
		let encryptCipher = try AES.CBC.Cipher(.encrypt, using: key, iv: iv)
		let encryptedBytes = AsyncCipher(cipher: encryptCipher, source: asyncInput)
		
		//When
		_ = try encryptCipher.finalize()

		//Then
		await assertThrowsErrorAsync(try await encryptedBytes.first { _ in true })
	}
}
