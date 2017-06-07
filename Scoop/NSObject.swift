//
//  NSObject.swift
//  Scoop
//
//  Created by Fran Lucena on 7/6/17.
//  Copyright © 2017 Fran Lucena. All rights reserved.
//

import Foundation


extension NSObject {
    func toDict() -> [String: Any] {
        var dict = [String: Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return dict
    }
}

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
