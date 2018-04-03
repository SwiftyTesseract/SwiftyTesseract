
Pod::Spec.new do |s|

  s.name                     = "SwiftyTesseract"
  s.version                  = "1.0.2"
  s.summary                  = "A Swift wrapper around Tesseract for use in iOS applications."

  s.description              = <<-DESC
                                SwiftyTesseract is a library used to perform optical character recognition
                                in your iOS projects. SwiftyTesseract only implements the functionality of
                                Tesseract and provides no additional image processing. If you would like an
                                out-of-the-box solution that performs live OCR, please check out
                                SwiftyTesseractRTE.  
                              DESC

  s.homepage                 = "https://github.com/SwiftyTesseract/SwiftyTesseract"

  s.license                  = { :type => "MIT", :file => "LICENSE.md" }

  s.author                   = { "Steven Sherry" => "steven.sherry@affinityforapps.com" }
  s.social_media_url         = "http://twitter.com/steven_0351"


  s.platform                 = :ios, "11.0"

  s.source                   = { :git => "https://github.com/SwiftyTesseract/SwiftyTesseract.git", :tag => "#{s.version}" }
  s.source_files             = "SwiftyTesseract/SwiftyTesseract/*.swift","SwiftyTesseract/SwiftyTesseract/**/*.{h,swift}"
  s.private_header_files     = "SwiftyTesseract/SwiftyTesseract/dependencies/include/**/*.h"



  s.requires_arc             = true

  s.frameworks               = "UIKit"

  s.ios.deployment_target    = "10.0"
  s.ios.vendored_library     = "SwiftyTesseract/SwiftyTesseract/dependencies/lib/*.a"
  s.pod_target_xcconfig      = {  "SWIFT_INCLUDE_PATHS" => "$(SRCROOT)/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/dependencies/include/tesseract/**",
                                  "OTHER_LDFLAGS" => "-lstdc++ -lz",
                                  "CLANG_CXX_LIBRARY" => "compiler-default" }

  s.preserve_paths           = "SwiftyTesseract/SwiftyTesseract/dependencies/include/tesseract/module.modulemap"

end
