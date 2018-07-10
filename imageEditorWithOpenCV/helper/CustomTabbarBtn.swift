//
//  CustomTabbarBtn.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/4/1.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import Foundation
import UIKit

class CustomUIButtonForUIToolbar: UIButton {
    
    let blueColor = UIColor.blue
    let grayColor = UIColor.gray
    
    override func awakeFromNib() {
        self.tintColor = grayColor
    }
    
    override var isHighlighted: Bool {
        
        didSet {
            if isHighlighted == true {
                tintColor = blueColor
                
            } else {
                tintColor = grayColor
                
            }
            tintColorDidChange()
        }
    }
    
}
