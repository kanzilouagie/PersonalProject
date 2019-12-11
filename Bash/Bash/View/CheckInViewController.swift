//
//  CheckInViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 11/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit
import Firebase

class CheckInViewController: UIViewController, UITableViewDataSource {

    
    
    @IBOutlet weak var CheckinTableView: UITableView!
    
    var checkIns = [[String: Any]]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        CheckinTableView.delegate = self
        CheckinTableView.dataSource = self
        getCheckIns()
        // Do any additional setup after loading the view.
    }
    
    func getCheckIns() {
       let db = Firestore.firestore()
                DispatchQueue.main.async {
                    db.collection("check-ins").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.checkIns.append(document.data())
                    print(self.checkIns)
                }
            }
        }
    }
    }
    



}

extension CheckInViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkIns.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckInCell") as! CheckInTableViewCell
        cell.CheckInEventName.text = ""
        cell.CheckInLocation.text = ""
        cell.CheckInProfileName.text = ""
        cell.CheckInProfileImage.load(url: NSURL(string: "")! as URL)
        return cell
    }
}
