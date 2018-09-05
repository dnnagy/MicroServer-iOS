//
//  File.swift
//  ebbeios
//
//  Created by Nagy Daniel on 2018. 09. 05..
//  Copyright © 2018. Nagy Daniel. All rights reserved.
//

import Foundation

public func sendFile(_ path: String, withSocket socket: Socket) throws {
    let file = try path.openForReading()
    try socket.writeFile(file)
    file.close()
}

public func sendFileAndClose(_ path: String, withSocket socket: Socket) throws {
    let file = try path.openForReading()
    try socket.writeFile(file)
    file.close()
    socket.close()
}
