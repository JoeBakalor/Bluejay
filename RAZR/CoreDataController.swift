//
//  CoreDataController.swift
//  RAZR
//
//  Created by Joe Bakalor on 9/15/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController: NSObject
{
    public enum RetrievByOptions{
        case location
        case physicalChannel
        case callSign
        case id
    }
    
    //SEARCH DATABASE FOR TOWER ENTRY MATCHING THE SEARCH PARAMETER
    func retrieveTowerEntryUsing(retrieveByOption: RetrievByOptions, optionValue: String) -> Tower?
    {
        print("option parmeter = \(optionValue)")
        var towerEntryInDB: Tower?
        let context = AppDelegate.viewContext

        //CHECK IF TOWER EXISTS
        let request: NSFetchRequest<Tower> = Tower.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "location", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        
        let predicate = predicateFor(retrieveByOption: retrieveByOption, optionValue: optionValue)//NSPredicate(format: "physicalChannel = %@", "\(recievedChannelDataArrayLocalCopy[indexPath.row].channel)")
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]

        //SUBMIT FETCH REQUEST
        let towerDataBaseEntry = try? context.fetch(request)

        //CHECK IF NIL
        if let towerDataFromDatabase = towerDataBaseEntry{
            print("NUMBER OF MATCHING ENTRIES FOUND = \(towerDataFromDatabase.count)")
            if towerDataFromDatabase.count == 1{
                towerEntryInDB = towerDataFromDatabase[0]
                
            } else if towerDataFromDatabase.count > 1{
                print("More than one entry found")
                print("Entries = \(towerDataFromDatabase)")
                var newest = towerDataFromDatabase.first?.dateRetrieved
                print("Newest = \(newest!)")
                towerEntryInDB = towerDataFromDatabase.first
                
                for entry in towerDataFromDatabase{
                    if newest! < entry.dateRetrieved!{
                        print("old entry is \(newest!) is less than \(entry.dateRetrieved!)")
                    }
                }
            }
        }
        
        return towerEntryInDB
    }
    
    //
    func predicateFor(retrieveByOption: RetrievByOptions, optionValue: String) -> NSPredicate
    {
        switch retrieveByOption
        {
        case .callSign:
            return NSPredicate(format: "callSign = %@", "\(optionValue)")
        case .location:
            return NSPredicate(format: "location = %@", "\(optionValue)")
        case.physicalChannel:
            return NSPredicate(format: "physicalChannel = %@", "\(optionValue)")
        case .id:
            return NSPredicate(format: "id = %@", "\(optionValue)")
        }
    }
    
}
