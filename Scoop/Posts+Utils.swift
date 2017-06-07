//
//  Posts+Utils.swift
//  Scoop
//
//  Created by Fran Lucena on 7/6/17.
//  Copyright © 2017 Fran Lucena. All rights reserved.
//

import Foundation
import Firebase

var removeObserverValue: Bool = false
let posts = FIRDatabase.database().reference().child(Posts.className)

class PostsModel {
    
    class func recoverPost(event: FIRDataEventType, completion: @escaping typealiases.PostsList) {
        let query = posts.queryOrdered(byChild: "published").queryEqual(toValue: true)
        fetch(query: query, event: event) {(posts) in
            completion(posts)
        }
    }
    
    class func recoverUserPost(event: FIRDataEventType, userId: String, completion: @escaping typealiases.PostsList){
        let query = posts.queryOrdered(byChild: "userId").queryEqual(toValue : userId)
        
        fetch(query: query, event: event) { (posts) in
            completion(posts)
        }
    }
    
    private class func fetch(query: FIRDatabaseQuery, event: FIRDataEventType, completion: @escaping typealiases.PostsList){
        // Se recuperan los datos de Firebase Database
        query.observe(event, with: { (snapshot) in
            
            var model: [Posts] = []
            
            // Se recuperan todos los datos hijos que se encuentran
            for child in snapshot.children {
                if let snapshot = child as? FIRDataSnapshot, snapshot.hasChildren() {
                    let post = Posts.init(snapshot: snapshot)
                    model.append(post)
                }
            }
            
            //TODO: -- TODO: Implementar en el Backend con más tiempo
            model.sort(by: { $0.creationDate > $1.creationDate })
            DispatchQueue.main.async {
                completion(model)
            }
            
        }) { (error) in
            completion([])
        }
    }
    
    class func uploadPost(post: Posts, imageData: Data, completion: @escaping typealiases.OperationCallbacks) {
        
        uploadImage(imageData: imageData as NSData) { (photo) in
            
            if photo != "" {
                post.photo = photo
            }
            
            let key = posts.childByAutoId().key
            let postInFB = ["\(key)": post.toDict()]
            posts.updateChildValues(postInFB)
            
            DispatchQueue.main.async {
                completion(Callbacks(done: true, message: "Post saved"))
            }
        }
    }
    
    
    class func deletePost(post: Posts, completion: @escaping typealiases.OperationCallbacks){
        posts.child(post.cloudRef!).removeValue(completionBlock: { (error, ref) in
            
            var ret = Callbacks(done: true, message: "Post deleted")
            if let error = error {
                ret = Callbacks(done: false,message: error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                completion(ret)
            }
        })
    }
    
    class func publishPost(postId: String, completion: @escaping typealiases.OperationCallbacks){
        
        posts.child(postId).child("published").setValue(true)
        
        completion(Callbacks(done: true, message: "Post published"))
        
    }
    
    
    class func getUserRatingPost(post: String, user: String, completion: @escaping (Int) -> ()){
        
        let query = posts.child(post).child("ratings").child(user)
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            query.removeAllObservers()
            
            DispatchQueue.main.async {
                if !(snapshot.value is NSNull) {
                    completion(snapshot.value as! Int)
                }else{
                    completion(0)
                }
            }
        })
    }
    
    
    class func uploadRatingUserPost(postCloudRef: String, userid: String, ratingValue: Int,  completion: @escaping typealiases.OperationCallbacks){
        
        let postFetch = posts.child(postCloudRef)
        
        let rating = ["\(userid)": ratingValue]
        postFetch.child("ratings").updateChildValues(rating)
        
        postFetch.observeSingleEvent(of: .value, with: { (snapshot) in
            
            postFetch.removeAllObservers()
            
            if snapshot.hasChildren() {
                let post_firebase = Post.init(snapshot: snapshot)
                
                //TODO: -- TODO: Implementar en el Backend con más tiempo
                post_firebase.numRatings = 0
                post_firebase.cumulativeRating = 0
                if let ratings = post_firebase.ratings {
                    for rating in ratings {
                        post_firebase.numRatings += 1
                        post_firebase.cumulativeRating += rating.rating
                    }
                }
                
                posts.child(postCloudRef).child(constants.numRatings).setValue(post_firebase.numRatings)
                posts.child(postCloudRef).child(constants.cumulativeRating).setValue(post_firebase.cumulativeRating)
                
                DispatchQueue.main.async {
                    completion(Callbacks(done: true, message: "Rating saved"))
                }
            }
        })
    }

    
    private class func uploadImage(imageData: NSData, completion: @escaping (String) -> ()){
        
        if imageData.length == 0 {
            completion("")
        }else{
            let storage = FIRStorage.storage()
            let postImages = storage.reference().child(Posts.className)
            let newImage = postImages.child(UUID().uuidString)
            newImage.put(imageData as Data, metadata: nil) { (metadata, error) in
                
                if let url = metadata?.downloadURL()?.absoluteString {
                    completion(url)
                }
            }
        }
    }
}
