//
//  FriendsRequestsTableViewCell.swift
//  Bash
//
//  Created by Kanzi Louagie on 08/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit

class FriendsRequestsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var requestProfilePic: UIImageView!
    @IBOutlet weak var requestName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
