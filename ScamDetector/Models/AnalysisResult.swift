//
//  AnalysisResult.swift
//  ScamDetector
//
//  Created by Kevin Issac on 17/04/26.
//

import Foundation
import SwiftUI

enum RiskLevel: String, CaseIterable, Codable {
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

struct AnalysisResult: Identifiable, Codable {
  var id: UUID = UUID()
  let originalMessage: String
  let riskLevel: RiskLevel
  let confidenceScore: Double
  let explanation: String
  let redFlags: [String]
  let scannedAt: Date
}
