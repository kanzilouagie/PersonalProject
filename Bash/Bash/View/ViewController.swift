//
//  ViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 02/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FBSDKLoginKit
import FirebaseUI

class ViewController: UIViewController {
    
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        let ref = Database.database().reference()
//        ref.childByAutoId().setValue(["name":"Kevin","age":13,"role":"Admin"])
        setUpElements();
    }
    
    func setUpElements() {
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }
    
    
    @IBAction func facebookLoginTapped(_ sender: Any) {
        let authUI = FUIAuth.defaultAuthUI()
        let providers: [FUIAuthProvider] = [
          FUIFacebookAuth()
        ]
        authUI!.providers = providers
        
        guard authUI != nil else {
            return
        }
        authUI?.delegate = self
        let authViewController = authUI!.authViewController()
        
        present(authViewController, animated: true, completion: nil)
        
    }
    
    func transitionToHome() {
        
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    

}

extension ViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error != nil {
            return 
        }
        
//        authDataResult?.user.uid
        self.transitionToHome()
    }
}

