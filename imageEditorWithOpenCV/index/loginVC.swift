//
//  loginVC.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/3/25.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit
import KeychainAccess

class loginVC: UIViewController {

    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var accLabel: UILabel!
    @IBOutlet weak var pwdLabel: UILabel!
    @IBOutlet weak var accTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var checkBoxBtn: CheckBox!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let dafault = UserDefaults.standard
    let keychain = Keychain(service: "I-Scan_App")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SQLiteManager.shared.deleteFileInfoTable()
        if SQLiteManager.shared.createDatebase(){
            print("============database create succeed================")
        }
        
        self.setLoginView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkKeyChain()
    }

    @IBAction func doLogin(_ sender: Any) {
        guard let acc = accTextField.text,
            let pwd = pwdTextField.text else { return }
        
        if acc != "" && pwd != "" {
            self.loginRequest(account: acc, password: pwd) { (_isSucceed) in
                guard let isSucceed = _isSucceed else { return }
                if isSucceed {
                    self.savePwdToDevice(account: acc, password: pwd)
                    self.appDelegate.userAccount = acc
                    self.getContractsList(account: acc, completionHandler: { (_list) in
                        guard let contactsList = _list else { return }
                        for contact in contactsList {
                            if !SQLiteManager.shared.insertContact(contact: contact) {
                                SQLiteManager.shared.loadAContact(contactID: contact.ContactID!, completionHandler: { (_contact) in
                                    guard let aContact = _contact else { return }
                                    contact.isReceiver = aContact.isReceiver
                                    if !SQLiteManager.shared.updateAContact(contact: contact) {
                                        print("error")
                                    }
                                })
                            }
                        }
                        self.appDelegate.userPassword = pwd
                        guard let indexVC = self.storyboard?.instantiateViewController(withIdentifier: "indexVC") as? indexVC else { return }
                        self.navigationController?.pushViewController(indexVC, animated: true)
                    })
                }else{
                    self.showError(title: nil, body: "帳號或密碼錯誤")
                }
            }
        }else {
            self.showError(title: nil, body: "欄位不可空白")
        }
    }
    
    private func savePwdToDevice(account: String, password: String) {
        
        if self.checkBoxBtn.isChecked {
            self.dafault.set(account, forKey: "I-Scan")
            self.keychain[account] = password
        }else {
            do{
                try keychain.removeAll()
                dafault.removeObject(forKey: "I-Scan")
            }catch{
                print("remove key chain fail: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkKeyChain() {
        let items = Keychain(service: "I-Scan_App").allKeys()
        if !items.isEmpty {
            if let account = UserDefaults.standard.object(forKey: "I-Scan") as? String,
                let pwd = try! keychain.get(account) {
                self.accTextField.text = account
                self.pwdTextField.text = pwd
                self.checkBoxBtn.isChecked = true
            }
        }else{
            self.checkBoxBtn.isChecked = false
        }
    }
    
    private func setLoginView() {
        setAccountLabel()
        setpassWordLabel()
    }
    
    private func setAccountLabel() {
        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = UIImage(named:"icon_user")
        let imageOffsetY:CGFloat = -5.0;
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(attachmentString)
        let  textAfterIcon = NSMutableAttributedString(string: " 帳號")
        completeText.append(textAfterIcon)
        self.accLabel.textAlignment = .center;
        self.accLabel.attributedText = completeText;
    }
    
    private func setpassWordLabel() {
        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = UIImage(named:"icon_lock")
        let imageOffsetY:CGFloat = -5.0;
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(attachmentString)
        let  textAfterIcon = NSMutableAttributedString(string: " 密碼")
        completeText.append(textAfterIcon)
        self.pwdLabel.textAlignment = .center;
        self.pwdLabel.attributedText = completeText;
    }
}
