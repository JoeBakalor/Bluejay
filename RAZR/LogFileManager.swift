//
//  LogFileManager.swift
//  RAZR
//
//  Created by Joe Bakalor on 8/18/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
var selectedFileUrl: URL!
//NOTIFCATION DEFINES
let CANT_DELETE_CURRENT_LOG_FILE = Notification.Name(rawValue: "triedToDeleteCurrentLogFile")

//============================== BASE CLASS =======================================
class LogFileManager: NSObject, FileManagerDelegate
{
    fileprivate var fileManager: FileManager!
    var currentSystemLogFilePath: URL!
    var logFileDirectoryPath: URL!

    
    enum LogFileType{
        case systemLog
        case spectrumAnalyzerLog
        case channelLog
    }
    
    struct LogFileConfiguration{
        var name = "Blank"
        //var
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    override init()
    {
        super.init()
        fileManager = FileManager.default
        let documentPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        print("Document Paths in userDomain = \(documentPaths)")
        //createNewFileWithName(name: "SYS_LOG\(Date())")
    }
}

//============================== =======================================
extension LogFileManager
{
    /******************************************************************************/
    //  CREATE NEW FILE FOR CURRENT TIME, CREATE DIRECTORY IF IT DOESNT ALREADY EXIST
    /******************************************************************************/
    func createNewFileWithName(name: String)
    {
        let fileName = name
        let DocumentDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let logFilesDirectoryUrl = DocumentDirectoryURL.appendingPathComponent("logFiles")
        logFileDirectoryPath = logFilesDirectoryUrl
        let fileURL = logFilesDirectoryUrl.appendingPathComponent(fileName).appendingPathExtension("txt")
        currentSystemLogFilePath = fileURL

        //  CREATE DIRECTORY IF IT DOESN'T ALREADY EXIST --> THIS SHOULD BE MODIFIED
        do {
            try fileManager.createDirectory(at: logFilesDirectoryUrl, withIntermediateDirectories: false, attributes: nil)
            print("Created new directory succesfully")
                
        } catch let error as NSError {
            
            print("Failed to create directory with errror = \(error)")
        }
        
        print("FILE_MANAGER File Path: \(fileURL)")
        
        let writeString = "SYSTEM LOG FILE CREATED @\(Date().formatted)"
        
        //  CREATE NEW SYS LOG FILE IN NEW DIRECTORY
        do {
            
            try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            
        } catch let error as NSError {
            
            print("Failed to write file to URL")
            print(error)
        }
        
    }
    
    /******************************************************************************/
    //  SET SELECTED FILE
    /******************************************************************************/
    func setSelectedFile(fileName: String)
    {
        selectedFileUrl = logFileDirectoryPath.appendingPathComponent(fileName)//.appendingPathExtension("txt")
    }
    
    /******************************************************************************/
    //  RETRIVE FILE CONTENTS FOR CURRENTLY SELECTED FILE
    /******************************************************************************/
    func getContentForSelectedFile() -> String
    {
        var fileContent: String = "ERROR READING FILE"
        
        do {
            print("File URL: \(selectedFileUrl)")
            let fileContentString = try String(contentsOf: selectedFileUrl, encoding: String.Encoding.utf8)
            fileContent = fileContentString
            
        } catch let error as NSError {
            
            print("Error: \(error.localizedDescription)")
        }
        
        return fileContent
    }

    /******************************************************************************/
    //  WRITE LOG DATA STRING TO LOG FILE
    /******************************************************************************/
    func writeTextToLog(text: String)
    {
        let stringAsData = text.data(using: .utf8, allowLossyConversion: false)!
        
        if FileManager.default.fileExists(atPath: currentSystemLogFilePath.path)
        {
            //print("File Path Exists, write new text to file")
            if let fileHandle = FileHandle(forWritingAtPath: currentSystemLogFilePath.path){
                defer {
                    fileHandle.closeFile()
                }
                fileHandle.seekToEndOfFile()
                fileHandle.write(stringAsData)
                fileHandle.closeFile()
            } else {
                print("Can't open file handle ")
            }
            
            
        } else {
            print("File not found at specified path: \(currentSystemLogFilePath!)")
        }
    }
    

    
    /******************************************************************************/
    //  RETRIEVE LIST OF CURRENT LOG FILES
    /******************************************************************************/
    func returnListOfLogFiles() -> [String]
    {
        var fileArray: [String] = []
        
        do{
            fileArray =  try fileManager.contentsOfDirectory(atPath: logFileDirectoryPath.path)
            print("FILE_MANAGER Log File Directory Contents = \(fileArray)")
            
        } catch {
            print("Error")
        }
        
        return fileArray
    }
    
//    func returnSelectedFilePath() -> NSURL{
//        
//    }
    

    /******************************************************************************/
    //  DELETE SINGLE FILE FROM DIRECTORY
    /******************************************************************************/
    func deleteFile(fileName: String)
    {
        let filePath = logFileDirectoryPath.appendingPathComponent(fileName)
        //  Dont delete curre log file
        if filePath.path != currentSystemLogFilePath.path{
            do{
                try fileManager.removeItem(atPath: filePath.path)
                print("File Deleted Successfully")
            } catch {
                print("Failed to delete single file with error")
            }
        } else {
            NotificationCenter.default.post(name: CANT_DELETE_CURRENT_LOG_FILE, object: self, userInfo: nil)
        }

    }
    
    /******************************************************************************/
    //  DELETE ALL FILES FROM DIRECTORY
    /******************************************************************************/
    func deleteAllFiles()
    {
        var directoryContents: [String]?
        do{
            let DirectoryContents = try fileManager.contentsOfDirectory(atPath: logFileDirectoryPath.path)
            directoryContents = DirectoryContents
            print("Going to delete contents = \(directoryContents!)")
        } catch let error as NSError {
            print("Directory Error = \(error)")
        }
        
        //Optional(file:///var/mobile/Containers/Data/Application/602103B0-F7C1-4115-93F3-01E5425CEB76/Documents/logFiles/SYS_LOG2017-09-06%2009:22:23.41%20.txt
        if let contents = directoryContents{
            for path in contents {
                
                print("Path extension = \(path)")
                let fullPath = logFileDirectoryPath.appendingPathComponent(path, isDirectory: false)
                    //.appendingPathExtension(path)//dirPath.stringByAppendingPathComponent(path as! String)
                    print("Full path = \(fullPath)")
                //don't delete current log file
                if fullPath.path != currentSystemLogFilePath.path{
                    do{
                        try fileManager.removeItem(atPath: fullPath.path)//.removeItem(at: fullPath)
                    } catch {
                        print("Failed to remove file with error")
                    }
                } else {
                    NotificationCenter.default.post(name: CANT_DELETE_CURRENT_LOG_FILE, object: self, userInfo: nil)
                }

            }
        }
        
    }
    
    
    
    
    
    
    
}
