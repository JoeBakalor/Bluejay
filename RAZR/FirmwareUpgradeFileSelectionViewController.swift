//
//  FirmwareUpgradeFileSelectionViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 5/30/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

let FILE_NAME = "FileName"
let FILE_PATH = "FilePath"

class FirmwareUpgradeFileSelectionViewController: UIViewController
{
    /*==========================================================================================*/
    //  Variables
    /*==========================================================================================*/
    var isFileSearchFinished: Bool?
    var isStackFileSelected: Bool?
    var selectedFirmwareFilesArray: NSMutableArray?
    var firmwareFilesListArray: NSArray?
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    override func viewDidLoad()
    {
        super.viewDidLoad()
        selectedFirmwareFilesArray = NSMutableArray()
    }
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    override func viewWillAppear(_ animated: Bool)
    {
        isFileSearchFinished = false
        isStackFileSelected = false
        selectedFirmwareFilesArray = NSMutableArray()
        
        findFilesInDocumentsFolderWithFinishBlock{ (fileListArray: NSArray) in
            self.firmwareFilesListArray = fileListArray
            isFileSearchFinished = true
        }
        print("FileListArray = \(firmwareFilesListArray!)")
    }
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    func findFilesInDocumentsFolderWithFinishBlock(_ completion:(_ finish: NSArray) -> Void)
    {
        var fileListArray = NSMutableArray()
        var documentPaths = NSSearchPathForDirectoriesInDomains( .documentDirectory , .userDomainMask , true)
        let documentsDirPath = documentPaths[0]
        let fm = FileManager.default
        var dirContents = NSArray()
        
        do {
            dirContents =  try fm.contentsOfDirectory(atPath: documentsDirPath) as NSArray } catch { print("Dont know what is actually going on")
        }
        
        let predicate = NSPredicate.init(format: "pathExtenstion == 'cyacd'")
        let fileNameArray = dirContents.filtered(using: predicate)
        
        for fileName in fileNameArray {
            
            let firmwareFile = NSMutableDictionary()
            firmwareFile.setValue(fileName, forKey: FILE_NAME)
            firmwareFile.setValue(documentsDirPath, forKey: FILE_PATH)
            fileListArray.add(firmwareFile)
        }
        completion(fileListArray)
    }
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
}
