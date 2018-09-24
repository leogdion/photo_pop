//
//  ViewController.swift
//  photo_pop
//
//  Created by Leo Dion on 9/23/18.
//  Copyright © 2018 Bright Digit, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet var originalImageView: UIImageView!
  @IBOutlet var poppedImageView: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let photoURL = Bundle.main.url(forResource: "PHOTO", withExtension: "HEIC")!
    //let source = CGImageSourceCreateWithURL(photoURL as CFURL, nil)
    let depthImage = CIImage(contentsOf: photoURL, options: [CIImageOption.auxiliaryDepth : true])!
    
    let disparityImage = depthImage.applyingFilter("CIDepthToDisparity")
    
    let image = UIImage(ciImage: disparityImage)
    poppedImageView.image = image
  }


}

