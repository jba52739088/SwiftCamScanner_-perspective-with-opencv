//
//  downloadVC.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/2/20.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class downloadVC: UIViewController, IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var fileArray = [FileInfo]()
    var parentVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadFiles), name: NSNotification.Name(rawValue: "reload_files_list"), object: nil)
        loadFiles()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadFiles()
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "接收文件")
    }
    
    // 讀取已下載之檔案及排序
    
    @objc func loadFiles() {
        print("loadFiles")
        SQLiteManager.shared.loadFiles { (files) in
            guard let files = files else { return }
            self.fileArray = files
            self.fileArray.sort(by: { (item1, item2) -> Bool in
                let file_1 = item1.UploadDateTime!
                let file_2 = item2.UploadDateTime!
                return file_1 > file_2
            })
            print("self.fileArray count: \(self.fileArray.count)")
            self.tableView.reloadData()
        }
    }
    
    // 全部刪除
    
    @IBAction func deleteAll(_ sender: Any) {
        for file in self.appdelegate.didSelectDownloadedFile {
            self.willDeleteLocalFile(PKey: file.PKey!, completionHandler: { (isSucceed) in
                if isSucceed {
                    if SQLiteManager.shared.deleteAFile(pkey: file.PKey!) {
                        self.loadFiles()
                    }
                }
            })
        }
        self.appdelegate.didSelectDownloadedFile = []
        self.loadFiles()
    }
    
    
    
    func didClickCheckBox(cell: downloadCell) {
        if cell.checkBoxBtn.isChecked {
            appdelegate.didSelectDownloadedFile.remove(where: { (file) -> Bool in
                return file.PKey == cell.file?.PKey
            })
        }else {
            appdelegate.didSelectDownloadedFile.insert(cell.file!, at: 0)
        }
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
    }
    
}

extension downloadVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! downloadCell
        if let date = fileArray[indexPath.row].UploadDate,
            let time = fileArray[indexPath.row].UploadDateTime,
            let uploader = fileArray[indexPath.row].UpLoadUserID{
            cell.timeLabel.text = time.components(separatedBy: "-")[1] + "-" + time.components(separatedBy: "-")[2]
            cell.uploaderLabel.text = uploader
            cell.parent = self
            cell.file = fileArray[indexPath.row]
            if appdelegate.didSelectDownloadedFile.contains(where: { $0.PKey == cell.file?.PKey }) {
                cell.checkBoxBtn.isChecked = true
            } else {
                cell.checkBoxBtn.isChecked = false
            }
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "filePageVC") as? filePageVC else { return }
        vc.file = fileArray[indexPath.row]
        vc.isForDownload = true
        self.parent?.navigationController?.pushViewController(vc, animated: true)
    }
}


