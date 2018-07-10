//
//  SQLiteManager.swift
//  imageEditorWithOpenCV
//
//  Created by 黃恩祐 on 2018/2/20.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import Foundation
import SQLite

class SQLiteManager{

    static let shared: SQLiteManager = SQLiteManager()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    private let db: Connection?
    private let databaseFileName = "i-scan.db"
    private let fileInfoTable = Table("AttFileInfo")
    private let contactsTable = Table("Contacts")

    private let PKey = Expression<String>("PKey")
    private let UserID = Expression<String>("UserID")
    private let UpLoadUserID = Expression<String>("UpLoadUserID")
    private let FileName = Expression<String>("FileName")
    private let FullPath = Expression<String>("FullPath")
    private let FileSize = Expression<Double>("FileSize")
    private let UploadDate = Expression<String>("UploadDate")
    private let UploadDateTime = Expression<String>("UploadDateTime")

    private let ContactID = Expression<String>("ContactID")
    private let ContactName = Expression<String>("ContactName")
    private let isReceiver = Expression<Bool>("isReceiver")

    private init() {
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        do {
            db = try Connection(documentsDirectory.appending("/\(databaseFileName)"))
            print ("open database succeed")
        } catch {
            db = nil
            print ("Unable to open database")
        }
    }

    func createDatebase() -> Bool {
        if createFileInfoTable() && createContactsTable() {
            return true
        }else{
            return false
        }
    }

    func createFileInfoTable() -> Bool {
        var createSucceed = false
        do{
            try db!.run(fileInfoTable.create(ifNotExists: true) { table in
                table.column(PKey, primaryKey: true)
                table.column(UserID, defaultValue: "")
                table.column(UpLoadUserID, defaultValue: "")
                table.column(FileName, defaultValue: "")
                table.column(FullPath, defaultValue: "")
                table.column(FileSize, defaultValue: 0)
                table.column(UploadDate, defaultValue: "")
                table.column(UploadDateTime, defaultValue: "")
            })
            print("create file Table succeed")
            createSucceed = true
        }catch{
            print("Unable to create file table")
            print(error.localizedDescription)
        }
        return createSucceed
    }

    func createContactsTable() -> Bool {
        var createSucceed = false
        do{
            try db!.run(contactsTable.create(ifNotExists: true) { table in
                table.column(UserID, defaultValue: "")
                table.column(ContactID, defaultValue: "")
                table.column(ContactName, defaultValue: "")
                table.column(isReceiver, defaultValue: false)
                table.primaryKey(UserID, ContactID)
            })
            print("create contact Table succeed")
            createSucceed = true
        }catch{
            print("Unable to create contact table")
            print(error.localizedDescription)
        }
        return createSucceed
    }
    
    func deleteFileInfoTable(){
        do{
            try db!.run(fileInfoTable.delete())
            print("delete file Table succeed")
        }catch{
            print("Unable to deletre file table")
            print(error.localizedDescription)
        }
    }


    func insertFileInfo(file: FileInfo) -> Bool {
        do {
            let insert = fileInfoTable.insert(PKey <- file.PKey!,
                                          UserID <- file.UserID!,
                                          UpLoadUserID <- file.UpLoadUserID!,
                                          FileName <- file.FullPath!,
                                          FullPath <- file.FullPath!,
                                          FileSize <- file.FileSize!,
                                          UploadDate <- file.UploadDate!,
                                          UploadDateTime <- file.UploadDateTime!)
            if try db!.run(insert) > 0 {
                return true
            }
        } catch {
            print("Insert file error: \(error.localizedDescription)")
        }
        return false
    }

    func loadFiles(completionHandler: (_ files: [FileInfo]?) -> Void) {
        let select = fileInfoTable.filter(UserID == self.appDelegate.userAccount && UpLoadUserID != self.appDelegate.userAccount)
        var allFiles = [FileInfo]()
        do{
            for aFile in try db!.prepare(select){
                let file = FileInfo(PKey: aFile[PKey],
                                    UserID: aFile[UserID],
                                    UpLoadUserID: aFile[UpLoadUserID],
                                    FileName: aFile[FileName],
                                    FullPath: aFile[FullPath],
                                    FileSize: aFile[FileSize],
                                    UploadDate: aFile[UploadDate],
                                    UploadDateTime: aFile[UploadDateTime])
                allFiles.append(file)
            }
            completionHandler(allFiles)
        }catch{
            print("load files error")
        }
    }

