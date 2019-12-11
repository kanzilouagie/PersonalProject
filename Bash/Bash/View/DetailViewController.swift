//
//  DetailViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 07/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {
    
    
    var DetailImage: URL?
    var DetailTitle: String?
    var DetailInterestedCount: Int?
    var DetailDescription: String?
    var DetailLocation: String?
    var DetailStartTime: String?
    var DetailId: String?
    
    
    
    
    @IBOutlet weak var eventTitle: UINavigationItem!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitleLable: UILabel!
    @IBOutlet weak var eventInterested: UILabel!
    @IBOutlet weak var eventBashButton: UIButton!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventStartTime: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        eventImage.load(url: DetailImage!)
        eventTitleLable.text = DetailTitle
        eventInterested.text = "\(String(DetailInterestedCount!)) mensen zijn geïnteresseerd"
        var startTime = DetailStartTime!
        startTime.removeFirst(11)
        startTime.removeLast(8)
        eventStartTime.text = startTime
        eventLocation.text = DetailLocation
        eventDescription.text = DetailDescription
        eventImage.layer.shadowRadius = 10
        eventImage.layer.cornerRadius = 20
        eventBashButton.layer.cornerRadius = 10
        eventDescription.sizeToFit()
        eventDescription.isScrollEnabled = false
        eventDescription.isEditable = false
        // Do any additional setup after loading the view.
        
    }
    
    
    @IBAction func BashButtonTapped(_ sender: UIButton) {
        let user = Auth.auth().currentUser!.uid
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.checkInViewController) as! CheckInViewController
        
        let db = Firestore.firestore()
        let docRef = db.collection("check-ins")
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
        docRef.addDocument(data: [
            "date" : time,
            "userUID": user,
            "eventUID": self.DetailId!
        ])
        
        self.navigationController?.pushViewController(DvC, animated: true)
    }
    
    
    
  
    


}
