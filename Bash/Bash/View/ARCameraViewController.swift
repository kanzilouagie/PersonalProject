//
//  ARCameraViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 14/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Reachability

class ARCameraViewController: UIViewController {
    
    @IBOutlet var augmentedRealityView: ARSCNView!
    @IBOutlet weak var setPosterButton: UIButton!
    @IBOutlet weak var takeImageButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    
//    let augmentedRealitySession = ARSession()
    var nodeWeCanChange: SCNNode?
    let imageGallery = [UIImage(named: "omslag"), UIImage(named: "omslag2")]
    var planeNode: SCNNode?
    var planeIsSet: Bool = false
    var focusSquare: FocusSquare?
    var screenCenter: CGPoint!
    var arImage: ARImage?
    var imageForAR: URL?
//    var teller = 0
    let reachability = try! Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSceneView()
        screenCenter = view.center
        setPosterButton.isHidden = false
        takeImageButton.isHidden = true
        instructionLabel.text = "Zoek een muur en richt je iPhone ernaartoe"
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
              let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.connectionFailedViewController) as! ConnectionFailedViewController
              DvC.isModalInPresentation = true
          self.navigationController?.pushViewController(DvC, animated: false)
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
          try reachability.startNotifier()
        }catch{
          print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {

      let reachability = note.object as! Reachability

      switch reachability.connection {
      case .wifi:
          print("Reachable via WiFi")
      case .cellular:
          print("Reachable via Cellular")
      case .unavailable:
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.connectionFailedViewController) as! ConnectionFailedViewController
            DvC.isModalInPresentation = true
          self.navigationController?.pushViewController(DvC, animated: false)
      case .none:
        print("none")
        }
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        augmentedRealityView.session.run(configuration)
        augmentedRealityView.delegate = self
        augmentedRealityView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func updateFocusSquare() {
        guard let focusSquareLocal = focusSquare else {return}
        guard let pointOfView = augmentedRealityView.pointOfView else {return}
        
        if(planeIsSet == true) {
            focusSquareLocal.setHidden(to: true)
        }
        
        let hitTest = augmentedRealityView.hitTest(screenCenter, types: .existingPlaneUsingExtent)
        if let hitTestResult = hitTest.first {
//            print("FocusSquare hit a plane")
            let addNewModel = hitTestResult.anchor is ARPlaneAnchor
            focusSquareLocal.isClosed = addNewModel
        } else {
//            print("FocusSquare doesn't hit a plane")
            focusSquareLocal.isClosed = false
        }
    }
    
    @IBAction func reloadView(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.arViewController) as! ARCameraViewController
        DvC.imageForAR = self.imageForAR
        self.navigationController?.pushViewController(DvC, animated: true)
    }
    
    @IBAction func takeImage(_ sender: UIButton) {
        let image = augmentedRealityView.snapshot()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let DvC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.pictureViewController) as! PictureViewController
        DvC.arPicture = image
        self.navigationController?.pushViewController(DvC, animated: false)
        
    }
    
    
    
    
    
    @IBAction func CameraButtonTapped(_ sender: UIButton) {
//        guard let imageToApply = imageGallery[sender.tag], let node = nodeWeCanChange  else { return }
//        node.geometry?.firstMaterial?.diffuse.contents = imageToApply
        guard arImage == nil else {return}
        let arImageLocal = ARImage()
        arImageLocal.arImage = self.imageForAR!.absoluteString
        arImageLocal.tapped()
//        arImageLocal.arImage = self.imageForAR!.absoluteString
        let hitTest = augmentedRealityView.hitTest(screenCenter, types: .existingPlaneUsingExtent)
        guard let worldTransformColumn3 = hitTest.first?.worldTransform.columns.3 else {return}
        arImageLocal.position = SCNVector3(worldTransformColumn3.x, worldTransformColumn3.y, worldTransformColumn3.z)
        self.augmentedRealityView.scene.rootNode.addChildNode(arImageLocal)
        self.arImage = arImageLocal
        augmentedRealityView.debugOptions = []
//        self.augmentedRealityView.scene.rootNode.addChildNode(imageToApply)
        planeIsSet = true
        setPosterButton.isHidden = true
        takeImageButton.isHidden = false
        instructionLabel.text = "Neem een foto van de poster"
    }
    
    
}



extension ARCameraViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}

        guard focusSquare == nil else {return}
        let focusSquareLocal = FocusSquare()
        self.augmentedRealityView.scene.rootNode.addChildNode(focusSquareLocal)
        self.focusSquare = focusSquareLocal
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let focusSquareLocal = focusSquare else {return}
        let hitTest = augmentedRealityView.hitTest(screenCenter, types: .existingPlane)
        let hitTestResult = hitTest.first
        
        guard let worldTransform = hitTestResult?.worldTransform else {return}
        let worldTransformColumn3 = worldTransform.columns.3
        focusSquareLocal.position = SCNVector3(worldTransformColumn3.x, worldTransformColumn3.y, worldTransformColumn3.z)
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }
    
}
