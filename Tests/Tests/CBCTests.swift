//
//  CBCTests.swift
//  Tests
//
//  Created by Gal Yedidovich on 01/08/2021.
//

import XCTest
import CryptoKit
import CBC

class CBCTests: XCTestCase {
	let key = SymmetricKey(size: .bits256)
	let iv = randomData(length: 16)
	
	func testShouldEncryptDataSuccess() throws {
		//Given
		let data = randomData(length: 100)
		
		//When
		let enc = try AES.CBC.encrypt(data, using: key, iv: iv)
		let dec = try AES.CBC.decrypt(enc, using: key, iv: iv)
		
		//Then
		XCTAssertEqual(data, dec)
	}
	
	func testShouldCipherDataSuccess() throws {
		//Given
		let data = randomData(length: 100)
		let partOne = data.subdata(in: 0 ..< data.count / 2)
		let partTwo = data.subdata(in: data.count / 2 ..< data.count)
		let cipher1 = try AES.CBC.Cipher(.encrypt, using: key, iv: iv)
		let cipher2 = try AES.CBC.Cipher(.decrypt, using: key, iv: iv)
		
		//When
		let e1 = try cipher1.update(partOne)
		let e2 = try cipher1.update(partTwo)
		let e3 = try cipher1.finalize()
		
		var decrypted: Data = try cipher2.update(e1)
		decrypted += try cipher2.update(e2)
		decrypted += try cipher2.update(e3)
		decrypted += try cipher2.finalize()
		
		//Then
		XCTAssertEqual(data, decrypted)
	}
	
	func testShouldCipherStreamSuccess() throws {
		//Given
		let data = randomData(length: 10_000)
		let encrypted = try AES.CBC.encrypt(data, using: key, iv: iv)
		let cipher = try AES.CBC.Cipher(.decrypt, using: key, iv: iv)
		let input = InputStream(data: encrypted)
		var decrypted = Data()
		var buffer = [UInt8](repeating: 0, count: 1024 * 32)
		input.open()
		
		//When
		while input.hasBytesAvailable {
			let bytesRead = input.read(&buffer, maxLength: buffer.count)
			let batch = Data(bytes: buffer, count: bytesRead)
			decrypted += try cipher.update(batch)
		}
		decrypted += try cipher.finalize()
		
		//Then
		XCTAssertEqual(data, decrypted)
	}
	
	func testShouldThrow_afterFinalize() throws {
		//Given
		let cipher = try AES.CBC.Cipher(.decrypt, using: key, iv: iv)
		_ = try cipher.finalize()
		
		//When
		//Then
		XCTAssertThrowsError(try cipher.update(Data()))
		XCTAssertThrowsError(try cipher.finalize())
	}
}
