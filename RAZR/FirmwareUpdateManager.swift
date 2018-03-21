//
//  FirmwareUpdateManager.swift
//  RAZR
//
//  Created by Joe Bakalor on 9/12/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
import WebKit
//import CoreNFC

class FirmwareUpdateManager: NSObject
{
    //var NFCManger = NFCNDEFReaderSession
    
    let taskURL      = URL(string: "http://www.winegardconnect.com/releasesrayzar/BLE_OTA_FS_BA_app_01.04.13.cyacd")!//BLE_OTA_FS_BA_boot01.00.09_app01.01.55.cyacd")!
    let testFileName = "BLE_OTA_FS_BA_boot01.00.09_app01.01.55.cyacd"
    
    
    // Check for new firmware on server
    func checkForNewFirmware(){
        
        let session = URLSession.shared
        var task: URLSessionDataTask
        
        //  Create Request Task
        task = session.dataTask(with: taskURL)
        { (data, response, error) -> Void in
            if error == nil {
                
                print("Attempting OTA file dowload froms server")
                //returnData = String(data: dataVar, encoding: .utf8)
                if let text = data{
                    
                    // dom = //createDocument
                    let convertedText = String(data: text, encoding: .utf8)!
                    self.saveFirmwareFile(fileData: convertedText)
                    print("FirmwareUpdateManager: Downloaded data = \(String(data: text, encoding: .utf8)!)")
                }
                
            } else {
                print("ERROR = \(String(describing: error))")
            }
        };
        
        task.resume()
        
    }
    

    func saveFirmwareFile(fileData: String){

        let fileName = "NewFirmware"
        let DocumentDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = DocumentDirectoryURL.appendingPathComponent(fileName).appendingPathExtension("cyacd")
        
        print("FILE_MANAGER File Path: \(fileURL)")
        
        let writeString = fileData
        
        //  CREATE NEW SYS LOG FILE IN NEW DIRECTORY
        do {
            try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed to write file to URL")
            print(error)
        }
    }
    
}
