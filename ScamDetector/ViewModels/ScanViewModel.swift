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

public struct ExampleMessage: Identifiable {
    public let id = UUID()
    let title: String
    let message: String
    let isScam: Bool
}

@MainActor
class ScanViewModel: ObservableObject {
    @Published var scannedMessageCount: Int = 20
    @Published var flaggedScamCount: Int = 13
    @Published var inputText: String = ""
    @Published var isScanning: Bool = false
    @Published var analysisResult: ScamAnalysisResult?
    @Published var scanError: String?

    let exampleMessages: [ExampleMessage] = [
        ExampleMessage(
            title: "Bank alert (Scam)",
            message: "URGENT: Your account is locked due to suspicious activity. Verify now at http://secure-bank-verify-login.co within 10 minutes to avoid permanent suspension.",
            isScam: true
        ),
        ExampleMessage(
            title: "Package fee (Scam)",
            message: "Your parcel delivery failed. Pay a $2.99 redelivery fee immediately at https://track-postal-fast-pay.com to avoid return to sender.",
            isScam: true
        ),
        ExampleMessage(
            title: "Team meeting (Safe)",
            message: "Hi team, reminder that our sprint planning meeting is tomorrow at 10:30 AM in Meeting Room B. Please bring your task updates.",
            isScam: false
        )
    ]
    
    func scanMessage() {
        let message = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        guard !isScanning else { return }
        
        guard
            let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String,
            !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            scanError = "API key is not configured."
            return
        }
        
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

    func useExampleMessage(_ message: String) {
        inputText = message
        scanError = nil
        analysisResult = nil
    }
}
