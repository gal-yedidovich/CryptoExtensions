//
//  FileProcessing.swift
//  SimpleEncryptor
//
//  Created by Gal Yedidovich on 02/08/2021.
//

import Foundation
import CryptoKit

typealias Operation = (Data) throws -> Data
typealias FinalOperation = () throws -> Data
typealias StreamsBlock = (InputStream, OutputStream) async throws -> ()

@available(macOS 12.0, iOS 15.0, *)
func process(file src: URL, to dest: URL, using key: SymmetricKey, bufferSize: Int = 32 * 1000,
			 operation: Operation, finalOperation: FinalOperation? = nil,
			 onProgress: OnProgress?) async throws {
	try await stream(from: src, to: dest) { input, output in
		let fileSize = src.fileSize!
		var offset: Int = 0
		var count = 0
		
		try await input.readAll(bufferSize: bufferSize) { buffer, bytesRead in
			offset += bytesRead
			onProgress?(Int((offset * 100) / fileSize))
			
			let data = Data(bytes: buffer, count: bytesRead)
			output.write(data: try operation(data))
			count = (count + 1) % 10
			if count == 0 {
				await Task.suspend()
			}
		}
		
		if let finalOperation = finalOperation {
			output.write(data: try finalOperation())
		}
	}
}

private func stream(from src: URL, to dest: URL, operation: StreamsBlock) async throws {
	let fm = FileManager.default
	
	let tempDir = fm.temporaryDirectory
	try fm.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
	let tempFile = tempDir.appendingPathComponent(UUID().uuidString)
	
	let input = InputStream(url: src)!
	let output = OutputStream(url: tempFile, append: false)!
	
	output.open()
	defer { output.close() }
	
	try await operation(input, output)
	
	if fm.fileExists(atPath: dest.path) {
		try fm.removeItem(at: dest)
	}
	
	try fm.moveItem(at: tempFile, to: dest)
}

extension URL {
	///computes file size at the URL, if exists
	var fileSize: Int? {
		let values = try? resourceValues(forKeys: [.fileSizeKey])
		return values?.fileSize
	}
}

extension InputStream {
	typealias Buffer = [UInt8]
	
	func readAll(bufferSize: Int, block: (Buffer, Int) async throws -> Void) async rethrows {
		open()
		defer { close() }
		
		var buffer = [UInt8](repeating: 0, count: bufferSize)
		while hasBytesAvailable {
			let bytesRead = read(&buffer, maxLength: buffer.count)
			guard bytesRead > 0 else { break }
			
			try await block(buffer, bytesRead)
		}
	}
}

extension OutputStream {
	func write(data: Data) {
		let buffer = [UInt8](data)
		write(buffer, maxLength: buffer.count)
	}
}
