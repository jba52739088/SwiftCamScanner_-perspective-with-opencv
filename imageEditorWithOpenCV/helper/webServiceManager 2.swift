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
    
    func getContractsList(account: String, completionHandler: @escaping (_ ContractsList:  [Contact]?) -> Void) {
        let soapRequest = AEXMLDocument()
        
        let envelopeAttributes = ["xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" :"http://www.w3.org/2001/XMLSchema","xmlns:soap" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: envelopeAttributes)
        let MSQL_SelectData : AEXMLElement = AEXMLElement(name: "MSQL_SelectData", value: "", attributes: ["xmlns":"http://tempuri.org/"])
//        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=i-Scan_test;User Id=iScantest;Password=123abc;")
                let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=LHG;User Id=lhg;Password=eaglec")
        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "SELECT EmplID2 AS ContactID,EmplName2 AS ContactName FROM fn_Data_EmployeeLink() WHERE EmplID='\(account)' ORDER BY EmplName2")
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
                    var contractsList: [Contact] = []
                    let xml = SWXMLHash.parse(xmlString)
                    let DocumentElement = xml["soap:Envelope"]["soap:Body"]["MSQL_SelectDataResponse"]["MSQL_SelectDataResult"]["diffgr:diffgram"]["DocumentElement"]
                    for element in DocumentElement.children {
                        if let ContactID = element["ContactID"].element?.text,
                            let ContactName = element["ContactName"].element?.text {
                            let aContact = Contact(UserID: account, ContactID: ContactID, ContactName: ContactName)
                            contractsList.append(aContact)
                        }
                    }
                    completionHandler(contractsList)
                }
        }
    }
    
    
    func changePassword(account: String, password: String, completionHandler: @escaping (Bool) -> Void) {
        let soapRequest = AEXMLDocument()
        
        let envelopeAttributes = ["xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" :"http://www.w3.org/2001/XMLSchema","xmlns:soap" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: envelopeAttributes)
        let MSQL_SelectData : AEXMLElement = AEXMLElement(name: "MSQL_SelectData", value: "", attributes: ["xmlns":"http://tempuri.org/"])
//        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=i-Scan_test;User Id=iScantest;Password=123abc;")
                let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=LHG;User Id=lhg;Password=eaglec")
        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "UPDATE dbo.Employee SET EmplPassword=N'\(password)' WHERE EmplID='\(account)'")
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
                    let succeedString = xml["soap:Envelope"]["soap:Body"]["MSQL_SelectDataResponse"]["MSQL_SelectDataResult"]["xs:schema"]["xs:element"].description
                    if succeedString == "<xs:element msdata:MainDataTable=\"LHG\" name=\"NewDataSet\" msdata:UseCurrentLocale=\"true\" msdata:IsDataSet=\"true\"><xs:complexType><xs:choice minOccurs=\"0\" maxOccurs=\"unbounded\"><xs:element msprop:TableName=\"LHG\" name=\"LHG\" msprop:strSQL=\"UPDATE dbo.Employee SET EmplPassword=N\'\(password)\' WHERE EmplID=\'\(account)\'\"><xs:complexType></xs:complexType></xs:element></xs:choice></xs:complexType></xs:element>" {
                        completionHandler(true)
                    }else {
                        completionHandler(false)
                    }
                    
                }
        }
    }
    
    
    func willAutoPrintFile(account: String, completionHandler: @escaping (Bool) -> Void) {
        let soapRequest = AEXMLDocument()
        
        let envelopeAttributes = ["xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" :"http://www.w3.org/2001/XMLSchema","xmlns:soap" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: envelopeAttributes)
        let MSQL_SelectData : AEXMLElement = AEXMLElement(name: "MSQL_SelectData", value: "", attributes: ["xmlns":"http://tempuri.org/"])
//        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=i-Scan_test;User Id=iScantest;Password=123abc;")
                let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=LHG;User Id=lhg;Password=eaglec")
//        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "UPDATE AttFileInfo SET IsBeDown=1, IsReceBeDel=1 WHERE UserID='\(account)' AND IsBeDown=0")
        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "UPDATE AttFileInfo SET IsBeDown=1 WHERE UserID='\(account)' AND IsBeDown=0")
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
                    let succeedString = xml["soap:Envelope"]["soap:Body"]["MSQL_SelectDataResponse"]["MSQL_SelectDataResult"]["xs:schema"]["xs:element"].description
                    if succeedString == "<xs:element msdata:MainDataTable=\"LHG\" name=\"NewDataSet\" msdata:UseCurrentLocale=\"true\" msdata:IsDataSet=\"true\"><xs:complexType><xs:choice minOccurs=\"0\" maxOccurs=\"unbounded\"><xs:element msprop:TableName=\"LHG\" name=\"LHG\" msprop:strSQL=\"UPDATE AttFileInfo SET IsBeDown=1 WHERE UserID=\'\(account)\' AND IsBeDown=0\"><xs:complexType></xs:complexType></xs:element></xs:choice></xs:complexType></xs:element>" {
                        completionHandler(true)
                    }else {
                        completionHandler(false)
                    }
                    
                }
        }
    }
    
    func willAutoPrintFile(PKey: String, completionHandler: @escaping (Bool) -> Void) {
        let soapRequest = AEXMLDocument()
        
        let envelopeAttributes = ["xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" :"http://www.w3.org/2001/XMLSchema","xmlns:soap" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: envelopeAttributes)
        let MSQL_SelectData : AEXMLElement = AEXMLElement(name: "MSQL_SelectData", value: "", attributes: ["xmlns":"http://tempuri.org/"])
        //        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=i-Scan_test;User Id=iScantest;Password=123abc;")
        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=LHG;User Id=lhg;Password=eaglec")
        //        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "UPDATE AttFileInfo SET IsBeDown=1, IsReceBeDel=1 WHERE UserID='\(account)' AND IsBeDown=0")
        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "UPDATE AttFileInfo SET IsBeDown=1 WHERE PKey='\(PKey)'")
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
                    let succeedString = xml["soap:Envelope"]["soap:Body"]["MSQL_SelectDataResponse"]["MSQL_SelectDataResult"]["xs:schema"]["xs:element"].description
                    if succeedString == "<xs:element msdata:MainDataTable=\"LHG\" name=\"NewDataSet\" msdata:UseCurrentLocale=\"true\" msdata:IsDataSet=\"true\"><xs:complexType><xs:choice minOccurs=\"0\" maxOccurs=\"unbounded\"><xs:element msprop:TableName=\"LHG\" name=\"LHG\" msprop:strSQL=\"UPDATE AttFileInfo SET IsBeDown=1 WHERE PKey=\'\(PKey)\' \"><xs:complexType></xs:complexType></xs:element></xs:choice></xs:complexType></xs:element>" {
                        completionHandler(true)
                    }else {
                        completionHandler(false)
                    }
                    
                }
        }
    }
    
    func willDeleteLocalFile(PKey: String, completionHandler: @escaping (Bool) -> Void) {
        let soapRequest = AEXMLDocument()
        
        let envelopeAttributes = ["xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" :"http://www.w3.org/2001/XMLSchema","xmlns:soap" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: envelopeAttributes)
        let MSQL_SelectData : AEXMLElement = AEXMLElement(name: "MSQL_SelectData", value: "", attributes: ["xmlns":"http://tempuri.org/"])
        //        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=i-Scan_test;User Id=iScantest;Password=123abc;")
        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=LHG;User Id=lhg;Password=eaglec")
        //        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "UPDATE AttFileInfo SET IsBeDown=1, IsReceBeDel=1 WHERE UserID='\(account)' AND IsBeDown=0")
        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "UPDATE AttFileInfo SET IsReceBeDel=1 WHERE PKey='\(PKey)'")
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
                    let succeedString = xml["soap:Envelope"]["soap:Body"]["MSQL_SelectDataResponse"]["MSQL_SelectDataResult"]["xs:schema"]["xs:element"].description
                    if succeedString == "<xs:element msdata:MainDataTable=\"LHG\" name=\"NewDataSet\" msdata:UseCurrentLocale=\"true\" msdata:IsDataSet=\"true\"><xs:complexType><xs:choice minOccurs=\"0\" maxOccurs=\"unbounded\"><xs:element msprop:TableName=\"LHG\" name=\"LHG\" msprop:strSQL=\"UPDATE AttFileInfo SET IsReceBeDel=1 WHERE PKey=\'\(PKey)\'\"><xs:complexType></xs:complexType></xs:element></xs:choice></xs:complexType></xs:element>" {
                        completionHandler(true)
                    }else {
                        completionHandler(false)
                    }
                    
                }
        }
    }

    func willDeleteLocalDiduploadFile(PKey: String, completionHandler: @escaping (Bool) -> Void) {
        let soapRequest = AEXMLDocument()
        
        let envelopeAttributes = ["xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" :"http://www.w3.org/2001/XMLSchema","xmlns:soap" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: envelopeAttributes)
        let MSQL_SelectData : AEXMLElement = AEXMLElement(name: "MSQL_SelectData", value: "", attributes: ["xmlns":"http://tempuri.org/"])
        //        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=i-Scan_test;User Id=iScantest;Password=123abc;")
        let strConnStr : AEXMLElement = AEXMLElement(name: "strConnStr", value: "Data Source=61.56.222.118;Initial Catalog=LHG;User Id=lhg;Password=eaglec")
        //        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "UPDATE AttFileInfo SET IsBeDown=1, IsReceBeDel=1 WHERE UserID='\(account)' AND IsBeDown=0")
        let strSQL : AEXMLElement = AEXMLElement(name: "strSQL", value: "UPDATE AttFileInfo SET IsPostBeDel=1 WHERE PKey='\(PKey)'")
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
                    let succeedString = xml["soap:Envelope"]["soap:Body"]["MSQL_SelectDataResponse"]["MSQL_SelectDataResult"]["xs:schema"]["xs:element"].description
                    if succeedString == "<xs:element msdata:MainDataTable=\"LHG\" name=\"NewDataSet\" msdata:UseCurrentLocale=\"true\" msdata:IsDataSet=\"true\"><xs:complexType><xs:choice minOccurs=\"0\" maxOccurs=\"unbounded\"><xs:element msprop:TableName=\"LHG\" name=\"LHG\" msprop:strSQL=\"UPDATE AttFileInfo SET IsPostBeDel=1 WHERE PKey=\'\(PKey)\'\"><xs:complexType></xs:complexType></xs:element></xs:choice></xs:complexType></xs:element>" {
                        completionHandler(true)
                    }else {
                        completionHandler(false)
                    }
                    
                }
        }
    }
}

   
