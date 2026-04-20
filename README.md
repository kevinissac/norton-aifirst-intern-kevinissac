# Norton Scam Detector

## Project Overview

**Assignment Option:** Option B — Scam Message Detector

This project is a native iOS app built with SwiftUI that allows users to paste or type a suspicious message, SMS, or URL and receive an AI-powered risk assessment, inspired by Norton Genie's scam detection feature.

The app analyzes the input and returns:

- A risk level: Safe, Suspicious, or Dangerous
- A confidence score (0–100)
- A brief explanation of why the message was flagged

## Demo Video

[Watch on YouTube](your-link-here)

## Architecture

The project is split into two targets:

- `ScamDetector`: iOS app UI and interaction flow.
- `ScamKit`: reusable Swift package that sends message content to Gemini and returns normalized scam analysis JSON.

This separation means ScamKit could be reused in future
Norton products across different Apple platforms.

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

The app uses _Google Gemini API_ to analyze text.

To obtain an API key, visit Google AI Studio (https://aistudio.google.com) at the link provided. Once there, locate the "Get API Key" option in the sidebar navigation. From that page, select the button to generate a new key, complete the required fields, and then copy your newly created API key.

The app reads the API key from `Info.plist` via `$(API_KEY)`, sourced from `Config.xcconfig`.

1. Open `ScamDetector.xcodeproj` in Xcode and create a `Config.xcconfig` file. (To create a Config.xcconfig file, right-click on the ScamDetector Root Project and select New File from Template. When the template selection dialog appears, search for Configuration Settings File, then click Next. In the Save File dialog, type Config.xcconfig as the filename and click Create. Once created, open the file and follow the next step.)
2. Set:

```xcconfig
API_KEY = <YOUR_GEMINI_API_KEY>
```

3. Confirm `Info.plist` contains:

```xml
<key>API_KEY</key>
<string>$(API_KEY)</string>
```

4. Now navigate to the ScamDetector Project settings, go to the Info tab, then locate the Configurations section. Expand the Debug configuration and set its value to the newly created Config.xcconfig file.

![alt text](/Screenshots/config.png)

Note: When opening Xcode, the Packages folder may appear highlighted in red — this is expected and can be safely ignored.

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

|                                 |                                 |                                 |
| :-----------------------------: | :-----------------------------: | :-----------------------------: |
| ![alt text](/Screenshots/1.PNG) | ![alt text](/Screenshots/2.PNG) | ![alt text](/Screenshots/3.PNG) |

## UX Decisions

### Reduced Interaction Depth

After exploring Norton Genie scam detection flow, I noticed the actual app requires 4-5 taps to reach a scan result.

In this prototype I reduced that to 3 taps:

1. Paste message
2. Tap "Analyze"
3. View result

This was a deliberate design decision to prioritize speed for the core use case, a user who just received a suspicious message wants an answer immediately, not after navigating through multiple screens.

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

## AI Interaction Log

**Tool:** GitHub Copilot

### Prompt 1: ScamKit Package

**Prompt:** "Wire up Gemini AI to the ScamKit package. Tha package will be provide public functions to get message and verify the text using AI and provide an output which inlcudes the following attributes in a sturctured json format - risk level (Safe / Suspicious / Dangerous), confidence score, and a brief explanation of why the message was flagged. "

**Output:** Generated ScamAnalysisResult struct with Codable conformance

**What I changed:** Added Color attribute to RiskLevel enum so the
UI layer could directly use semantic colors without needing
switch statements in every view. Removed Label attribute because
the enum case name already serves as the label, avoiding
redundant data.

### Prompt 2: UI Design

**Prompt:** "Design the following UI, with navigation bar, text showing "We've scanned 20 messages and flagged 13 as scams" where the numbers are in blue and green and are dynamic based on users scan count, a multiline input field. Use SF Symbols for system icons and images will be provided in assets." (Attached Figma UI Design)

**Output:** Updated ContentView

**What I changed:** Replaced VStack with ScrollView to handle
smaller device sizes gracefully. Repositioned the mascot image
outside the input card to match Figma hierarchy. Updated
navigation bar to use native SwiftUI NavigationStack instead of
AI's custom implementation, which was less maintainable.

### Prompt 3: UI Design

**Prompt:** "Remove bottom safe area inset so that the inputSection will be all way down. And remove the bottom corner radius. " (Attached Figma UI Design)

**Output:** Updated ContentView

**What I changed:** The AI was unable to correctly implement the safeAreaInset modifier, requiring manual intervention to complete it. Instead of the expected solution, the AI offered an alternative approach that did not align with the desired outcome. This taught me that AI tools struggle with using the right SwiftUI layout modifiers in most cases.

### Prompt 4: Bug Fixes

**Prompt:** "Gemini output could not be decoded into expected JSON Format"

**Output:** Updated ScamAnalysisResult and ScamKit

**What I changed:** Accepted the JSON parsing fix but removed
some redundant code like the label attribute as the enum case already serves that purpose.

### Prompt 5: Example Messages

**Prompt:** "Add at least 2 example scam messages so the user can tap to auto-populate the input field."

**Output:** Updated ScamViewModel

**What I changed:** A few additional examples of legitimate, non-scam messages were added.

## AI Code Review

I asked GitHub Copilot to review my ScanViewModel and ScamKit
package with this prompt:
"Review this Swift ViewModel for error handling gaps, memory leaks,
Swift best practices and edge cases"

**Important note:** The majority of the core logic lives in the
ScamKit Swift Package — ScanViewModel is primarily responsible
for UI state management and delegating to ScamKit.

**What AI suggested:**

1. `invalidResponse` error thrown during URL construction in
   ScamKit was misleading — suggested `URLError(.badURL)` instead
2. Confidence score normalization in ScamKit incorrectly treated
   fractional values like 1.5 as percentages — suggested stricter
   bounds checking
3. Silent failure when API key is missing in ScanViewModel —
   suggested setting `scanError` to communicate to the user
4. `isScanning` not reset if Task is cancelled — suggested `defer`
5. In-flight scan not cancellable — suggested storing a Task handle
6. Unused imports and class not marked `final` in ScanViewModel

**What I changed:**

- In ScamKit: Changed `invalidResponse` to `URLError(.badURL)`
  for URL construction failures for a more accurate error type
- In ScamKit: Applied stricter confidence score normalization
  to correctly handle fractional values
- In ScanViewModel: Applied API key empty check with
  user-facing error message
- In ScanViewModel: Removed unused imports

**What I rejected:**

- Did not apply `defer { isScanning = false }` — the current
  flow already resets isScanning at the end of the Task block.
  For this prototype's scope the explicit reset is readable
  and intentional.
- Did not implement full Task cancellation in `clear()` —
  adding a stored Task handle introduces complexity not
  justified for a single-request prototype.

## Reflection

**What I learned:**

- Separating ScamKit as its own Swift Package early made testing
  significantly easier. I could run swift test without launching
  a simulator, which saved a lot of time.
- AI tools are best used for scaffolding and boilerplate. Any
  logic that required understanding the specific app context
  needed to be written or heavily modified manually.
- Prompt specificity matters, vague prompts produced generic
  output, while detailed prompts with context produced something
  actually usable.

**What I'd do differently:**

- Write the Gemini prompt engineering earlier, getting the AI
  to return consistent JSON took more iteration than expected.
- Add UI tests in addition to unit tests to cover the full
  scan flow.
- Add multiple AI models to ScamKit Package for more flexibility.
