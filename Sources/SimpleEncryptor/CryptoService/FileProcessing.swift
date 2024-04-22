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
typealias SafeStreamBlock = (OutputStream) async throws -> ()

@available(macOS 12.0, iOS 15.0, *)
func process(file src: URL, to dest: URL, using key: SymmetricKey, bufferSize: Int = 32 * 1000,
			 operation: Operation, finalOperation: FinalOperation? = nil,
			 onProgress: OnProgress?) async throws {
	guard let fileSize = src.fileSize else {
		throw ProcessingError.fileNotFound
	}
	
	try await safeStream(to: dest) { output in
		var offset: Int = 0
		var count = 0
		
		let batches = src.resourceBytes.chunked(upTo: bufferSize)
		for try await batch in batches {
			offset += batch.count
			onProgress?(Int((offset * 100) / fileSize))
			
			let processedData = try operation(Data(batch))
			output.write(data: processedData)
			
			count = (count + 1) % 10
			if count == 0 {
				await Task.yield()
			}
		}
		
		if let finalOperation = finalOperation {
			output.write(data: try finalOperation())
		}
	}
}

@available(macOS 12.0, iOS 15.0, *)
private func safeStream(to dest: URL, operation: SafeStreamBlock) async throws {
	let fm = FileManager.default
	
	let tempDir = fm.temporaryDirectory
	try fm.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
	let tempFile = tempDir.appendingPathComponent(UUID().uuidString)
	
	guard let output = OutputStream(url: tempFile, append: false) else {
		throw ProcessingError.failedToCreateOutputStream
	}
	
	output.open()
	defer { output.close() }
	
	try await operation(output)
	
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

extension OutputStream {
	func write(data: Data) {
		let buffer = [UInt8](data)
		write(buffer, maxLength: buffer.count)
	}
}

enum ProcessingError: LocalizedError {
	case fileNotFound
	case failedToCreateOutputStream
	
	var errorDescription: String? {
		switch self {
		case .fileNotFound: return "Source file not found"
		case .failedToCreateOutputStream: return "Failed to create output stream to destination file"
		}
	}
}
