//
//  PictureViewController.swift
//  Bash
//
//  Created by Kanzi Louagie on 16/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController {
    
    var arPicture: UIImage?

    
    
    @IBOutlet weak var ARPicture: UIImageView!
    @IBOutlet weak var saveImageButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        ARPicture.image = arPicture
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func saveImage(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(arPicture!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    

}
