//
//  SimpleEncryptorTests.swift
//  Tests
//
//  Created by Gal Yedidovich on 01/08/2021.
//

import XCTest
import CryptoKit
@testable import SimpleEncryptor

class SimpleEncryptorTests: XCTestCase {
	
	func testShouldEncryptGCMDataSuccess() throws {
		try testDataEncryption(withType: .gcm)
	}
	
	func testShouldEncryptCBCDataSuccess() throws {
		let iv = Data(randomString(length: 16).utf8)
		try testDataEncryption(withType: .cbc(iv: iv))
	}
	
	func testShouldEncryptChachaPolyDataSuccess() throws {
		try testDataEncryption(withType: .chachaPoly)
	}
	
	@available(macOS 12.0, iOS 15.0, *)
	func testShouldEncryptGCMFileSuccess() async throws {
		try await testFileEncryption(withType: .gcm)
	}
	
	@available(macOS 12.0, iOS 15.0, *)
	func testShouldEncryptCBCFileSuccess() async throws {
		let iv = Data(randomString(length: 16).utf8)
		try await testFileEncryption(withType: .cbc(iv: iv))
	}
	
	@available(macOS 12.0, iOS 15.0, *)
	func testShouldEncryptChachaPolyFileSuccess() async throws {
		try await testFileEncryption(withType: .chachaPoly)
	}
	
	@available(macOS 12.0, iOS 15.0, *)
	func testShouldThrowErrorWhenFileNotFound() async {
		//Given
		let encryptor = SimpleEncryptor(type: .gcm, keyService: MockKeyService())
		
		let src = URL(fileURLWithPath: "notFoundSrc.txt")
		let dest = URL(fileURLWithPath: "notFoundDest.txt")
		
		//When
		do {
			try await encryptor.encrypt(file: src, to: dest)
			XCTFail("Should throw an error")
		} catch {
			XCTAssertEqual(error.localizedDescription, ProccessingError.fileNotFound.localizedDescription)
		}
	}
	
	@available(macOS 12.0, iOS 15.0, *)
	func testShouldCallProgressTenTimes() async throws {
		//Given
		let BUFFER_SIZE: Int = ChaChaPolyService.BUFFER_SIZE
		let EXPECTED_NUMBER_OF_STEPS = 10

		let encryptor = SimpleEncryptor(type: .chachaPoly, keyService: MockKeyService())
		let data = Data(randomString(length: BUFFER_SIZE * EXPECTED_NUMBER_OF_STEPS).utf8)
		var count = 0
		
		let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		let url = baseURL.appendingPathComponent("data.txt")
		let encUrl = baseURL.appendingPathComponent("enc_data.txt")
		try data.write(to: url)
		
		//When
		try await encryptor.encrypt(file: url, to: encUrl) { progress in count += 1 }
		
		//Then
		XCTAssertEqual(count, EXPECTED_NUMBER_OF_STEPS)
		
		try FileManager.default.removeItem(at: url)
		try FileManager.default.removeItem(at: encUrl)
	}
	
	func testShouldThrowErrorWhenFailsToCreateKey() {
		//Given
		let EXPECTED_ERROR: KeychainError = KeychainError.storeKeyError(-1)
		let keyService = MockKeyService(fetchResult: .success(nil), createResult: .failure(EXPECTED_ERROR))
		let encryptor = SimpleEncryptor(type: .gcm, keyService: keyService)
		let data = Data(randomString(length: 100).utf8)
		
		//When
		do {
			_ = try encryptor.encrypt(data: data)
			XCTFail("Should throw an error")
		} catch {
			XCTAssertEqual(error.localizedDescription, EXPECTED_ERROR.localizedDescription)
		}
	}
	
	func testShouldThrowErrorWhenFailsToFetchKey() {
		//Given
		let EXPECTED_ERROR: KeychainError = KeychainError.storeKeyError(-1)
		let keyService = MockKeyService(fetchResult: .failure(EXPECTED_ERROR))
		let encryptor = SimpleEncryptor(type: .gcm, keyService: keyService)
		let data = Data(randomString(length: 100).utf8)
		
		//When
		do {
			_ = try encryptor.encrypt(data: data)
			XCTFail("Should throw an error")
		} catch {
			XCTAssertEqual(error.localizedDescription, EXPECTED_ERROR.localizedDescription)
		}
	}
	
	private func testDataEncryption(withType type: CryptoServiceType) throws {
		//Given
		let encryptor = SimpleEncryptor(type: type, keyService: MockKeyService())
		let data = Data(randomString(length: 100).utf8)
		
		//When
		let enc = try encryptor.encrypt(data: data)
		let dec = try encryptor.decrypt(data: enc)
		
		//Then
		XCTAssertEqual(data, dec)
	}
	
	@available(macOS 12.0, iOS 15.0, *)
	private func testFileEncryption(withType type: CryptoServiceType) async throws {
		//Given
		let encryptor = SimpleEncryptor(type: type, keyService: MockKeyService())
		let data = Data(randomString(length: 10_000).utf8)
		
		let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		let url = baseURL.appendingPathComponent("data.txt")
		let encUrl = baseURL.appendingPathComponent("enc_data.txt")
		let decUrl = baseURL.appendingPathComponent("dec_data.txt")
		try data.write(to: url)
		
		//When
		try await encryptor.encrypt(file: url, to: encUrl)
		try await encryptor.decrypt(file: encUrl, to: decUrl)
		
		//Then
		let dec = try Data(contentsOf: decUrl)
		XCTAssertEqual(data, dec)
		
		try FileManager.default.removeItem(at: url)
		try FileManager.default.removeItem(at: encUrl)
		try FileManager.default.removeItem(at: decUrl)
	}
}

fileprivate struct MockKeyService: KeyService {
	var fetchResult: Result<SymmetricKey?, Error> = .success(SymmetricKey(size: .bits256))
	var createResult: Result<SymmetricKey, Error> = .success(SymmetricKey(size: .bits256))
	
	func createKey() throws -> SymmetricKey {
		try createResult.get()
	}
	
	func fetchKey() throws -> SymmetricKey? {
		try fetchResult.get()
	}
}
