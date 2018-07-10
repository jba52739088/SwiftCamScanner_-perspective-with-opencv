//
//  sideMenuVC.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/4/6.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class receiverVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var contactsList: [Contact]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.title = "指定接收者"
        self.tableView.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SQLiteManager.shared.loadContactList { (_list) in
            guard let contactsList = _list else { return }
            self.contactsList = contactsList
            self.tableView.reloadData()
        }
    }
}

extension receiverVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let contactsArray = self.contactsList {
            return contactsArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let contactsArray = self.contactsList {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! receiverCell
            cell.selectionStyle = .none
            cell.contact = contactsArray[indexPath.row]
            cell.titleLabel.text = contactsArray[indexPath.row].ContactName!
            if contactsArray[indexPath.row].isReceiver {
                cell.switchBtn.isOn = true
            }else {
                cell.switchBtn.isOn = false
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
