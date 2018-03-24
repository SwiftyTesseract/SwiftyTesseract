
Pod::Spec.new do |s|

  s.name                    = "SwiftyTesseract"
  s.version                 = "1.0.0"
  s.summary                 = "A Swift wrapper around Tesseract for use in iOS applications."

  s.description             = <<-DESC
                              SwiftyTesseract is a library used to perform optical character recognition
                              in your iOS projects. SwiftyTesseract only implements the functionality of
                              Tesseract and provides no additional image processing. If you would like an
                              out-of-the-box solution that performs live OCR, please check out
                              SwiftyTesseractRTE.  
                            DESC

  s.homepage                = "https://github.com/Steven0351/SwiftyTesseract"

  s.license                 = { :type => "MIT", :file => "LICENSE.md" }

  s.author                  = { "Steven Sherry" => "steven.sherry@affinityforapps.com" }
  s.social_media_url        = "http://twitter.com/steven_0351"


  s.platform                = :ios, "11.0"

  s.source                  = { :git => "https://github.com/Steven0351/SwiftyTesseract.git", :tag => "#{s.version}" }
  s.source_files            = "SwiftyTesseract", "SwiftyTesseract/**/*.{h,m}"
  s.private_header_files    = "SwiftyTesseract/dependencies/include/**/*.h"

  s.requires_arc            = true

  s.frameworks              = "UIKit"

  s.ios.deployment_target    = "10.0"
  s.ios.vendored_library     = "SwiftyTesseract/dependencies/lib/*.a"
  s.xcconfig                 = {  "OTHER_LDFLAGS" => "-lstdc++ -lz",
                                  "CLANG_CXX_LIBRARY" => "compiler-default" }

end
