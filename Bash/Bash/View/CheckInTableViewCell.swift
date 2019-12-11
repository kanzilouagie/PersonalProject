//
//  CheckInTableViewCell.swift
//  Bash
//
//  Created by Kanzi Louagie on 11/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit

class CheckInTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var CheckInProfileImage: UIImageView!
    @IBOutlet weak var CheckInProfileName: UILabel!
    @IBOutlet weak var CheckInEventName: UILabel!
    @IBOutlet weak var CheckInLocation: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
