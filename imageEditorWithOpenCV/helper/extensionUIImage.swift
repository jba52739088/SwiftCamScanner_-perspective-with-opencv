//
//  extensionUIImage.swift
//  UIImageFilterExtension
//
//  Created by 黃恩祐 on 2018/1/30.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

//--- UIImageFilterExtension.swift ---
extension UIImage
{
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedTo100KB() -> UIImage? {
        guard let imageData = UIImagePNGRepresentation(self) else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1024.0 // ! Or devide for 1024 if you need KB but not kB
        
        while imageSizeKB > 10240 { // ! Or use 1024 if you need KB but not kB
            
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
                let imageData = UIImagePNGRepresentation(resizedImage)
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1024.0 // ! Or devide for 1024 if you need KB but not kB
        }
        print("imageSizeKB: \(imageSizeKB)")
        return resizingImage
    }
    
}


extension UINavigationController {
    
    public func pushViewController(viewController: UIViewController,
                                   animated: Bool,
                                   completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
}

