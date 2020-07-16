//
//  Tesseract+RecognizedBlock.swift
//  
//
//  Created by Steven Sherry on 7/15/20.
//

import Foundation
import libtesseract

extension Tesseract {
  /// Performs OCR on an image and identifies the regions recognized in the coordinate space of the _image_
  /// - Parameters:
  ///   - imageData: The `Data` representation of an image (e.g. `UIImage.pngData()`)
  ///   - levels: The levels which correspond to the granularity of the desired recognized blocks
  /// - Returns: On success, a `(String, [PageIteratorLevel: [RecognizedBlock]])` that contains
  /// the recognized string and a dictionary of `[RecognizedBlock]` keyed by the provided `PageIteratorLevel`s
  public func recognizedBlocks(
    from imageData: Data,
    for levels: [PageIteratorLevel]
  ) -> Result<(String, [PageIteratorLevel: [RecognizedBlock]]), Error> {
    
    typealias IteratorResult = Result<[PageIteratorLevel: [RecognizedBlock]], Error>
    
    return performOCR(on: imageData).flatMap { string in
      perform { tessPointer in
        
        levels.map { level in
          (level, recognizedBlocks(for: level, with: tessPointer))
        }
        .reduce(IteratorResult.success([:])) { acc, next in
          let (key, value) = next
          
          return acc.mergeMap(with: value) { dict, blocks in
            var copy = dict
            copy[key] = blocks
            return copy
          }
        }
        .map { dict in
          (string, dict)
        }
      }
    }
  }
  
  /// Performs OCR on an image and identifies the regions recognized in the coordinate space of the image
  /// - Parameters:
  ///   - imageData: The `Data` representation of an image (e.g. `UIImage.pngData()`)
  ///   - level: The level which corresponds to the granularity of the desired recognized block
  /// - Returns: On success, a tuple of the recognized string and an array of `RecognizedBlock`s in
  ///  the coordinate space of the _image_.
  public func recognizedBlocks(
    from imageData: Data,
    for level: PageIteratorLevel
  ) -> Result<(String, [RecognizedBlock]), Error> {
    
    recognizedBlocks(from: imageData, for: [level]).flatMap { string, dict in
      guard let blocks = dict[level] else {
        // This really is something of an impossible state, but who really likes force-unwrapping?
        return .failure(.iteratorLevelNotFoundInDictionary(level))
      }
      
      return .success((string, blocks))
    }
  }
  
  /// This method must be called *after* `performOCR(on:)`. Otherwise calling this method will result in failure.
  func recognizedBlocks(for level: PageIteratorLevel, with pointer: TessBaseAPI) -> Result<[RecognizedBlock], Error> {
    guard let resultIterator = TessBaseAPIGetIterator(pointer)
      else { return .failure(Tesseract.Error.unableToRetrieveIterator) }

    defer { TessPageIteratorDelete(resultIterator) }

    var results = [RecognizedBlock]()

    repeat {
      if let block = block(from: resultIterator, for: level) {
        results.append(block)
      }
    } while (TessPageIteratorNext(resultIterator, level) > 0)

    return .success(results)
  }

  private func block(from iterator: OpaquePointer, for level: TessPageIteratorLevel) -> RecognizedBlock? {
    guard let cString = TessResultIteratorGetUTF8Text(iterator, level) else { return nil }
    defer { TessDeleteText(cString) }

    let boundingBox = makeBoundingBox(from: iterator, for: level)
    let text = String(cString: cString)
    let confidence = TessResultIteratorConfidence(iterator, level)

    return RecognizedBlock(text: text, boundingBox: boundingBox, confidence: confidence)
  }

  private func makeBoundingBox(from iterator: OpaquePointer, for level: TessPageIteratorLevel) -> BoundingBox {
    var box = BoundingBox()
    TessPageIteratorBoundingBox(iterator, level, &box.originX, &box.originY, &box.widthOffset, &box.heightOffset)
    return box
  }
}

public struct RecognizedBlock {
  public let text: String
  public let boundingBox: BoundingBox
  public let confidence: Float
}

public struct BoundingBox {
  public internal(set) var originX: Int32 = 0
  public internal(set) var originY: Int32 = 0
  public internal(set) var widthOffset: Int32 = 0
  public internal(set) var heightOffset: Int32 = 0
}

#if canImport(CoreGraphics)
import CoreGraphics

public extension BoundingBox {
  var cgRect: CGRect {
    return CGRect(
      x: .init(originX),
      y: .init(originY),
      width: .init(widthOffset - originX),
      height: .init(heightOffset - originY)
    )
  }
}
#endif

extension Tesseract.Error {
  public static func iteratorLevelNotFoundInDictionary(_ level: PageIteratorLevel) -> Tesseract.Error {
    Tesseract.Error("The iterator level \(level) was not found in the dictionary")
  }
}

public typealias PageIteratorLevel = TessPageIteratorLevel
extension PageIteratorLevel: Hashable { }

public extension PageIteratorLevel {
  static let block = RIL_BLOCK
  static let paragraph = RIL_PARA
  static let textline = RIL_TEXTLINE
  static let word = RIL_WORD
  static let symbol = RIL_SYMBOL
}

extension Result {
  func mergeMap<A, B>(
    with other: Result<A, Failure>,
    transform: (Success, A) -> B
  ) -> Result<B, Failure> {
    flatMap { success in
      other.map { a in
        transform(success, a)
      }
    }
  }
}
