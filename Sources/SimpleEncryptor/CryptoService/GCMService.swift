//
//  GCMService.swift
//  SimpleEncryptor
//
//  Created by Gal Yedidovich on 02/08/2021.
//

import Foundation
import CryptoKit

struct GCMService: CryptoService {
	private static let BUFFER_SIZE = 1024 * 32
	
	func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
		try AES.GCM.seal(data, using: key).combined!
	}
	
	func decrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
		let box = try AES.GCM.SealedBox(combined: data)
		return try AES.GCM.open(box, using: key)
	}
	
	func encrypt(file src: URL, to dest: URL, using key: SymmetricKey, onProgress: OnProgress?) throws {
		try processTest(file: src, to: dest, using: key, bufferSize: Self.BUFFER_SIZE,
						operation: { try encrypt($0, using: key) },
						onProgress: onProgress)
	}
	
	func decrypt(file src: URL, to dest: URL, using key: SymmetricKey, onProgress: OnProgress?) throws {
		try processTest(file: src, to: dest, using: key, bufferSize: Self.BUFFER_SIZE + 28,
						operation: { try decrypt($0, using: key) },
						onProgress: onProgress)
	}
}

typealias Operation = (Data) throws -> Data
typealias FinalOperation = () throws -> Data
func processTest(file src: URL, to dest: URL, using key: SymmetricKey, bufferSize: Int = 32 * 1000,
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


extension InputStream {
	typealias Buffer = [UInt8]
	
	func readAll(bufferSize: Int, block: (Buffer, Int) throws -> Void) rethrows {
		open()
		defer { close() }
		
		var buffer = [UInt8](repeating: 0, count: bufferSize)
		while hasBytesAvailable {
			let bytesRead = read(&buffer, maxLength: buffer.count)
			guard bytesRead > 0 else { break }
			
			try block(buffer, bytesRead)
		}
	}
}

extension OutputStream {
	func write(data: Data) {
		let buffer = [UInt8](data)
		write(buffer, maxLength: buffer.count)
	}
}
