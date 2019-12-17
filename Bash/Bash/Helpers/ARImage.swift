//
//  FocusSquare.swift
//  Bash
//
//  Created by Kanzi Louagie on 15/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import SceneKit

class ARImage: SCNNode {

    var useImage: UIImage?
    var image: UIImage?
    var arImage: String? = "lol"
    
    override init() {
        super.init()

    }
    
    func tapped() {
        let image = self.arImage!
        let plane = SCNPlane(width: 0.5, height: 0.3)
        let imageUrl = URL(string: image)!
        let imageData = try! Data(contentsOf: imageUrl)
        plane.firstMaterial?.diffuse.contents = UIImage(data: imageData)
        geometry = plane
        eulerAngles.x = GLKMathDegreesToRadians(0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
