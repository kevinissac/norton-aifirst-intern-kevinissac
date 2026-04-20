//
//  ContentView.swift
//  ScamDetector
//
//  Created by Kevin Issac on 17/04/26.
//

import SwiftUI
import ScamKit

struct ContentView: View {
    @StateObject private var viewModel = ScanViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    if !isInputFocused && viewModel.analysisResult == nil {
                        headerSection
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    inputSection
                }
            }
            .onTapGesture {
                UIApplication.shared.dismissKeyboard()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // Hook for history action.
                    } label: {
                        Image(systemName: "clock")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(.black)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    logoView
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Hook for settings action.
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(.black)
                    }
                }
            }
        }
        .onChange(of: viewModel.isScanning) { oldValue, newValue in
            if newValue {
                UIApplication.shared.dismissKeyboard()
            }
        }
    }
    
    private var logoView: some View {
        Group {
            if let image = UIImage(named: "logo") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield")
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.05))
                    Text("norton")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.black)
                    
                    Text("You're protected")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color(red: 0.62, green: 0.86, blue: 0.0))
                .clipShape(Capsule())
                
                Text("We've scanned \(Text("\(viewModel.scannedMessageCount.pluralized("message"))").foregroundStyle(Color(red: 0.18, green: 0.43, blue: 0.84))) and flagged \(Text("\(viewModel.flaggedScamCount.pluralized("message"))").foregroundStyle(Color(red: 0.0, green: 0.67, blue: 0.20))) as scams.")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.black)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(.dog)
                .resizable()
                .scaledToFit()
                .frame(width: 150)
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 24) {
            Text("Scan a message or link")
                .multilineTextAlignment(.center)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(.black)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.inputText)
                    .focused($isInputFocused)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.black)
                    .frame(height: 108)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .disabled(viewModel.isScanning)
                
                if viewModel.inputText.isEmpty {
                    Text("Paste the text or link here.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.gray)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .allowsHitTesting(false)
                }
            }
            
            if (viewModel.analysisResult == nil) {
                exampleMessagesSection
            }
            
            if (viewModel.analysisResult != nil) {
                analysisSection
            }
            
            Button {
                if viewModel.analysisResult != nil {
                    viewModel.clear()
                } else {
                    viewModel.scanMessage()
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isScanning {
                        ProgressView()
                            .tint(.black)
                        Text("Analyzing...")
                            .font(.system(.body, design: .rounded, weight: .bold))
                    } else if viewModel.analysisResult != nil {
                        Text("Done")
                            .font(.system(.body, design: .rounded, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                    } else {
                        Text("Analyze")
                            .font(.system(.body, design: .rounded, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.98, green: 0.89, blue: 0.02))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.black, lineWidth: 2)
                )
            }
            .disabled(viewModel.isScanning)
            
            
            if viewModel.analysisResult != nil || viewModel.isScanning {
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .padding(.bottom, 64)
        .background(
            Color(red: 0.93, green: 0.93, blue: 0.93)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 36,
                        bottomLeadingRadius: 0, // no rounding at bottom
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 36,
                        style: .continuous
                    )
                )
                .ignoresSafeArea(edges: .bottom) // extends behind home indicator
        )
    }

    private var exampleMessagesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Try an example")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.exampleMessages) { example in
                        Button {
                            viewModel.useExampleMessage(example.message)
                            isInputFocused = true
                        } label: {
                            Text(example.title)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(
                                    example.isScam
                                        ? Color(red: 1.0, green: 0.9, blue: 0.9)
                                        : Color(red: 0.9, green: 1.0, blue: 0.9)
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isScanning)
                    }
                }
            }
        }
    }

    private var analysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let result = viewModel.analysisResult {
                Text("Result")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Risk level")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.black.opacity(0.7))
                        Spacer()
                        Text(result.riskLevel.rawValue)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(result.riskLevel.color)
                    }

                    HStack {
                        Text("Confidence")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.black.opacity(0.7))
                        Spacer()
                        Text("\(Int(result.confidenceScore * 100))%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.black)
                    }

                    Text(result.explanation)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                )
            }

            if let errorMessage = viewModel.scanError {
                Text(errorMessage)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

//    private func riskColor(for riskLevel: ScamRiskLevel) -> Color {
//        switch riskLevel {
//        case .safe:
//            return .green
//        case .suspicious:
//            return .orange
//        case .dangerous:
//            return .red
//        }
//    }
}
