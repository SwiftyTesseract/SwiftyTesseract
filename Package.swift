// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftyTesseract",
  platforms: [.iOS(.v11), .macOS(.v10_13)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "SwiftyTesseract",
      targets: ["SwiftyTesseract"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/SwiftyTesseract/libtesseract.git", from: "0.1.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "SwiftyTesseract",
      dependencies: ["libtesseract"],
      linkerSettings: [.linkedLibrary("z"), .linkedLibrary("c++")]
    ),
    .testTarget(
      name: "SwiftyTesseractTests",
      dependencies: ["SwiftyTesseract"],
      resources: [.copy("Resources/tessdata"), .copy("Resources/images")]
    ),
//    .testTarget(
//      name: "SwiftyTesseractAppKitTests",
//      dependencies: ["SwiftyTesseract"],
//      resources: [.copy("Resources/tessdata")]
//    )
  ]
)
