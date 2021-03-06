//
//  ChangeManager.swift
//  trySwift
//
//  Created by Natasha Murashev on 8/17/16.
//  Copyright © 2016 NatashaTheRobot. All rights reserved.
//

import RealmSwift
import CloudKit

struct ChangeManager {
    
    static let lastChangedDataNotification = "LastChangedDataNotification"
    
    static func syncChanges() {
        let defaults = NSUserDefaults.standardUserDefaults()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let publicDB = CKContainer.defaultContainer().publicCloudDatabase
            guard let lastChangeDate = defaults.objectForKey(ChangeManager.lastChangedDataNotification) as? NSDate else {
                let appSubmitionDate = NSDate.date(year: 2016, month: 8, day: 16, hour: 5, minute: 0, second: 0)
                defaults.setObject(appSubmitionDate, forKey: ChangeManager.lastChangedDataNotification)
                return
            }
            
            let predicate = NSPredicate(format: "creationDate > %@", lastChangeDate)
            let query = CKQuery(recordType: "Change", predicate: predicate)
            publicDB.performQuery(query, inZoneWithID: nil) { result, error in
                
                guard let result = result else {
                    // will update again on future launch
                    return
                }
                
                result.forEach {
                    updateRecord($0)
                }
                defaults.setObject(NSDate(), forKey: ChangeManager.lastChangedDataNotification)
            }
        }
    }
    
    static func syncWatchChanges() {
        let defaults = NSUserDefaults.standardUserDefaults()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let publicDB = CKContainer.defaultContainer().publicCloudDatabase
            guard let lastChangeDate = defaults.objectForKey(WatchSessionManager.watchDataUpdatedNotification) as? NSDate else {
                let appSubmitionDate = NSDate.date(year: 2016, month: 8, day: 16, hour: 5, minute: 0, second: 0)
                defaults.setObject(appSubmitionDate, forKey: WatchSessionManager.watchDataUpdatedNotification)
                return
            }
            
            let predicate = NSPredicate(format: "creationDate > %@", lastChangeDate)
            let query = CKQuery(recordType: "Change", predicate: predicate)
            publicDB.performQuery(query, inZoneWithID: nil) { result, error in
                
                guard let result = result else {
                    // will update again on future launch
                    return
                }
                
                guard !result.isEmpty else { return }
                
                var changes = [[String: AnyObject]]()
                
                result.forEach {
                    guard let creationDate = $0.creationDate,
                        let object = $0["object"] as? String,
                        let id = $0["id"] as? Int,
                        let field = $0["field"] as? String,
                        let newValue = $0["newValue"] as? String else {
                            return
                    }
                    
                    let changeDict: [String : AnyObject] = [
                        "creationDate" : creationDate,
                        "object": object,
                        "id": id,
                        "field": field,
                        "newValue": newValue]
                    
                    if field == "imagePath" {
                        guard let imageAsset = $0["image"] as? CKAsset else { return }
                        WatchSessionManager.sharedManager.transferFile(imageAsset.fileURL, metadata: changeDict)
                    } else {
                        changes.append(changeDict)
                        WatchSessionManager.sharedManager.transferUserInfo(["changes" : changes])
                    }
                }
            }
        }
    }
}

private extension ChangeManager {
    
    static func updateRecord(record: CKRecord) {
        guard let object = record["object"] as? String,
            let id = record["id"] as? Int,
            let field = record["field"] as? String,
            let newValue = record["newValue"] as? String else {
                return
        }
        
        
        let realm = try! Realm()
        if object == "Speaker" {
            if let speaker = realm.objects(Speaker).filter("id == \(id)").first {
                if field == "imagePath" {
                    guard let imageAsset = record["image"] as? CKAsset else {
                        return
                    }
                    
                    try! realm.write {
                        speaker["imageName"] = nil
                        speaker[field] = imageAsset.fileURL.path
                    }
                    
                } else {
                    try! realm.write {
                        speaker[field] = newValue
                    }
                }
            }
        } else if object == "Presentation" {
            if let presentation = realm.objects(Presentation).filter("id == \(id)").first {
                try! realm.write {
                    presentation[field] = newValue
                }
            }
        }
    }
}
