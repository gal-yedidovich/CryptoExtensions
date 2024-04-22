//
//  Extensions.swift
//  
//
//  Created by Gal Yedidovich on 26/11/2022.
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
			let cfData = CFDataCreateWithBytesNoCopy(nil, bytes.baseAddress?.assumingMemoryBound(to: UInt8.self), bytes.count, kCFAllocatorNull)
			return (cfData as Data?) ?? Data()
		}
	}
}
