//
//  ConnectionFailedViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 16/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit
import Reachability

class ConnectionFailedViewController: UIViewController {
    
    let reachability = try! Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                  let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as! HomeViewController
          self.navigationController?.pushViewController(DvC, animated: false)
            } else {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                  let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as! HomeViewController
          self.navigationController?.pushViewController(DvC, animated: false)
            }
        }
        reachability.whenUnreachable = { _ in
            print("still no internetconnection")
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
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
          let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as! HomeViewController
            DvC.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(DvC, animated: false)
      case .cellular:
          let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as! HomeViewController
                DvC.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(DvC, animated: false)
      case .unavailable:
        print("none")
      case .none:
        print("none")
        }
    }

}
