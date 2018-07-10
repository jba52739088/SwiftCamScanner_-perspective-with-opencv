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

