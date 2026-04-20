//
//  ScanViewModel.swift
//  ScamDetector
//
//  Created by Kevin Issac on 18/04/26.
//

import Foundation
import SwiftUI
import Combine
import ScamKit

@MainActor
class ScanViewModel: ObservableObject {
    @Published var scannedMessageCount: Int = 20
    @Published var flaggedScamCount: Int = 13
    @Published var inputText: String = ""
    @Published var isScanning: Bool = false
    @Published var analysisResult: ScamAnalysisResult?
    @Published var scanError: String?
    
    func scanMessage() {
        let message = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        guard !isScanning else { return }
        
        guard let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String else { return }
        
        isScanning = true
        scanError = nil
        analysisResult = nil
        
        Task {
            do {
                let scamKit = ScamKit(apiKey: apiKey)
                let result = try await scamKit.verifyMessage(message)

                analysisResult = result
                scannedMessageCount += 1
                if result.riskLevel != .safe {
                    flaggedScamCount += 1
                }
            } catch {
                scanError = error.localizedDescription
            }

            isScanning = false
        }
    }
    
    func clear() {
        isScanning = false
        scanError = nil
        analysisResult = nil
        inputText = ""
    }
}
