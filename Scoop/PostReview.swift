//
//  PostReview.swift
//  Scoop
//
//  Created by Fran Lucena on 13/6/17.
//  Copyright © 2017 Fran Lucena. All rights reserved.
//

import UIKit
import Firebase

class PostReview: UIViewController {
    
    //MARK: - Properties
    var post: Posts!
    
    //MARK: - Outlets
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var rateText: UILabel!
    @IBOutlet weak var rateSlide: UISlider!
   
    
    
    //MARK: - Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        rateSlide.isEnabled = false
        
        let myColor : UIColor = UIColor( red: 204.0/255.0, green: 204.0/255.0, blue:204.0/255.0, alpha: 1.0 )
        postText.layer.masksToBounds = true
        postText.layer.borderColor = myColor.cgColor
        postText.layer.borderWidth = 0.5;
        postText.layer.cornerRadius = 5.0;
        
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        postImage.layer.borderWidth = 0.5
        postImage.layer.borderColor = borderColor.cgColor
        postImage.layer.cornerRadius = 5.0
        
        
        if let elementPost = post {
            
            titleText.text = elementPost.title
            postText.text = elementPost.description
            
            rateSlide.isHidden = false
            rateText.isHidden = false
            
            if let currentUser = FIRAuth.auth()?.currentUser {
                PostsModel.getUserRatingPost(post: elementPost.cloudRef!, user: currentUser.uid, completion: { (rating) in
                    self.rateSlide.value = Float(rating)
                    self.rateSlide.isEnabled = true
                    self.rateText.text = String(Int(rating))
                })
                
            } else {
                rateSlide.isHidden = true
                rateText.isHidden = true
            }
            postImage.imageFromServerUrl(urlString: elementPost.photo)
            
            if post.cumulativeRating != 0 && post.numRatings != 0 {
                rateText.text = String(format: "%.2f", Float(post.cumulativeRating) / Float(post.numRatings))
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Actions
    @IBAction func rateAction(_ sender: Any) {
        rateSlide.value = roundf(rateSlide.value)
        rateText.text = String(Int(rateSlide.value))
    }
    
    @IBAction func ratePost(_ sender: Any) {
        
        // Se valida si hay un post instanciado y un usuario logado
        if let elementPost = post,
            let currentUser = FIRAuth.auth()?.currentUser {
            // Se guarda la valoración
            PostsModel.uploadRatingUserPost(postCloudRef: elementPost.cloudRef!, userid: currentUser.uid, ratingValue: Int(rateSlide.value), completion: { (result) in
                print(result.description)
            })
        }
    }
    
}
