//
//  ScamAnalysisResult.swift
//  ScamKit
//
//  Created by Kevin Issac on 19/04/26.
//


import Foundation
import SwiftUI

public enum ScamRiskLevel: String, Codable, CaseIterable {
    case safe
    case suspicious
    case dangerous

    var color: Color {
      switch self {
      case .safe:
        return .green
      case .suspicious:
        return .yellow
      case .dangerous:
        return .red
      }
    }

    var label: String {
      switch self {
      case .safe:
        return "Safe"
      case .suspicious:
        return "Suspicious"
      case .dangerous:
        return "Dangerous"
      }
    }
}

public struct ScamAnalysisResult: Codable {
    public let riskLevel: ScamRiskLevel
    public let confidenceScore: Double
    public let explanation: String

    public init(riskLevel: ScamRiskLevel, confidenceScore: Double, explanation: String) {
        self.riskLevel = riskLevel
        self.confidenceScore = confidenceScore
        self.explanation = explanation
    }
}
