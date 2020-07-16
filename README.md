# SwiftyTesseract
![SPM compatible](https://img.shields.io/badge/SPM-compatible-blueviolet.svg)
![swift-version](https://img.shields.io/badge/Swift-5.3-orange.svg)
![platforms](https://img.shields.io/badge/Platforms-%20iOS%2011.0%20%2B%20|%20macOS%2010.13%20%2B%20|%20Linux%20-lightgrey.svg) 
![CI](https://github.com/SwiftyTesseract/SwiftyTesseract/workflows/CI/badge.svg)

# Using SwiftyTesseract in Your Project
Import the module
```swift
import SwiftyTesseract
```
There are two ways to quickly instantiate SwiftyTesseract without altering the default values. With one language:
```swift
let tesseract = Tesseract(language: .english)
```
Or with multiple languages:
```swift
let tesseract = Tesseract(languages: [.english, .french, .italian])
```

## Performing OCR
### Platform Agnostic (available on all platforms)
Pass an instance of `Data` derived from an image to `performOCR(on:)`
```swift
let imageData = try Data(contentsOf: urlOfYourImage)
let result: Result<String, Tesseract.Error> = tesseract.performOCR(on: imageData)
```

### Combine (available for iOS, macOS, and macCatalyst)
Pass an instance of `Data` derived from an image to `performOCRPublisher(on:)`
```swift
let imageData = try Data(contentsOf: urlOfYourImage)
let result: AnyPublisher<String, Tesseract.Error> = tesseract.performOCRPublisher(on: imageData)
```

### UIKit (iOS and macCatalyst)
Pass a `UIImage` to the `performOCR(on:)` _or_ `performOCRPublisher(on:)` methods:
```swift
let image = UIImage(named: "someImageWithText.jpg")!
let result: Result<String, Error> = tesseract.performOCR(on: image)
let publisher: AnyPublisher<String, Error> = tesseract.performOCRPublisher(on: image)
```

### AppKit
Pass a `NSImage` to the `performOCR(on:)` _or_ `performOCRPublisher(on:)` methods:
```swift
let image = NSImage(named: "someImageWithText.jpg")!
let result: Result<String, Error> = tesseract.performOCR(on: image)
let publisher: AnyPublisher<String, Error> = tesseract.performOCRPublisher(on: image)
```

### Conclusion
For people who just want a synchronous call, the `performOCR(on:)` method provides a `Result<String, Error>` return value and blocks on the thread it is called on.

The `performOCRPublisher(on:)` publisher is available for ease of performing OCR in a background thread and receiving results on the main thread like so (only available on iOS 13.0+ and macOS 10.15+):
```swift
let cancellable = tesseract.performOCRPublisher(on: image)
  .subscribe(on: backgroundQueue)
  .receive(on: DispatchQueue.main)
  .sink(
    receiveCompletion: { completion in 
      // do something with completion
    },
    receiveValue: { string in
      // do something with string
    }
  )
```
The publisher provided by `performOCRPublisher(on:)` is a **cold** publisher, meaning it does not perform any work until it is subscribed to.

# Extensibility
## Tesseract Variable Configuration
Starting in 4.0.0, all public instance variables of Tesseract have been removed in favor of a more declaritive API:
```swift
let tesseract = Tesseract(language: .english) {
  set(.disallowlist, "@#$%^&*")
  set(.minimumCharacterHeight, .integer(35))
  set(.preserveInterwordSpaces, .true)
}
// or
let tesseract = Tesseract(language: .english)
tesseract.configure {
  set(.disallowlist, "@#$%^&*")
  set(.minimumCharacterHeight, .integer(35))
  set(.preserveInterwordSpaces, .true)
}
```
The pre-4.0.0 API looks like this:
```swift
let swiftyTesseract = SwiftyTesseract(languge: .english)
swiftyTesseract.blackList = "@#$%^&*"
swiftyTesseract.minimumCharacterHeight = 35
swiftyTesseract.preserveInterwordSpaces = true
```

The major downside to the pre-4.0.0 API was it's lack of extensibility. If a user needed to set a variable that existed in the Google Tesseract API but didn't exist on the SwiftyTesseract API, their options were to fork the project or create a PR.

### Tesseract.Variable
`Tesseract.Variable` is a new struct introduced in 4.0.0. It's definition is quite simple:
```swift
extension Tesseract {
  public struct Variable: RawRepresentable {
    public init(rawValue: String) {
      self.init(rawValue)
    }
    
    public init(_ rawValue: String) {
      self.rawValue = rawValue
    }
    
    public let rawValue: String
  }
}

// Extensions containing the previous API variables available as members of SwiftyTesseract
public extension Tesseract.Variable {
  static let allowlist = Tesseract.Variable("tessedit_char_whitelist")
  static let disallowlist = Tesseract.Variable("tessedit_char_blacklist")
  static let preserveInterwordSpaces = Tesseract.Variable("preserve_interword_spaces")
  static let minimumCharacterHeight = Tesseract.Variable("textord_min_xheight")
  static let oldCharacterHeight = Tesseract.Variable("textord_old_xheight")
}
```
The problem here is that the library doesn't cover all the cases. What if you wanted to set Tesseract to only recognize numbers? You may be able to set the `allowlist` to only recognize numerals, but the Google Tesseract API already has a variable that does that: "classify_bln_numeric_mode".

Extending the library to make use of that variable could look something like this:
```swift
tesseract.configure {
  set(Tesseract.Variable("classify_bln_numeric_mode"), .true)
}
// or extend Tesseract.Variable to get a clean trailing dot syntax
extension Tesseract.Variable {
  static let numericMode = Tesseract.Variable("classify_bln_numeric_mode")
}

tesseract.configure {
  set(.numericMode, .true)
}
```

## `perform(action:)`


## A Note on Initializer Defaults
The full signature of the primary `Tesseract` initializer is
```swift
public init Tesseract(
  languages: [RecognitionLanguage], 
  dataSource: LanguageModelDataSource = Bundle.main, 
  engineMode: EngineMode = .lstmOnly
)
```
The bundle parameter is required to locate the `tessdata` folder. This will only need to be changed if `SwiftyTesseract` is not being implemented in your application bundle. The engine mode dictates the type of `.traineddata` files to put into your `tessdata` folder. `.lstmOnly` was chosen as a default due to the higher speed and reliability found during testing, but could potentially vary depending on the language being recognized as well as the image itself. See [Which Language Training Data Should You Use?](#language-data) for more information on the different types of `.traineddata` files that can be used with `SwiftyTesseract`

## libtesseract
Tesseract and it's dependencies are now built and distributed as an xcframework under the [SwiftyTesseract/libtesseract](https://github.com/SwiftyTesseract/libtesseract) repository.

# Installation
Swift Package Manager is now the only supported dependency manager for bringing SwiftyTesseract into your project.

### Apple Platforms
```swift
// Package.swift
// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "AwesomePackage",
  platforms: [
    // These are the minimum versions libtesseract supports
    .macOS(.v10_13),
    .iOS(.v11),
  ],
  products: [
    .library(
      name: "AwesomePackage",
      targets: ["AwesomePackage"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/SwiftyTesseract/SwiftyTesseract.git", from: "4.0.0")
  ],
  targets: [
    .target(
      name: "AwesomePackage",
      dependencies: ["SwiftyTesseract"]
    ),
  ]
)
```
### Linux
```swift
// Package.swift
// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "AwesomePackage",
  products: [
    .library(
      name: "AwesomePackage",
      targets: ["AwesomePackage"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/SwiftyTesseract/SwiftyTesseract.git", from: "4.0.0")
  ],
  targets: [
    .target(
      name: "AwesomePackage",
      dependencies: ["SwiftyTesseractLinux"]
    ),
  ]
)
```

## Additional configuration
### Shipping language training files as part of your application bundle
1. Download the appropriate language training files from the [tessdata](https://github.com/tesseract-ocr/tessdata), [tessdata_best](https://github.com/tesseract-ocr/tessdata_best), or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast)  repositories.
2. Place your language training files into a folder on your computer named `tessdata`
3. Drag the folder into your project. You **must** enure that "Create folder references" is selected or `Tesseract` will **not** be succesfully instantiated.
![tessdata_folder_example](https://lh3.googleusercontent.com/fnzZw7xhM1YsPXhCnt-vG3ASoe6QP0x72uZzdpPdOOd8ApBYRTy05M5-xq6cabO7Th4SyjdFaG1PTSOnBywXujo0UOVbgb5sp1azScHfj1PvvMxWgLePs1NWrstjsAiqgURfYnUJ=w2400)

### Custom Location
Thanks to [Minitour](https://github.com/Minitour), developers now have more flexibility in where and how the language training files are included for Tesseract to use. This may be beneficial if your application supports multiple languages but you do not want your application bundle to contain all the possible training files needed to perform OCR (each language training file can range from 1 MB to 15 MB). You will need to provide conformance to the following protocol:
```swift
public protocol LanguageModelDataSource {
  var pathToTrainedData: String { get }
}
```

Then pass it to the Tesseract initializer:
```swift
let customDataSource = CustomDataSource()
let tesseract = Tesseract(
  language: .english, 
  dataSource: customDataSource, 
  engineMode: .lstmOnly
)
```
See the `testDataSourceFromFiles()` test in `SwiftyTesseractTests.swift` (located near the end of the file) for an example on how this can be done.

### <a name="language-data"></a>Which Language Training Data Should You Use? 
There are three different types of `.traineddata` files that can be used in `SwiftyTesseract`: [tessdata](https://github.com/tesseract-ocr/tessdata), [tessdata_best](https://github.com/tesseract-ocr/tessdata_best), or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) that correspond to `SwiftyTesseract` `EngineMode`s `.tesseractOnly`, `.lstmOnly`, and `.tesseractLstmCombined`. `.tesseractOnly` uses the legacy [Tesseract](https://github.com/tesseract-ocr/tesseract) engine and can only use language training files from the [tessdata](https://github.com/tesseract-ocr/tessdata) repository. During testing of `SwiftyTesseract`, the `.tesseractOnly` engine mode was found to be the least reliable. `.lstmOnly` uses a long short-term memory recurrent neural network to perform OCR and can use language training files from either [tessdata_best](https://github.com/tesseract-ocr/tessdata_best), [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast), or [tessdata](https://github.com/tesseract-ocr/tessdata) repositories. During testing, [tessdata_best](https://github.com/tesseract-ocr/tessdata_best) was found to provide the most reliable results at the cost of speed, while [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) provided results that were comparable to [tessdata](https://github.com/tesseract-ocr/tessdata) (when used with `.lstmOnly`) and faster than both [tessdata](https://github.com/tesseract-ocr/tessdata) and [tessdata_best](https://github.com/tesseract-ocr/tessdata_best). `.tesseractLstmCombined` can only use language files from the [tessdata](https://github.com/tesseract-ocr/tessdata) repository, and the results and speed seemed to be on par with [tessdata_best](https://github.com/tesseract-ocr/tessdata_best). For most cases, `.lstmOnly` along with the [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) language training files will likely be the best option, but this could vary depending on the language and application of `SwiftyTesseract` in your project.

### Linux Specific Configuration
#### TODO

## Custom Trained Data
The steps required are the same as the instructions provided in [additional configuration](#additional-configuration). To utilize custom `.traineddata` files, simply use the `.custom(String)` case of `RecognitionLanguage`:
```swift
let swiftyTesseract = Tesseract(language: .custom("custom-traineddata-file-prefix"))
```
For example, if you wanted to use the MRZ code optimized `OCRB.traineddata` file provided by [Exteris/tesseract-mrz](https://github.com/Exteris/tesseract-mrz), the instance of Tesseract would be created like this:
```swift
let swiftyTesseract = Tesseract(language: .custom("OCRB"))
```
You may also include the first party Tesseract language training files with custom training files:
```swift
let swiftyTesseract = Tesseract(languages: [.custom("OCRB"), .english])
```

## Recognition Results
When it comes to OCR, the adage "garbage in, garbage out" applies. SwiftyTesseract is no different. The underlying [Tesseract](https://github.com/tesseract-ocr/tesseract) engine will process the image and return **anything** that it believes is text. For example, giving SwiftyTesseract this image
![raw_unprocessed_image](https://lh3.googleusercontent.com/xqGYRoK3ZPCUzNu-M-LVnmEpPBwT5QRkwGKd6nGBdCgwfAPeZGH2ctWzRQfVc4DhNoUbDmHHyQYc3iRqwjPWfBCEpIbxJiBj9aqii4XtBR1InHoMbt_jdSHvkNnKgQ7vCdhi1pVn=w2400)
yields the following:
```bash
a lot of jibbersh...
‘o 1 $ : M |
© 1 3 1; ie oI
LW 2 = o .C P It R <0f
O — £988 . 18 |
SALE + . < m m & f f |
7 Abt | | . 3 I] R I|
3 BE? | is —bB (|
* , § Be x I 3 |
...a lot more jibberish
```
You can see that it picked **SALE** out of the picture, but everything else surrounding it was still attempted to be read regardless of orientation. It is up to the individual developer to determine the appropriate way to edit and transform the image to allow SwiftyTesseract to render text in a way that yields predictable results. Originally, SwiftyTesseract was intended to be an out-of-the-box solution, however, the logic that was being added into the project made too many assumptions, nor did it seem right to force any particular implementation onto potential adoptors. [SwiftyTesseractRTE](https://github.com/Steven0351/SwiftyTesseractRTE) provides a ready-made solution that can be implemented in a project with a few lines of code that **should** suit most needs and is a better place to start if the goal for your project is to get OCR into an application with little effort.

## Contributions Welcome
`SwiftyTesseract` does not currently implement the full Tesseract API, so if there is functionality that you would like implemented, create an issue and open a pull request! Please see [Contributing to SwiftyTesseract](Contributions.md) for the full guidelines on creating issues and opening pull requests to the project.

## Documentation
Official documentation for SwiftyTesseract can be found [here](https://swiftytesseract.github.io/SwiftyTesseract/)

## Attributions
SwiftyTesseract would not be possible without the work done by the [Tesseract](https://github.com/tesseract-ocr/tesseract) team.

See the [Attributions section](https://github.com/SwiftyTesseract/libtesseract#attributions) in the [libtesseract repo](https://github.com/SwiftyTesseract/libtesseract) for a full list of vendored dependencies and their licenses.
