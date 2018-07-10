//
//  downloadCell.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/2/22.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class downloadCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var uploaderLabel: UILabel!
    @IBOutlet weak var checkBoxBtn: CheckBox!
    
    var parent = downloadVC()
    var file: FileInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(didClickOnCheckBox))
        self.checkBoxBtn.addGestureRecognizer(tap)
        self.checkBoxBtn.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func didClickOnCheckBox() {
        self.parent.didClickCheckBox(cell: self)
    }
}
