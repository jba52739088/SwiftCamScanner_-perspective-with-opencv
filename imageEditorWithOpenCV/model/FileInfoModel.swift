//
//  FileInfoModel.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/2/21.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import Foundation

class FileInfo: NSObject {
    
    var PKey: String?
    var UserID: String?
    var UpLoadUserID: String?
    var FileName: String?
    var FullPath: String?
    var FileSize: Double?
    var UploadDate: String?
    var UploadDateTime: String?
    
    init(PKey: String, UserID: String, UpLoadUserID: String, FileName: String, FullPath: String, FileSize: Double, UploadDate: String, UploadDateTime: String) {
        self.PKey = PKey
        self.UserID = UserID
        self.UpLoadUserID = UpLoadUserID
        self.FileName = FileName
        self.FullPath = FullPath
        self.FileSize = FileSize
        self.UploadDate = UploadDate
        self.UploadDateTime = UploadDateTime
    }
}
