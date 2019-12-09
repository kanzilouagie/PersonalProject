//
//  HomeViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 02/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit
import FirebaseUI
import SwiftyJSON
import Alamofire
import PromiseKit
import Firebase
import FirebaseDatabase
import FBSDKLoginKit

class HomeViewController: UIViewController, UITableViewDataSource  {
    
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var ProfileButton: UIBarButtonItem!
    
    var eventsData: [RequestedData] = []
    var arrayData: [JSON] = []
    var arrayCafes: [String] = []
    var authUI: FUIAuth!
    var LoginPopupCount = 0
    var isPresented: Bool = false
    private var authListener: AuthStateDidChangeListenerHandle?
    
    let titles = ["hawai party", "dub party xl", "techno rave"]
    let interested = [10, 321, 378]
    let images = [UIImage(named: "omslag"), UIImage(named: "omslag2"), UIImage(named: "omslag3")]

    override func viewDidLoad() {
        super.viewDidLoad()
//        getUserInfo()
        fetchCafesFromDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            //logout af en aan zetten voor debugging purposes
//            logOut()
            
            authListener = Auth.auth().addStateDidChangeListener { (auth, user) in

                if user != nil {
//                    self.getUserInfo()
                
                } else {
                    self.authUI = FUIAuth.defaultAuthUI()
                    self.authUI?.delegate = self
                    if(self.LoginPopupCount < 1) {
                        self.signIn()
                    }
                    self.LoginPopupCount += 1
                }
            }
        }

        // Remove the listener once it's no longer needed
        deinit {
            if authListener != nil {
                Auth.auth().removeStateDidChangeListener(authListener!)
            }
        }
    
    
    @IBAction func ProfileButtonTapped(_ sender: UIBarButtonItem) {
            self.isPresented = false
            authListener = Auth.auth().addStateDidChangeListener { (auth, user) in
                if user != nil {
                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                            let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.SettingsViewController) as! SettingsViewController
                    if(self.isPresented == false) {
                        self.navigationController?.pushViewController(DvC, animated: true)
                        print("present deze viewController")
                        self.isPresented = true
                    } else {
                        print("already deze viewcontroller")
                    }

                } else {
                    self.authUI = FUIAuth.defaultAuthUI()
                    self.authUI?.delegate = self
                    self.signIn()
                }
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
        print("Logged Out")
    }
    
//    func getUserInfo() {
//        if Auth.auth().currentUser != nil {
//          let user = Auth.auth().currentUser
//          if let user = user {
//            let uid = user.uid
//            let email = user.email
//            let photoURL = user.photoURL
//            print(uid)
//            print(email!)
//            print(photoURL!)
//        } else {
//          print("no user signed in")
//        }
//
//        }
//    }
    
    func checkDate(date:String) -> Bool {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateformatter.locale = Locale(identifier: "en_US_POSIX")
        let dateDate = dateformatter.date(from: date)
        
        if(dateDate! >= Date()) {
            return true
        }
        
        return false
    }
    

    
    func sortData() {
        var customObjects = eventsData
        DispatchQueue.main.async {
        customObjects = customObjects.sorted(by: {
            $0.start_time.compare($1.start_time) == .orderedDescending
        })

//        for obj in customObjects {
//            print("Sorted Date: \(obj.start_time) with title: \(obj.placename)")
//        }
            self.eventsData = customObjects
            self.eventTableView.reloadData()
        }

    }
    
    
    func fetchCafesFromDatabase() {
        let db = Firestore.firestore()
                DispatchQueue.main.async {
                    db.collection("cafes").whereField("stad", isEqualTo: "Kortrijk").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let cafenaam = document.data()["cafenaam"] as? String {
                        self.arrayCafes.append("https://graph.facebook.com/\(cafenaam)/events?access_token=EAAikZAhKooxgBAPT4MvuW64cJ8rwlkqdI1ewatDXwYEBUATA4zmh1x6yNEXhZAtKjOgUfVrefD0WYFlb0QsUHlz4aqRZAkC4LZByXLXRYkhCScZBLdZApe8HnzOrmzMuje9dejVIzSBY3OZBkWzlRFBT9JzKntjCHLki5xxPXwNsQZDZD&fields=description,end_time,name,place,start_time,id,interested_count,cover&filter=stream")
//                            print(cafenaam)
                    }
                   
                }
            }
            self.fetchMultipleData()
        }
    }
    }
    
    
    
    func fetchMultipleData() {
//        print(self.arrayCafes)
        arrayCafes.forEach({ (cafe) in
        DispatchQueue.main.async {
            Alamofire.request(cafe).responseJSON() { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let data = json["data"]
                    data.array?.forEach({ (event) in
                        let event = RequestedData(name: event["name"].stringValue, Description: event["description"].stringValue, interested_count: event["interested_count"].intValue, id: event["id"].stringValue, start_time: event["start_time"].stringValue, end_time: event["end_time"].stringValue, placename: event["place"]["name"].stringValue, city: event["place"]["location"]["city"].stringValue, longitude: event["place"]["location"]["longitude"].floatValue, altitude: event["place"]["location"]["altitude"].floatValue, cover: event["cover"]["source"].url!)
                        if(self.checkDate(date: event.start_time)) {
                            self.eventsData.append(event)
                        }

                    })
                case .failure(let err):
                    print(err.localizedDescription)
                }
                self.sortData()
            }
        }
        })
    }
    
    
    
    
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        eventsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventTableViewCell
        let event = eventsData.reversed()[indexPath.row]
        cell.EventTitle.text = event.name
        cell.EventInterested.text = String(event.interested_count)
        cell.EventImage.load(url: event.cover)
        var startTime = event.start_time
        startTime.removeFirst(11)
        startTime.removeLast(8)
        cell.EventTime.text = startTime
        cell.EventLocation.text = event.placename
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 380.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.DetailViewController) as! DetailViewController
        let event = eventsData.reversed()[indexPath.row]
        DvC.DetailDescription = event.Description
        DvC.DetailImage = event.cover
        DvC.DetailInterestedCount = event.interested_count
        DvC.DetailLocation = event.placename
        DvC.DetailStartTime = event.start_time
        DvC.DetailTitle = event.name
        
        self.navigationController?.pushViewController(DvC, animated: true)
               
//        view.window?.rootViewController = DvC
//        view.window?.makeKeyAndVisible()
        
    }
    
    

}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async {
            [weak self] in if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension HomeViewController: FUIAuthDelegate {
    
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
        let db = Firestore.firestore()
        let docRef = db.collection("users").document((authDataResult?.user.uid)!)
        
        docRef.getDocument { (document, error) in
            if let document = document {
                if document.exists {
                    print("Document data: \(document.data()!)")
                } else {
                    print("document doesn't exist")
                }
            }
        }
        docRef.setData([
            "name": (authDataResult?.user.displayName)!,
            "profile_pic": (authDataResult?.user.photoURL)!
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    
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
}

extension UIViewController {

    var isModal: Bool {

        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController

        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}
