//
//  LoginController.swift
//  Scoop
//
//  Created by Fran Lucena on 7/6/17.
//  Copyright © 2017 Fran Lucena. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var googleLoginBtn: UIButton!
    
    var handle: FIRAuthStateDidChangeListenerHandle!
    
    typealias actionUserCommand = (_ : String, _ : String) -> Void
    
    enum ActionUser: String {
        case toLogin = "Login"
        case toSignIn = "Registrar nuevo usuario"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self as! GIDSignInUIDelegate
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if let _ = FIRAuth.auth()?.currentUser {
                print(user?.email)
                self.getUserInfo(user)
            } else {
                self.getUserInfo(user)
            }
        })
    }
    
    @IBAction func doLoginEmail(_ sender: Any) {
        makeLogout()
        
        showUserLoginDialog(withCommand: login, userAction: .toLogin)
    }
    
    @IBAction func doGoogleLogin(_ sender: Any) {
        makeLogout()
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func doLoginAnonymous(_ sender: Any) {
        makeLogout()
        
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if let _ = error {
                print("Ha ocurrido un error al loguearse con un usuario Anónimo")
                return
            }
            print(user?.uid ?? "")
        })
    }
    
    @IBAction func doLogout(_ sender: Any) {
        makeLogout()
    }
    
    //MARK: - Functions
    func showUserLoginDialog(withCommand actionCmd: @escaping actionUserCommand, userAction: ActionUser) {
        // Se instancia el controlador de alertas
        let alertController = UIAlertController(title: "Scoop", message: userAction.rawValue, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: userAction.rawValue, style: .default, handler: { (action) in
            let eMailTxt = (alertController.textFields?[0])! as UITextField
            let passTxt = (alertController.textFields?[1])! as UITextField
            
            // Se comprueba si algo ha salido mal
            if (eMailTxt.text?.isEmpty)!, (passTxt.text?.isEmpty)! {
                // No continuar y lanzar error
            } else {
                actionCmd(eMailTxt.text!, passTxt.text!)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel login", style: .default, handler: { (action) in
            
        }))
        
        alertController.addTextField { (txtField) in
            txtField.placeholder = "email"
            txtField.textAlignment = .natural
        }
        
        alertController.addTextField { (txtField) in
            txtField.placeholder = "password"
            txtField.textAlignment = .natural
            txtField.isSecureTextEntry = true
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func login(_ name: String, andPass pass: String) {
        FIRAuth.auth()?.signIn(withEmail: name, password: pass, completion: { (user, error) in
            if let _ = error {
                print(error?.localizedDescription)
                // Se crea el usuario
                FIRAuth.auth()?.createUser(withEmail: name, password: pass, completion: { (user, error) in
                    if let _ = error {
                        print(error?.localizedDescription)
                        return
                    }
                })
                return
            }
            print("user: \(user?.email! ?? "")")
        })
    }
    
    fileprivate func makeLogout() {
        if let _ = FIRAuth.auth()?.currentUser {
            do {
                try FIRAuth.auth()?.signOut()
                GIDSignIn.sharedInstance().signOut()
                self.getUserInfo(nil as FIRUser!)
                
            } catch let error {
                print(error)
            }
        } else {
            self.getUserInfo(nil as FIRUser!)
        }
    }
    
    func getUserInfo(_ user: FIRUser!) {
        if let _ = user,
            !user.isAnonymous {
            userName.text = user?.displayName
            self.title = user?.displayName
            if let picProfile = user.photoURL as URL! {
                userImage.imageFromServerUrl(urlString: picProfile.absoluteString)
            }
        } else {
            userName.text = ""
            self.title = ""
            userImage.imageFromServerUrl(urlString: "")
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "launchWithLogged" {
            let controller = (segue.destination as! UINavigationController).topViewController as! MainTimeline
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
}
