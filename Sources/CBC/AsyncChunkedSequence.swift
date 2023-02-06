//
//  AsyncChunkedSequence.swift
//  
//
//  Created by Gal Yedidovich on 05/12/2021.
//


public extension AsyncSequence {
	func chunked(upTo chunkSize: Int) -> AsyncChunkedSequence<Self> {
		AsyncChunkedSequence(sequence: self, chunkSize: chunkSize)
	}
}

public struct AsyncChunkedSequence<AsyncSeq : AsyncSequence>: AsyncSequence {
	public typealias Element = [AsyncSeq.Element]
	
	let sequence: AsyncSeq
	let chunkSize: Int
	
	public func makeAsyncIterator() -> AsyncIterator {
		AsyncIterator(innerIterator: sequence.makeAsyncIterator(), chunkSize: chunkSize)
	}
	
	public struct AsyncIterator: AsyncIteratorProtocol {
		var innerIterator: AsyncSeq.AsyncIterator
		let chunkSize: Int
		
		public mutating func next() async throws -> Element? {
			var chunk: Element = []
			
			while chunk.count < chunkSize, let value = try await innerIterator.next() {
				chunk.append(value)
			}
			
			return chunk.isEmpty ? nil : chunk
		}
	}
}
