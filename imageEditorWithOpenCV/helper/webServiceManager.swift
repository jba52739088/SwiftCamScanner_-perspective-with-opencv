//
//  webServiceManager.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/2/21.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SWXMLHash
import StringExtensionHTML
import AEXML
import Kingfisher

extension UIViewController {
    
    func getFileShouldDownloadData(userID: String, completionHandler: @escaping () -> Void){
        
        let soapRequest = AEXMLDocument()
        
        let envelopeAttributes = ["xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" :"http://www.w3.org/2001/XMLSchema","xmlns:soap" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: envelopeAttributes)
        let MSQL_SelectData : AEXMLElement = AEXMLElement(name: "MSQL_SelectData", value: "", attributes: ["xmlns":"http://tempuri.org/"])
//        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=i-Scan_test;User Id=iScantest;Password=123abc;")
                let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=LHG;User Id=lhg;Password=eaglec")
        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "SELECT PKey, UpLoadUserID, WebPath, UploadDateTime, IsBeDown FROM AttFileInfo WHERE IsReceBeDel=0 AND UserID='\(userID)' ORDER BY UploadDateTime DESC")
//        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "SELECT * FROM AttFileInfo WHERE UserID='\(userID)' AND IsBeDown=0 ORDER BY UploadDateTime ASC")
        MSQL_SelectData.addChild(strConnStr)
        MSQL_SelectData.addChild(strSQL)
        let body = envelope.addChild(name: "soap:Body")
        body.addChild(MSQL_SelectData)
        //        print(soapRequest.xml)
        let soapLenth = String(soapRequest.xml.count)
        let theURL = URL(string: "http://61.56.222.118/LHGWS/LHGWS.asmx")
        
