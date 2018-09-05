//
//  ViewController.swift
//  MicroServer
//
//  Created by Nagy Daniel on 2018. 09. 04..
//  Copyright © 2018. Nagy Daniel. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dg = DispatchGroup()
        dg.enter()
        startServer(8080, dispatchGroup: dg)
        dg.wait()
        
        print("[WKWEBVIEW] Sending request...")
        self.webView.load( URLRequest(url: URL(string: "http://localhost:8080/")! ) )
    }

    
    func startServer(_ port: UInt16, dispatchGroup dg: DispatchGroup) {
        
        DispatchQueue.global(qos: .background).async {
            
            let server = HttpServer()
            
            server.connectionHandler = {(req, socket) in
                print("[HTTPSERVER] Got request!")
                req.debugInfo()
                
                // Return a HTTP/1.1 response
                var responseHeader = String()
                
                responseHeader.append("HTTP/1.1 200 OK\r\n")
                responseHeader.append("Server: iOS MicroServer")
                responseHeader.append("Content-Type: text/html; charset=iso-8859-1")
                responseHeader.append("\r\n")
                responseHeader.append("\r\n")
                
                let content = "<html><body><h1>Hello, World!</h1></body></html>"
                
                responseHeader.append(content)
                
                do {
                    print("[HTTPSERVER] Sending response...")
                    try socket.writeUTF8(responseHeader)
                    socket.close() // close socket after writing
                } catch(let e) {
                    fatalError("Could not respond: \(e)")
                }
                
            }
            
            do {
                try server.start(port, forceIPv4: true)
                print("Server has started ( port = \(try server.port()) ). Try to connect now...")
                dg.leave()
            } catch {
                fatalError("Server start error: \(error)")
            }
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

