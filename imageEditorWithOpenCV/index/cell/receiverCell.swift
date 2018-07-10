//
//  sideMenuCell.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/4/6.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class receiverCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    
    var contact: Contact?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func doSwitch(_ sender: Any) {
        guard let thisContact = self.contact else { return }
        if self.switchBtn.isOn {
            print("on")
            thisContact.isReceiver = true
        }else {
            print("off")
            thisContact.isReceiver = false
        }
        if !SQLiteManager.shared.updateAContact(contact: thisContact) {
            print("error")
        }
    }
}
