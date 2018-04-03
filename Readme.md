# SwiftyTesseract
![pod-version](https://img.shields.io/cocoapods/v/SwiftyTesseract.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![platforms](https://img.shields.io/badge/Platform-iOS-lightgrey.svg) ![swift-version](https://img.shields.io/badge/Swift-4.0%20%2F%204.1-orange.svg) [![Build Status](https://travis-ci.org/SwiftyTesseract/SwiftyTesseract.svg?branch=master)](https://travis-ci.org/SwiftyTesseract/SwiftyTesseract)

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
To perform OCR, simply pass a `UIImage` to the `performOCR(on:completionHandler:)` method and handle the recognized string in the completion handler:
```swift
guard let image = UIImage(named: "someImageWithText.jpg") else { return }
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
The bundle parameter is required to locate the `tessdata` folder. This will only need to be changed if `SwiftyTesseract` is not being implemented in your primary bundle. The engine mode dictates the type of `.traineddata` files to put into your `tessdata` folder. `.lstmOnly` was chosen as a default due to the higher speed and reliability found during testing, but could potentially vary depending on the language you are using to perform OCR. See [Which Language Training Data Should You Use?](#language-data) for more information on the different types of `.traineddata` files that can be used with `SwiftyTesseract`

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

**Tested with `carthage version`: `0.29.0`**

Add this to `Cartfile`

```
github "SwiftyTesseract/SwiftyTesseract" ~> 1.0
```

```bash
$ carthage update
```

## Additional configuration
1. Download the appropriate language training files from the [tessdata](https://github.com/tesseract-ocr/tessdata), [tessdata_best](https://github.com/tesseract-ocr/tessdata_best), or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast)  repositories.
2. Place your language training files into a folder on your computer named `tessdata`
3. Drag the folder into your project. You **must** enure that "Create folder references" is selected or `SwiftyTesseract` will **not** be succesfully instantiated.
![tessdata_folder_example](https://lh3.googleusercontent.com/FhfztqTSmcJ_YsL_f4ApOt6IpwzF9U2Uxc9M-J68bRxh1PKu8zwtJ1lgguqudDOPMPt7xW0qOX1_1E_a9nYBbG3wX8FwtVBcrJWGoepQiW4L-nUCX89kNADotaifiPNIViCJqborkPYLtclL-RUeFwplKrmhl7sgSV89uPnE6W49cAI18umgXdZyRmsGjtY9OmnUVpO-ICRs6B4okWHdTzET9ti45iKYsPgTmqFKlRPNezPEnjusSDdrKzmyoofV5dL-kKXox5toSoOlZXuWLgvRUjM0uJturQNE7z97KFjt5L_0_1ccR6XFhjFxQf7LshcmiCnw3RUkCQC0fKiiz4VU9QqcP6rYtpkegkhVnon9L1-80xWg74C5xWpd_8h4PuUDIPI-BdWSfBm8fi_uGtkiEVbkjoq1iBUknIFbCi5N8bnvoREb7ysm8w13REbZfVW86hcSjPETnRSxAIDkzcdGimqMpI4chLvQc45o1fYVwPdhmzCVUn7XErjnl5HVTpYw1o6Uh8TY8QCfdmvOk3SjPZ2lxQ0t2E9kAc2AW68GVWcrteDYRaF0spgsQVHvshNd9ZaMTwIsOXgGFrV4Txx1zhSt_bo8LNxwdA=w1458-h862-no)


### <a name="language-data"></a>Which Language Training Data Should You Use? 
There are three different types of `.traineddata` files that can be used in `SwiftyTesseract`: [tessdata](https://github.com/tesseract-ocr/tessdata), [tessdata_best](https://github.com/tesseract-ocr/tessdata_best), or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) that correspond to `SwiftyTesseract` `EngineMode`s `.tesseractOnly`, `.lstmOnly`, and `.tesseractLstmCombined`. `.tesseractOnly` uses the legacy [Tesseract](https://github.com/tesseract-ocr/tesseract) engine and can only use language training files from the [tessdata](https://github.com/tesseract-ocr/tessdata) repository. During testing of `SwiftyTesseract`, the `.tesseractOnly` engine mode was found to be the least reliable. `.lstmOnly` uses a long short-term memory recurrent neural network to perform OCR and can use language training files from either [tessdata_best](https://github.com/tesseract-ocr/tessdata_best), [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast), or [tessdata](https://github.com/tesseract-ocr/tessdata) repositories. During testing, [tessdata_best](https://github.com/tesseract-ocr/tessdata_best) was found to provide the most reliable results at the cost of speed, while [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) provided results that were comparable to [tessdata](https://github.com/tesseract-ocr/tessdata) (when used with `.lstmOnly`) and faster than both [tessdata](https://github.com/tesseract-ocr/tessdata) and [tessdata_best](https://github.com/tesseract-ocr/tessdata_best). `.tesseractLstmCombined` can only use language files from the [tessdata](https://github.com/tesseract-ocr/tessdata) repository, and the results and speed seemed to be on par with [tessdata_best](https://github.com/tesseract-ocr/tessdata_best). For most cases, `.lstmOnly` along with the [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) language training files will likely be the best option, but this could vary depending on the language and application of `SwiftyTesseract` in your project. 

## Recognition Results
When it comes to OCR, the adage "garbage in, garbage out" applies. SwiftyTesseract is no different. The underlying [Tesseract](https://github.com/tesseract-ocr/tesseract) engine will process the image and return **anything** that it believes is text. For example, giving SwiftyTesseract this image
![raw_unprocessed_image](https://lh3.googleusercontent.com/V-xCvMWDzNhF90w4VfMTDarXTQDIveSYWwvIPpqI6ttC39rizowSGAgaHBXEtQidC4hiySCzJgNokx-ul2x5iWdD2Y6gVSb4kJalgGpLonedh9lfWmOUawZ3ag9GRQIn8X-GjkKItq0liDvglytXlX3K3FYSSz28wisV2eOJ30T7ONWAffX39iCt27R6W9P8rwlvJrDNjWAb95uVM72SicTX4DtJt-Aqnio50YKAULozL8LI1eHYZmSBJulRRk5tUKM7ekSYVTu81mwQjtWjTPIQoYdT_mpViYC8U27Bdm66oBF6_sV4YdF7jyseTbpOSWUoV3TjHOLIXAp-H-bNTuV6zjPDqvS15RcdvE0TYUF0SB1WW0cCZRom1268lqjD-Xe6yyYd5tvsvgCK6fQrxjN6aKAiT5jhAu5tYHPQV-mhhMLmO9i1iyrlDaU3ENVyWLp-60EvbKqW511a_-ZXBJD9zXSmCQVQi--Lq2mIOto5Je4d4v558Zz4tLtC6NjpY7v78IFNh9Ds10bxD-xMHpMPc4_BvT5gOB65hBUaMY9sxIbTbn4I5pQMtv8ADo-PMIwx5tz6EVEUg2A4EW11JymqePVysfvpwefu2Q=w2368-h1776-no)
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
`SwiftyTesseract` does not currently impelement the full Tesseract API, so if there is functionality that you would like implemented, create an issue and open a pull request! Please see [Contributing to SwiftyTesseract](Contributions.md) for the full guidelines on creating issues and opening pull requests to the project.

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
