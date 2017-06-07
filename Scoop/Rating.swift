//
//  Rating.swift
//  Scoop
//
//  Created by Fran Lucena on 7/6/17.
//  Copyright © 2017 Fran Lucena. All rights reserved.
//

import UIKit
import Firebase

class Rating: NSObject {
    
    var userId: String
    var rating: Int
    
    init(userId: String, rating: Int) {
        self.userId = userId
        self.rating = rating
    }
    
    init(snapshot: FIRDataSnapshot?) {
        self.userId = (snapshot?.key)!
        self.rating = snapshot?.value as! Int
    }

}
