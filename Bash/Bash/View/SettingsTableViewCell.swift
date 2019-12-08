//
//  SettingsTableViewCell.swift
//  Bash
//
//  Created by Kanzi Louagie on 08/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else { return }
            textLabel?.text = sectionType.description
            switchControl.isHidden = !sectionType.containsSwitch
        }
    }
    
    lazy var switchControl: UISwitch = {
            let switchControl = UISwitch()
            switchControl.isOn = true
            switchControl.onTintColor = UIColor(red: 255/255, green: 0/255, blue: 71/255, alpha: 1)
            switchControl.translatesAutoresizingMaskIntoConstraints = false
            switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
            
            return switchControl
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func handleSwitchAction(sender: UISwitch) {
        if sender.isOn {
            print("turned On")
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            print("turned of")
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }

}
