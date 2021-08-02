//
//  SimpleEncryptorTests.swift
//  SimpleEncryptorTests
//
//  Created by Gal Yedidovich on 01/08/2021.
//

import XCTest
import SimpleEncryptor

class SimpleEncryptorTests: XCTestCase {
	let encryptor = SimpleEncryptor(type: .gcm)
	
	func testShouldEncryptDataSuccess() throws {
		//Given
		let data = Data(randomString(length: 100).utf8)
		
		//When
		let enc = try encryptor.encrypt(data: data)
		let dec = try encryptor.decrypt(data: enc)
		
		//Then
		XCTAssertEqual(data, dec)
	}
	
	func testShouldEncryptFileSuccess() throws {
		//Given
		let data = Data(randomString(length: 10_000).utf8)
		
		let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		let url = baseURL.appendingPathComponent("data.txt")
		let encUrl = baseURL.appendingPathComponent("enc_data.txt")
		let decUrl = baseURL.appendingPathComponent("dec_data.txt")
		try data.write(to: url)
		
		//When
		try encryptor.encrypt(file: url, to: encUrl)
		try encryptor.decrypt(file: encUrl, to: decUrl)
		
		//Then
		let dec = try Data(contentsOf: decUrl)
		XCTAssertEqual(data, dec)


		try FileManager.default.removeItem(at: url)
		try FileManager.default.removeItem(at: encUrl)
		try FileManager.default.removeItem(at: decUrl)
	}
}

fileprivate func randomString(length: Int) -> String {
	let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	return String((0..<length).map { _ in letters.randomElement()! })
}
