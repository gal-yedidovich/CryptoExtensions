//
//  HelperMethods.swift
//  Tests
//
//  Created by Gal Yedidovich on 02/08/2021.
//

import Foundation
import XCTest

func randomData(length: Int) -> Data {
	let range = UInt8.min...UInt8.max
	let nums: [UInt8] = (0..<length).map { _ in UInt8.random(in: range) }
	return Data(nums)
}

func assertThrowsErrorAsync<T>(_ expression: @autoclosure () async throws -> T) async {
	do {
		let result = try await expression()
		XCTFail("Expected to throw an error, instead got: \(result)")
	} catch {
		// do nothing
	}
}
