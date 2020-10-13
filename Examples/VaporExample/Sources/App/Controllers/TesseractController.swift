//
//  TeseractController.swift
//  
//
//  Created by Steven Sherry on 7/18/20.
//

import Vapor
import SwiftyTesseract

final class TesseractController {
  let tesseract = Tesseract(language: .english, dataSource: Bundle.module)
  
  struct MultipartImageData: Content {
    let image: Data
  }
  
  struct RecognitionResults: Content {
    let recognizedText: String
  }
  
  func recognizeImage(_ req: Request) throws -> RecognitionResults {
    let imageData = try req.content.decode(MultipartImageData.self)
    
    return try tesseract.performOCR(on: imageData.image)
      .map(RecognitionResults.init)
      .get()
  }
}

extension TesseractController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    routes.post("tesseract", use: recognizeImage(_:))
  }
}
