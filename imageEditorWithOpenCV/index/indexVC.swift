//
//  indexVC.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/3/25.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class indexVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
}
