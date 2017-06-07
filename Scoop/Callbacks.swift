//
//  Callbacks.swift
//  Scoop
//
//  Created by Fran Lucena on 7/6/17.
//  Copyright © 2017 Fran Lucena. All rights reserved.
//

import Foundation

struct Callbacks {
    
    var done: Bool
    var message: String
    
    init(done: Bool, message: String) {
        self.done = done
        self.message = message
    }
    
    var description: String {
        if self.done {
            return "Ok: " + self.message
        } else {
            return "KO: " + self.message
        }
    }
    
}
