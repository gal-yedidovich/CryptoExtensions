//
//  CBCError.swift
//  CBC
//
//  Created by Gal Yedidovich on 02/08/2021.
//

import Foundation
import CryptoKit
import CommonCrypto

internal struct CBCError: LocalizedError {
	let message: String
	let status: Int32
	
	var errorDescription: String? {
		return "CBC Error: \"\(message)\", status: \"\(statusString)\" (\(status)."
	}
	
	private var statusString: String {
		switch Int(status) {
		case kCCSuccess:
			return "Success"
		case kCCParamError:
			return "Illegal parameter value"
		case kCCBufferTooSmall:
			return "Insufficient buffer provided for specified operation"
		case kCCMemoryFailure:
			return "Memory allocation failure"
		case kCCAlignmentError:
			return "Input size was not aligned properly"
		case kCCDecodeError:
			return "Input data did not decode or decrypt properly"
		case kCCUnimplemented:
			return "Function not implemented for the current algorithm"
		case kCCOverflow:
			return "Overflow"
		case kCCRNGFailure:
			return "Random Number Generation Failure"
		case kCCCallSequenceError:
			return "Call Sequence Error"
		case kCCKeySizeError:
			return "Invalid key size"
		case kCCInvalidKey:
			return "Key is not valid"
		case kCCUnspecifiedError:
			return "Unspecified Error"
		default:
			return "Unknown status"
		}
	}
}

internal enum CipherError: LocalizedError {
	case finalized
	
	var errorDescription: String? {
		switch self {
		case .finalized:
			return "Cipher is finalized"
		}
	}
}
