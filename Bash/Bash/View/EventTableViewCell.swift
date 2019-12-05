//
//  EventTableViewCell.swift
//  Bash
//
//  Created by Kanzi Louagie on 03/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var EventImage: UIImageView!
    @IBOutlet weak var EventTitle: UILabel!
    @IBOutlet weak var EventInterested: UILabel!
    @IBOutlet weak var EventWrapperView: UIView!
    @IBOutlet weak var EventTime: UILabel!
    @IBOutlet weak var EventLocation: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        EventWrapperView.layer.cornerRadius = 20
        EventWrapperView.backgroundColor = .white
        EventWrapperView.layer.borderWidth = 0
        EventWrapperView.layer.masksToBounds = true
        EventWrapperView.dropShadow();
//        EventImage.layer.cornerRadius = 20
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        
        // Configure the view for the selected state
    }

}

extension UIView {

  // OUTPUT 1
  func dropShadow(scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.1
    layer.shadowOffset = CGSize(width: 0, height: 6)
    layer.shadowRadius = 10
    layer.cornerRadius = 20
    layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }

  // OUTPUT 2
  func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowOffset = offSet
    layer.shadowRadius = radius

    layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }
}
