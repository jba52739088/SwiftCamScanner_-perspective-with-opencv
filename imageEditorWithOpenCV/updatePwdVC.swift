//
//  updatePwdVC.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/4/6.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class updatePwdVC: UIViewController {
    
    
    @IBOutlet weak var pwdTestField: UITextField!
    @IBOutlet weak var rePwdTextField: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "變更密碼"
    }
    
    // 執行更改密碼

    @IBAction func doUpdate(_ sender: Any) {
        guard let newPwd = self.pwdTestField.text,
            let rePwd = self.rePwdTextField.text else { return }
        if newPwd != "" && rePwd != "" {
            if newPwd != rePwd {
                self.showError(title: nil, body: "密碼不一致")
            }else if newPwd == appdelegate.userPassword {
                self.showError(title: nil, body: "密碼與舊密碼相同")
            }else {
                self.changePassword(account: appdelegate.userAccount, password: newPwd, completionHandler: { (value) in
                    if value {
                        let alert = UIAlertController(title: nil, message: "密碼更改成功", preferredStyle: .alert)
                        let action = UIAlertAction(title: "確定", style: .default, handler: { (action) in
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }else {
                        self.showError(title: nil, body: "密碼更改失敗")
                    }
                })
            }
        }else {
            self.showError(title: nil, body: "欄位不可空白")
        }
    }
    
}
