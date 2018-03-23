# SwiftyTesseract
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![platforms](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)

#### SwiftyTesseract is currently only availble for use on iOS

# Using SwiftyTesseract in Your Project
Import the module
```swift
import SwiftyTesseract
```
There are two ways to instantiate SwiftyTesseract without altering the default values. With one language:
```swift
let swiftyTesseract = SwiftyTesseract(language: .english)
```
Or with multiple languages:
```swift
let swiftyTesseract = SwiftyTesseract(languages: [.english, .french, .italian])
```
To perform OCR, simply pass a UIImage to the performOCR function and handle the recognized string in the completion handler:
```swift
swiftyTesseract.performOCR(on: image) { recognizedString in

  guard let recognizedString = recognizedString else { return }
  print(recognizedString)

}
```

## A Note on Initializer Defaults
The full signature of the primary `SwiftyTesseract` initializer is
```swift
public init SwiftyTesseract(languages: [RecognitionLanguage], 
                            bundle: Bundle = .main, 
                            engineMode: EngineMode = .lstmOnly)
```
The bundle parameter is required to locate the `tessdata` folder. This will only need to be changed if `SwiftyTesseract` is not being implemented in your primary bundle. The engine mode dictates the type of `.traineddata` files to put into your `tessdata` folder. `.lstmOnly` was chosen as a default due to the higher speed reliability found during testing, but could potentially vary depending on the language you are using to perform OCR. See [Which Language Training Data Should You Use?](#language-data) for more information on the different types of `.traineddata` files that can be used with `SwiftyTesseract`

# Installation
### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

**Tested with `pod --version`: `1.3.1`**

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'SwiftyTesseract',    '~> 1.0'
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

### [Carthage](https://github.com/Carthage/Carthage)

**Tested with `carthage version`: `0.28.0`**

Add this to `Cartfile`

```
github "SwiftyTesseract/SwiftyTesseract" ~> 1.0
```

```bash
$ carthage update
```

### Additional configuration
1. Download the appropriate language training files from the [tessdata](https://github.com/tesseract-ocr/tessdata), [tessdata_best](https://github.com/tesseract-ocr/tessdata_best), or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast)  repositories.
2. Place your language training files into a folder on your computer named `tessdata`
3. Drag the folder into your project. You **must** enure that "Create folder references" is checked or `SwiftyTesseract` will **not** be succesfully instantiated.


### <a name="language-data"></a>Which Language Training Data Should You Use? 
There are three different types of `.traineddata` files that can be used in `SwiftyTesseract`: [`tessdata`](https://github.com/tesseract-ocr/tessdata), [`tessdata_best`](https://github.com/tesseract-ocr/tessdata_best), or [`tessdata_fast`](https://github.com/tesseract-ocr/tessdata_fast) that correspond to `SwiftyTesseract` `EngineMode`s `.tesseractOnly`, `.lstmOnly`, and `.tesseractLstmCombined`. `.tesseractOnly` uses the legacy [Tesseract](https://github.com/tesseract-ocr/tesseract) engine and can only use language training files from the [`tessdata`](https://github.com/tesseract-ocr/tessdata) repository. During testing of `SwiftyTesseract`, the `.tesseractOnly` engine mode was found to be the least reliable. `.lstmOnly` uses a long short-term memory recurrent neural network to perform OCR and can use language training files from either [`tessdata_best`](https://github.com/tesseract-ocr/tessdata_best) or [`tessdata_fast`](https://github.com/tesseract-ocr/tessdata_fast) repositories. During testing, [`tessdata_best`](https://github.com/tesseract-ocr/tessdata_best) was found to provide the most reliable results at the cost of speed, while [`tessdata_fast`](https://github.com/tesseract-ocr/tessdata_fast) provided results that were more reliable than [`tessdata`](https://github.com/tesseract-ocr/tessdata) and faster than [`tessdata_best`](https://github.com/tesseract-ocr/tessdata_best). `.tesseractLstmCombined` can only use language files from the [`tessdata`](https://github.com/tesseract-ocr/tessdata) repository, and the results and speed seemed to be on par with [`tessdata_best`](https://github.com/tesseract-ocr/tessdata_best). For most cases, `.lstmOnly` along with the [`tessdata_fast`](https://github.com/tesseract-ocr/tessdata_fast) language training files will likely be the best option, but this could vary depending on the language and application of `SwiftyTesseract` in your project. 

## Contributions Welcome
`SwiftyTesseract` does not currently impelement the full Tesseract API, so if there is functionality that you would like implemented, create an issue and open a pull request! Please see [Contributing to SwiftyTesseract](Contributions.md) for the full guidelines for creating issues and opening pull requests to the project.

## Attributions
SwiftyTesseract would not be possible without the work done by the [Tesseract](https://github.com/tesseract-ocr/tesseract) team. Special thanks also goes out to [Tesseract-OCR-iOS](https://github.com/gali8/Tesseract-OCR-iOS) for the Makefiles that were tweaked to build Tesseract and it's dependencies for use on iOS architectures. 
