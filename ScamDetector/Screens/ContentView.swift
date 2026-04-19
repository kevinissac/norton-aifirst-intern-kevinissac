//
//  ContentView.swift
//  ScamDetector
//
//  Created by Kevin Issac on 17/04/26.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var viewModel = ScanViewModel()

  var body: some View {
    NavigationStack {
      ZStack {
        Color.white
          .ignoresSafeArea()
          .onTapGesture {
            UIApplication.shared.dismissKeyboard()
          }

        VStack(spacing: 0) {
          headerSection
            .padding(.horizontal, 20)
            .padding(.top, 8)

          Spacer()

          inputSection
        }
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
    HStack(alignment: .top, spacing: 10) {
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

        Text("We've scanned \(Text(viewModel.scannedMessageCount.formatted()).foregroundStyle(Color(red: 0.18, green: 0.43, blue: 0.84))) messages and flagged \(Text(viewModel.flaggedScamCount.formatted()).foregroundStyle(Color(red: 0.0, green: 0.67, blue: 0.20))) as scams.")
          .font(.system(.largeTitle, design: .rounded, weight: .bold))
          .foregroundStyle(.black)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 0)

      Group {
        if let image = UIImage(named: "dog") {
          Image(uiImage: image)
            .resizable()
            .scaledToFit()
        } else {
          Image(systemName: "dog.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.05))
            .padding(8)
        }
      }
      .frame(width: 112, height: 112)
    }
  }

  private var inputSection: some View {
    VStack(spacing: 24) {
      Text("Scan a message or link")
        .multilineTextAlignment(.center)
        .font(.system(.largeTitle, design: .rounded, weight: .bold))
        .foregroundStyle(.black)

      ZStack(alignment: .topLeading) {
        TextEditor(text: $viewModel.inputText)
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

        if viewModel.inputText.isEmpty {
          Text("Paste the text or link here.")
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .foregroundStyle(Color.gray)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .allowsHitTesting(false)
        }
      }

      Button {
        viewModel.scanMessage()
      } label: {
        HStack(spacing: 8) {
          Text("Scan message")
            .font(.system(.body, design: .rounded, weight: .bold))
          Image(systemName: "arrow.right")
            .font(.system(size: 20, weight: .bold))
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
}
