//
//  ScanViewModel.swift
//  ScamDetector
//
//  Created by Kevin Issac on 18/04/26.
//

import Foundation
import SwiftUI
import Combine

class ScanViewModel: ObservableObject {
  @Published var scannedMessageCount: Int = 20
  @Published var flaggedScamCount: Int = 13
  @Published var inputText: String = ""

  func scanMessage() {
    // Placeholder update until scanner integration is connected.
    guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return
    }

    scannedMessageCount += 1
  }
}
