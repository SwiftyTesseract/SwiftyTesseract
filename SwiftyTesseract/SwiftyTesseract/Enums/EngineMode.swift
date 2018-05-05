//
//  EngineMode.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 3/22/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import libtesseract

/// Specifically determines the underlying method that Tesseract uses to perforn OCR
public enum EngineMode: TessOcrEngineMode.RawValue {
  /// The legacy Tesseract engine. This can only use training data from the
  /// [tessdata](https://github.com/tesseract-ocr/tessdata) repository
  case tesseractOnly = 0
  /// Utilizes a long short-term memory recurrent neural network. This can use training data from
  /// [tessdata](https://github.com/tesseract-ocr/tessdata),
  /// [tessdata_best](https://github.com/tesseract-ocr/tessdata_best),
  /// or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) respositories
  case lstmOnly = 1
  /// A combination of the legacy Tesseract engine and a long short-term memory
  /// recurrent neural network. This can only use training data from the
  /// [tessdata](https://github.com/tesseract-ocr/tessdata) repository
  case tesseractLstmCombined = 2
}
