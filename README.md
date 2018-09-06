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
     // Set response header
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
}

try? server.start(8888, forceIPv4: true)
```

## Sending files

```swift
var server: HttpServer = HttpServer()

server.connectionHandler = { (req, socket) in
    
    // First find file if exists
    if !req.path.isEmpty {
                
          let documentsPathURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                               appropriateFor: nil, create: true)
                                                               
          let fileURL = documentsPathURL.appendingPathComponent(req.path)
                
          var isDir: ObjCBool = ObjCBool(true)
          let exists = FileManager.default.fileExists(atPath: fileURL, isDirectory: &isDir)
   
          // Send if it is not a directory
          if  exists && !isDir.boolValue {
          
            do {
                // Set response header
                var responseHeader = String()
                        
                responseHeader.append("HTTP/1.1 200 OK\r\n")
                responseHeader.append("Server: iOS MicroServer")
                responseHeader.append("Content-Type: \(fileURL.mimeType())")
                responseHeader.append("\r\n")
                responseHeader.append("\r\n")
                        
                // Send header
                try socket.writeUTF8(responseHeader)
                        
                // Try to send file
                try sendFileAndClose(fileURL.path, withSocket: socket)
              } catch (let e) {
                 // Handle error
              }
          } else {
              print("File does not exist or is a directory ")
          }
   } else {
       print("req.path is empty!")
   }
}

try? server.start(8888, forceIPv4: true)
```
