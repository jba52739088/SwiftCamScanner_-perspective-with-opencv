//
//  cameraVC.swift
//  customCamera
//
//  Created by 黃恩祐 on 2018/2/3.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit
import SwiftCamScanner
import XLPagerTabStrip

class cameraVC: UIViewController {

    @IBOutlet weak var reCaptureButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var captureButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var trimmingButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var cancelButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var cancelButton2: CustomUIButtonForUIToolbar!
    @IBOutlet weak var capturePreviewView: UIView!
    @IBOutlet weak var viewForCrop: UIView!
    @IBOutlet weak var viewForPhoto: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var image: UIImage?
    var cropView: CropView!
    let cameraController = CameraController()
    var photoFromCamera = true
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        guard let uploadVC = self.parent as? uploadVC else { return }
        if photoFromCamera {
            self.reCaptureButton.setTitle("重拍", for: .normal)
        }else {
            self.reCaptureButton.setTitle("重選", for: .normal)
        }
        self.appDelegate.previewViewRatio = self.capturePreviewView.frame.height / self.capturePreviewView.frame.width
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func setView() {
        let navHeight = self.navigationController?.navigationBar.frame.size.height
        let statusHeight = UIApplication.shared.statusBarFrame.height
        self.capturePreviewView.frame.size = CGSize(width: self.capturePreviewView.frame.width, height: self.capturePreviewView.frame.height - navHeight! - statusHeight - self.appDelegate.btnBarHeight)
        self.captureButton.isTabBarBtn(image: "ic_photo_camera_white_24dp")
        self.cancelButton.isTabBarBtn(image: "ic_cancel_white_24dp")
        self.cancelButton2.isTabBarBtn(image: "ic_cancel_white_24dp")
        self.trimmingButton.isTabBarBtn(image: "ic_crop_white_24dp")
        self.reCaptureButton.isTabBarBtn(image: "ic_replay_white_24dp")
        self.viewForPhoto.layer.zPosition = 1
        self.viewForCrop.layer.zPosition = 0
    }
    
    func configureCameraController() {
        if let aImage = self.image {
            self.beginCropImage(image: aImage)
            
        }else{
            cameraController.prepare { (error) in
                if let error = error {
                    print("error: \(error)")
                }
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
                self.viewForPhoto.layer.zPosition = 1
                self.viewForPhoto.isUserInteractionEnabled = true
                self.viewForCrop.layer.zPosition = 0
                self.viewForCrop.isUserInteractionEnabled = false
            }
        }
        
    }
    
