# SwiftyTesseract
![pod-version](https://img.shields.io/cocoapods/v/SwiftyTesseract.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![platforms](https://img.shields.io/badge/Platform-iOS%2011.0%20%2B-lightgrey.svg) ![swift-version](https://img.shields.io/badge/Swift-5.2-orange.svg) ![CI](https://github.com/SwiftyTesseract/SwiftyTesseract/workflows/CI/badge.svg)

# Using SwiftyTesseract in Your Project
Import the module
```swift
import SwiftyTesseract
```
There are two ways to quickly instantiate SwiftyTesseract without altering the default values. With one language:
```swift
let swiftyTesseract = SwiftyTesseract(language: .english)
```
Or with multiple languages:
```swift
let swiftyTesseract = SwiftyTesseract(languages: [.english, .french, .italian])
```
To perform OCR, simply pass a `UIImage` to the `performOCR(on:)` _or_ `performOCRPublisher(on:)` methods:
```swift
let image = UIImage(named: "someImageWithText.jpg")!
let result: Result<String, Error> = swiftyTesseract.performOCR(on: image)
let publisher: AnyPublisher<String, Error> = swiftyTesseract.performOCRPublisher(on: image)
```

## Why Two Methods?
For people who just want a synchronous call, the `performOCR(on:)` method provides a `Result<String, Error>` return value and blocks on the thread it is called on.

The `performOCRPublisher(on:)` publisher is available for ease of performing OCR in a background thread and receiving results on the main thread like so (only available on iOS 13.0+):
```swift
let cancellable = swiftyTesseract.performOCRPublisher(on: image)
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

### Deprecation Notices
Starting in version 3.0.0 `performOCR(on:completionHandler:)` has been deprecated and will be removed in a future release.

Starting in version 3.1.0 `init(language:bundle:engineMode:)` and `init(languages:bundle:engineMode:)` has been deprecated and will be removed in a future release. A new protocol, `LanguageModelDataSource`, allows more flexibility where the language training files has been introduced. SwiftyTesseract ships with an extension to `Bundle` that conforms to `LanguageModelDataSource`. See the [Custom Location](#custom-location) section of [Additional Configuration](#additional-configuration)

## A Note on Initializer Defaults
The full signature of the primary `SwiftyTesseract` initializer is
```swift
public init SwiftyTesseract(
  languages: [RecognitionLanguage], 
  dataSource: LanguageModelDataSource = Bundle.main, 
  engineMode: EngineMode = .lstmOnly
)
```
The bundle parameter is required to locate the `tessdata` folder. This will only need to be changed if `SwiftyTesseract` is not being implemented in your primary bundle. The engine mode dictates the type of `.traineddata` files to put into your `tessdata` folder. `.lstmOnly` was chosen as a default due to the higher speed and reliability found during testing, but could potentially vary depending on the language being recognized as well as the image itself. See [Which Language Training Data Should You Use?](#language-data) for more information on the different types of `.traineddata` files that can be used with `SwiftyTesseract`

## Building Tesseract and It's Dependencies From Source
The Makefile used to build the static binaries vendored with SwiftyTesseract is located at SwiftyTesseract/SwiftyTesseract/Makefile. There is also an aggregate target named `libtesseract` that can be run directly in Xcode that can perform the build and move the binaries and headers into the proper directories. This is provided as a *convenience* for others if they are interested in updating or modifying the dependencies. 

# Installation
Note: These are the **only** supported methods of pulling SwiftyTesseract into your project. The project has seen several people open issues to find that their method of including SwiftyTesseract into their project was to clone, build, then copy and paste the framework into their project. This is not supported.
### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

**Tested with `pod --version`: `1.3.1`**

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'SwiftyTesseract',    '~> 3.0'
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

### [Carthage](https://github.com/Carthage/Carthage)

**Tested with `carthage version`: `0.29.0`**

Add this to `Cartfile`

```
github "SwiftyTesseract/SwiftyTesseract" ~> 3.0
```

```bash
$ carthage update
```

## Additional configuration
### Shipping language training files as part of your application bundle
1. Download the appropriate language training files from the [tessdata](https://github.com/tesseract-ocr/tessdata), [tessdata_best](https://github.com/tesseract-ocr/tessdata_best), or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast)  repositories.
2. Place your language training files into a folder on your computer named `tessdata`
3. Drag the folder into your project. You **must** enure that "Create folder references" is selected or `SwiftyTesseract` will **not** be succesfully instantiated.
![tessdata_folder_example](https://lh3.googleusercontent.com/fnzZw7xhM1YsPXhCnt-vG3ASoe6QP0x72uZzdpPdOOd8ApBYRTy05M5-xq6cabO7Th4SyjdFaG1PTSOnBywXujo0UOVbgb5sp1azScHfj1PvvMxWgLePs1NWrstjsAiqgURfYnUJ=w2400)

### Custom Location
Thanks to [Minitour](https://github.com/Minitour), developers now have more flexibility in where and how the language training files are included for Tesseract to use. This may be beneficial if your application supports multiple languages but you do not want your application bundle to contain all the possible training files needed to perform OCR (each language training file can range from 1 MB to 15 MB). You will need to provide conformance to the following protocol:
```swift
public protocol LanguageModelDataSource {
  var pathToTrainedData: String { get }
}
```

Then pass it to the SwiftyTesseract initializer:
```swift
let customDataSource = CustomDataSource()
let tesseract = SwiftyTesseract(
  language: .english, 
  dataSource: customDataSource, 
  engineMode: .lstmOnly
)
```
See the `testDataSourceFromFiles()` test in `SwiftyTesseractTests.swift` (located near the end of the file) for an example on how this can be done.

### <a name="language-data"></a>Which Language Training Data Should You Use? 
There are three different types of `.traineddata` files that can be used in `SwiftyTesseract`: [tessdata](https://github.com/tesseract-ocr/tessdata), [tessdata_best](https://github.com/tesseract-ocr/tessdata_best), or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) that correspond to `SwiftyTesseract` `EngineMode`s `.tesseractOnly`, `.lstmOnly`, and `.tesseractLstmCombined`. `.tesseractOnly` uses the legacy [Tesseract](https://github.com/tesseract-ocr/tesseract) engine and can only use language training files from the [tessdata](https://github.com/tesseract-ocr/tessdata) repository. During testing of `SwiftyTesseract`, the `.tesseractOnly` engine mode was found to be the least reliable. `.lstmOnly` uses a long short-term memory recurrent neural network to perform OCR and can use language training files from either [tessdata_best](https://github.com/tesseract-ocr/tessdata_best), [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast), or [tessdata](https://github.com/tesseract-ocr/tessdata) repositories. During testing, [tessdata_best](https://github.com/tesseract-ocr/tessdata_best) was found to provide the most reliable results at the cost of speed, while [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) provided results that were comparable to [tessdata](https://github.com/tesseract-ocr/tessdata) (when used with `.lstmOnly`) and faster than both [tessdata](https://github.com/tesseract-ocr/tessdata) and [tessdata_best](https://github.com/tesseract-ocr/tessdata_best). `.tesseractLstmCombined` can only use language files from the [tessdata](https://github.com/tesseract-ocr/tessdata) repository, and the results and speed seemed to be on par with [tessdata_best](https://github.com/tesseract-ocr/tessdata_best). For most cases, `.lstmOnly` along with the [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) language training files will likely be the best option, but this could vary depending on the language and application of `SwiftyTesseract` in your project. 

## Custom Trained Data
The steps required are the same as the instructions provided in [additional configuration](#additional-configuration). To utilize custom `.traineddata` files, simply use the `.custom(String)` case of `RecognitionLanguage`:
```swift
let swiftyTesseract = SwiftyTesseract(language: .custom("custom-traineddata-file-prefix"))
```
For example, if you wanted to use the MRZ code optimized `OCRB.traineddata` file provided by [Exteris/tesseract-mrz](https://github.com/Exteris/tesseract-mrz), the instance of SwiftyTesseract would be created like this:
```swift
let swiftyTesseract = SwiftyTesseract(language: .custom("OCRB"))
```
You may also include the first party Tesseract language training files with custom training files:
```swift
let swiftyTesseract = SwiftyTesseract(languages: [.custom("OCRB"), .english])
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
SwiftyTesseract would not be possible without the work done by the [Tesseract](https://github.com/tesseract-ocr/tesseract) team. Special thanks also goes out to [Tesseract-OCR-iOS](https://github.com/gali8/Tesseract-OCR-iOS) for the Makefiles that were tweaked to build Tesseract and it's dependencies for use on iOS architectures.

SwiftyTesseract bundles Tesseract and it's dependencies as binaries. The full list of dependencies is as follows:
* [Tesseract](https://github.com/tesseract-ocr/tesseract) - License under the [Apache v2 License](https://github.com/tesseract-ocr/tesseract/blob/master/LICENSE)
* [Leptonica](http://www.leptonica.org) - Licensed under the [BSD 2-Clause License](http://www.leptonica.org/about-the-license.html)
* [libpng](http://www.libpng.org) - Licensed under the [Libpng License](http://www.libpng.org/pub/png/src/libpng-LICENSE.txt)
* [libjpeg](http://libjpeg.sourceforge.net) - Licensed under the [Libjpeg License](http://jpegclub.org/reference/libjpeg-license/)
* [libtiff](http://www.libtiff.org) - Licensed under the [Libtiff License](https://fedoraproject.org/wiki/Licensing:Libtiff?rd=Licensing/libtiff)
