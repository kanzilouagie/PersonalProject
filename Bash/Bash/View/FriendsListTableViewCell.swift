//
//  FriendsListTableViewCell.swift
//  Bash
//
//  Created by Kanzi Louagie on 08/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit

class FriendsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendsPic: UIImageView!
    @IBOutlet weak var friendsName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        friendsPic.layer.masksToBounds = false
        friendsPic.layer.borderColor = UIColor.black.cgColor
        friendsPic.layer.cornerRadius = friendsPic.frame.height/2
        friendsPic.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
