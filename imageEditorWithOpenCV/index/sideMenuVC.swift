//
//  sideMenuVC.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/4/6.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class sideMenuVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var sender = mainVC()
    var autoPrint = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.tableView.tableFooterView = UIView()
        
        if let autoPrint = UserDefaults.standard.object(forKey: "I-Scan-autoPrint") as? Bool {
            self.autoPrint = autoPrint
            self.tableView.reloadData()
        }
        
    }



}

extension sideMenuVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! sideMenuCell
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.switchBtn.isHidden = false
            cell.switchBtn.isOn = autoPrint
            cell.titleLabel.text = "是否自動列印"
        case 1:
            cell.switchBtn.isHidden = true
            cell.titleLabel.text = "全部刪除"
        case 2:
            cell.switchBtn.isHidden = true
            cell.titleLabel.text = "變更密碼"
        case 3:
            cell.switchBtn.isHidden = true
            cell.titleLabel.text = "登出"
        default:
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("是否自動列印")
//            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! sideMenuCell
//            if cell.switchBtn.isOn {
//                cell.switchBtn.isOn = false
//            }else {
//                cell.switchBtn.isOn = true
//            }
            return
        case 1:
            print("全部刪除")
            SQLiteManager.shared.loadFiles(completionHandler: { (_files) in
                guard let files = _files else { return }
                for file in files {
                    
                    self.willDeleteLocalFile(PKey: file.PKey!, completionHandler: { (isSucceed) in
                        if isSucceed {
                            if SQLiteManager.shared.deleteAFile(pkey: file.PKey!) {
                                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reload_files_list"), object: nil, userInfo: nil))
                            }
                        }
                    })
                }
            })
            
            SQLiteManager.shared.getUpdateFiles(completionHandler: { (_files) in
                guard let files = _files else { return }
                for file in files {
                    self.willDeleteLocalDiduploadFile(PKey: file.PKey!, completionHandler: { (isSucceed) in
                        if isSucceed {
                            if SQLiteManager.shared.deleteAFile(pkey: file.PKey!) {
                                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reload_files_list"), object: nil, userInfo: nil))
                            }
                        }
                    })
                }
            })
            
            sender.moveToViewController(at: 0)
        case 2:
            sender.pushToChangePasswordVC()
        case 3:
            print("登出")
            SQLiteManager.shared.loadFiles(completionHandler: { (_files) in
                guard let files = _files else { return }
                for file in files {
                    if !SQLiteManager.shared.deleteAFile(pkey: file.PKey!) {
                        print("delete file(PK: \(file.PKey!)) error")
                    }
                }
            })
            if self.appdelegate.timer != nil {
                self.appdelegate.timer?.invalidate()
                self.appdelegate.timer = nil
            }
            self.sender.navigationController?.popToRootViewController(animated: true)
        default:
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
