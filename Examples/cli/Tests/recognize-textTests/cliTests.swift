import XCTest
import class Foundation.Bundle

final class cliTests: XCTestCase {
  func test_whenProvidedAnImagePath_cliSuccessfullyPrintsRecognizedText() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    
    // Some of the APIs that we use below are available in macOS 10.13 and above.
    guard #available(macOS 10.13, *) else {
      return
    }
    
    let fooBinary = productsDirectory.appendingPathComponent("recognize-text")
    
    let process = Process()
    process.executableURL = fooBinary
    process.arguments = Bundle.module
      .path(forResource: "image_sample", ofType: "jpg")
      .map { [$0] }
    
    let pipe = Pipe()
    process.standardOutput = pipe
    
    try process.run()
    process.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    
    XCTAssertEqual(output, "1234567890\n\n")
  }
  
  /// Returns path to the built products directory.
  var productsDirectory: URL {
    #if os(macOS)
    for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
      return bundle.bundleURL.deletingLastPathComponent()
    }
    fatalError("couldn't find the products directory")
    #else
    return Bundle.main.bundleURL
    #endif
  }
  
  static var allTests = [
    ("testExample", test_whenProvidedAnImagePath_cliSuccessfullyPrintsRecognizedText),
  ]
}
