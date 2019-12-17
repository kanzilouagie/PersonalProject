//
//  DetailViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 07/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit
import Firebase
import Reachability

class DetailViewController: UIViewController {
    
    
    var DetailImage: URL?
    var DetailTitle: String?
    var DetailInterestedCount: Int?
    var DetailDescription: String?
    var DetailLocation: String?
    var DetailStartTime: String?
    var DetailId: String?
    let reachability = try! Reachability()
    
    
    
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(rightButtonTapped))
        // Do any additional setup after loading the view.
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
              let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.connectionFailedViewController) as! ConnectionFailedViewController
              DvC.isModalInPresentation = true
          self.navigationController?.pushViewController(DvC, animated: false)
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
          try reachability.startNotifier()
        }catch{
          print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {

      let reachability = note.object as! Reachability

      switch reachability.connection {
      case .wifi:
          print("Reachable via WiFi")
      case .cellular:
          print("Reachable via Cellular")
      case .unavailable:
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.connectionFailedViewController) as! ConnectionFailedViewController
            DvC.isModalInPresentation = true
          self.navigationController?.pushViewController(DvC, animated: false)
      case .none:
        print("none")
        }
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
    
    @objc func rightButtonTapped() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.arViewController) as! ARCameraViewController
        DvC.imageForAR = self.DetailImage
        self.navigationController?.pushViewController(DvC, animated: true)
    }
    
    
    
  
    


}
