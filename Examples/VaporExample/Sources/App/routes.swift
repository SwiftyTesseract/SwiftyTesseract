import Vapor
import SwiftyTesseract

func routes(_ app: Application) throws {
  app.get { req in
    return "It works!"
  }
  
  app.get("hello") { req -> String in
    return "Hello, world!"
  }
  
  // The default body size is 16kb, which isn't very friendly to image uploads
  app.routes.defaultMaxBodySize = "50mb"
  try app.register(collection: TesseractController())
}
