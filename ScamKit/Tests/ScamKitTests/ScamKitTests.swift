import XCTest
@testable import ScamKit

final class ScamKitTests: XCTestCase {
    
    // AI Provided
    override func tearDown() {
        URLProtocolStub.requestHandler = nil
        super.tearDown()
    }

    func testScamAnalysisResultNormalizesWholeNumberPercentage() throws {
        let json = #"{"riskLevel":"Safe","confidenceScore":85,"explanation":"Looks fine."}"#

        let result = try JSONDecoder().decode(ScamAnalysisResult.self, from: Data(json.utf8))

        XCTAssertEqual(result.riskLevel, .safe)
        XCTAssertEqual(result.confidenceScore, 0.85, accuracy: 0.0001)
        XCTAssertEqual(result.explanation, "Looks fine.")
    }

    func testScamRiskLevelDecodesWithWhitespaceAndCaseDifferences() throws {
        let json = #"{"riskLevel":"  sUsPiCiOuS\n","confidenceScore":"0.64","explanation":"Pressure language detected."}"#

        let result = try JSONDecoder().decode(ScamAnalysisResult.self, from: Data(json.utf8))

        XCTAssertEqual(result.riskLevel, .suspicious)
        XCTAssertEqual(result.confidenceScore, 0.64, accuracy: 0.0001)
    }

    func testScamAnalysisResultParsesPercentageStringConfidence() throws {
        let json = #"{"riskLevel":"Dangerous","confidenceScore":"67%","explanation":"Likely phishing attempt."}"#

        let result = try JSONDecoder().decode(ScamAnalysisResult.self, from: Data(json.utf8))

        XCTAssertEqual(result.riskLevel, .dangerous)
        XCTAssertEqual(result.confidenceScore, 0.67, accuracy: 0.0001)
    }

    func testScamAnalysisResultClampsFractionalConfidenceAboveOne() throws {
        let json = #"{"riskLevel":"Safe","confidenceScore":1.5,"explanation":"No immediate concern."}"#

        let result = try JSONDecoder().decode(ScamAnalysisResult.self, from: Data(json.utf8))

        XCTAssertEqual(result.confidenceScore, 1.0, accuracy: 0.0001)
    }

    func testVerifyMessageThrowsOnEmptyInput() async {
        let scamKit = ScamKit(apiKey: "test-key")

        do {
            _ = try await scamKit.verifyMessage("   \n ")
            XCTFail("Expected emptyMessage error")
        } catch let error as ScamKitError {
            if case .emptyMessage = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected emptyMessage, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // AI Provided
    func testVerifyMessageParsesJSONWrappedInCodeFence() async throws {
        let session = makeMockedSession {
            let body = #"""
            {
              "candidates": [
                {
                  "content": {
                    "parts": [
                      {
                        "text": "```json\n{\"riskLevel\":\"Dangerous\",\"confidenceScore\":92,\"explanation\":\"Impersonation and urgent payment demand.\"}\n```"
                      }
                    ]
                  }
                }
              ]
            }
            """#
            return (200, Data(body.utf8))
        }

        let scamKit = ScamKit(apiKey: "abc123", session: session)
        let result = try await scamKit.verifyMessage("Please transfer now to avoid account closure")

        XCTAssertEqual(result.riskLevel, .dangerous)
        XCTAssertEqual(result.confidenceScore, 0.92, accuracy: 0.0001)
        XCTAssertEqual(result.explanation, "Impersonation and urgent payment demand.")
    }

        func testVerifyMessageJSONReturnsNormalizedPayload() async throws {
                let session = makeMockedSession {
                        let body = #"""
                        {
                            "candidates": [
                                {
                                    "content": {
                                        "parts": [
                                            {
                                                "text": "{\"riskLevel\":\"Safe\",\"confidenceScore\":100,\"explanation\":\"Routine reminder message.\"}"
                                            }
                                        ]
                                    }
                                }
                            ]
                        }
                        """#
                        return (200, Data(body.utf8))
                }

                let scamKit = ScamKit(apiKey: "abc123", session: session)
                let output = try await scamKit.verifyMessageJSON("Reminder: standup is at 9:30 AM")
                let decoded = try JSONDecoder().decode(ScamAnalysisResult.self, from: Data(output.utf8))

                XCTAssertEqual(decoded.riskLevel, .safe)
                XCTAssertEqual(decoded.confidenceScore, 1.0, accuracy: 0.0001)
                XCTAssertEqual(decoded.explanation, "Routine reminder message.")
        }

        func testVerifyMessageThrowsRequestFailedOnNonSuccessStatus() async {
                let session = makeMockedSession {
                        let body = #"{"error":{"message":"Quota exceeded"}}"#
                        return (429, Data(body.utf8))
                }

                let scamKit = ScamKit(apiKey: "abc123", session: session)

                do {
                        _ = try await scamKit.verifyMessage("Act now to unlock your account")
                        XCTFail("Expected requestFailed error")
                } catch let error as ScamKitError {
                        switch error {
                        case let .requestFailed(statusCode, body):
                                XCTAssertEqual(statusCode, 429)
                                XCTAssertEqual(body, #"{"error":{"message":"Quota exceeded"}}"#)
                        default:
                                XCTFail("Expected requestFailed, got \(error)")
                        }
                } catch {
                        XCTFail("Unexpected error type: \(error)")
                }
        }

    private func makeMockedSession(
        _ handler: @escaping @Sendable () throws -> (Int, Data)
    ) -> URLSession {
        URLProtocolStub.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            XCTAssertTrue(request.url?.absoluteString.contains("generateContent?key=abc123") == true)

            let (statusCode, data) = try handler()
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }
}


// AI Provided
private final class URLProtocolStub: URLProtocol {
    nonisolated(unsafe) static var requestHandler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
