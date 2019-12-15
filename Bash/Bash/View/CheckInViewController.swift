//
//  CheckInViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 11/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON

class CheckInViewController: UIViewController, UITableViewDataSource {

    
    
    @IBOutlet weak var CheckinTableView: UITableView!
    
    var checkIns = [[String: Any]]()
    var userName: String?
    var userImage: String?
    var userData: [UserData] = []
    var eventData: [EventData] = []
    let dispatchGroup = DispatchGroup()
    var firestoreReg: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        CheckinTableView.delegate = self
        CheckinTableView.dataSource = self
        self.getCheckIns()
        //self.getNeededUserData()
        //self.getNeededEventData()
          //  self.CheckinTableView.reloadData()


        // Do any additional setup after loading the view.
    }

    
    func getCheckIns() {
       let db = Firestore.firestore()
            db.collection("check-ins").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.checkIns.append(document.data())
 
                    }
                }
                print("getCheckins")
                 print("aantal checkins: ", self.checkIns.count)
             self.getNeededUserData()
            }
    }
    
    func getNeededUserData() {
        let db = Firestore.firestore()
        var teller = self.checkIns.count;
            self.checkIns.forEach({ (user) in
                let docRef = db.collection("users").document(user["userUID"]! as! String)
                
                firestoreReg = docRef.addSnapshotListener { [weak self] document, error in
                    if let document = document {
                            
                            if document.exists {
                                print(teller);
                                
                            if(teller == 1){
                                let userName = document.data()!["name"] as? String
                                let userImage = document.data()!["profile_pic"] as? String
                                let userData = UserData(name: userName!, cover: userImage!)
                                self!.userData.append(userData)
                                //
                                self!.getNeededEventData();
                                    
                                }else{
                                   let userName = document.data()!["name"] as? String
                                   let userImage = document.data()!["profile_pic"] as? String
                                   let userData = UserData(name: userName!, cover: userImage!)
                                   self!.userData.append(userData)
                                   
                                }
                                 teller-=1;
                                
                           } else {
                                print("document doesn't exist");
                           }
                    }
                }
            })
        
        //
        
        
     }
    
    func getNeededEventData() {
        print(self.userData.count);
            self.checkIns.forEach({ (event) in

               let url = "https://graph.facebook.com/\(event["eventUID"]!)?access_token=EAAikZAhKooxgBAPT4MvuW64cJ8rwlkqdI1ewatDXwYEBUATA4zmh1x6yNEXhZAtKjOgUfVrefD0WYFlb0QsUHlz4aqRZAkC4LZByXLXRYkhCScZBLdZApe8HnzOrmzMuje9dejVIzSBY3OZBkWzlRFBT9JzKntjCHLki5xxPXwNsQZDZD&fields=description,end_time,name,place,start_time,id,interested_count,cover&filter=stream"
               Alamofire.request(url).responseJSON() { (response) in
               switch response.result {
                           case .success(let value):
                               let json = JSON(value)
                               let event = EventData(name: json["name"].stringValue, location: json["place"]["location"]["city"].stringValue)
                               self.eventData.append(event);
                               self.CheckinTableView.reloadData()
                                

                           case .failure(let err):
                               print(err.localizedDescription)
                           }
               }
            })
             

     }

    
    
    
    
    
    
    



}

extension CheckInViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckInCell") as! CheckInTableViewCell
        let profileData = self.userData[indexPath.row]
       let evenementData = self.eventData[indexPath.row]
        print("eventdata: ", self.eventData.count)
        print("userdata: ", self.userData.count)
        cell.CheckInEventName.text = evenementData.name
        cell.CheckInLocation.text = evenementData.location
        cell.CheckInProfileName.text = profileData.name
        cell.CheckInProfileImage.load(url: NSURL(string: profileData.cover)! as! URL)
        return cell
    }
}
