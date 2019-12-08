//
//  FriendsRequestsViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 08/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class FriendsRequestsViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var requestsTableView: UITableView!
    
    var authUI: FUIAuth!
    var arrayRequests: [String] = []
    var ArrayFriendsRequests = [[String: Any]]()
    var CurrentFriends: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        let db = Firestore.firestore()
        let docRef = db.collection("users").document((user?.uid)!)
        
        docRef.getDocument { (document, error) in
            if let document = document {
                if document.exists {
                    self.arrayRequests = document.data()!["friendRequests"] as! [String]
                    self.CurrentFriends = document.data()!["friends"] as! [String]
                    self.getRequests()
                } else {
                    print("document doesn't exist")
                }
            }
        
    }

        // Do any additional setup after loading the view.
    }
    
        func getRequests() {
            let db = Firestore.firestore()
            arrayRequests.forEach({ (request) in
            DispatchQueue.main.async {
            let docRef = db.collection("users").document(request)
            docRef.getDocument { (document, error) in
                    if let document = document {
                        if document.exists {
                            let data = document.data()
                            self.ArrayFriendsRequests.append(data!)
                        } else {
                            print(document.data()!)
                            print("document doesn't exist")
                        }
                    }
                
               self.requestsTableView.reloadData()

                   }
            }
            })

        }
    
}



extension FriendsRequestsViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return ArrayFriendsRequests.count
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80.0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsRequestsCell", for: indexPath) as! FriendsRequestsTableViewCell
            let friend = ArrayFriendsRequests[indexPath.row]
            let profilePicSized = NSURL(string: "\((friend["profile_pic"])!)?width=300&height=300")!  as URL
            cell.requestProfilePic.load(url: profilePicSized)
            cell.requestName.text = (ArrayFriendsRequests[indexPath.row]["name"]! as! String)
            print(ArrayFriendsRequests[indexPath.row]["name"]! as! String)
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Verwijderen", message: "\(ArrayFriendsRequests[indexPath.row]["name"]! as! String) Verwijderen als vriend?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "JA", style: .default, handler: { (action) in
                    switch action.style {
                    case .default:
                        let user = Auth.auth().currentUser
                        let db = Firestore.firestore()
                        let docRef = db.collection("users").document((user?.uid)!)
                        
                        self.CurrentFriends.append(self.arrayRequests[indexPath.row])
                        self.arrayRequests.remove(at: indexPath.row)
                        docRef.setData([
                            "friends": self.CurrentFriends,
                            "friendRequests": self.arrayRequests
                        ], merge: true)
                        tableView.reloadData()
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.SettingsViewController) as! SettingsViewController
                        self.navigationController?.pushViewController(DvC, animated: true)
                    case .cancel:
                        print("cancel")
                    case .destructive:
                        print("")
                    
                    @unknown default:
                        fatalError()
                    }}))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                switch action.style {
                case .default:
                    print("default")
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("")
                
                @unknown default:
                    fatalError()
                }}))
        self.present(alert, animated: true, completion: nil)
    
        

    }
}