        var serverRequest = URLRequest(url: theURL!)
        serverRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        serverRequest.addValue(soapLenth, forHTTPHeaderField: "Content-Length")
        serverRequest.addValue("http://tempuri.org/MSQL_SelectData", forHTTPHeaderField: "SOAPAction")
        serverRequest.addValue("61.56.222.118", forHTTPHeaderField: "Host")
        serverRequest.httpMethod = "POST"
        serverRequest.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        
        Alamofire.request(serverRequest)
            .responseString { response in
                if let xmlString = response.result.value {
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reload_files_list"), object: nil, userInfo: nil))
                    //                    print("xmlString: \(xmlString)")
                    let xml = SWXMLHash.parse(xmlString)
                    //                    print("xml: \(xml)")
                    let DocumentElement = xml["soap:Envelope"]["soap:Body"]["MSQL_SelectDataResponse"]["MSQL_SelectDataResult"]["diffgr:diffgram"]["DocumentElement"]
                    for element in DocumentElement.children {
                        if let PKey = element["PKey"].element?.text,
                            let UpLoadUserID = element["UpLoadUserID"].element?.text,
                            let IsBeDown = element["IsBeDown"].element?.text,
                            let WebPath = element["WebPath"].element?.text,
                            let FileName = WebPath.components(separatedBy: "/").last,
                            let UploadDateTime = element["UploadDateTime"].element?.text,
                            let UploadDate = UploadDateTime.components(separatedBy: " ").first{
                            
                            let afile = FileInfo(PKey: PKey, UserID: userID, UpLoadUserID: UpLoadUserID, FileName: FileName, FullPath: WebPath, FileSize: 0, UploadDate: UploadDate, UploadDateTime: UploadDateTime)
                            
                            if let imageURL = URL(string: "http://61.56.222.118" + WebPath){
                                ImageDownloader.default.downloadImage(with: imageURL, options: [], progressBlock: nil) {
                                    (aImage, error, url, data) in
                                    guard let image = aImage else { print("download image error"); return}
                                    //                                    print("Downloaded Image: \(image)")
                                    do {
                                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                        let fileURL = documentsURL.appendingPathComponent(FileName)
                                        if let pngImageData = UIImagePNGRepresentation(image) {
                                            try pngImageData.write(to: fileURL, options: .atomic)
                                            //                                            print("fileURL: \(fileURL)")
                                            afile.FullPath = FileName
                                            if SQLiteManager.shared.insertFileInfo(file: afile){ }
                                            if (UIApplication.shared.delegate as! AppDelegate).isAutoPrint && IsBeDown == "false" && (UIApplication.shared.delegate as! AppDelegate).isPrinting == false {
                                                self.printNow(image, completionHandler: {
                                                    (UIApplication.shared.delegate as! AppDelegate).isPrinting = true
                                                    self.willAutoPrintFile(PKey: afile.PKey!, completionHandler: { (isSucceed) in
                                                        if isSucceed {
                                                            print("isSucceed")
                                                            (UIApplication.shared.delegate as! AppDelegate).isPrinting = false
                                                        }
                                                    })
                                                })
                                            }
                                        }
                                    } catch {
                                        print("save image error")
                                    }
                                }
                            }
                        }
                    }
                    
                    completionHandler()
                }else{
                    print("error fetching XML")
                }
        }
    }
    
    func uploadDataToServer(userID: String, data: String, strReceiverId: String, fileName: String, completionHandler: @escaping () -> Void){
        let soapRequest = AEXMLDocument()
        let envelopeAttributes = ["xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" :"http://www.w3.org/2001/XMLSchema","xmlns:soap" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: envelopeAttributes)
        let OneFileUpload_M : AEXMLElement = AEXMLElement(name: "OneFileUpload2_M", value: "", attributes: ["xmlns":"http://tempuri.org/"])
//        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=i-Scan_test;User Id=iScantest;Password=123abc;")
                let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=LHG;User Id=lhg;Password=eaglec")
        let fs : AEXMLElement = AEXMLElement(name: "fs", value: data)
        let strDBName : AEXMLElement = AEXMLElement(name: "strDBName", value: "iScan_M")
        let strReceiverID : AEXMLElement = AEXMLElement(name: "strReceiverID", value: strReceiverId)
        let strUUserID : AEXMLElement = AEXMLElement(name: "strUUserID", value: "\(userID)")
        let fileName : AEXMLElement = AEXMLElement(name: "fileName", value: fileName)
        let strCCFromID : AEXMLElement = AEXMLElement(name: "strCCFromID", value: strReceiverId)
        OneFileUpload_M.addChild(fs)
        OneFileUpload_M.addChild(strConnStr)
        OneFileUpload_M.addChild(strDBName)
        OneFileUpload_M.addChild(strReceiverID)
        OneFileUpload_M.addChild(strUUserID)
        OneFileUpload_M.addChild(fileName)
        OneFileUpload_M.addChild(strCCFromID)
        let body = envelope.addChild(name: "soap:Body")
        body.addChild(OneFileUpload_M)
        //                print(soapRequest.xml)
        let soapLenth = String(soapRequest.xml.count)
        let theURL = URL(string: "http://61.56.222.118/LHGWS/LHGWS.asmx")
        
        var serverRequest = URLRequest(url: theURL!)
        serverRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        serverRequest.addValue(soapLenth, forHTTPHeaderField: "Content-Length")
        serverRequest.addValue("http://tempuri.org/OneFileUpload2_M", forHTTPHeaderField: "SOAPAction")
        serverRequest.addValue("61.56.222.118", forHTTPHeaderField: "Host")
        serverRequest.httpMethod = "POST"
        serverRequest.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        
        Alamofire.request(serverRequest)
            .responseString { response in
                print("response: \(response)")
                if let xmlString = response.result.value {
                    let xml = SWXMLHash.parse(xmlString)
                    let DocumentElement = xml["soap:Envelope"]["soap:Body"]["OneFileUpload2_MResponse"]
                    if let OneFileUpload_MResult = DocumentElement["OneFileUpload2_MResult"].element?.text{
                        print("OneFileUpload2_MResult: \(OneFileUpload_MResult)")
                        
                        self.getFileDidUploadData(userID: userID)
                        completionHandler()
                    }
                }else{
                    print("error fetching XML")
                }
                
                
        }
    }
    
    
    
    
    
    func getFileDidUploadData(userID: String){

        let soapRequest = AEXMLDocument()

        let envelopeAttributes = ["xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" :"http://www.w3.org/2001/XMLSchema","xmlns:soap" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: envelopeAttributes)
        let MSQL_SelectData : AEXMLElement = AEXMLElement(name: "MSQL_SelectData", value: "", attributes: ["xmlns":"http://tempuri.org/"])
//        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=i-Scan_test;User Id=iScantest;Password=123abc;")
                let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=LHG;User Id=lhg;Password=eaglec")
        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "SELECT PKey, UserID, WebPath, UploadDateTime FROM AttFileInfo WHERE IsPostBeDel=0 AND UpLoadUserID='\(userID)' ORDER BY UploadDateTime DESC")
        MSQL_SelectData.addChild(strConnStr)
        MSQL_SelectData.addChild(strSQL)
        let body = envelope.addChild(name: "soap:Body")
        body.addChild(MSQL_SelectData)
        //        print(soapRequest.xml)
        let soapLenth = String(soapRequest.xml.count)
        let theURL = URL(string: "http://61.56.222.118/LHGWS/LHGWS.asmx")

        var serverRequest = URLRequest(url: theURL!)
        serverRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        serverRequest.addValue(soapLenth, forHTTPHeaderField: "Content-Length")
        serverRequest.addValue("http://tempuri.org/MSQL_SelectData", forHTTPHeaderField: "SOAPAction")
        serverRequest.addValue("61.56.222.118", forHTTPHeaderField: "Host")
        serverRequest.httpMethod = "POST"
        serverRequest.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)

        Alamofire.request(serverRequest)
            .responseString { response in
                if let xmlString = response.result.value {
                    //                    print("xmlString: \(xmlString)")
                    let xml = SWXMLHash.parse(xmlString)
                    //                    print("xml: \(xml)")
                    let DocumentElement = xml["soap:Envelope"]["soap:Body"]["MSQL_SelectDataResponse"]["MSQL_SelectDataResult"]["diffgr:diffgram"]["DocumentElement"]
                    for element in DocumentElement.children {
                        if let PKey = element["PKey"].element?.text,
                            let UserID = element["UserID"].element?.text,
                            let WebPath = element["WebPath"].element?.text,
                            let FileName = WebPath.components(separatedBy: "/").last,
                            let UploadDateTime = element["UploadDateTime"].element?.text,
                            let UploadDate = UploadDateTime.components(separatedBy: " ").first{
                            let afile = FileInfo(PKey: PKey, UserID: UserID, UpLoadUserID: userID, FileName: FileName, FullPath: WebPath, FileSize: 0, UploadDate: UploadDate, UploadDateTime: UploadDateTime)

                            if let imageURL = URL(string: "http://61.56.222.118" + WebPath){
                                ImageDownloader.default.downloadImage(with: imageURL, options: [], progressBlock: nil) {
                                    (aImage, error, url, data) in
                                    guard let image = aImage else { print("download image error"); return}
                                    //                                    print("Downloaded Image: \(image)")
                                    do {
                                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                        let fileURL = documentsURL.appendingPathComponent(FileName)
                                        if let jpgImageData = UIImageJPEGRepresentation(image, 1) {
                                            try jpgImageData.write(to: fileURL, options: .atomic)
                                            //                                            print("fileURL: \(fileURL)")
                                            afile.FullPath = FileName
                                            if !SQLiteManager.shared.insertFileInfo(file: afile){
                                                print("insert file data error")
                                            }
                                            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reload_files_list"), object: nil, userInfo: nil))
                                        }
                                    } catch {
                                        print("save image error")
                                    }
                                }
                            }
                        }
                    }
                }else{
                    print("error fetching XML")
                }
        }
    }
    
    
    
    
    
    
    
    
    func loginRequest(account: String, password: String, completionHandler: @escaping (_ loginSucceed: Bool?) -> Void) {
        let soapRequest = AEXMLDocument()
        
        let envelopeAttributes = ["xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" :"http://www.w3.org/2001/XMLSchema","xmlns:soap" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: envelopeAttributes)
        let MSQL_SelectData : AEXMLElement = AEXMLElement(name: "MSQL_SelectData", value: "", attributes: ["xmlns":"http://tempuri.org/"])
//        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=i-Scan_test;User Id=iScantest;Password=123abc;")
        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=LHG;User Id=lhg;Password=eaglec")
        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "SELECT * FROM dbo.Employee WHERE EmplID='\(account)' AND EmplPassword='\(password)' AND IsMobilePhone=1")
        MSQL_SelectData.addChild(strConnStr)
        MSQL_SelectData.addChild(strSQL)
        let body = envelope.addChild(name: "soap:Body")
        body.addChild(MSQL_SelectData)
        let theURL = URL(string: "http://61.56.222.118/LHGWS/LHGWS.asmx")
        
        var serverRequest = URLRequest(url: theURL!)
        serverRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        serverRequest.addValue("http://tempuri.org/MSQL_SelectData", forHTTPHeaderField: "SOAPAction")
        serverRequest.addValue("61.56.222.118", forHTTPHeaderField: "Host")
        serverRequest.httpMethod = "POST"
        serverRequest.httpBody = soapRequest.xml.data(using: String.Encoding.utf8)
        
        Alamofire.request(serverRequest)
            .responseString { response in
                if let xmlString = response.result.value {
                    let xml = SWXMLHash.parse(xmlString)
                    let DocumentElement = xml["soap:Envelope"]["soap:Body"]["MSQL_SelectDataResponse"]["MSQL_SelectDataResult"]["diffgr:diffgram"]["DocumentElement"].element
                    if DocumentElement != nil {
                        if let display = xml["soap:Envelope"]["soap:Body"]["MSQL_SelectDataResponse"]["MSQL_SelectDataResult"]["diffgr:diffgram"]["DocumentElement"]["LHG"]["DisplayName"].element?.text {
                            (UIApplication.shared.delegate as! AppDelegate).userDisplayName = display
                        }
                        completionHandler(true)
                    }else{
                        
                        completionHandler(false)
                    }
                }
        }
    }
    
    
    
    func showError(title: String?, body: String?) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


