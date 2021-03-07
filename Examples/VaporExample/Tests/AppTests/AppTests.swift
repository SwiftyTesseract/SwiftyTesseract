@testable import App
import XCTVapor

final class AppTests: XCTestCase {
  func testHelloWorld() throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)

    try app.test(
      .POST,
      "tesseract",
      beforeRequest: { request in
        try request.content
          .encode(
            TesseractController
              .MultipartImageData(
                image: Bundle.module
                  .url(forResource: "image_sample", withExtension: "jpg")
                  .map { try Data.init(contentsOf: $0) }!
              ),
            as: .formData
          )
      },
      afterResponse: { response in
        let responseData = try response.content
          .decode(TesseractController.RecognitionResults.self)
        
        XCTAssertEqual("1234567890\n", responseData.recognizedText)
      }
    )
  }
}
