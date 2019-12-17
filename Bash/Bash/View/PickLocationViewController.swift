//
//  PickLocationViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 11/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit
import Firebase
import Reachability

class PickLocationViewController: UIViewController, UITableViewDataSource  {
    
    
    @IBOutlet weak var PickLocationTableView: UITableView!
    
    var cafes: [String] = []
    let reachability = try! Reachability()
    override func viewDidLoad() {
        super.viewDidLoad()
        PickLocationTableView.delegate = self
        PickLocationTableView.dataSource = self
        PickLocationTableView.tableFooterView = UIView(frame: .zero)
//        PickLocationTableView.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 71/255, alpha: 1)
        getCafes()
        
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
    

    func getCafes() {
        let db = Firestore.firestore()
                        DispatchQueue.main.async {
                            db.collection("cafes").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            if(self.cafes.contains((document.data()["stad"] as? String)!)) {
                                print("exists")
                            } else {
                                self.cafes.append((document.data()["stad"] as? String)!)
                                print(self.cafes)
                        }
                        }
                    }
                                self.PickLocationTableView.reloadData()
                }
            }
    }

}

extension PickLocationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cafes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath) as! PickLocationTableViewCell
        cell.LocationLable.text = self.cafes[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HomeViewController.selectedCafe = self.cafes[indexPath.row]
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as! HomeViewController
        self.navigationController?.view.layer.add(CATransition().segueFromLeft(), forKey: nil)
        self.navigationController?.pushViewController(DvC, animated: false)
    }
}
