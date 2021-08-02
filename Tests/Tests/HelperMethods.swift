//
//  File.swift
//  File
//
//  Created by Gal Yedidovich on 02/08/2021.
//

import Foundation

func randomString(length: Int) -> String {
	let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	return String((0..<length).map { _ in letters.randomElement()! })
}
