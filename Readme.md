# SwiftyTesseract
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 

#### SwiftyTesseract is currently only availble for use on iOS

# Using SwiftyTesseract in Your Project

```swift
import SwiftyTesseract
```

```swift
let swiftyTesseract = SwiftyTesseract(language: .english)
swiftyTesseract.performOCR(from: image) { success, recognizedString in

  guard 
    success,
    let string = recognizedString
  else { return }
  
  print(string)
}
```

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

### Additional configuration
1. Download the appropriate language training files from [tessdata](https://github.com/tesseract-ocr/tessdata) repository.
2. 

### [Carthage](https://github.com/Carthage/Carthage)

**Tested with `carthage version`: `0.28.0`**

Add this to `Cartfile`

```
github "ReactiveX/RxSwift" ~> 4.0
```

```bash
$ carthage update
```


## Attributions
SwiftyTesseract would not be possible without the work done by the [Tesseract](https://github.com/tesseract-ocr/tesseract) team. Special thanks also goes out to [Tesseract-OCR-iOS](https://github.com/gali8/Tesseract-OCR-iOS) for the Makefiles that were tweaked to build Tesseract and it's dependencies for use on iOS architectures. 
