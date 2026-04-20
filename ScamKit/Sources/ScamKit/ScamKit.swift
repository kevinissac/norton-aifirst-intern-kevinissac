//
//  ScamKit.swift
//  ScamKit
//
//  Created by Kevin Issac on 19/04/26.
//

import Foundation


public final class ScamKit {
    private let apiKey: String
    private let model: String
    private let session: URLSession
    
    public init(apiKey: String, model: String = "gemini-2.5-flash-lite", session: URLSession = .shared) {
        self.apiKey = apiKey
        self.model = model
        self.session = session
    }
    
    public func verifyMessage(_ message: String) async throws -> ScamAnalysisResult {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ScamKitError.emptyMessage
        }
        
        let prompt = buildPrompt(for: trimmed)
        let aiText = try await generateContent(prompt: prompt)
        let jsonData = try extractJSONData(from: aiText)
        
        do {
            return try JSONDecoder().decode(ScamAnalysisResult.self, from: jsonData)
        } catch {
            throw ScamKitError.invalidJSONFromModel
        }
    }
    
    public func verifyMessageJSON(_ message: String) async throws -> String {
        let result = try await verifyMessage(message)
        let data = try JSONEncoder().encode(result)
        return String(decoding: data, as: UTF8.self)
    }
    
    private func buildPrompt(for message: String) -> String {
  """
  You are a scam detection assistant.
  Analyze the message below and return ONLY valid JSON with this exact schema:
  {
    "riskLevel": "Safe" | "Suspicious" | "Dangerous",
    "confidenceScore": number,
    "explanation": string
  }
  
  Rules:
  - confidenceScore must be between 0 and 1.
  - explanation must be concise (max 2 sentences).
  - Do not include markdown, code fences, or additional keys.
  
  Message to analyze:
  \(message)
  """
    }
    
    private func generateContent(prompt: String) async throws -> String {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = GeminiRequest(
            contents: [
                .init(parts: [.init(text: prompt)])
            ],
            generationConfig: .init(temperature: 0.2)
        )
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ScamKitError.invalidResponse
        }
        
        guard (200 ... 299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8)
            throw ScamKitError.requestFailed(statusCode: httpResponse.statusCode, body: body)
        }
        
        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = decoded.candidates.first?.content.parts.first?.text,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ScamKitError.missingAIContent
        }
        return text
    }
    
    private func extractJSONData(from output: String) throws -> Data {
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let data = trimmed.data(using: .utf8),
           (try? JSONSerialization.jsonObject(with: data)) != nil {
            return data
        }
        
        let withoutFences = trimmed
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let data = withoutFences.data(using: .utf8),
           (try? JSONSerialization.jsonObject(with: data)) != nil {
            return data
        }
        
        throw ScamKitError.invalidJSONFromModel
    }
}

