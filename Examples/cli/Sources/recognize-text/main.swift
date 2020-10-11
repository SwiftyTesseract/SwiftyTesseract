import ArgumentParser
import Foundation
import SwiftyTesseract

struct RecognizeText: ParsableCommand {
  
  enum OCRError: Error {
    case error(String)
    case tesseract(Tesseract.Error)
  }
  
  @Argument(help: "The image to perform OCR on")
  var imagePath: String
  
  func run() throws {
    let tesseract = Tesseract(
      language: .english,
      dataSource: Bundle.module
    )
    
    guard
      let imageData = FileManager
        .default
        .contents(atPath: imagePath)
    else { throw OCRError.error("Image not found") }
    
    
    switch tesseract.performOCR(on: imageData) {
      case .success(let value): print(value)
      case .failure(let error): throw OCRError.tesseract(error)
    }
  }
}

RecognizeText.main()
