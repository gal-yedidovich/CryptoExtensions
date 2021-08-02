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
typealias Operation = (Data) throws -> Data
typealias FinalOperation = () throws -> Data
typealias StreamsBlock = (InputStream, OutputStream) throws -> ()

func process(file src: URL, to dest: URL, using key: SymmetricKey, bufferSize: Int = 32 * 1000,
				 operation: Operation, finalOperation: FinalOperation? = nil,
				 onProgress: OnProgress?) throws {
	try stream(from: src, to: dest) { input, output in
		let fileSize = src.fileSize!
		var offset: Int = 0
		
		try input.readAll(bufferSize: bufferSize) { buffer, bytesRead in
			offset += bytesRead
			onProgress?(Int((offset * 100) / fileSize))
			
			let data = Data(bytes: buffer, count: bytesRead)
			output.write(data: try operation(data))
		}
		
		if let finalOperation = finalOperation {
			output.write(data: try finalOperation())
		}
	}
}

private func stream(from src: URL, to dest: URL, operation: StreamsBlock) throws {
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
