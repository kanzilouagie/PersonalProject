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
    
    var arrayRequests2: [String] = []
    var ArrayFriendsRequests2 = [[String: Any]]()
    var CurrentFriends2: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        let db = Firestore.firestore()
        let docRef = db.collection("users").document((user?.uid)!)
        requestsTableView.separatorStyle = .none
        
        docRef.getDocument { (document, error) in
            if let document = document {
                if document.exists {
                    if(document.data()!["friendRequests"] != nil) {
                        self.arrayRequests = document.data()!["friendRequests"] as! [String]
                        self.CurrentFriends = document.data()!["friends"] as! [String]
                        self.getRequests()
                    } else {
                        print("no friend requests")
                    }

                } else {
                    print("document doesn't exist")
                }
            }
        
    }

        // Do any additional setup after loading the view.
    }
    
    func getOtherUserData(uid: String) {
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(uid)
            docRef.getDocument { (document, error) in
                if let document = document {
                    if document.exists {
                        if(document.data()!["friendRequests"] != nil) {
                            self.arrayRequests2 = document.data()!["friendRequests"] as! [String]
                            self.CurrentFriends2 = document.data()!["friends"] as! [String]
                            self.getRequests2()
                        } else {
                            print("no friend requests")
                        }

                    } else {
                        print("document doesn't exist")
                    }
                }
        }
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
    
    func getRequests2() {
         let db = Firestore.firestore()
         arrayRequests2.forEach({ (request) in
         DispatchQueue.main.async {
         let docRef = db.collection("users").document(request)
         docRef.getDocument { (document, error) in
                 if let document = document {
                     if document.exists {
                         let data = document.data()
                         self.ArrayFriendsRequests2.append(data!)
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
            if(ArrayFriendsRequests.count != 0) {
                return ArrayFriendsRequests.count
            } else {
                return 1
            }

        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80.0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsRequestsCell", for: indexPath) as! FriendsRequestsTableViewCell
            
            if(ArrayFriendsRequests.count != 0) {
                let friend = ArrayFriendsRequests[indexPath.row]
                let profilePicSized = NSURL(string: "\((friend["profile_pic"])!)?width=300&height=300")!  as URL
                cell.requestProfilePic.load(url: profilePicSized)
                cell.requestName.text = (ArrayFriendsRequests[indexPath.row]["name"]! as! String)
                print(ArrayFriendsRequests[indexPath.row]["name"]! as! String)
                return cell
            } else {
                cell.requestProfilePic.image = UIImage(named: "logo")
                cell.requestName.text = "no requests"
                return cell
            }
            
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Toevoegen", message: "\(ArrayFriendsRequests[indexPath.row]["name"]! as! String) toevoegen als vriend?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "JA", style: .default, handler: { (action) in
                    switch action.style {
                    case .default:
                        let user = Auth.auth().currentUser
                        let user2 = self.ArrayFriendsRequests[indexPath.row]["uid"]! as! String
                        let db = Firestore.firestore()
                        let docRef = db.collection("users").document(user!.uid)
                        let docRef2 = db.collection("users").document(user2)
                        self.getOtherUserData(uid: user2)
                        self.CurrentFriends2.append(user!.uid)
                        docRef2.setData([
                            "friends": self.CurrentFriends2,
                            "friendRequests": self.arrayRequests2
                        ], merge: true)
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
