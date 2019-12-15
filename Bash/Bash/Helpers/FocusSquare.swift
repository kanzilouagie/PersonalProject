//
//  FocusSquare.swift
//  Bash
//
//  Created by Kanzi Louagie on 15/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import SceneKit

class FocusSquare: SCNNode {
    
    var isClosed: Bool = true {
        didSet {
            geometry?.firstMaterial?.diffuse.contents = self.isClosed ? UIImage(named: "closed") : UIImage(named: "open")
        }
    }
    
    override init() {
        super.init()
        let plane = SCNPlane(width: 0.1, height: 0.1)
        plane.firstMaterial?.diffuse.contents = UIImage(named: "closed")
        
        geometry = plane
        eulerAngles.x = GLKMathDegreesToRadians(0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHidden(to hidden: Bool) {
        var fadeTo: SCNAction
        
        if hidden {
            fadeTo = .fadeOut(duration: 0.5)
        } else {
            fadeTo = .fadeIn(duration: 0.5)
        }
        
        let actions = [fadeTo, .run({(focusSquare: SCNNode) in focusSquare.isHidden = hidden})]
        
        runAction(.sequence(actions))
    }
}
