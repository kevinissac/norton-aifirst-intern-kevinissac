//
//  ScamKitError.swift
//  ScamKit
//
//  Created by Kevin Issac on 19/04/26.
//


import Foundation

public enum ScamKitError: LocalizedError {
	case emptyMessage
	case invalidResponse
	case missingAIContent
	case invalidJSONFromModel
	case requestFailed(statusCode: Int, body: String?)

	public var errorDescription: String? {
		switch self {
		case .emptyMessage:
			return "Message cannot be empty."
		case .invalidResponse:
			return "Gemini API returned an invalid response."
		case .missingAIContent:
			return "Gemini API returned no message content."
		case .invalidJSONFromModel:
			return "Gemini output could not be decoded into expected JSON format."
		case let .requestFailed(statusCode, body):
			if let body, !body.isEmpty {
				return "Gemini request failed with status code \(statusCode): \(body)"
			}
			return "Gemini request failed with status code \(statusCode)."
		}
	}
}
