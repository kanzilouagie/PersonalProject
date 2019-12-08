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
    var authUI: FUIAuth!
    
    // Check for auth status some where
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //logout af en aan zetten voor debugging purposes
//        try! Auth.auth().signOut()
        
        
        authListener = Auth.auth().addStateDidChangeListener { (auth, user) in

            if user != nil {
                self.transitionToHome()
            
            } else {
                self.authUI = FUIAuth.defaultAuthUI()
                self.authUI?.delegate = self
                self.signIn()
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
    
    
    func transitionToHome() {
        
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    func signIn() {
        let providers: [FUIAuthProvider] = [
          FUIFacebookAuth(),
          FUIEmailAuth()
          
        ]
        if authUI.auth?.currentUser == nil {
            self.authUI?.providers = providers
            present(authUI.authViewController(), animated: true, completion: nil)
        } else {
            return
        }
    }
    

}

extension ViewController: FUIAuthDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
             if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
             return true
           }
           // other URL handling goes here.
           return false
       }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error != nil {
            return 
        }
        
        //data halen van de ingelogde user.
        print("facebook profiel foto: ", authDataResult?.user.photoURL ?? "String")
        self.transitionToHome()
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        
        loginViewController.title = "Bash"
        loginViewController.view.subviews[0].backgroundColor = .black
        loginViewController.view.subviews[0].subviews[0].backgroundColor = UIColor.clear
        loginViewController.navigationItem.leftBarButtonItem = nil
        
        
        let marginInsets: CGFloat = 16
        let imageHeight: CGFloat = 225
        let imageY = self.view.center.y - imageHeight
        
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - (marginInsets * 2), height: imageHeight)
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        loginViewController.view.addSubview(logoImageView)
        
        return loginViewController
    }
}

