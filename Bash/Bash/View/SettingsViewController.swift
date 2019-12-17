//
//  SettingsViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 07/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit
import FirebaseUI
import Reachability

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingsTableView: UITableView!
    
    
    @IBOutlet weak var ProfilePic: UIImageView!
    @IBOutlet weak var ProfileName: UILabel!
    @IBOutlet weak var ProfileEmail: UILabel!
    
    
    
    var authUI: FUIAuth!
    let reachability = try! Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.tableFooterView = UIView(frame: .zero)
//        getUserInfo()
        checkLoggedIn()
        
        
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

    
    func checkLoggedIn() {
        if Auth.auth().currentUser != nil {
        let user = Auth.auth().currentUser
            let profilePicSized = NSURL(string: "\((user?.photoURL)!)?width=300&height=300")!  as URL
            ProfilePic.load(url: profilePicSized)
            ProfilePic.layer.borderWidth = 1
            ProfilePic.layer.masksToBounds = false
            ProfilePic.layer.borderColor = UIColor.black.cgColor
            ProfilePic.layer.cornerRadius = ProfilePic.frame.height/2
            ProfilePic.clipsToBounds = true
            ProfileName.text = user!.displayName
            ProfileEmail.text = user!.email
        } else {
//            self.authUI = FUIAuth.defaultAuthUI()
//            self.authUI?.delegate = self
//            signIn()
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as! HomeViewController
            self.navigationController?.view.layer.add(CATransition().segueFromRight(), forKey: nil)
            self.navigationController?.pushViewController(DvC, animated: false)
            
        }
    }
    
    func signIn() {
        let providers: [FUIAuthProvider] = [
          FUIFacebookAuth()
          
        ]
        if authUI.auth?.currentUser == nil {
            self.authUI?.providers = providers
            self.present(authUI.authViewController(), animated: true, completion: nil)
            
        } else {
            return
        }
    }
    
    
    
    func logOut() {
        try! Auth.auth().signOut()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as! HomeViewController
        self.navigationController?.pushViewController(DvC, animated: true)
        print("Logged Out")
    }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource,FUIAuthDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
             if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
             return true
           }
           // other URL handling goes here.
           return false
       }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error != nil {
            return
        }
        
        //data halen van de ingelogde user.
//        print("facebook profiel foto: ", authDataResult?.user.photoURL ?? "String")
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        
        loginViewController.title = "Bash"
        loginViewController.view.subviews[0].backgroundColor = .black
        loginViewController.view.subviews[0].subviews[0].backgroundColor = UIColor.clear
        loginViewController.navigationItem.leftBarButtonItem = nil
        
        
        let marginInsets: CGFloat = 16
        let imageHeight: CGFloat = 225
        let imageY = self.view.center.y - imageHeight
        
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - (marginInsets * 2), height: imageHeight)
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        loginViewController.view.addSubview(logoImageView)
        
        return loginViewController
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingsSections(rawValue: section) else { return 0 }
        
        switch section {
        case .Social: return SocialOptions.allCases.count
        case .Communication: return CommunicationOptions.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 71/255, alpha: 1)
        
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .white
        title.text = SettingsSections(rawValue: section)?.description
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
        
        guard let section = SettingsSections(rawValue: indexPath.section) else { return UITableViewCell() }
            
            switch section {
            case .Social:
                let social = SocialOptions(rawValue: indexPath.row)
                cell.sectionType = social
            case .Communication:
                let communications = CommunicationOptions(rawValue: indexPath.row)
                cell.sectionType = communications
            }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSections(rawValue: indexPath.section) else { return }
        
        switch section {
        case .Social:
            if((SocialOptions(rawValue: indexPath.row)?.description)! == "Profiel Bewerken") {
                print("hey bewerk maar eh")
            }
            
            if((SocialOptions(rawValue: indexPath.row)?.description)! == "Uitloggen") {
                let alert = UIAlertController(title: "Uitloggen", message: "Afmelden bij Bash?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    switch action.style {
                    case .default:
                        self.logOut()
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
            
            if((SocialOptions(rawValue: indexPath.row)?.description)! == "Vriendenlijst") {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.friendsListViewController) as! FriendsListViewController
                self.navigationController?.pushViewController(DvC, animated: true)
            }
            
            if((SocialOptions(rawValue: indexPath.row)?.description)! == "Vriendschapsverzoeken") {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.friendsRequestViewController) as! FriendsRequestsViewController
                self.navigationController?.pushViewController(DvC, animated: true)
            }
            
            if((SocialOptions(rawValue: indexPath.row)?.description)! == "Vrienden Toevoegen") {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.AddFriendsViewController) as! AddFriendsViewController
                self.navigationController?.pushViewController(DvC, animated: true)
            }
            
        case .Communication:
            print((CommunicationOptions(rawValue: indexPath.row)?.description)!)
        }
    }
}

extension CATransition {

//New viewController will appear from bottom of screen.
func segueFromBottom() -> CATransition {
    self.duration = 0 //set the duration to whatever you'd like.
    self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    self.type = CATransitionType.moveIn
    self.subtype = CATransitionSubtype.fromTop
    return self
}
//New viewController will appear from top of screen.
func segueFromTop() -> CATransition {
    self.duration = 0.375 //set the duration to whatever you'd like.
    self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    self.type = CATransitionType.moveIn
    self.subtype = CATransitionSubtype.fromBottom
    return self
}
 //New viewController will appear from left side of screen.
func segueFromLeft() -> CATransition {
    self.duration = 0.5 //set the duration to whatever you'd like.
    self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    self.type = CATransitionType.moveIn
    self.subtype = CATransitionSubtype.fromLeft
    return self
}
//New viewController will pop from left side of screen.
func segueFromRight() -> CATransition {
    self.duration = 0.5 //set the duration to whatever you'd like.
    self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    self.type = CATransitionType.moveIn
    self.subtype = CATransitionSubtype.fromRight
    return self
    }
    
//New viewController will pop from right side of screen.
func popFromRight() -> CATransition {
    self.duration = 0.1 //set the duration to whatever you'd like.
    self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    self.type = CATransitionType.reveal
    self.subtype = CATransitionSubtype.fromRight
    return self
}
//New viewController will appear from left side of screen.
func popFromLeft() -> CATransition {
    self.duration = 0.1 //set the duration to whatever you'd like.
    self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    self.type = CATransitionType.reveal
    self.subtype = CATransitionSubtype.fromLeft
    return self
   }
}
