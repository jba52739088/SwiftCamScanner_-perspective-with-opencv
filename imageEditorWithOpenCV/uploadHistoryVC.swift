//
//  uploadHistoryVC.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/2/20.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class uploadHistoryVC: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var fileArray = [FileInfo]()
    var parentVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadFiles), name: NSNotification.Name(rawValue: "reload_files_list"), object: nil)
        self.tableView.tableFooterView = UIView()
        self.getFileDidUploadData(userID: self.appdelegate.userAccount)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadFiles()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "上傳記錄")
    }
    
    
    
    @objc func loadFiles() {
        SQLiteManager.shared.getUpdateFiles { (files) in
            guard let files = files else { return }
            self.fileArray = files
            print("self.fileArray count: \(self.fileArray.count)")
                self.fileArray.sort(by: { (item1, item2) -> Bool in
                    let file_1 = item1.UploadDateTime!
                    let file_2 = item2.UploadDateTime!
                    return file_1 > file_2
                })

            self.tableView.reloadData()
        }
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        for file in self.appdelegate.didSelectUploadedFile {
            self.willDeleteLocalDiduploadFile(PKey: file.PKey!, completionHandler: { (isSucceed) in
                if isSucceed {
                    if SQLiteManager.shared.deleteAFile(pkey: file.PKey!) {
                        self.appdelegate.didSelectUploadedFile = []
                        self.loadFiles()
                    }
                }
            })
        }
    }
    
    func didClickCheckBox(cell: uploadHistoryCell) {
        if cell.checkBtn.isChecked {
            appdelegate.didSelectUploadedFile.remove(where: { (file) -> Bool in
                return file.PKey == cell.file?.PKey
            })
        }else {
            appdelegate.didSelectUploadedFile.insert(cell.file!, at: 0)
        }
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
    }
    

}

extension uploadHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! uploadHistoryCell
        if let date = fileArray[indexPath.row].UploadDate,
            let time = fileArray[indexPath.row].UploadDateTime,
            let size = fileArray[indexPath.row].UserID{
            cell.timeLabel.text = time.components(separatedBy: "-")[1] + "-" + time.components(separatedBy: "-")[2]
            cell.sizeLabel.text = size
            cell.parent = self
            cell.file = fileArray[indexPath.row]
            if appdelegate.didSelectUploadedFile.contains(where: { $0.PKey == cell.file?.PKey }) {
                cell.checkBtn.isChecked = true
            } else {
                cell.checkBtn.isChecked = false
            }
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "filePageVC") as? filePageVC else { return }
        vc.file = fileArray[indexPath.row]
        self.parent?.navigationController?.pushViewController(vc, animated: true)
    }
}

