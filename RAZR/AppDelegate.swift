 //
//  AppDelegate.swift
//  RAZR
//
//  Created by Joe Bakalor on 5/25/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var managedObjectModel: NSManagedObjectModel?
    var managedObjectContext: NSManagedObjectContext?
    var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    //@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
    //@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
    //@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
    var window: UIWindow?
    var oldFilePath: URL?
    var newFilePath: URL?


    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().barTintColor = UIColor.winegardBlue//(red: 0, green: 0/255, blue: 205/255, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
       // self.saveContext()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        createFirmwareDirectory()
        let fileManager = FileManager.default
        var documentPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        let inboxPath = documentPaths[0].appendingPathComponent("Inbox")
        let oldFilePath = inboxPath.appendingPathComponent(url.lastPathComponent)
        print("Old File Path = \(oldFilePath)")
        
        let theFileName = (url.deletingPathExtension()).lastPathComponent
        let newFilePath = documentPaths[0].appendingPathComponent("\(theFileName).cyacd")
                
        
        if !fileManager.fileExists(atPath: "\(newFilePath)"){ //== nil{
            do {
                try fileManager.copyItem(at: oldFilePath, to: newFilePath)//(at: oldFilePath, to: newFilePath)
                print("NEW FILE TO INSERT")
            } catch {
                //print("did not work")
            }
        } else {
            print("file present already") //so we need to remove it
        }
        
        //THIS IS THE ONE
        do {
            let testTwo = try String(contentsOf: newFilePath)
            print("File as String = \(testTwo)")
        } catch {
            print("Didnt work \(error)")
        }
        
        do { try fileManager.removeItem(at: oldFilePath); print("Removed old file!")} catch { print("Could not remove old file") }
        
        return true
    }

    func createFirmwareDirectory()
    {
        let fileManager = FileManager.default
        let DocumentDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let firmwareUpdateFilesDirectoryUrl = DocumentDirectoryURL.appendingPathComponent("firmwareUpdates")
        //logFileDirectoryPath = logFilesDirectoryUrl
        
        //  CREATE DIRECTORY IF IT DOESN'T ALREADY EXIST --> THIS SHOULD BE MODIFIED
        do {
            try fileManager.createDirectory(at: firmwareUpdateFilesDirectoryUrl, withIntermediateDirectories: false, attributes: nil)
            print("Created new directory succesfully")
            
        } catch let error as NSError {
            
            print("Failed to create directory with errror = \(error)")
        }
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "RAZR")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    static var persistantContainer: NSPersistentContainer{
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    static var viewContext: NSManagedObjectContext{
        return persistantContainer.viewContext
    }
    
    //let coreDataContainer = AppDelegate.persistantContainer
    //let context = AppDelegate.viewContext
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    

}

