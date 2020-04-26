#### 3.1.0 - April 26, 2020
* Added `LanguageModelDataSource` protocol for flexibility in defining where language training files are located.
* Added `recognizedBlocks(for:)` method on SwiftyTesseract for getting box coordinates from Tesseract.
* Deprecated `init(language:bundle:engineMode:)` and `init(languages:bundle:engineMode:)` in favor of `init(language:dataSource:engineMode:)` and `init(languages:dataSource:engineMode:)`.
* Special thank you to [Minitour](https://github.com/Minitour) for his hard work bringing these features to the library!

While not directly impacting the public facing API of the library, a number of housekeeping changes have been put in place:
* Added PR Template
* Added checklists to Feature request and Bug report templates
* Updated [Contribution Guidelines](CONTRIBUTING.md) and [Readme](README.md) to clarify what the project will support.
* Migrated from Travis CI to GitHub Actions
* Utilizing fastlane for build automation and deployment tasks.
* Moved documentation out of the repo. It will now be auto-generated on release and pushed to the shiny new gh-pages branch.
* Added stale-bot to clean up old issues that have had no activity after 30 days, with a 7-day grace period for anyone to comment to keep the issue open.


#### 3.0.0 - April 2, 2020
* Deprecated `performOCR(on:completionHandler:)`
* Added `performOCR(on:)` and `performOCRPublisher(on:)` methods to replace the aforementioned deprecated method
* Added Makefile and aggregate target `libtesseract` to build dependencies from source

#### 2.2.0 - March 30, 2019
* Added `minimumCharacterHeight` property to enable SwiftyTesseract to ignore characters below
a user-defined threshold.
* Added `createPDF(from:)` method to create a PDF `Data` object from an array of `UIImage`s that
OCR is performed on. 

#### 2.1.0 - February 2, 2019
* Added `preserveInterwordSpaces` property to allow more than one space between words if desired.
* Updated underlying Tesseract library to 4.0.0 release version.

#### 2.0.0 - September 25, 2018
* `CustomData` was enum removed in favor of keeping one enum, `RecognitionLanguage`, that utilizes an associated types as opposed to raw values. This is the only breaking change in 2.0.0 that should only affect users of `CustomData`.
* The underlying Tesseract library has been updated to 4.0.0-beta.4

#### 1.1.0 - May 5, 2018
* Created `CustomData` enum to enable the use of custom `.traineddata` files.
* Added support for iOS 9.0

#### 1.0.3 - April 4, 2018
* Added semaphore to make `performOCR(on:completionHandler:)` thread-safe

#### 1.0.2 - April 2, 2018
* Fixed documentation

#### 1.0.1 - March 30, 2018

* Fixed issue with disk I/O bug that starting occurring in iOS 11.3 that caused a crash when calling `write(to:options:)` on an instance of `Data` to a file name that didn't exist (previously the file would be created if it didn't exist). All conversions from UIImage to Pix are now done in memory, completely bypassing disk I/O altogether.
