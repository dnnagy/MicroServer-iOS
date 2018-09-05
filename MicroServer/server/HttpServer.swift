//
//  HttpServer.swift
//  MicroServer
//
//  Created by Nagy Daniel on 2018. 08. 24..
//  Copyright © 2018. Nagy Daniel. All rights reserved.
//

import Foundation
import Dispatch

public protocol HttpServerDelegate: class {
    func socketConnectionReceived(_ socket: Socket)
}

public typealias HTTPConnectionHandler = (HttpRequest, Socket) -> ()

public class HttpServer {
    
    public weak var delegate : HttpServerDelegate?
    
    private var socket = Socket(socketFileDescriptor: -1)
    private var sockets = Set<Socket>()
    
    public var connectionHandler: HTTPConnectionHandler = { (req, socket) in print("I do nothing. Override me!") }
    
    public enum HttpServerState: Int32 {
        case starting
        case running
        case stopping
        case stopped
    }
    
    private var stateValue: Int32 = HttpServerState.stopped.rawValue
    
    public private(set) var state: HttpServerState {
        get {
            return HttpServerState(rawValue: stateValue)!
        }
        set(state) {
            #if !os(Linux)
            OSAtomicCompareAndSwapInt(self.state.rawValue, state.rawValue, &stateValue)
            #else
            //TODO - hehe :)
            self.stateValue = state.rawValue
            #endif
        }
    }
    
    public var operating: Bool { get { return self.state == .running } }
    
    /// String representation of the IPv4 address to receive requests from.
    /// It's only used when the server is started with `forceIPv4` option set to true.
    /// Otherwise, `listenAddressIPv6` will be used.
    public var listenAddressIPv4: String?
    
    /// String representation of the IPv6 address to receive requests from.
    /// It's only used when the server is started with `forceIPv4` option set to false.
    /// Otherwise, `listenAddressIPv4` will be used.
    public var listenAddressIPv6: String?
    
    private let queue = DispatchQueue(label: "swifter.httpserverio.clientsockets")
    
    public func port() throws -> Int {
        return Int(try socket.port())
    }
    
    public func isIPv4() throws -> Bool {
        return try socket.isIPv4()
    }
    
    deinit {
        stop()
    }
    
    @available(macOS 10.10, *)
    
    public func start(_ port: in_port_t = 8080, forceIPv4: Bool = false, priority: DispatchQoS.QoSClass = DispatchQoS.QoSClass.background) throws {
        guard !self.operating else { return }
        stop()
        self.state = .starting
        let address = forceIPv4 ? listenAddressIPv4 : listenAddressIPv6
        self.socket = try Socket.tcpSocketForListen(port, forceIPv4, SOMAXCONN, address)
        self.state = .running
        DispatchQueue.global(qos: priority).async { [weak self] in
            guard let strongSelf = self else { return }
            guard strongSelf.operating else { return }
            while let socket = try? strongSelf.socket.acceptClientSocket() {
                DispatchQueue.global(qos: priority).async { [weak self] in
                    guard let strongSelf = self else { return }
                    guard strongSelf.operating else { return }
                    strongSelf.queue.async {
                        strongSelf.sockets.insert(socket)
                    }
                    strongSelf.handleConnection(socket)
                    strongSelf.queue.async {
                        strongSelf.sockets.remove(socket)
                    }
                }
            }
            strongSelf.stop()
        }
    }
    
    public func stop() {
        guard self.operating else { return }
        self.state = .stopping
        // Shutdown connected peers because they can live in 'keep-alive' or 'websocket' loops.
        for socket in self.sockets {
            socket.close()
        }
        self.queue.sync {
            self.sockets.removeAll(keepingCapacity: true)
        }
        socket.close()
        self.state = .stopped
    }
    
    public func handleConnection(_ socket: Socket) {
        let parser = HttpParser()
        while self.operating, let request = try? parser.readHttpRequest(socket) {
           
            let request = request
            request.address = try? socket.peername()
            
            self.connectionHandler(request, socket)
        }
        socket.close()
    }
}
