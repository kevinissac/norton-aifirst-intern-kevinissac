# ScamDetector

ScamDetector is a SwiftUI iOS app that analyzes suspicious messages and links using a local Swift package, `ScamKit`, backed by the Google Gemini API.

## What This Project Includes

- `ScamDetector`: iOS app UI and interaction flow.
- `ScamKit`: reusable Swift package that sends message content to Gemini and returns normalized scam analysis JSON.
- Unit tests for parsing, normalization, and API error handling.

## Key Features

- Paste message text or links and run an analysis.
- Risk classification output:
  - `Safe`
  - `Suspicious`
  - `Dangerous`
- Confidence normalization to a `0...1` score.
- Human-readable explanation in the result.
- Example messages to quickly test behavior.

## Requirements

- macOS (for local build and tests)
- Xcode (latest recommended)
- Swift tools `6.2`
- iOS deployment target: `17.0` (app + ScamKit package)
- macOS deployment target for SwiftPM tests: `12.0`
- A valid Google Gemini API key

## Project Structure

```text
ScamDetector/
  App/
  Screens/
  ViewModels/
  Resources/
  Extensions/
ScamKit/
  Sources/ScamKit/
  Tests/ScamKitTests/
```

## Setting up Google Gemini API Key

The app uses *Google Gemini API* to analyze text.

To obtain an API key, visit Google AI Studio (https://aistudio.google.com) at the link provided. Once there, locate the "Get API Key" option in the sidebar navigation. From that page, select the button to generate a new key, complete the required fields, and then copy your newly created API key.

The app reads the API key from `Info.plist` via `$(API_KEY)`, sourced from `Config.xcconfig`.

1. Create a `Config.xcconfig` file.
2. Set:

```xcconfig
API_KEY = <YOUR_GEMINI_API_KEY>
```

3. Confirm `Info.plist` contains:

```xml
<key>API_KEY</key>
<string>$(API_KEY)</string>
```

## Run The iOS App

1. Open `ScamDetector.xcodeproj` in Xcode.
2. Select the `ScamDetector` scheme.
3. Choose an iOS Simulator (or device).
4. Build and run.

## Run Tests (ScamKit)

From the package directory:

```bash
cd ScamKit
swift test
```

Current status in this workspace: `8 tests passing`.

## Screenshots

| | | |
|:-------------------------:|:-------------------------:|:-------------------------:|
| ![alt text](/Screenshots/1.PNG) | ![alt text](/Screenshots/2.PNG) | ![alt text](/Screenshots/3.PNG) |

## ScamKit API Contract

### Input

- `verifyMessage(_ message: String)` where message is non-empty text.

### Output Schema

```json
{
  "riskLevel": "Safe | Suspicious | Dangerous",
  "confidenceScore": 0.0,
  "explanation": "Short explanation"
}
```

### Public APIs

- `verifyMessage(_:) async throws -> ScamAnalysisResult`
- `verifyMessageJSON(_:) async throws -> String`

## Error Handling

`ScamKit` surfaces domain-specific errors:

- `emptyMessage`
- `invalidResponse`
- `missingAIContent`
- `invalidJSONFromModel`
- `requestFailed(statusCode:body:)`


## Security Recommendation

Do not commit real API keys to source control.

Recommended approach:

- Store `API_KEY` in a local, untracked config file.
- Keep secrets out of committed `xcconfig` files.
