//
//  OTAFileParser.swift
//  RAZR
//
//  Created by Joe Bakalor on 5/30/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation

let FILE_HEADER_MAX_LENGTH = 12
let FILE_PARSER_ERROR_CODE = 555

class OTAFileParser: NSObject
{
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    override init()
    {
        super.init()
    }
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    func parseFirmwareFile(withName fileName: String, filePath: String) -> (header: [String: String], rowData: [[String: String]], rowIdArray: [[Int: String]], error: Error)
    {
        var fileHeaderDict = [String: String]()
        var firmwareFileDataArray = [[String: String]]()
        var rowIdArray: [[Int: String]] = [[Int: String]]()
        var error = NSError.init()
        var contents: String = ""
        
        let path = Bundle.main.path(forResource: "\(fileName)", ofType: FILE_PATH)
        var text = ""
        do {
            
            text = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            
        } catch {
            
            print("could not find file")
        }
        //var text = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)

        return (fileHeaderDict, firmwareFileDataArray, rowIdArray, error)
    }
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
//    func removeEmptyRowsAndJunkDataFromArray(dataArray: NSMutableArray) -> NSMutableArray
//    {
//        var modifiedDataArray = dataArray
//        
//        for i in 0...modifiedDataArray.count{
//            
//            if (modifiedDataArray[i] as! String) == ""{
//                
//                modifiedDataArray.removeObject(at: i)
//                
//            } else {
//                
//                var charactersToRemove = NSCharacterSet.alphanumerics.inverted
//                var trimmedReplacement = (modifiedDataArray[i] as! String).components(separatedBy: charactersToRemove).joined(separator: "")
//                modifiedDataArray.replaceObject(at: i , with: trimmedReplacement)
//            }
//        }
//        
//        return modifiedDataArray
//    }
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
//    func parseRowDataString(rowData: String) -> NSMutableDictionary
//    {
//        var rowDataDict = NSMutableDictionary()
//        
//        
//        let two = rowData.index(rowData.startIndex, offsetBy: 2)
//        let three = rowData.index(rowData.startIndex, offsetBy: 3)
//        
//        let six = rowData.index(rowData.startIndex, offsetBy: 6)
//        let seven = rowData.index(rowData.startIndex, offsetBy: 7)
//        
//        let ten = rowData.index(rowData.startIndex, offsetBy: 10)
//        let eleven = rowData.index(rowData.startIndex, offsetBy: 11)
//        let endMinusTwelve = rowData.index(rowData.startIndex, offsetBy: rowData.length - 11)//, offsetBy: 12)
//        //let endMinusTwelve = rowData.index(rowData.startIndex, offsetBy: rowData.length - 11)//, offsetBy: 12)
//        
//        rowDataDict.setValue(rowData.substring(with: rowData.startIndex..<three), forKey: ARRAY_ID)
//        rowDataDict.setValue(rowData.substring(with: two..<seven), forKey: ROW_NUMBER)
//        rowDataDict.setValue(rowData.substring(with: six..<eleven), forKey: DATA_LENGTH)
//        
//        var dataString = rowData.substring(with: ten..<endMinusTwelve)
//        var testVar = rowDataDict.value(forKey: DATA_LENGTH).getIntegerFromHexString
//
//        if testVar != (dataString.length / 2){
//            return nil
//        }
//        
//        var byteArray = NSMutableArray()
//        
//        for var i: Int = 0; (i + 2)<dataString.length; i += 2{
//            
//            var variableRangeStart = dataString.index(dataString.startIndex, offsetBy: i)
//            var variableRangeEnd = dataString.index(dataString.startIndex, offsetBy: i + 3)
//            byteArray.addObject(dataString.substring(with: variableRangeStart..<variableRangeEnd))
//
//            
//        }
//        
//        rowDataDict.setValue(byteArray, forKey: DATA_ARRAY)
//        let startRowData = rowData.index(rowData.startIndex, offsetBy: rowData.length - 2)
//        
//        let endRowData = rowData.index(rowData.startIndex, offsetBy: rowData.length + 1)
//        rowDataDict.setValue(rowData.substring(with: startRowData..<endRowData), forKey: CHECKSUM_OTA)
//        
//        return rowDataDict
//    }
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
}



