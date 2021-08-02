//
//  File.swift
//  File
//
//  Created by Gal Yedidovich on 02/08/2021.
//

import Foundation
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
