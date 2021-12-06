//
//  AsyncChunkedSequence.swift
//  
//
//  Created by Gal Yedidovich on 05/12/2021.
//


@available(macOS 12.0, iOS 15.0, *)
extension AsyncSequence {
	func chunked(upTo chunkSize: Int) -> AsyncChunkedSequence<Self> {
		AsyncChunkedSequence(sequence: self, chunkSize: chunkSize)
	}
}

@available(macOS 12.0, iOS 15.0, *)
struct AsyncChunkedSequence<AsyncSeq : AsyncSequence>: AsyncSequence {
	typealias Element = [AsyncSeq.Element]
	
	let sequence: AsyncSeq
	let chunkSize: Int
	
	func makeAsyncIterator() -> AsyncIterator {
		AsyncIterator(innerIterator: sequence.makeAsyncIterator(), chunkSize: chunkSize)
	}
	
	struct AsyncIterator: AsyncIteratorProtocol {
		var innerIterator: AsyncSeq.AsyncIterator
		let chunkSize: Int
		
		mutating func next() async throws -> Element? {
			var chunk: Element = []
			
			while chunk.count < chunkSize, let value = try await innerIterator.next() {
				chunk.append(value)
			}
			
			return chunk.isEmpty ? nil : chunk
		}
	}
}
