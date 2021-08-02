//
//  Extensions.swift
//  Util
//
//  Created by Gal Yedidovich on 02/08/2021.
//

import Foundation
import CryptoKit

public extension Data {
	var bytes: [UInt8] {
		[UInt8](self)
	}
}

public extension SymmetricKey {
	/// A Data instance created safely from the contiguous bytes without making any copies.
	var dataRepresentation: Data {
		return withUnsafeBytes { bytes in
			let cfdata = CFDataCreateWithBytesNoCopy(nil, bytes.baseAddress?.assumingMemoryBound(to: UInt8.self), bytes.count, kCFAllocatorNull)
			return (cfdata as Data?) ?? Data()
		}
	}
}

public extension URL {
	///computes file size at the URL, if exists
	var fileSize: Int? {
		let values = try? resourceValues(forKeys: [.fileSizeKey])
		return values?.fileSize
	}
	
	///computes file size at the URL, if exists
	var fileSize2: Int? {
		let values = try? FileManager.default.attributesOfItem(atPath: self.path)
		return values?[.size] as? Int
	}
}
