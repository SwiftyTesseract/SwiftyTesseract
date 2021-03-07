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

    // swiftlint:disable nesting
    typealias IteratorResult = Result<[PageIteratorLevel: [RecognizedBlock]], Error>
    // swiftlint:enable nesting

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
  private func recognizedBlocks(
    for level: PageIteratorLevel,
    with pointer: TessBaseAPI
  ) -> Result<[RecognizedBlock], Error> {

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
    TessPageIteratorBoundingBox(iterator, level, &box.left, &box.top, &box.right, &box.bottom)
    return box
  }
}

/// The block of text reognized
public struct RecognizedBlock {

  /// The text recognized within the block
  public let text: String

  /// The coordinate space of the image the text was recognized in
  public let boundingBox: BoundingBox

  /// The confidence level of the recognition operation on a scale of 0.0 to 100.0
  public let confidence: Float
}

/// The coordinate space of a recognized block of text
public struct BoundingBox {

  /// The leftmost point of the bounding box of the reconigzed block in the coordinate space of the image
  public internal(set) var left: Int32 = 0

  /// The topmost point of the bounding box of the reconigzed block in the coordinate space of the image
  public internal(set) var top: Int32 = 0

  /// The rightmost point of the bounding box of the recognized block in the coordinate space of the image
  public internal(set) var right: Int32 = 0

  /// The bottomost point of the bounding box  of the recognized block in the coordinate space of the image
  public internal(set) var bottom: Int32 = 0
}

#if canImport(CoreGraphics)
import CoreGraphics

public extension BoundingBox {

  /// The CGRect of the bounding box. Assumes an upper-left origin (most often the case on iOS).
  var cgRect: CGRect {
    return CGRect(
      x: CGFloat(left),
      y: CGFloat(top),
      width: CGFloat(right - left),
      height: CGFloat(bottom - top)
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

// swiftlint:disable identifier_name
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
