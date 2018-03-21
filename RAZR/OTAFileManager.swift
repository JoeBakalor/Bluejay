//
//  OTAFileManager.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/5/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation

class OTAFileManager: NSObject
{
    //  Variables
    struct otaFile{
        
        struct headerPayload{
            var siliconID = String()
            var siliconRevision = String()
            var checkSumType = String()
        }
        
        struct dataPayload{
            var arrayID = String()
            var rowNumber = String()
            var dataLength = String()
            var dataArray: [String] = []
            var checkSumOta  = String()
        }
        
        struct rowIDPayload{
            var rowID = String()
            var rowCount = Int()
        }
    }
    
    typealias otaFileStructure = (headerData: otaFile.headerPayload,
                                  dataPayload: [otaFile.dataPayload],
                                  rowID: [otaFile.rowIDPayload])
    
    var fileArray: [(fileName: String, fileContent: [String])] = []
    var newOtaFileArray: [(fileName: String, otaReadyContent: otaFileStructure)]?
    
    var otaFileArray: [(fileName: String,
                        otaReadyContent: (headerData: otaFile.headerPayload,
                                          dataPayload: [otaFile.dataPayload],
                                          rowID: [otaFile.rowIDPayload]))] = []
    
    var otaFormattedFile = (headerData: otaFile.headerPayload(),
                            dataPayload: [otaFile.dataPayload()],
                            rowID: [otaFile.rowIDPayload()])
    
    //completion(otaFormattedFile.headerData, otaFormattedFile.dataPayload, otaFormattedFile.rowID)
    //
    override init(){
        super.init()
    }
}


// =========================== FILE LOADING AND PARSING  ===========================
extension OTAFileManager
{
    /******************************************************************************/
    //  Load available OTA Files from Document Directory into fileArray
    /******************************************************************************/
    func loadAvailableOtaFiles() -> [(fileName: String, fileContent: [String])]{
        
        fileArray = []
        let documentsUrl = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first!
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                                includingPropertiesForKeys: nil,
                                                                                options: [])
            //FOR DEBUG ONLY<<<<REMOVE>>>>
            if false { print(directoryContents) }
            if false { print("Number of Files Found = \(directoryContents.count)") }
            
            for file in 0...directoryContents.count - 1{
                do {
                    //get file contents as string
                    let fileContentString = try String(contentsOf: directoryContents[file],
                                                       encoding: String.Encoding.utf8)
                    //convert file conents string to array of strings separated by new lines
                    var firmwareFileComponentArray = fileContentString.components(separatedBy: .newlines)
                    
                    //create array to save componenets after removing garbage characters
                    var newArray: [String] = []
                    
                    for i in 0...firmwareFileComponentArray.count - 1{
                        let charactersToRemoveFromString = NSCharacterSet.alphanumerics.inverted
                        let modifiedString = firmwareFileComponentArray[i].trimmingCharacters(in:  charactersToRemoveFromString)
                        
                        if modifiedString != ""{
                            newArray.append(modifiedString)
                        }
                    }
                    
                    firmwareFileComponentArray = newArray
                
                    //let otaContent = getOtaFormattedFile(forFileContent: firmwareFileComponentArray)
                    let nameOfFile = String(describing: directoryContents[file].lastPathComponent)
                    
                    fileArray.append((fileName: nameOfFile, firmwareFileComponentArray))
                    //otaFileArray.append(fileName: nameOfFile, otaReadyContent: otaContent)
                    
                } catch let error as NSError {
                    print("Error: \(error.localizedDescription)")
                }
            }
            
        } catch let error as NSError{
            print("Error: \(error.localizedDescription)")
        }
    
        //fileArray is list of files that have been prepared for parsing
        return fileArray
    }
    
    //  Format single String file into ota formatted file
    func getOtaFormattedFile(forFileContent fileContent: [String], completion: @escaping (otaFile.headerPayload, [otaFile.dataPayload],[otaFile.rowIDPayload]) -> Void)// -> (headerData: otaFile.headerPayload, dataPayload: [otaFile.dataPayload], rowID: [otaFile.rowIDPayload])
    {
        //otaFormattedFile.dataPayload.removeAll()
        //otaFormattedFile = ("","","")
        var newFileStringArray = fileContent
        let headerString = fileContent[0]
        otaFormattedFile.headerData.siliconID = headerString.sub(start: 0,end: 8)
        otaFormattedFile.headerData.siliconRevision = headerString.sub(start: 8, end: 10)
        otaFormattedFile.headerData.checkSumType = headerString.sub(start: 10, end: 12)
        
        newFileStringArray.remove(at: 0)
        var rowCount = 0
        var totalCount: Float = Float(newFileStringArray.count)
        var j: Float = 0
        
        var startDate = Date()
        for rowData in newFileStringArray{
            
            j += 1
            
            if rowData.characters.count > 20 {
                
                
                var notificationInfo: [String: AnyObject]?
                
                var rowIdPayload = otaFile.rowIDPayload()
                notificationInfo = ["status" : ((j/totalCount)) as AnyObject]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateParseStatusID"), object: self, userInfo: notificationInfo)
                
                //each payload is separated in array id row number and data
                var rowDataPayload = otaFile.dataPayload(
                    arrayID: rowData.sub(start: 0, end: 2),
                    rowNumber: rowData.sub(start: 2, end: 6),
                    dataLength: rowData.sub(start: 6, end: 10),
                    dataArray: [],
                    checkSumOta: "")
                
                //let dataOnly = rowData.sub(start: 10, end: rowData.characters.count - 12)
                let dataOnly = rowData.sub(start: 10, end: rowData.characters.count - 1)
                var byteArray: [String] = []
                //var characterArray: [String.CharacterView] = []

                if true{

                    var h = 0
                    var val = ""
                    for char in dataOnly.characters{

                        switch h{
                        case 0: val = String(char); h = 1
                        case 1: val += String(char); byteArray.append(val); h = 0
                        default: 1
                        }
                    }
                }

                // val = String(char)
                //      val += String(char)
                //if
                //0.42000
//                if true{
//
//                    var h = 0
//                    var val = ""
//                    for char in dataOnly.characters{
//
//                        switch h{
//                        case 0: val = String(char); h = 1
//                        case 1: val += String(char); byteArray.append(val); h = 0
//                        default: 1
//                        }
//                    }
//                }
                
                
                rowCount += 1
                rowDataPayload.dataArray = byteArray
                rowDataPayload.checkSumOta = rowData.sub(start: rowData.characters.count - 2, end: rowData.characters.count)
                rowIdPayload.rowID = rowData.sub(start: 0, end: 2)
                rowIdPayload.rowCount = rowCount
                
                //parsed row payload to dataPayload array
                otaFormattedFile.dataPayload.append(rowDataPayload)
                otaFormattedFile.rowID.append(rowIdPayload)
                
            } else {
                print("Error")
            }
        }
        
        print("OTA FILE PROCESSING TIME = \(Date().timeIntervalSince(startDate))")
        otaFormattedFile.dataPayload.removeFirst()
        //NEED TO TEST THIS COMPLETION HANDLER
        completion(otaFormattedFile.headerData, otaFormattedFile.dataPayload, otaFormattedFile.rowID)
        //return otaFormattedFile
    }
    
}

extension String
{
    func sub(start: Int, end: Int) -> String{
        
        let startFrom = self.index(self.startIndex, offsetBy: start)
        let endAt = self.index(self.startIndex, offsetBy: end )
        return self.substring(with: startFrom..<endAt)
    }
    
}


