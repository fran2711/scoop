//
//  NewPost.swift
//  Scoop
//
//  Created by Fran Lucena on 13/6/17.
//  Copyright © 2017 Fran Lucena. All rights reserved.
//

import UIKit
import Firebase

class NewPost: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Properties
    var isReadyToPublish: Bool = false
    var imageCaptured: UIImage! {
        didSet {
            imagePost.image = imageCaptured
        }
    }
    
    //MARK: - Outlets
    @IBOutlet weak var titlePostTxt: UITextField!
    @IBOutlet weak var textPostTxt: UITextView!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let myColor : UIColor = UIColor( red: 204.0/255.0, green: 204.0/255.0, blue:204.0/255.0, alpha: 1.0 )
        textPostTxt.layer.masksToBounds = true
        textPostTxt.layer.borderColor = myColor.cgColor
        textPostTxt.layer.borderWidth = 0.5;
        textPostTxt.layer.cornerRadius = 5.0;
        
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        imagePost.layer.borderWidth = 0.5
        imagePost.layer.borderColor = borderColor.cgColor
        imagePost.layer.cornerRadius = 5.0
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Actions
    @IBAction func takePhoto(_ sender: Any) {

        self.present(pushAlertCameraLibrary(), animated: true, completion: nil)
    }
    
    @IBAction func publish(_ sender: Any) {
        isReadyToPublish = (sender as! UISwitch).isOn
    }
    
    @IBAction func savePost(_ sender: Any) {
        let post = Posts(title: self.titlePostTxt.text!,
                         des: self.textPostTxt.text!,
                         latitude: "",
                         longitude: "",
                         published: self.isReadyToPublish,
                         userId: (FIRAuth.auth()?.currentUser?.uid.description)!,
            email: (FIRAuth.auth()?.currentUser?.email)!,
            userName: (FIRAuth.auth()?.currentUser?.displayName)!)
        
        // Se instancia un objeto data para almacenar la imagen asociada
        var data = Data.init()
        if let image = imagePost.image,
            let imageData = UIImagePNGRepresentation(image) {
            data = imageData
        }
        
        doneButton.isEnabled = false
        PostsModel.uploadPost(post: post, imageData: data) { (result) in
            print(result.description)
            self.doneButton.isEnabled = true
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    //MARK: Functions for Camera
    internal func pushAlertCameraLibrary() -> UIAlertController {
        let actionSheet = UIAlertController(title: NSLocalizedString("Select the image source", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: .actionSheet)
        
        let libraryBtn = UIAlertAction(title: NSLocalizedString("Select photo library", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.photoLibrary)
            
        }
        let cameraBtn = UIAlertAction(title: NSLocalizedString("Select camera", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.camera)
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        actionSheet.addAction(libraryBtn)
        actionSheet.addAction(cameraBtn)
        actionSheet.addAction(cancel)
        
        return actionSheet
    }
    
    internal func takePictureFromCameraOrLibrary(_ source: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        switch source {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                picker.sourceType = UIImagePickerControllerSourceType.camera
            } else {
                return
            }
        case .photoLibrary:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        case .savedPhotosAlbum:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        self.present(picker, animated: true, completion: nil)
    }

}

// MARK: UIImagePickerController Delegate
extension NewPost {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageCaptured = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        self.dismiss(animated: false, completion: {
        })
    }
    
}
