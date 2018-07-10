//
//  sideMenuCell.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/4/6.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class sideMenuCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    
    let dafault = UserDefaults.standard
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // 切換是否自動列印
    
    @IBAction func tapSwitchBtn(_ sender: Any) {
        self.appDelegate.isAutoPrint = self.switchBtn.isOn
        self.dafault.set(self.switchBtn.isOn, forKey: "I-Scan-autoPrint")
    }
}
