//
//  filePageVC.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/2/22.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class filePageVC: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var printerBtn: UIButton!
    
    var file: FileInfo?
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    var isForDownload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgView.contentMode = .scaleAspectFit
        loadImgFromFile()
        self.printerBtn.isUserInteractionEnabled = true
        if !isForDownload {
            self.printerBtn.isHidden = true
            self.printerBtn.isUserInteractionEnabled = false
        }
    }
    
    
    @IBAction func doPrint(_ sender: Any) {
        guard let image = self.imgView.image else { return }
        self.printNow(image) {
            //
        }
    }
    
    
    func loadImgFromFile() {
        guard let file = self.file else { return }
        self.imgView.image = load(fileName: file.FileName!)
//        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom))
//        self.imgView.addGestureRecognizer(gesture)
        self.imgView.isUserInteractionEnabled = true
        let zoomGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imgView.addGestureRecognizer(zoomGesture)
        self.imgView.addGestureRecognizer(panGesture)
    }
    
    private func load(fileName: String) -> UIImage? {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        print("fileURL: \(fileURL)")
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    @objc private func pinchHandler(gesture: UIPinchGestureRecognizer) {
        if let view = gesture.view {
            
            switch gesture.state {
            case .changed:
                let pinchCenter = CGPoint(x: gesture.location(in: view).x - view.bounds.midX,
                                          y: gesture.location(in: view).y - view.bounds.midY)
                let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: gesture.scale, y: gesture.scale)
                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                view.transform = transform
                gesture.scale = 1
            case .ended:
                return
            default:
                return
            }
            
            
        }
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            let translation = gestureRecognizer.translation(in: self.view)
            // note: 'view' is optional and need to be unwrapped
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        }
    }
}

extension UIViewController {
    
    func printNow(_ image: UIImage, completionHandler: @escaping () -> Void){
        let controller = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .photoGrayscale//.photo
        printInfo.jobName = "Testprint";
        printInfo.duplex = .none
        controller.printingItem = image
        controller.showsPaperSelectionForLoadedPapers = false
        (UIApplication.shared.delegate as! AppDelegate).isPrinting = true
        controller.present(animated: true) { (controller, completed, error) in
            if (!completed && (error != nil)) {
                print("FAILED! due to error \(error.debugDescription)")
                (UIApplication.shared.delegate as! AppDelegate).isPrinting = false
            }
            print("Completed: \(completed)")
            if completed {
                completionHandler()
            }else {
                (UIApplication.shared.delegate as! AppDelegate).isPrinting = false
            }
            
        }
    }

}
