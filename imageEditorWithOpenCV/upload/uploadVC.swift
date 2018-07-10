//
//  uploadVC.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/2/20.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class uploadVC: UIViewController {

    @IBOutlet weak var libraryBtn: CustomUIButtonForUIToolbar!
    @IBOutlet weak var cameraBtn: CustomUIButtonForUIToolbar!
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var parentVC: UIViewController?
    let picker = UIImagePickerController()
    var byCamera = false
    var byLibrary = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        self.libraryBtn.isTabBarBtn(image: "ic_insert_photo_white_24dp")
        self.cameraBtn.isTabBarBtn(image: "ic_photo_camera_white_24dp")
    }
    
    @IBAction func clickLibraryBtn(_ sender: Any) {
        print("clickLibraryBtn")
        byCamera = false
        byLibrary = true
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func clickCameraBtn(_ sender: Any) {
        byCamera = true
        byLibrary = false
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "cameraVC") as? cameraVC else { return }
        self.addChildViewController(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
        vc.configureCameraController()
    }
    

    
}

extension uploadVC: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "上傳文件")
    }
}

extension uploadVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        dismiss(animated:true, completion: nil)
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "cameraVC") as? cameraVC else { return }
        self.addChildViewController(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
        vc.image = chosenImage
        vc.photoFromCamera = false
//        vc.beginCropImage(image: vc.image!)
        vc.configureCameraController()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


extension Array where Element: Equatable {
    
    @discardableResult mutating func remove(object: Element) -> Bool {
        if let index = index(of: object) {
            self.remove(at: index)
            return true
        }
        return false
    }
    
    @discardableResult mutating func remove(where predicate: (Array.Iterator.Element) -> Bool) -> Bool {
        if let index = self.index(where: { (element) -> Bool in
            return predicate(element)
        }) {
            self.remove(at: index)
            return true
        }
        return false
    }
    
    
}

extension Array where Array.Element: AnyObject {
    
    func index(ofElement element: Element) -> Int? {
        for (currentIndex, currentElement) in self.enumerated() {
            if currentElement === element {
                return currentIndex
            }
        }
        return nil
    }
    
    
}
