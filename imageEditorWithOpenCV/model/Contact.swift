//
//  Contact.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/5/1.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import Foundation

class Contact: NSObject {
    
    var UserID: String?
    var ContactID: String?
    var ContactName: String?
    var isReceiver: Bool = false
    
    init(UserID: String, ContactID: String, ContactName: String) {
        self.UserID = UserID
        self.ContactID = ContactID
        self.ContactName = ContactName
    }
}
