//
//  mainVC.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/2/20.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SideMenu

class mainVC: ButtonBarPagerTabStripViewController {

    var menuRightNavigationController: UISideMenuNavigationController?
    let purpleInspireColor = UIColor(red:0.13, green:0.03, blue:0.25, alpha:1.0)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        self.setBtnBarView()
        super.viewDidLoad()

        appDelegate.mainVC = self
        
        
        self.setNavBar()
        self.setSideMenu()
        if let autoPrint = UserDefaults.standard.object(forKey: "I-Scan-autoPrint") as? Bool {
            self.appDelegate.isAutoPrint = autoPrint
        }
        
        self.appDelegate.btnBarHeight = self.buttonBarView.frame.height
        self.autoDownloadFile()
        self.appDelegate.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.autoDownloadFile), userInfo: nil, repeats: true)
        
        
    }

    private func setNavBar() {
        let button: UIButton = UIButton(type: UIButtonType.custom)
        button.setImage(UIImage(named: "ic_menu"), for: .normal)
        button.addTarget(self, action: #selector(menuBtnPressed), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let menuButton = UIBarButtonItem(customView: button)
        let receiverBtn = UIBarButtonItem(title: "指定接收者", style: .plain, target: self, action: #selector(receiverBtnPressed))
        
        self.navigationItem.rightBarButtonItems = [menuButton, receiverBtn]
        
        let leftItem = UIBarButtonItem(title: "i-Scan",
                                       style: .plain,
                                       target: self,
                                       action: nil)
        self.navigationItem.leftBarButtonItem = leftItem
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    private func setSideMenu() {
        guard let sideMenu = self.storyboard?.instantiateViewController(withIdentifier: "sideMenuVC") as? sideMenuVC else { return }
        sideMenu.sender = self
        menuRightNavigationController = UISideMenuNavigationController(rootViewController: sideMenu)
        SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
    }
    
    private func setBtnBarView() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = purpleInspireColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 30
        settings.style.buttonBarRightContentInset = 30
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = self?.purpleInspireColor
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = self.storyboard?.instantiateViewController(withIdentifier: "uploadVC") as! uploadVC
        let child_2 = self.storyboard?.instantiateViewController(withIdentifier: "uploadHistoryVC") as! uploadHistoryVC
        let child_3 = self.storyboard?.instantiateViewController(withIdentifier: "downloadVC") as! downloadVC
        child_1.parentVC = self
        child_2.parentVC = self
        child_3.parentVC = self
        return [child_1, child_2, child_3]
    }
    
    @objc func menuBtnPressed() {
        present(SideMenuManager.default.menuRightNavigationController!, animated: true, completion: nil)
    }

    @objc func receiverBtnPressed() {
        guard let receiverVC = self.storyboard?.instantiateViewController(withIdentifier: "receiverVC") as? receiverVC else { return }
        self.navigationController?.pushViewController(viewController: receiverVC, animated: true, completion: {
            print("receiverVC")
        })
    }
    
    func pushToChangePasswordVC() {
        guard let updatePwdVC = self.storyboard?.instantiateViewController(withIdentifier: "updatePwdVC") as? updatePwdVC else { return }
        self.navigationController?.pushViewController(viewController: updatePwdVC, animated: true, completion: nil)
    }
    
    @objc func autoDownloadFile() {
        self.getFileShouldDownloadData(userID: self.appDelegate.userAccount) {
            print("15")
        }
    }
}

