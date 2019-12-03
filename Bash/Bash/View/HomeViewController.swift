//
//  HomeViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 02/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit
import FirebaseUI

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        // Do any additional setup after loading the view.
    }
    
    func getUserInfo() {
        if Auth.auth().currentUser != nil {
          let user = Auth.auth().currentUser
          if let user = user {
            let uid = user.uid
            let email = user.email
            let photoURL = user.photoURL
            print(uid)
            print(email!)
            print(photoURL!)
        } else {
          print("no user signed in")
        }
        
        }
    }
    

}