    func getUpdateFiles(completionHandler: (_ files: [FileInfo]?) -> Void) {
        let select = fileInfoTable.filter(UpLoadUserID == self.appDelegate.userAccount)
        var allFiles = [FileInfo]()
        do{
            for aFile in try db!.prepare(select){
                let file = FileInfo(PKey: aFile[PKey],
                                    UserID: aFile[UserID],
                                    UpLoadUserID: aFile[UpLoadUserID],
                                    FileName: aFile[FileName],
                                    FullPath: aFile[FullPath],
                                    FileSize: aFile[FileSize],
                                    UploadDate: aFile[UploadDate],
                                    UploadDateTime: aFile[UploadDateTime])
                allFiles.append(file)
            }
            completionHandler(allFiles)
        }catch{
            print("load files error")
        }
    }

    func loadAFile(pkey: String, completionHandler: (_ files: FileInfo?) -> Void) {
        let select = fileInfoTable.filter( PKey == pkey)
        do{
            for aFile in try db!.prepare(select){
                let file = FileInfo(PKey: aFile[PKey],
                                    UserID: aFile[UserID],
                                    UpLoadUserID: aFile[UpLoadUserID],
                                    FileName: aFile[FileName],
                                    FullPath: aFile[FullPath],
                                    FileSize: aFile[FileSize],
                                    UploadDate: aFile[UploadDate],
                                    UploadDateTime: aFile[UploadDateTime])
                completionHandler(file)
            }
        }catch{
            print("load files error")
        }
    }

    func deleteAFile(pkey: String) -> Bool {
        let select = fileInfoTable.filter( PKey == pkey)
        do{
            let delete = select.delete()
            if try db!.run(delete) > 0 {
                print("delete a file succeed")
                return true
            }
        } catch {
            print("delete a file failed: \(error.localizedDescription)")
        }
        return false

    }

    // Contacts

    func insertContact(contact: Contact) -> Bool {
        do {
            let insert = contactsTable.insert(UserID <- contact.UserID!,
                                              ContactID <- contact.ContactID!,
                                              ContactName <- contact.ContactName!,
                                              isReceiver <- contact.isReceiver)
            if try db!.run(insert) > 0 {
                return true
            }
        } catch {
            print("Insert contact error: \(error.localizedDescription)")
        }
        return false
    }

    func loadAContact(contactID: String, completionHandler: (_ contact: Contact?) -> Void) {
        let select = contactsTable.filter( UserID == self.appDelegate.userAccount && ContactID == contactID)
        do{
            for aContact in try db!.prepare(select){
                let contact = Contact(UserID: aContact[UserID],
                                      ContactID: aContact[ContactID],
                                      ContactName: aContact[ContactName])
                contact.isReceiver = aContact[isReceiver]
                completionHandler(contact)
            }
        }catch{
            print("load contact error")
        }
    }

    func loadContactList(completionHandler: (_ contacts: [Contact]?) -> Void) {
        let select = contactsTable.filter(UserID == self.appDelegate.userAccount)
        var allContacts = [Contact]()
        do{
            for aContact in try db!.prepare(select){
                let contact = Contact(UserID: aContact[UserID],
                                      ContactID: aContact[ContactID],
                                      ContactName: aContact[ContactName])
                contact.isReceiver = aContact[isReceiver]
                allContacts.append(contact)
            }
            completionHandler(allContacts)
        }catch{
            print("load contacts list error")
        }
    }

    func updateAContact(contact: Contact) -> Bool {
        do {
            let select = contactsTable.filter( UserID == self.appDelegate.userAccount && ContactID == contact.ContactID!)

            let update = select.update(UserID <- contact.UserID!,
                                              ContactID <- contact.ContactID!,
                                              ContactName <- contact.ContactName!,
                                              isReceiver <- contact.isReceiver)
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("update contact error: \(error.localizedDescription)")
        }
        return false
    }

}

