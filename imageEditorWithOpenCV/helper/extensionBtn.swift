//
//  extensionBtn.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/3/29.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func centerVertically(padding: CGFloat = 6.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
                return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }
    
    func isTabBarBtn(image name: String) {
        self.centerVertically(padding: 3)
        let blueColor = UIColor.blue
        let grayColor = UIColor.gray
        guard let image = UIImage(named: name) else { return }
        let tintedImage = image.withRenderingMode(.alwaysTemplate)
        self.setImage(tintedImage, for: .normal)
        self.tintColor = grayColor
        self.setTitleColor(grayColor, for: .normal)
        self.setTitleColor(blueColor, for: .highlighted)
    }
    
    func isTabBarBtn() {
        self.centerVertically(padding: 3)
        let blueColor = UIColor(red: 63, green: 81, blue: 181, alpha: 1)
        let grayColor = UIColor(red: 94, green: 94, blue: 94, alpha: 1)
        guard let image = self.imageView?.image else { return }
        let tintedImage = image.withRenderingMode(.alwaysTemplate)
        self.setImage(tintedImage, for: .normal)
        self.tintColor = grayColor
        self.setTitleColor(grayColor, for: .normal)
        self.setTitleColor(blueColor, for: .highlighted)
    }
    
}
