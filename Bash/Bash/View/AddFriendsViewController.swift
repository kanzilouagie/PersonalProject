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

class AddFriendsViewController: UIViewController, UITableViewDataSource {
    
    

    @IBOutlet weak var AddFriendsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var arrayRequests: [String] = []
    var ArrayFriendsRequests = [[String: Any]]()
    var CurrentFriends: [String] = []
    
    
        var searchFriends = [String]()
        var authUI: FUIAuth!
        var arrayFriends: [String] = []
        var ArrayFriendsList = [[String: Any]]()
        var arraySearchList = [[String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        AddFriendsTableView.delegate = self
        AddFriendsTableView.dataSource = self
        searchBar.delegate = self
        AddFriendsTableView.separatorStyle = .none
        
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
        
        docRef.getDocument { (document, error) in
            if let document = document {
                if document.exists {
                    if(document.data()!["friendRequests"] != nil) {
                        self.arrayRequests = document.data()!["friendRequests"] as! [String]
                        self.CurrentFriends = document.data()!["friends"] as! [String]
                        self.getRequests()
                    } else {
                        print("no friend requests")
                        if(document.data()!["friends"] != nil) {
                        self.CurrentFriends = document.data()!["friends"] as! [String]
                        } else {
                           print("no friends")
                        }
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
            
           self.AddFriendsTableView.reloadData()

               }
        }
        })

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
            
            self.AddFriendsTableView.reloadData()
            
//                    print(self.ArrayFriendsList)
                   // Do any additional setup after loading the view.
               }
        }
        })

    }
    
    func getUsers(searchText: String) {
        let db = Firestore.firestore()
        DispatchQueue.main.async {
            db.collection("users").order(by: "name").start(at: [searchText as Any]).end(at: [(searchText+"\u{f8ff}") as Any])
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                             self.arraySearchList.append(data)
                            print("------------------------------NIEWE LIJST------------------------", self.arraySearchList)
                        }
                    }
            }
                }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.AddFriendsTableView.reloadData()
        })
        
    }
    
    
    
    
}



extension AddFriendsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraySearchList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendsCell", for: indexPath) as! AddFriendsTableViewCell
        if(arraySearchList.count != 0) {
            let friend = arraySearchList[indexPath.row]
             let profilePicSized = NSURL(string: "\((friend["profile_pic"])!)?width=300&height=300")!  as URL
             cell.ProfilePic.load(url: profilePicSized)
             cell.ProfileName.text = arraySearchList[indexPath.row]["name"]! as! String
             print(arraySearchList[indexPath.row]["name"]! as! String)
             return cell
        } else {
            cell.ProfileName.text = "no friends found"
            return cell
        }
 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          
          let alert = UIAlertController(title: "Toevoegen", message: "\(arraySearchList[indexPath.row]["name"]! as! String) toevoegen als vriend?", preferredStyle: .alert)
                  alert.addAction(UIAlertAction(title: "JA", style: .default, handler: { (action) in
                      switch action.style {
                      case .default:
                          let user = Auth.auth().currentUser
                          let db = Firestore.firestore()
                          let docRef = db.collection("users").document(self.arraySearchList[indexPath.row]["uid"]! as! String)
                          
                          self.arrayRequests.append(user!.uid)

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

extension AddFriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getUsers(searchText: searchText)
        self.AddFriendsTableView.reloadData()
        self.arraySearchList = []
    }
    
}


