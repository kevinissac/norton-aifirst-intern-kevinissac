//
//  ScamAnalysisResult.swift
//  ScamKit
//
//  Created by Kevin Issac on 19/04/26.
//


import Foundation
import SwiftUI

public enum ScamRiskLevel: String, Codable, CaseIterable {
    case safe = "Safe"
    case suspicious = "Suspicious"
    case dangerous = "Dangerous"
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "safe":
            self = .safe
        case "suspicious":
            self = .suspicious
        case "dangerous":
            self = .dangerous
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown risk level: \(value)"
            )
        }
    }
    
    public var color: Color {
        switch self {
        case .safe:
            return .green
        case .suspicious:
            return .yellow
        case .dangerous:
            return .red
        }
    }
    
//    public var label: String {
//        switch self {
//        case .safe:
//            return "Safe"
//        case .suspicious:
//            return "Suspicious"
//        case .dangerous:
//            return "Dangerous"
//        }
//    }
}

public struct ScamAnalysisResult: Codable {
    public let riskLevel: ScamRiskLevel
    public let confidenceScore: Double
    public let explanation: String
    
    public enum CodingKeys: String, CodingKey {
        case riskLevel
        case confidenceScore
        case explanation
    }
    
    public init(riskLevel: ScamRiskLevel, confidenceScore: Double, explanation: String) {
        self.riskLevel = riskLevel
        self.confidenceScore = Self.normalizedConfidenceScore(from: confidenceScore)
        self.explanation = explanation
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        riskLevel = try container.decode(ScamRiskLevel.self, forKey: .riskLevel)
        explanation = try container.decode(String.self, forKey: .explanation)
        
        if let score = try? container.decode(Double.self, forKey: .confidenceScore) {
            confidenceScore = Self.normalizedConfidenceScore(from: score)
            return
        }
        
        if let scoreInt = try? container.decode(Int.self, forKey: .confidenceScore) {
            confidenceScore = Self.normalizedConfidenceScore(from: Double(scoreInt))
            return
        }
        
        if let scoreString = try? container.decode(String.self, forKey: .confidenceScore),
           let parsed = Self.parseConfidenceScore(from: scoreString) {
            confidenceScore = Self.normalizedConfidenceScore(from: parsed)
            return
        }
        
        throw DecodingError.dataCorruptedError(
            forKey: .confidenceScore,
            in: container,
            debugDescription: "confidenceScore must be numeric or numeric string"
        )
    }
    
    private static func parseConfidenceScore(from raw: String) -> Double? {
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasSuffix("%") {
            let numberText = value.dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
            guard let percent = Double(numberText) else { return nil }
            return percent / 100
        }
        return Double(value)
    }
    
    private static func normalizedConfidenceScore(from value: Double) -> Double {
        let clampedValue = min(max(value, 0), 1)
        
        guard value.isFinite else {
            return clampedValue
        }
        
        // Only treat whole-number values in the 0...100 range as percentages.
        // Fractional values such as 1.5 are interpreted as direct scores and clamped.
        if value > 1, value <= 100, value.rounded(.towardZero) == value {
            return value / 100
        }
        
        return clampedValue
    }
}
