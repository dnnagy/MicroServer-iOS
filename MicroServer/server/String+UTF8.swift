//
//  String+UTF8.swift
//  MicroServer
//
//  Created by Nagy Daniel on 2018. 09. 04..
//  Copyright © 2018. Nagy Daniel. All rights reserved.
//

import Foundation

extension String {
    
    init?(utf8Bytes: [UInt8]) {
        self.init(bytes: utf8Bytes, encoding: .utf8)
    }
    
    public func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    public func unquote() -> String {
        var scalars = self.unicodeScalars;
        if scalars.first == "\"" && scalars.last == "\"" && scalars.count >= 2 {
            scalars.removeFirst();
            scalars.removeLast();
            return String(scalars)
        }
        return self
    }
}
