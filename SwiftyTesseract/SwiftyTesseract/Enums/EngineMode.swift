//
//  EngineMode.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 3/22/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import libtesseract

/// Specifically determines the underlying method that Tesseract uses to perforn OCR
///
/// - tesseractOnly:         The legacy Tesseract engine. This can only use training data from the
///                          [tessdata](https://github.com/tesseract-ocr/tessdata) repository
///
/// - lstmOnly:              Utilizes a long short-term memory recurrent neural network. This can use training data from
///                          [tessdata](https://github.com/tesseract-ocr/tessdata),
///                          [tessdata_best](https://github.com/tesseract-ocr/tessdata_best),
///                          or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) respositories
///
/// - tesseractLstmCombined: A combination of the legacy Tesseract engine and a long short-term memory
///                          recurrent neural network. This can only use training data from the
///                          [tessdata](https://github.com/tesseract-ocr/tessdata) repository
///
public enum EngineMode: TessOcrEngineMode.RawValue {
  case tesseractOnly = 0
  case lstmOnly = 1
  case tesseractLstmCombined = 2
}