    @IBAction func cancleBtn(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func captureBtn(_ sender: Any) {
        cameraController.captureImage {(_image, error) in
            guard let image = _image else {
                print("Image capture error : \(error.debugDescription)")
                return
            }
            self.cameraController.captureSession?.stopRunning()
            
            let cropped = CGRect(x: 0, y: 0 , width: image.size.width, height: image.size.width * self.appDelegate.previewViewRatio)
            let croppedImage = self.CropImage(image: image, cropRect: cropped)
            
//
            
//            let cgImage = self.getCGImageWithCorrectOrientation(image);
//
//            let scaledCropArea = CGRect(
//                x: 0,
//                y: 0,
//                width: cgImage.height * 2,
//                height: cgImage.width
//            )
//
//            let croppedCGImage = cgImage.cropping(to: scaledCropArea)
//            let croppedImage = UIImage(cgImage: croppedCGImage!, scale: 1, orientation: .up)
            
            
            
            
            self.beginCropImage(image: croppedImage)
//            self.beginCropImage(image: image)
        }
    }
    
    @IBAction func trimmingBtn(_ sender: Any) {
        self.cropView.cropAndTransform { (croppedImage) in
            if let editImageVC = self.storyboard?.instantiateViewController(withIdentifier: "editImageVC") as? editImageVC {
                self.parent?.addChildViewController(editImageVC)
                editImageVC.view.frame = self.parent!.view.frame
                editImageVC.photoFromCamera = self.photoFromCamera
                self.parent?.view.addSubview(editImageVC.view)
                editImageVC.didMove(toParentViewController: self.parent!)
                editImageVC.configEditImageVC(image: croppedImage)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        }
    }
    
    @IBAction func rePhotoBtn(_ sender: Any) {
        guard let uploadVC = self.parent as? uploadVC else { return }
        if photoFromCamera{
            uploadVC.clickCameraBtn(uploadVC)
        }else {
            uploadVC.clickLibraryBtn(uploadVC)
        }
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func beginCropImage(image: UIImage) {
        self.cropView = CropView(frame: self.capturePreviewView.bounds)
        self.cropView.setUpImage(image: image)
        self.capturePreviewView.addSubview(self.cropView)
//        self.viewForPhoto.frame = CGRect(x: 0, y: self.view.frame.height, width: self.viewForPhoto.frame.width, height: self.viewForPhoto.frame.height)
        self.viewForPhoto.layer.zPosition = 0
        self.viewForPhoto.isUserInteractionEnabled = false
        self.viewForCrop.layer.zPosition = 1
        self.viewForCrop.isUserInteractionEnabled = true
    }
    
    
    private func CropImage( image:UIImage , cropRect:CGRect) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(cropRect.size, true, 0);
//        UIGraphicsBeginImageContextWithOptions(
        let context = UIGraphicsGetCurrentContext();
        
        context?.translateBy(x: 0.0, y: image.size.height);
        context?.scaleBy(x: 1.0, y: -1.0);
        context?.draw(image.rotate(radians: .pi * 2).cgImage!, in: CGRect(x:0, y: 0.5 * (image.size.height - (image.size.width * self.appDelegate.previewViewRatio)), width:image.size.width, height:image.size.height), byTiling: true);
        context?.clip(to: [cropRect]);
        
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return croppedImage!;
    }
    
//    func getCGImageWithCorrectOrientation(_ image : UIImage) -> CGImage {
//        if (image.imageOrientation == UIImageOrientation.up) {
//            return image.cgImage!;
//        }
//
//        var transform : CGAffineTransform = CGAffineTransform.identity;
//
//        switch (image.imageOrientation) {
//        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
//            transform = transform.translatedBy(x: 0, y: image.size.height);
//            transform = transform.rotated(by: CGFloat(-1.0 * M_PI_2));
//            break;
//        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
//            transform = transform.translatedBy(x: image.size.width, y: 0);
//            transform = transform.rotated(by: CGFloat(M_PI_2));
//            break;
//        case UIImageOrientation.down, UIImageOrientation.downMirrored:
//            transform = transform.translatedBy(x: image.size.width, y: image.size.height);
//            transform = transform.rotated(by: CGFloat(M_PI));
//            break;
//        default:
//            break;
//        }
//
//        switch (image.imageOrientation) {
//        case UIImageOrientation.rightMirrored, UIImageOrientation.leftMirrored:
//            transform = transform.translatedBy(x: image.size.height, y: 0);
//            transform = transform.scaledBy(x: -1, y: 1);
//            break;
//        case UIImageOrientation.downMirrored, UIImageOrientation.upMirrored:
//            transform = transform.translatedBy(x: image.size.width, y: 0);
//            transform = transform.scaledBy(x: -1, y: 1);
//            break;
//        default:
//            break;
//        }
//
//        let contextWidth : Int;
//        let contextHeight : Int;
//
//        switch (image.imageOrientation) {
//        case UIImageOrientation.left, UIImageOrientation.leftMirrored,
//             UIImageOrientation.right, UIImageOrientation.rightMirrored:
//            contextWidth = (image.cgImage?.height)!;
//            contextHeight = (image.cgImage?.width)!;
//            break;
//        default:
//            contextWidth = (image.cgImage?.width)!;
//            contextHeight = (image.cgImage?.height)!;
//            break;
//        }
//
//        let context : CGContext = CGContext(data: nil, width: contextWidth, height: contextHeight,
//                                            bitsPerComponent: image.cgImage!.bitsPerComponent,
//                                            bytesPerRow: image.cgImage!.bytesPerRow,
//                                            space: image.cgImage!.colorSpace!,
//                                            bitmapInfo: image.cgImage!.bitmapInfo.rawValue)!;
//
//        context.concatenate(transform);
//        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: CGFloat(contextWidth), height: CGFloat(contextHeight)));
//
//        let cgImage = context.makeImage();
//
//        return cgImage!;
//    }

}

extension cameraVC: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "上傳記錄")
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.x, y: -origin.y, width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}
