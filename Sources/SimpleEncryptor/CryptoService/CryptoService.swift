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


func stream(from src: URL, to dest: URL, operation: (InputStream, OutputStream) throws -> ()) throws {
	let fm = FileManager.default
	
	let tempDir = fm.temporaryDirectory
	try fm.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
	let tempFile = tempDir.appendingPathComponent(UUID().uuidString)
	
	let input = InputStream(url: src)!
	let output = OutputStream(url: tempFile, append: false)!
	
	output.open()
	defer { output.close() }
	
	try operation(input, output)
	
	if fm.fileExists(atPath: dest.path) {
		try fm.removeItem(at: dest)
	}
	
	try fm.moveItem(at: tempFile, to: dest)
}
