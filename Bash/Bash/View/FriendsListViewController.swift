//
//  FriendsListViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 08/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class FriendsListViewController: UIViewController, UITableViewDataSource {
    
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    
        var authUI: FUIAuth!
        var arrayFriends: [String] = []
        var ArrayFriendsList = [[String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.separatorStyle = .none
        
        let user = Auth.auth().currentUser
        let db = Firestore.firestore()
        let docRef = db.collection("users").document((user?.uid)!)
        docRef.getDocument { (document, error) in
            if let document = document {
                if document.exists {
                    if(document.data()!["friends"] != nil) {
                         self.arrayFriends = document.data()!["friends"] as! [String]
                        self.getFriends()
                    } else {
                        print("nothing in the document")
                    }
                   
                } else {
                    print("document doesn't exist")
                }
            }
        
        // Do any additional setup after loading the view.
    }
    }
    
    func getFriends() {
        let db = Firestore.firestore()
        arrayFriends.forEach({ (friend) in
        DispatchQueue.main.async {
        let docRef = db.collection("users").document(friend)
        docRef.getDocument { (document, error) in
                if let document = document {
                    if document.exists {
                        let data = document.data()
                        self.ArrayFriendsList.append(data!)
                    } else {
                        print("document doesn't exist")
                    }
                }
            
            self.friendsTableView.reloadData()
            
               }
        }
        })

    }
    
    
    
    
}



extension FriendsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(ArrayFriendsList.count != 0) {
                return ArrayFriendsList.count
        } else {
            return 1
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsListCell", for: indexPath) as! FriendsListTableViewCell
        if(ArrayFriendsList.count != 0) {
            let friend = ArrayFriendsList[indexPath.row]
             let profilePicSized = NSURL(string: "\((friend["profile_pic"])!)?width=300&height=300")!  as URL
             cell.friendsPic.load(url: profilePicSized)
             cell.friendsName.text = ArrayFriendsList[indexPath.row]["name"]! as! String
             print(ArrayFriendsList[indexPath.row]["name"]! as! String)
             return cell
        } else {
            cell.friendsName.text = "no friends found"
            cell.friendsPic.image = UIImage(named: "logo")
            return cell
        }
 
    }
}


