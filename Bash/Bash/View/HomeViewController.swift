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

class HomeViewController: UIViewController, UITableViewDataSource  {
    
    @IBOutlet weak var eventTableView: UITableView!
    
    var eventsData: [RequestedData] = []
    var arrayData: [JSON] = []
    var arrayCafes: [String] = []
    
    let titles = ["hawai party", "dub party xl", "techno rave"]
    let interested = [10, 321, 378]
    let images = [UIImage(named: "omslag"), UIImage(named: "omslag2"), UIImage(named: "omslag3")]

    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        fetchCafesFromDatabase()
    }
    
    
    func logOut() {
        try! Auth.auth().signOut()
    }
    
    func getUserInfo() {
        if Auth.auth().currentUser != nil {
          let user = Auth.auth().currentUser
          if let user = user {
            let uid = user.uid
            let email = user.email
            let photoURL = user.photoURL
            print(uid)
            print(email!)
            print(photoURL!)
        } else {
          print("no user signed in")
        }
        
        }
    }
    
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
    
    func fetchuserData() {
        DispatchQueue.main.async { Alamofire.request("https://graph.facebook.com/Reflexjeugdhuis/events?access_token=EAAikZAhKooxgBAPT4MvuW64cJ8rwlkqdI1ewatDXwYEBUATA4zmh1x6yNEXhZAtKjOgUfVrefD0WYFlb0QsUHlz4aqRZAkC4LZByXLXRYkhCScZBLdZApe8HnzOrmzMuje9dejVIzSBY3OZBkWzlRFBT9JzKntjCHLki5xxPXwNsQZDZD&fields=description,end_time,name,place,start_time,id,interested_count,cover&filter=stream").responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                    let data = json["data"]
                data.array?.forEach({ (event) in
                    let event = RequestedData(name: event["name"].stringValue, Description: event["description"].stringValue, interested_count: event["interested_count"].intValue, id: event["id"].stringValue, start_time: event["start_time"].stringValue, end_time: event["end_time"].stringValue, placename: event["place"]["name"].stringValue, city: event["place"]["location"]["city"].stringValue, longitude: event["place"]["location"]["longitude"].floatValue, altitude: event["place"]["location"]["altitude"].floatValue, cover: event["cover"]["source"].url!)
                    if(self.checkDate(date: event.start_time)) {
                        print("ja")
                        self.eventsData.append(event)
                    }



                })
                self.eventTableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
            }

            }
        }
    }
    
    func sortData() {
        var customObjects = eventsData
        DispatchQueue.main.async {
        customObjects = customObjects.sorted(by: {
            $0.start_time.compare($1.start_time) == .orderedDescending
        })

        for obj in customObjects {
            print("Sorted Date: \(obj.start_time) with title: \(obj.placename)")
        }
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
