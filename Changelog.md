
#### 1.0.3 - April 4, 2018
* Added semaphore to make `perform(on:completionHandler:)` thread-safe

#### 1.0.2 - April 2, 2018
* Fixed documentation

#### 1.0.1 - March 30, 2018

* Fixed issue with disk I/O bug that starting occuring in iOS 11.3 that caused a crash when calling `write(to:options:)` on an instance of `Data` to a file name that didn't exist (previously the file would be created if it didn't exist). All conversions from UIImage to Pix are now done in memory, completely bypassing disk I/O altogether.