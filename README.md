# MicroServer-iOS
A very basic http server based on the [swifter](https://github.com/httpswift/swifter) project.

It's just opening a tcp socket, listening on a specified port, and parsing http requests.

## Usage

Copy files in the server directory to Your project. Then You can just use it:

```swift
var server: HttpServer = HttpServer()

server.connectionHandler = { (req, socket) in
  print("[HTTPServer] Got request:")
  req.debugInfo()
  
  do {
     
     // Return a HTTP/1.1 response
     var responseHeader = String()
                        
     responseHeader.append("HTTP/1.1 200 OK\r\n")
     responseHeader.append("Server: iOS MicroServer")
     responseHeader.append("Content-Type: \(fileURL.mimeType())")
     responseHeader.append("\r\n")
     responseHeader.append("\r\n")
                        
     // Send header
     try socket.writeUTF8(responseHeader)
     
     // Send body
     let body: String = "<h1> Hello World! </h1>"
     try socket.writeUTF8(body)
     
     // Close socket after You have sent everything
     socket.close()
                        
} catch (let e) {
     // Handle errors
}
```
