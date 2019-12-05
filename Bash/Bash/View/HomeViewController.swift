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

class HomeViewController: UIViewController, UITableViewDataSource  {
    
    @IBOutlet weak var eventTableView: UITableView!
    
    var eventsData: [RequestedData] = []
    
    
    let titles = ["hawai party", "dub party xl", "techno rave"]
    let interested = [10, 321, 378]
    let images = [UIImage(named: "omslag"), UIImage(named: "omslag2"), UIImage(named: "omslag3")]

    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        fetchuserData()
        // Do any additional setup after loading the view.
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
    
    func fetchuserData() {
        DispatchQueue.main.async { Alamofire.request("https://graph.facebook.com/cafetkanon/events?access_token=EAAikZAhKooxgBAPT4MvuW64cJ8rwlkqdI1ewatDXwYEBUATA4zmh1x6yNEXhZAtKjOgUfVrefD0WYFlb0QsUHlz4aqRZAkC4LZByXLXRYkhCScZBLdZApe8HnzOrmzMuje9dejVIzSBY3OZBkWzlRFBT9JzKntjCHLki5xxPXwNsQZDZD&fields=description,end_time,name,place,start_time,id,interested_count,cover").responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                    let data = json["data"]
                data.array?.forEach({ (event) in
                    let event = RequestedData(name: event["name"].stringValue, Description: event["description"].stringValue, interested_count: event["interested_count"].intValue, id: event["id"].stringValue, start_time: event["start_time"].stringValue, end_time: event["end_time"].stringValue, placename: event["place"]["name"].stringValue, city: event["place"]["location"]["city"].stringValue, longitude: event["place"]["location"]["longitude"].floatValue, altitude: event["place"]["location"]["altitude"].floatValue, cover: event["cover"]["source"].url!)
                    self.eventsData.append(event)
                })
                self.eventTableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
            }

            }
        }
    }
    
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        eventsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventTableViewCell
    
        let event = eventsData[indexPath.row]
        cell.EventTitle.text = event.name
        cell.EventInterested.text = String(event.interested_count)
        cell.EventImage.load(url: event.cover)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 340.0;//Choose your custom row height
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

