# SwiftyTesseract

## This library is no longer maintained and will see no further updates.
I created this project out of a need to perform OCR on labels and machine readable formats in a warehouse environment. It served that purpose well enough,
however I have not worked on that project in over 3 years and have not personally used this project since. 

If you need OCR support in your application, I suggest you use the first party option by using the [Text Recognition](https://developer.apple.com/documentation/vision/recognizing_text_in_images)
capabilities of Apple's Vision framework. If your language is not supported by Apple, I suggest you fork this project and maintain it yourself. If you need assistance migrating to another solution
or in maintaining your own fork, you or your company can reach out to me to arrange a contract agreement.

---

![SPM compatible](https://img.shields.io/badge/SPM-compatible-blueviolet.svg?style=for-the-badge&logo=swift)
![swift-version](https://img.shields.io/badge/Swift-5.3-orange.svg?style=for-the-badge&logo=swift)
![platforms](https://img.shields.io/badge/Platforms-%20iOS%2011.0%20%2B%20|%20macOS%2010.13%20%2B%20|%20Linux%20-lightgrey.svg?style=for-the-badge)

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/SwiftyTesseract/SwiftyTesseract/CI?label=CI&logo=github&style=for-the-badge)
![Examples Status](https://img.shields.io/github/workflow/status/SwiftyTesseract/SwiftyTesseract/Examples?label=Examples&logo=github&style=for-the-badge)
![Linux ARM and macOS M1 Build Badge](https://img.shields.io/drone/build/SwiftyTesseract/SwiftyTesseract?label=Linux%20and%20macOS%20ARM64&server=https%3A%2F%2Fdrone.stevensherry.dev&style=for-the-badge&logo=drone)

## Table of Contents
* [Version Compatibility](#Version-Compatibility)
* [Class name change](#`SwiftyTesseract`-class-renamed-to-`Tesseract`)
* [Using SwiftyTesseract in Your Project](#Using-SwiftyTesseract-in-Your-Project)
  * [Performing OCR](#Performing-OCR)
    * [Platform Agnostic](#Platform-Agnostic)
    * [Combine](#Combine)
    * [UIKit](#UIKit)
    * [AppKit](#AppKit)
  * [Extensibility](#Extensibility)
    * [Tesseract Variable Configuration](#Tesseract-Variable-Configuration)
    * [Tesseract.Variable](#tesseractvariable)
    * [perform(action:)](#performaction)
  * [Initializer Defaults](#A-Note-on-Initializer-Defaults)
  * [libtesseract](#libtesseract)
  * [Installation](#Installation)
    * [Apple Platforms](#Apple-Platforms)
    * [Linux](#Linux)
  * [Additional Configuration](#Additional-Configuration)
    * [Shipping language training files in an application bundle](#Shipping-language-training-files-as-part-of-an-application-bundle)
    * [Shipping language training files as part of a Swift Package](#Shipping-language-training-files-as-part-of-a-Swift-Package)
    * [Custom location for language files](#Custom-Location)
  * [Language Training Data Considerations](#Language-Training-Data-Considerations)
  * [Linux Specific Configuration](#Linux-Specific-Configuration)
  * [Custom Trained Data](#Custom-Trained-Data)
  * [Recognition Results](#Recognition-Results)
* [Contributions](#Contributions-Welcome)
* [Documentation](#Documentation)
* [Attributions](#Attributions)

## Version Compatibility
| SwiftyTesseract Version |     Platforms Supported     | Swift Version  |
| ----------------------- | :-------------------------: | -------------: |
| 4.x.x                   | **iOS** **macOS** **Linux** | 5.3            |
| 3.x.x                   |          **iOS**            | 5.0 - 5.2      |
| 2.x.x                   |          **iOS**            | 4.2            |
| 1.x.x                   |          **iOS**            | 4.0 - 4.1      |

### Known Issue Submitting to App Store Connect
When submitting to App Store Connect, libtesseract.framework will need to be removed from your app bundle before submission. This can be achieved through a post-build action in your application target's scheme by running the following:
```bash
rm -rf "${TARGET_BUILD_DIR}/${PRODUCT_NAME}.app/Frameworks/libtesseract.framework"
```
If you are facing this error after already building your project, you will need to clear your derived data and perform a clean build.

This issue currently affects all binary Swift packages and is not unique to this project. Please see [SwiftyTesseract issue #83](https://github.com/SwiftyTesseract/SwiftyTesseract/issues/83) and [libtesseract issue #3](https://github.com/SwiftyTesseract/libtesseract/issues/3) for more information.

### Develop
Develop should be considered unstable and API breaking changes could happen at any time. If you need to utilize some changes contained in develop, adding the specific commit is highly recommended:
```swift
.package(
    url: "https://github.com/SwiftyTesseract/SwiftyTesseract.git",
    // This is just an example of a commit hash, do not just copy and paste this into your Package.swift
    .revision("0e0c6aca147add5d5750ecb7810837ef4fd10fc2")
)
```

### SwiftyTesseract 3.x.x Support
4.0.0 contains a lot of major breaking changes and there have been issues when migrating from Xcode 11 to 12 with versions 3.x.x. The `support/3.x.x` branch has been created to be able to address any issues for those who are unable or unwilling to migrate to the latest version. This branch is only to support blocking issues and will not see any new features.

### Support for Cocoapods and Carthage Dropped
As the Swift Package Manager improves year over year, I have been decided to take advantage of binary Swift Packages that were announced during WWDC 2020 to eliminate having the dependency files being built ad-hoc and served out of the main source repo. This also has the benefit for being able to support other platforms via Swift Package Manager like Linux because the project itself is no longer dependent on Tesseract being vendored out of the source repository. While I understand this may cause some churn with existing projects that rely on SwiftyTesseract as a dependency, Apple platforms themselves have their own first-party OCR support through the [Vision APIs](https://developer.apple.com/documentation/vision/recognizing_text_in_images).

## `SwiftyTesseract` class renamed to `Tesseract`
The SwiftyTesseract class name felt a bit verbose and is more descriptive of the project than the class itself. To disambiguate between Google's Tesseract project and SwiftyTesseract's `Tesseract` class, all mentions of the class will be displayed as a code snippet: `Tesseract`.

## Using SwiftyTesseract in Your Project
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

### Performing OCR
#### Platform Agnostic
Pass an instance of `Data` derived from an image to `performOCR(on:)`
```swift
let imageData = try Data(contentsOf: urlOfYourImage)
let result: Result<String, Tesseract.Error> = tesseract.performOCR(on: imageData)
```

#### Combine 
Pass an instance of `Data` derived from an image to `performOCRPublisher(on:)`
```swift
let imageData = try Data(contentsOf: urlOfYourImage)
let result: AnyPublisher<String, Tesseract.Error> = tesseract.performOCRPublisher(on: imageData)
```

#### UIKit
Pass a `UIImage` to the `performOCR(on:)` _or_ `performOCRPublisher(on:)` methods:
```swift
let image = UIImage(named: "someImageWithText.jpg")!
let result: Result<String, Error> = tesseract.performOCR(on: image)
let publisher: AnyPublisher<String, Error> = tesseract.performOCRPublisher(on: image)
```

#### AppKit
Pass a `NSImage` to the `performOCR(on:)` _or_ `performOCRPublisher(on:)` methods:
```swift
let image = NSImage(named: "someImageWithText.jpg")!
let result: Result<String, Error> = tesseract.performOCR(on: image)
let publisher: AnyPublisher<String, Error> = tesseract.performOCRPublisher(on: image)
```

#### Conclusion
For people who want a synchronous call, the `performOCR(on:)` method provides a `Result<String, Error>` return value and blocks on the thread it is called on.

The `performOCRPublisher(on:)` publisher is available for ease of performing OCR in a background thread and receiving results on the main thread (only available on iOS 13.0+ and macOS 10.15+):
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

### Extensibility
The major downside to the pre-4.0.0 API was it's lack of extensibility. If a user needed to set a variable or perform an operation that existed in the Google Tesseract API but didn't exist on the SwiftyTesseract API, the only options were to fork the project or create a PR. This has been remedied by creating an extensible API for Tesseract variables and Tesseract functions. 

#### Tesseract Variable Configuration
Starting in 4.0.0, all public instance variables of Tesseract have been removed in favor of a more extensible and declarative API:
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
let swiftyTesseract = SwiftyTesseract(language: .english)
swiftyTesseract.blackList = "@#$%^&*"
swiftyTesseract.minimumCharacterHeight = 35
swiftyTesseract.preserveInterwordSpaces = true
```

#### Tesseract.Variable
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

extension Tesseract.Variable: ExpressibleByStringLiteral {
  public typealias StringLiteralType = String

  public init(stringLiteral value: String) {
    self.init(value)
  }
}

// Extensions containing the previous API variables available as members of SwiftyTesseract
public extension Tesseract.Variable {
  static let allowlist: Tesseract.Variable = "tessedit_char_whitelist"
  static let disallowlist: Tesseract.Variable = "tessedit_char_blacklist"
  static let preserveInterwordSpaces: Tesseract.Variable = "preserve_interword_spaces"
  static let minimumCharacterHeight: Tesseract.Variable = "textord_min_xheight"
  static let oldCharacterHeight: Tesseract.Variable = "textord_old_xheight"
}
```
The problem here is that the library doesn't cover all the cases. What if you wanted to set `Tesseract` to only recognize numbers? You may be able to set the `allowlist` to only recognize numerals, but the Google Tesseract API already has a variable that does that: "classify_bln_numeric_mode".

Extending the library to make use of that variable could look something like this:
```swift
tesseract.configure {
  set("classify_bln_numeric_mode", .true)
}
// Or extend Tesseract.Variable to get a clean trailing dot syntax:
// Using ExpressibleByStringLiteral conformance
extension Tesseract.Variable {
  static let numericMode: Tesseract.Variable = "classify_bln_numeric_mode"
}
// Using initializer
extension Tesseract.Variable {
  static let numericMode = Tesseract.Variable("classify_bln_numeric_mode")
}

tesseract.configure {
  set(.numericMode, .true)
}
```

#### `perform(action:)`
Another issue that I've seen come up several times is "Can you implement **X** Tesseract feature" as a feature request. This has the same implications as the old property-based accessors for setting Tesseract variables. The `perform(action:)` method allows users full access to the Tesseract API in a thread-safe manner.

This comes with one **major** caveat: **You will be completely responsible for managing memory when dealing with the Tessearct API directly**. Using the Tesseract C API means that ARC will not help you. If you use this API directly, make sure your instrument your code and check for leaks. Swift's `defer` functionality pairs really well with managing memory when dealing directly with C APIs; check out [`Sources/SwiftyTesseract/Tesseract+OCR.swift`](https://github.com/SwiftyTesseract/SwiftyTesseract/blob/develop/Sources/SwiftyTesseract/Tesseract%2BOCR.swift) for examples of using `defer` to release memory.

All of the library methods provided on `Tesseract` other than `Tesseract.perform(action:)` and `Tesseract.configure(_:)` are implemented as extensions using only `Tesseract.perform(action:)` to access the pointer created during initialization. To see this in action see the implementation of `performOCR(on:)` in [`Sources/SwiftyTesseract/Tesseract+OCR.swift`](https://github.com/SwiftyTesseract/SwiftyTesseract/blob/develop/Sources/SwiftyTesseract/Tesseract%2BOCR.swift)

As an example, let's implement [issue #66](https://github.com/SwiftyTesseract/SwiftyTesseract/issues/66) using `perform(action:)`:
```swift
import SwiftyTesseract
import libtesseract

public typealias PageSegmentationMode = TessPageSegMode
public extension PageSegmentationMode {
  static let osdOnly = PSM_OSD_ONLY
  static let autoOsd = PSM_AUTO_OSD
  static let autoOnly = PSM_AUTO_ONLY
  static let auto = PSM_AUTO
  static let singleColumn = PSM_SINGLE_COLUMN
  static let singleBlockVerticalText = PSM_SINGLE_BLOCK_VERT_TEXT
  static let singleBlock = PSM_SINGLE_BLOCK
  static let singleLine = PSM_SINGLE_LINE
  static let singleWord = PSM_SINGLE_WORD
  static let circleWord = PSM_CIRCLE_WORD
  static let singleCharacter = PSM_SINGLE_CHAR
  static let sparseText = PSM_SPARSE_TEXT
  static let sparseTextOsd = PSM_SPARSE_TEXT_OSD
  static let count = PSM_COUNT
}

public extension Tesseract {
  var pageSegmentationMode: PageSegmentationMode {
    get {
      perform { tessPointer in
        TessBaseAPIGetPageSegMode(tessPointer)
      }
    }
    set {
      perform { tessPointer in
        TessBaseAPISetPageSegMode(tessPointer, newValue)
      }
    }
  }
}

// usage
tesseract.pageSegmentationMode = .singleColumn
```

If you don't care about all of the boilerplate needed to make your call site feel "Swifty", you could implement it simply like this:
```swift
import SwiftyTesseract
import libtesseract

extension Tesseract {
  var pageSegMode: TessPageSegMode {
    get {
      perform { tessPointer in
        TessBaseAPIGetPageSegMode(tessPointer)
      }
    }
    set {
      perform { tessPointer in
        TessBaseAPISetPageSegMode(tessPointer, newValue)
      }
    }
  }
}

// usage
tesseract.pageSegMode = PSM_SINGLE_COLUMN
```
#### ConfigurationBuilder
The declarative configuration syntax is achieved by accepting a function builder with functions that have a return value of `(TessBaseAPI) -> Void`. Using the previous example of extending the library to set the page segmentation mode of Tesseract, you could also create a function with a return signature of `(TessBaseAPI) -> Void` to utilize the declarative configuration block either during initialization or through `Tesseract.configure(:_)`:
```swift
import SwiftyTesseract
import libtesseract

func setPageSegMode(_ pageSegMode: TessPageSegMode) -> (TessBaseAPI) -> Void {
  return { tessPointer in
    TessBaseAPISetPageSegMode(tessPointer, pageSetMode)
  }
}

let tesseract = Tesseract(language: .english) {
  setPageSegMode(PSM_SINGLE_COLUMN)
}
// or post initialization
tesseract.configure {
  setPageSegMode(PSM_SINGLE_COLUMN)
}
```

(The information for what to implement for this example was found in the [Tesseract documentation](https://tesseract-ocr.github.io/tessapi/4.0.0/a00014.html#a4d1f965486ce272064ffdbd7a618234c))

#### Conclusion
The major feature of 4.0.0 is it's lack of features. The core of `Tesseract` is less than 130 lines of code, with the remainder of the code base implemented as extensions. I have attempted to be as un-opinionated as possible while providing an API that feels right at home in Swift. Users of the library are not limited to what I have time for or what other contributors to the project are able to contribute.
Now that this API is available, additions to the API surface of the library will be very selective. There should no longer be any restrictions to users of the library given the extensibility.

### A Note on Initializer Defaults
The full signature of the primary `Tesseract` initializer is
```swift
public init Tesseract(
  languages: [RecognitionLanguage], 
  dataSource: LanguageModelDataSource = Bundle.main, 
  engineMode: EngineMode = .lstmOnly,
  @ConfigurationBuilder configure: () -> (TessBaseAPI) -> Void = { { _ in } }
)
```
The bundle parameter is required to locate the `tessdata` folder. This will need to be changed if `Tesseract` is not being implemented in your application bundle or if you are developing a Swift Package project (in this case you would need to specify `Bundle.module`, see `Tests/SwiftyTesseractTests/SwiftyTesseractTests.swift` for an example). The engine mode dictates the type of `.traineddata` files to put into your `tessdata` folder. `.lstmOnly` was chosen as a default due to the higher speed and reliability found during testing, but could potentially vary depending on the language being recognized as well as the image itself. See [Which Language Training Data Should You Use?](#language-data) for more information on the different types of `.traineddata` files that can be used with `SwiftyTesseract`

### libtesseract
Tesseract and it's dependencies are now built and distributed as an xcframework under the [SwiftyTesseract/libtesseract](https://github.com/SwiftyTesseract/libtesseract) repository for Apple platforms. Any issues regarding the build configurations for those should be raised under that repository.

### Installation
Swift Package Manager is now the only supported dependency manager for bringing SwiftyTesseract into your project.

#### Apple Platforms
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
    .package(url: "https://github.com/SwiftyTesseract/SwiftyTesseract.git", .upToNextMajor(from: "4.0.0"))
  ],
  targets: [
    .target(
      name: "AwesomePackage",
      dependencies: ["SwiftyTesseract"]
    ),
  ]
)
```
#### Linux
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
    .package(url: "https://github.com/SwiftyTesseract/SwiftyTesseract.git", .upToNextMajor(from: "4.0.0"))
  ],
  targets: [
    .target(
      name: "AwesomePackage",
      dependencies: ["SwiftyTesseract"]
    ),
  ]
)
```
#### Linux Specific System Configuration
You will need to install libtesseract-dev (must be a >= 4.1.0 release) and libleptonica-dev on the host system before running any application that has a dependency on SwiftyTesseract. For Ubuntu (or Debian based distributions) that may look like this:
```bash
apt-get install -yq libtesseract-dev libleptonica-dev
```
The Dockerfiles in the `docker` directory and `Examples/VaporExample` provide an example. The Ubuntu 20.04 apt repository ships with compatible versions of libtesseract-dev and libleptonica-dev. If you are building against another distribution, then you will need to research what versions of the libraries are available or how to get appropriate versions installed into your image or system.

### Additional configuration
#### Shipping language training files as part of an application bundle
1. Download the appropriate language training files from the [tessdata](https://github.com/tesseract-ocr/tessdata), [tessdata_best](https://github.com/tesseract-ocr/tessdata_best), or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast)  repositories.
2. Place your language training files into a folder on your computer named `tessdata`
3. Drag the folder into your project. You **must** enure that "Create folder references" is selected or `Tesseract` will **not** be successfully instantiated.
![tessdata_folder_example](https://lh3.googleusercontent.com/fnzZw7xhM1YsPXhCnt-vG3ASoe6QP0x72uZzdpPdOOd8ApBYRTy05M5-xq6cabO7Th4SyjdFaG1PTSOnBywXujo0UOVbgb5sp1azScHfj1PvvMxWgLePs1NWrstjsAiqgURfYnUJ=w2400)

#### Shipping language training files as part of a Swift Package
If you choose to keep the language training data files under source control, you will want to
copy your tessdata directory as a package resource:
```swift
let package = Package(
  // Context omitted for brevity. The full Package.swift for this example
  // can be found in Examples/VaporExample/Package.swift
  targets: [
    .target(
      name: "App",
      dependencies: [
        .product(name: "Vapor", package: "vapor"),
        "SwiftyTesseract"
      ],
      // The path relative to your Target directory. In this example, the path
      // relative to the source root would be Sources/App/tessdata
      resources: [.copy("tessdata")],
    )
  ]
)
```

If you prefer not to keep the language training data files under source control see the instructions for using a custom location
below.

#### Custom Location
Thanks to [Minitour](https://github.com/Minitour), developers now have more flexibility in where and how the language training files are included for Tesseract to use. This may be beneficial if your application supports multiple languages but you do not want your application bundle (or git repo) to contain all the possible training files needed to perform OCR (each language training file can range from 1 MB to 15 MB). You will need to provide conformance to the following protocol:
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

### Language Training Data Considerations
There are three different types of `.traineddata` files that can be used in `Tesseract`: [tessdata](https://github.com/tesseract-ocr/tessdata), [tessdata_best](https://github.com/tesseract-ocr/tessdata_best), or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) that correspond to `Tesseract` `EngineMode`s `.tesseractOnly`, `.lstmOnly`, and `.tesseractLstmCombined`. `.tesseractOnly` uses the legacy [Tesseract](https://github.com/tesseract-ocr/tesseract) engine and can only use language training files from the [tessdata](https://github.com/tesseract-ocr/tessdata) repository. During testing of SwiftyTesseract, the `.tesseractOnly` engine mode was found to be the least reliable. `.lstmOnly` uses a long short-term memory recurrent neural network to perform OCR and can use language training files from either [tessdata_best](https://github.com/tesseract-ocr/tessdata_best), [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast), or [tessdata](https://github.com/tesseract-ocr/tessdata) repositories. During testing, [tessdata_best](https://github.com/tesseract-ocr/tessdata_best) was found to provide the most reliable results at the cost of speed, while [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) provided results that were comparable to [tessdata](https://github.com/tesseract-ocr/tessdata) (when used with `.lstmOnly`) and faster than both [tessdata](https://github.com/tesseract-ocr/tessdata) and [tessdata_best](https://github.com/tesseract-ocr/tessdata_best). `.tesseractLstmCombined` can only use language files from the [tessdata](https://github.com/tesseract-ocr/tessdata) repository, and the results and speed seemed to be on par with [tessdata_best](https://github.com/tesseract-ocr/tessdata_best). For most cases, `.lstmOnly` along with the [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) language training files will likely be the best option, but this could vary depending on the language and application of SwiftyTesseract in your project.

### Custom Trained Data
The steps required are the same as the instructions provided in [additional configuration](#additional-configuration). To utilize custom `.traineddata` files, simply use the `.custom(String)` case of `RecognitionLanguage`:
```swift
let tesseract = Tesseract(language: .custom("custom-traineddata-file-prefix"))
```
For example, if you wanted to use the MRZ code optimized `OCRB.traineddata` file provided by [Exteris/tesseract-mrz](https://github.com/Exteris/tesseract-mrz), the instance of Tesseract would be created like this:
```swift
let tesseract = Tesseract(language: .custom("OCRB"))
```
You may also include the first party Tesseract language training files with custom training files:
```swift
let tesseract = Tesseract(languages: [.custom("OCRB"), .english])
```

### Recognition Results
When it comes to OCR, the adage "garbage in, garbage out" applies. SwiftyTesseract is no different. The underlying [Tesseract](https://github.com/tesseract-ocr/tesseract) engine will process the image and return **anything** that it believes is text. For example, giving SwiftyTesseract this image
![raw_unprocessed_image](https://lh3.googleusercontent.com/xqGYRoK3ZPCUzNu-M-LVnmEpPBwT5QRkwGKd6nGBdCgwfAPeZGH2ctWzRQfVc4DhNoUbDmHHyQYc3iRqwjPWfBCEpIbxJiBj9aqii4XtBR1InHoMbt_jdSHvkNnKgQ7vCdhi1pVn=w2400)
yields the following:
```bash
a lot of jibberish...
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
You can see that it picked **SALE** out of the picture, but everything else surrounding it was still attempted to be read regardless of orientation. It is up to the individual developer to determine the appropriate way to edit and transform the image to allow SwiftyTesseract to render text in a way that yields predictable results. Originally, SwiftyTesseract was intended to be an out-of-the-box solution, however, the logic that was being added into the project made too many assumptions, nor did it seem right to force any particular implementation onto potential adopters. [SwiftyTesseractRTE](https://github.com/SwiftyTesseract/SwiftyTesseractRTE) provides a ready-made solution that can be implemented in a project with a few lines of code that **should** suit most needs and is a better place to start if the goal for your project is to get OCR into an application with little effort.

## Contributions Welcome
SwiftyTesseract does not implement the full Tesseract API. Given the extensible nature of the library, you should try to implement any additions yourself. If you think those additions would be useful to everyone else as well, please open a pull request! Please see [Contributing to SwiftyTesseract](CONTRIBUTING.md) for the full guidelines on creating issues and opening pull requests to the project.

## Documentation
Official documentation for SwiftyTesseract can be found [here](https://github.com/SwiftyTesseract/SwiftyTesseract/wiki)

## Attributions
SwiftyTesseract would not be possible without the work done by the [Tesseract](https://github.com/tesseract-ocr/tesseract) team.

See the [Attributions section](https://github.com/SwiftyTesseract/libtesseract#attributions) in the [libtesseract repo](https://github.com/SwiftyTesseract/libtesseract) for a full list of vendored dependencies and their licenses.
