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
    
    // save a ref to the handler
    private var authListener: AuthStateDidChangeListenerHandle?
    
    // Check for auth status some where
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
            

        authListener = Auth.auth().addStateDidChangeListener { (auth, user) in

            if user != nil {
                self.transitionToHome()
            
            } else {
                self.presentLogin()
            }
        }
    }

    // Remove the listener once it's no longer needed
    deinit {
        if authListener != nil {
            Auth.auth().removeStateDidChangeListener(authListener!)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func presentLogin() {
        let authUI = FUIAuth.defaultAuthUI()
        let providers: [FUIAuthProvider] = [
          FUIFacebookAuth(),
          FUIEmailAuth()
          
        ]
        authUI!.providers = providers
        
        guard authUI != nil else {
            return
        }
        authUI?.delegate = self
        let authViewController = authUI!.authViewController()
        
        present(authViewController, animated: false, completion: nil)
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
        
        //data halen van de ingelogde user.
        print("facebook profiel foto: ", authDataResult?.user.photoURL ?? "String")
        self.transitionToHome()
    }
}

