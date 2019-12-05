//
//  EventData.swift
//  Bash
//
//  Created by Kanzi Louagie on 05/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct EventData {
    
    var eventsData: [RequestedData] = []
//
//    func fetchuserData() {
//        DispatchQueue.main.async { Alamofire.request("https://graph.facebook.com/cafetkanon/events?access_token=EAAikZAhKooxgBAPT4MvuW64cJ8rwlkqdI1ewatDXwYEBUATA4zmh1x6yNEXhZAtKjOgUfVrefD0WYFlb0QsUHlz4aqRZAkC4LZByXLXRYkhCScZBLdZApe8HnzOrmzMuje9dejVIzSBY3OZBkWzlRFBT9JzKntjCHLki5xxPXwNsQZDZD&fields=description,end_time,name,place,start_time,id,interested_count,cover").responseJSON { (response) in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                    let data = json["data"]
//                data.array?.forEach({ (event) in
//                    let event = RequestedData(name: event["name"].stringValue, Description: event["description"].stringValue, interested_count: event["interested_count"].intValue, id: event["id"].stringValue, start_time: event["start_time"].stringValue, end_time: event["end_time"].stringValue, placename: event["place"]["name"].stringValue, city: event["place"]["location"]["city"].stringValue, longitude: event["place"]["location"]["longitude"].floatValue, altitude: event["place"]["location"]["altitude"].floatValue)
//                    self.eventsData.append(event)
//                })
//                case .failure(let error):
//                    print(error.localizedDescription)
//            }
//
//            }
//        }
//    }
}
