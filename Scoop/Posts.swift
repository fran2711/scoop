//
//  Posts.swift
//  Scoop
//
//  Created by Fran Lucena on 7/6/17.
//  Copyright © 2017 Fran Lucena. All rights reserved.
//

import UIKit
import Firebase

class Posts: NSObject {
    
    var title: String
    var des: String
    var photo: String
    var latitude: String
    var longitude: String
    var published: Bool
    var numRatings: Int
    var cumulativeRating: Int
    var creationDate: String
    var userId: String
    var email: String
    var userName: String
    var ratings: [Rating]?
    var cloudRef: String?
        
    init(title: String, des: String, latitude: String, longitude: String, published: Bool, userId: String, email: String, userName: String) {
        self.title = title
        self.des = des
        self.photo = ""
        self.latitude = latitude
        self.longitude = longitude
        self.published = published
        self.numRatings = 0
        self.cumulativeRating = 0
        self.creationDate = Date().description
        self.userId = userId
        self.email = email
        self.userName = userName
        self.ratings = []
        self.cloudRef = nil
    }
    
    init(snapshot: FIRDataSnapshot?) {
        self.title = (snapshot?.value as? [String: Any])? ["title"] as! String
        self.des = (snapshot?.value as? [String:Any])?["des"] as! String
        self.photo = (snapshot?.value as? [String:Any])?["photo"] as! String
        self.latitude = (snapshot?.value as? [String:Any])?["latitude"] as! String
        self.longitude = (snapshot?.value as? [String:Any])?["longitude"] as! String
        self.published = (snapshot?.value as? [String:Any])?["published"] as! Bool
        self.numRatings = (snapshot?.value as? [String:Any])?["numRatings"] as! Int
        self.cumulativeRating = (snapshot?.value as? [String:Any])?["cumulativeRating"] as! Int
        self.creationDate = (snapshot?.value as? [String:Any])?["creationDate"] as! String
        self.userId = (snapshot?.value as? [String:Any])?["userId"] as! String
        self.email = (snapshot?.value as? [String:Any])?["email"] as! String
        self.userName = (snapshot?.value as? [String:Any])?["userName"] as! String
        self.cloudRef = snapshot?.key.description
        
        // Ratings
        let ratings = (snapshot?.value as? [String:Any])?["ratings"]
        self.ratings = ratings.map {
            let ratings = $0 as! [String:Int]
            return ratings.map({ Rating(userId: $0, rating: $1) })
        }
    }
}
