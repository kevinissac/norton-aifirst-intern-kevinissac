//
//  GeminiResponse.swift
//  ScamKit
//
//  Created by Kevin Issac on 19/04/26.
//

import Foundation

public struct GeminiResponse: Decodable {
	let candidates: [Candidate]

	struct Candidate: Decodable {
		let content: Content
	}

	struct Content: Decodable {
		let parts: [Part]
	}

	struct Part: Decodable {
		let text: String?
	}
}