//    func parseFirmwareFile(withName fileName: String, andPath filePath: String, onFinish: (_ header: NSMutableDictionary, _ rowData: NSArray, _ rowIDArray: NSArray,_ error: String) -> Void)
//    {
//        var fileHeaderDict = NSMutableDictionary()
//        var firmwareFileDataArray = NSMutableArray()
//        var rowIDArray = NSMutableArray()
//        var error: String = ""
//        var fileContents: String
//        var contents: String
//
//        if let filePath = Bundle.main.path(forResource: "\(fileName)", ofType: FILE_PATH){
//
//            do {
//
//                //let contents = try String(contentsOfFile: NSString.path(withComponents: ["\(filePath)", "\(fileName)"]))
//                contents = try String(contentsOfFile: NSString.path(withComponents: ["\(filePath)", "\(fileName)"]), encoding: String.Encoding.utf8)
//                print("\(contents)")
//                fileContents = contents
//
//            } catch {
//
//                print("error")
//                //contents could not be loaded
//            }
//
//                if contents.characters.count > 0{
//
//                    var fileContentsArray = fileContents.components(separatedBy: .newlines)
//
//                    if fileContentsArray != nil{
//
//                        fileContentsArray = removeEmptyRowsAndJunkDataFromArray(dataArray: fileContentsArray as! NSMutableArray) as! [String]
//
//                        var fileHeader = fileContentsArray[0]
//                        print("File Header = \(fileHeader)")
//
//                        if fileHeader.characters.count >= FILE_HEADER_MAX_LENGTH {
//
//                            let rangeOne = fileHeader.index(fileHeader.startIndex, offsetBy: 8)
//                            let rangeOneEnd = fileHeader.index(fileHeader.startIndex, offsetBy: 9)//
//                            let rangeTwo = fileHeader.index(fileHeader.startIndex, offsetBy: 10)//
//                            let rangeTwoEnd = fileHeader.index(fileHeader.startIndex, offsetBy: 11)//
//                            //let rangeThree = fileHeader.index(fileHeader.startIndex, offsetBy: 12)
//                            let rangeThreeEnd = fileHeader.index(fileHeader.startIndex, offsetBy: 13)//
//
//                            fileHeaderDict.setValue(fileHeader.substring(with: fileHeader.startIndex..<rangeOneEnd), forKey: SILICON_ID)
//                            fileHeaderDict.setValue(fileHeader.substring(with: rangeOne..<rangeTwoEnd), forKey: SILICON_REV)
//                            fileHeaderDict.setValue(fileHeader.substring(with: rangeTwo..<rangeThreeEnd), forKey: CHECKSUM_TYPE)
//
//                            fileContentsArray.remove(at: 0)
//
//                            var rowID = ""
//                            var rowCount = 0
//                            var rowIdDict = NSMutableDictionary()
//
//                            for dataRowString in fileContentsArray{
//
//                                if dataRowString.length > 20{
//
//                                    if parseRowDataString(rowData: dataRowString) != nil {
//                                        firmwareFileDataArray.add(parseRowDataString(rowData: dataRowString))
//
//                                        if rowID == "" {
//                                            rowID = dataRowString.substring(with: dataRowString.startIndex..<dataRowString.index(dataRowString.startIndex, offsetBy: 3))
//                                            rowCount += 1
//
//                                        } else if rowID == dataRowString.substring(with: dataRowString.startIndex..<dataRowString.index(dataRowString.startIndex, offsetBy: 3)){
//
//                                            rowCount += 1
//                                        } else {
//
//                                            rowIdDict.setValue(rowID, forKey: ROW_ID)
//                                            rowIDArray.add(rowIdDict)
//                                            rowIdDict = NSMutableDictionary()
//                                            rowID = dataRowString.substring(with: dataRowString.startIndex..<dataRowString.index(dataRowString.startIndex, offsetBy: 3))
//                                            rowCount = 1
//                                        }
//
//                                    } else {
//                                        //error = [[NSError alloc] initWithDomain:PARSING_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"invalidFile") forKey:NSLocalizedDescriptionKey]];
//                                        onFinish(nil, nil, nil, error)
//                                    }
//
//                                } else {
//                                    //error = [[NSError alloc] initWithDomain:FILE_FORMAT_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"dataFormatInvalid") forKey:NSLocalizedDescriptionKey]];
//                                    onFinish(nil, nil, nil, error)
//                                    break
//                                }
//
//                            }
//                            if error != nil{
//
//                                rowIdDict.setValue(rowID, forKey: ROW_ID)
//                                rowIdDict.setValue(NSNumber(value: rowCount), forKey: ROW_COUNT)
//                                rowIDArray.add(rowIdDict)
//                                onFinish(fileHeaderDict, firmwareFileDataArray, rowIdArray, nil)
//                            }
//
//                    } else {
//                        //error = [[NSError alloc] initWithDomain:PARSING_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"invalidFile") forKey:NSLocalizedDescriptionKey]];
//                        onFinish(nil, nil, nil, error)
//                    }
//
//                } else {
//
//                    //error = [[NSError alloc] initWithDomain:PARSING_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"parsingFailed") forKey:NSLocalizedDescriptionKey]];
//
//                    onFinish(nil,nil,nil, error)
//
//                }
//
//            } else {
//
//            //error = [[NSError alloc] initWithDomain:FILE_EMPTY_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"fileEmpty") forKey:NSLocalizedDescriptionKey]];
//                onFinish(nil,nil,nil, error);
//
//            }
//
//
//        }
//        onFinish(fileHeaderDict, firmwareFileDataArray, rowIDArray, error)
//    }
//let rangeOne = NSMakeRange(0, 9)
//var siliconId = fileHeader.substring(to: fileHeader.index(fileHeader.startIndex, offsetBy: 8))
//fileHeaderDict.setValue(fileHeader.substring(to: fileHeader.index(fileHeader.startIndex, offsetBy: 8)), forKey: SILICON_ID)

//        do {
//            fileContents = try String.init(contentsOfFile: NSString.path(withComponents: Array.init(arrayLiteral: filePath, fileName, error)))//(array: filePath, fileName, nil)))
//            } catch {
//                print("error")
//        }
