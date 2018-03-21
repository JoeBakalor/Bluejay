//
//  SMFileManager.swift
//  RAZR
//
//  Created by Joe Bakalor on 9/12/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

//WINEGARD APP WILL HAVE THE FOLLOWING DIRECTORIES ON TOP OF THE MAIN DIRECTORY
//1. logFiles
//2. firmwareFiles
//3. TBD

import Foundation
class SMFileManager:NSObject
{
    let baseDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    fileprivate var fileManager: FileManager!
    
    //
    func createNewFileIn(directory: URL, with name: String)
    {
        
    }
    
    //
    func deleteFileIn(directory: URL, with name: String)
    {
        
    }
    
    //
    func deleteAllFilesInDirectory(directoryName: String)
    {
        
    }
    
    //
    func createDirectoryAt(directoryName: String)
    {
        let newDirectoryURL = baseDirectory.appendingPathComponent(directoryName)
        
        //  CREATE DIRECTORY IF IT DOESN'T ALREADY EXIST --> THIS SHOULD BE MODIFIED
        do {
            
            try fileManager.createDirectory(at: newDirectoryURL, withIntermediateDirectories: false, attributes: nil)
            print("Created new directory succesfully")
            
        } catch let error as NSError {
            
            print("Failed to create directory with errror = \(error)")
            
        }
    }
    
    //
    func getListOfFilesIn(directory: URL)
    {
        
    }
    
}
