//
//  ViewController.swift
//  photo_pop
//
//  Created by Leo Dion on 9/23/18.
//  Copyright © 2018 Bright Digit, LLC. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
  
  @IBOutlet var originalImageView: UIImageView!
  @IBOutlet var poppedImageView: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let fileURL = Bundle.main.url(forResource: "PHOTO", withExtension: "HEIC")!
    // Create a CGImageSource
    guard let source = CGImageSourceCreateWithURL(fileURL as CFURL, nil) else {
      return
    }
    
    guard let auxDataInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0, kCGImageAuxiliaryDataTypeDisparity) as? [AnyHashable : Any] else {
      return
    }
    
    // This is the star of the show!
    var depthData: AVDepthData
    
    do {
      // Get the depth data from the auxiliary data info
      depthData = try AVDepthData(fromDictionaryRepresentation: auxDataInfo)
      
    } catch {
      return
    }
    
    // Make sure the depth data is the type we want
    if depthData.depthDataType != kCVPixelFormatType_DisparityFloat32 {
      depthData = depthData.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
    }
    
    let depthDataMap = depthData.depthDataMap
    depthDataMap.normalize()
    
    let depthCoreImage = CIImage(cvImageBuffer: depthDataMap)
    let origCoreImage = CIImage(contentsOf: fileURL)!

    let origUImage = UIImage(ciImage: origCoreImage)
    let depthUImage = UIImage(ciImage: depthCoreImage)
    let maxToDim = max(origUImage.size.width, origUImage.size.height)
    let maxFromDim = max(depthUImage.size.width, depthUImage.size.height)
    
    let scale = maxToDim / maxFromDim
    
    let slope : CGFloat = 10.0
    let bias : CGFloat = 10.0
    
    var mask = depthCoreImage.applyingFilter("CIColorMatrix", parameters: [
      "inputRVector" : CIVector(x: slope, y: 0, z: 0, w: 0),
      "inputGVector" : CIVector(x: 0, y: slope, z: 0, w: 0),
      "inputBVector" : CIVector(x: 0, y: 0, z: slope, w: 0),
      "inputBiasVector" : CIVector(x: bias, y: bias, z: bias, w: 0)
    ])
    
    
    mask = mask.applyingFilter("CIColorClamp")
    
    let backgroundImage = origCoreImage.applyingFilter("CIPhotoEffectMono")
    let outputImage = origCoreImage.applyingFilter("CIBlendWithMask", parameters: [kCIInputBackgroundImageKey : backgroundImage, kCIInputMaskImageKey: mask])
    
    self.originalImageView.image = origUImage
    self.poppedImageView.image = UIImage(ciImage: outputImage)
//
//    guard let mask = depthFilters?.createMask(for: depthImage, withFocus: CGFloat(depthSlider.value), andScale: scale),
//      let filterImage = filterImage,
//      let orientation = origImage?.imageOrientation else {
//        return
//    }
    //self.poppedImageView.image = UIImage(ciImage: depthImage)
  }


}

