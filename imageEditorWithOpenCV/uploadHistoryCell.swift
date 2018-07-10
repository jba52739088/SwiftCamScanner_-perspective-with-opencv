//
//  downloadCell.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/2/22.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class uploadHistoryCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var checkBtn: CheckBox!
    
    var parent = uploadHistoryVC()
    var file: FileInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didClickOnCheckBox))
        self.checkBtn.addGestureRecognizer(tap)
        self.checkBtn.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func didClickOnCheckBox() {
        self.parent.didClickCheckBox(cell: self)
    }

}
