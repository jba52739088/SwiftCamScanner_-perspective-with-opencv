//
//  editImageVC.swift
//  customCamera
//
//  Created by 黃恩祐 on 2018/1/30.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit
import Foundation
import ImageIO
import MobileCoreServices

class editImageVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sendBtn: CustomUIButtonForUIToolbar!
    @IBOutlet weak var redoBtn: CustomUIButtonForUIToolbar!
    @IBOutlet weak var cancelBtn: CustomUIButtonForUIToolbar!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var rawImage: UIImage?
    var textInImage = ""
    let date = Date()
    var photoFromCamera = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let uploadVC = self.parent as? uploadVC else { return }
        if uploadVC.byCamera {
            self.redoBtn.setTitle("重拍", for: .normal)
        }else {
            self.redoBtn.setTitle("重選", for: .normal)
        }
    }
    
    func configEditImageVC(image: UIImage) {
        
        let rawImage = RGBAImage(image:image)!
        let _image = ImageProcess.brightness(rawImage, contrast: 1, brightness: 0.25)
        
//        self.rawImage = adjustImage(rawImage).toUIImage()!
        self.rawImage = adjustImage(_image).toUIImage()!

        let userDisplayName = self.appDelegate.userDisplayName
        let userAccount = self.appDelegate.userAccount
        let sendTime = self.sendTime()
        let sendMS = self.sendMS()
        let sentPage = self.sendPage()
        let drawText = "傳送者：\(userDisplayName)(\(userAccount)) 傳送時間：\(sendTime) 單號：\(userAccount)-\(sendMS)-\(sentPage)"
        self.imageView.image = self.textToImage(drawText: drawText, inImage: self.rawImage!, atPoint: CGPoint(x: 0, y: 10))
    }
    
    func setView() {
        self.sendBtn.isTabBarBtn(image: "ic_send_white_24dp")
        self.redoBtn.isTabBarBtn(image: "ic_replay_white_24dp")
        self.cancelBtn.isTabBarBtn(image: "ic_cancel_white_24dp")
    }

    
    @IBAction func upload(_ sender: Any) {
        guard let image = self.imageView.image else { return }
        guard let imageData = UIImageJPEGRepresentation(resizeImage(image: image, width: 1654, height: 2339), 1)?.base64EncodedString()
            else { print("covert image to data error"); return }
        
        SQLiteManager.shared.loadContactList { (_list) in
            var isReceiverCount = 0
            guard let contactsList = _list else { return }
            for contact in contactsList {
                if contact.isReceiver {
                    isReceiverCount += 1
                }
            }
            if isReceiverCount != 0 {
                for contact in contactsList {
                    if contact.isReceiver {
                        self.uploadDataToServer(userID: self.appDelegate.userAccount, data: imageData, strReceiverId: contact.ContactID!, fileName: fileNameString(strReceiverId: contact.ContactID!, date: self.date)) {
                            // save photo to Album
                            //                        guard let uploadedImage = UIImage(data: Data(base64Encoded: imageData)!) else { return }
                            //                        UIImageWriteToSavedPhotosAlbum(uploadedImage, self, nil, nil)
                            //
                        }
                    }
                    
                }
                guard let uploadVC = self.parent as? uploadVC else { return }
                for vc in uploadVC.childViewControllers {
                    vc.view.removeFromSuperview()
                }
            }else {
                let alert = UIAlertController(title: "請選取接收者", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
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
    
    
    @IBAction func cancelBtn(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }

    func fileNameString(strReceiverId: String, date: Date) -> String {
        let senderID = self.appDelegate.userAccount
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = dateFormatter.string(from: date)
        let fileString = senderID + "." + strReceiverId + "." + dateString + "-0000.jpg"
        return fileString
    }
    
    func jpegImage(image: UIImage, maxSize: Int, minSize: Int, times: Int) -> Data? {
        var img = image
        img = resizeImage(image: img, width: 1654, height: 2339)
        var maxQuality: CGFloat = 1.0
        var minQuality: CGFloat = 0.0
        var bestData: Data? = UIImageJPEGRepresentation(img, 1)
        var counter: CGFloat = 0
        while bestData!.count > maxSize {
            for _ in 1...times {
                let thisQuality = (maxQuality + minQuality) / 1.1
                guard let data = UIImageJPEGRepresentation(img, thisQuality) else { return nil }
                let thisSize = data.count
                if thisSize > maxSize * 2 {
                    let i: CGFloat = CGFloat(maxSize) / CGFloat(thisSize)
                    maxQuality = i
                }else if thisSize > ((maxSize + minSize) / 2)  {
                    maxQuality = thisQuality
                } else {
                    minQuality = thisQuality
                    bestData = data
                    if thisSize > minSize {
                        return bestData
                    }
                }
                bestData = data
            }
            counter += 1
            if bestData!.count > maxSize {
                img = resizeImage(image: img, width: 1654 * (1 - (counter / 10)), height: 2339 * (1 - (counter / 10)))
            }
        }
        return bestData
    }
    
    func resizeImage(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        let targetSize = CGSize(width: width, height: height)
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func adjustImage(_ image: RGBAImage) -> RGBAImage {
        var outImage = image
        outImage.process { (pixel) -> Pixel in
            var pixel = pixel
            var totalR:Int = 0
            var totalG:Int = 0
            var totalB:Int = 0
            
            // 120
            if Int(pixel.R) > 175 {
                totalR = 255
            }else {
                totalR = 0
            }
            
            // 135
            if Int(pixel.G) > 175  {
                totalG = 255
            }else {
                totalG = 0
            }
            
            // 135
            if Int(pixel.B) > 175  {
                totalB = 255
            }else {
                totalB = 0
            }
            
            let a = Int(pixel.A)
            
            let brad = a << 24 | totalR << 16 | totalG << 8 | totalB
            
            // 4294967295
            let primary: Int64 = 4294967295
            if brad >= primary {
                totalR = 255
                totalG = 255
                totalB = 255
            }else{
                totalR = 0
                totalG = 0
                totalB = 0
            }
            
            pixel.R = UInt8(totalR)
            pixel.G = UInt8(totalG)
            pixel.B = UInt8(totalB)
            
            
            return pixel
        }
        return outImage
    }

    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let textFontAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 22),
            NSAttributedStringKey.foregroundColor: UIColor.black,
            ] as [NSAttributedStringKey : Any]
        let stringWidth = text.widthOfString(usingFont: UIFont.systemFont(ofSize: 22))
        let stringHeight = text.heightOfString(usingFont: UIFont.systemFont(ofSize: 22))
        
        
        let attributedString = NSAttributedString(string: text, attributes: textFontAttributes)
        let rect = CGRect(origin: CGPoint(x: (image.size.width - stringWidth) / 2, y: 5), size: CGSize(width: image.size.width, height: stringHeight))
        attributedString.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func sendTime() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self.date)
    }
    
    func sendMS() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mmss"
        return dateFormatter.string(from: self.date)
    }
    
    func sendPage() -> String {
        
        var count = 1
        SQLiteManager.shared.getUpdateFiles { (files) in
            guard let files = files else { return }
            let dateFormatter : DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            for file in files {
                if dateFormatter.string(from: self.date) == file.UploadDate {
                    count += 1
                }
            }
        }
        let page = String(count)
        return page.leftPadding(toLength: 4, withPad: "0")
    }
    
    var lastScale:CGFloat!
    @objc func zoom(gesture:UIPinchGestureRecognizer) {
        if(gesture.state == .began) {
            // Reset the last scale, necessary if there are multiple objects with different scales
            lastScale = gesture.scale
        }
        if (gesture.state == .began || gesture.state == .changed) {
            let currentScale = gesture.view!.layer.value(forKeyPath:"transform.scale")! as! CGFloat
            // Constants to adjust the max/min values of zoom
            let kMaxScale:CGFloat = 3.0
            let kMinScale:CGFloat = 1.0
            var newScale = 1 -  (lastScale - gesture.scale)
            newScale = min(newScale, kMaxScale / currentScale)
            newScale = max(newScale, kMinScale / currentScale)
            let transform = (gesture.view?.transform)!.scaledBy(x: newScale, y: newScale);
            gesture.view?.transform = transform
            lastScale = gesture.scale  // Store the previous scale factor for the next pinch gesture call
        }
    }
    

}


extension String {
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func leftPadding(toLength: Int, withPad: String = " ") -> String {
        
        guard toLength > self.count else { return self }
        
        let padding = String(repeating: withPad, count: toLength - self.count)
        return padding + self
    }
}

