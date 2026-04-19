//
//  GeminiRequest.swift
//  ScamKit
//
//  Created by Kevin Issac on 19/04/26.
//


import Foundation

public struct GeminiRequest: Encodable {
	let contents: [Content]
	let generationConfig: GenerationConfig

	struct Content: Encodable {
		let parts: [Part]
	}

	struct Part: Encodable {
		let text: String
	}

	struct GenerationConfig: Encodable {
		let temperature: Double
	}
}
