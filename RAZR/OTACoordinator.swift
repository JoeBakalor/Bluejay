//
//  OTACoordinator.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/5/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth

//============================== BASE CLASEE =======================================
class OTACoordinator: NSObject
{
    /******************************************************************************/
    // Constants
    /******************************************************************************/
    let BACK_BUTTON_ALERT_TAG                                   = 200
    let UPGRADE_RESUME_ALERT_TAG                                = 201
    let UPGRADE_STOP_ALERT_TAG                                  = 202
    let APP_UPGRADE_BTN_TAG                                     = 203
    let APP_STACK_UPGRADE_COMBINED_BTN_TAG                      = 204
    let APP_STACK_UPGRADE_SEPARATE_BTN_TAG                      = 205
    let MAX_DATA_SIZE                                           = 133
    let COMMAND_PACKET_MIN_SIZE                                 = 7
    
    //Bootloader Constants
    let COMMAND_START_BYTE: UInt8                                       = 0x01
    let COMMAND_END_BYTE: UInt8                                         = 0x17
    
    //Bootloader command codes
    let VERIFY_CHECKSUM: UInt8                                          = 0x31
    let GET_FLASH_SIZE: UInt8                                           = 0x32
    let SEND_DATA: UInt8                                                = 0x37
    let ENTER_BOOTLOADER: UInt8                                         = 0x38
    let PROGRAM_ROW: UInt8                                              = 0x39
    let VERIFY_ROW: UInt8                                               = 0x3A
    let EXIT_BOOTLOADER: UInt8                                          = 0x3B
    
    // Bootloader status/Error codes
    let SUCCESS: UInt8                                                  = 0x00
    let ERROR_FILE: UInt8                                               = 0x01
    let ERROR_EOF: UInt8                                                = 0x02
    let ERROR_LENGTH: UInt8                                             = 0x03
    let ERROR_DATA: UInt8                                               = 0x04
    let ERROR_COMMAND: UInt8                                            = 0x05
    let ERROR_DEVICE: UInt8                                             = 0x06
    let ERROR_VERSION: UInt8                                            = 0x07
    let ERROR_CHECKSUM: UInt8                                           = 0x08
    let ERROR_ARRAY: UInt8                                              = 0x09
    let ERROR_ROW: UInt8                                                = 0x0A
    let ERROR_BOOTLOADER: UInt8                                         = 0x0B
    let ERROR_APPLICATION: UInt8                                        = 0x0C
    let ERROR_ACTIVE: UInt8                                             = 0x0D
    let ERROR_UNKNOWN: UInt8                                            = 0x0F
    let ERROR_ABORT: UInt8                                              = 0xFF
    /******************************************************************************/
    // Variables
    /******************************************************************************/
    var siliconID: String                                       = ""
    var siliconRevision: String                                 = ""
    var isWriteRowDataSuccess: Bool                             = false
    var isWritePacketDataSuccess: Bool                          = false
    var rowParameters: (startRowNumber: Int, endRowNumber: Int) = (0,0)
    var checkSum: UInt8                                         = 0x00
    var isApplicationValid: Bool                                = false
    
    

    /******************************************************************************/
    // OPTIONALS
    /******************************************************************************/
    var commandArray                    : [UInt8?] = []
    var checkSumType                    : String?
    var bootloaderCharacteristic        : CBCharacteristic?
    var peripheral                      : CBPeripheral?
    //temporary, use peripheral reference from BLEConnectionManagerInstance
    var otaFile = (headerData: OTAFileManager.otaFile.headerPayload(), dataPayload: [OTAFileManager.otaFile.dataPayload()], rowID: [OTAFileManager.otaFile.rowIDPayload()])

    var completionHandler: ((Bool, Int, NSError) -> (Void))?// = nil//{(success, id, error) in }
    
    typealias file = (headerData: OTAFileManager.otaFile.headerPayload, dataPayload: [OTAFileManager.otaFile.dataPayload], rowID: [OTAFileManager.otaFile.rowIDPayload])
    
    
    
    //var cbCharacteristicUpdationHandler(Bool, Int, NSError) -> Void
    /******************************************************************************/
    //  Intialize with characteristic used for bootloading
    /******************************************************************************/
    override init()//bootloaderChar: CBCharacteristic)
    {
        //otaFile = (headerData: OTAFileManager.otaFile.headerPayload(), dataPayload: [OTAFileManager.otaFile.dataPayload()], rowID: [OTAFileManager.otaFile.rowIDPayload()])
        super.init()
        
        //bootloaderCharacteristic = bootloaderChar
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleCharacteristicUpdatesFromDevice(_:)), name: NSNotification.Name(rawValue: "otaCharacteristicUpdateID"), object: nil)
    }

}


//============================== ====================================
extension OTACoordinator
{
    /******************************************************************************/
    //  Set file chosen by user after file is parsed, this is called by completion handler
    /******************************************************************************/
    func setFileToSend(fileToSend: file)
    {
        otaFile = fileToSend
        print("OTA File set \(otaFile)")
    }

    
    /******************************************************************************/
    //
    /******************************************************************************/
    func initiateUpdate()
    {
        
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func stopUpdate()
    {
        
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func setChecksumType(type: String)
    {
        checkSumType = type
    }
    
    
}


//============================== OTA CORE STATE MACHINE ==============================
extension OTACoordinator
{
    
}

//============================== OTA HELPER FUNCTIONS ==============================
extension OTACoordinator
{

    /******************************************************************************/
    //
    /******************************************************************************/
    func writeDataToCharacteristic(withData data: NSData)
    {
        
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func getBootloaderDataFromCharacteristic(characteristic: CBCharacteristic)
    {
        
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func getFlashDataFromCharacteristic(characteristic: CBCharacteristic)
    {
        
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func getRowCheckSumFromCharacteristic(characteristic: CBCharacteristic)
    {
        
    }
    
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func checkApplicationCheckSumFromCharacteristic(characteristic: CBCharacteristic)
    {
        
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func createCommandPacket(commandCode: UInt8, dataLength: UInt16, data: [String: Any]) -> Data
    {
        var packet                      = Data()
        var commandPacketArray: [UInt8] = [0]

        commandPacketArray.append(COMMAND_START_BYTE)
        commandPacketArray.append(commandCode)
        commandPacketArray.append(UInt8(dataLength>>8))
        commandPacketArray.append(UInt8(dataLength & 0b00000000_11111111))
        
        
        if commandCode == GET_FLASH_SIZE{
            commandPacketArray.append(UInt8(data[FLASH_ARRAY_ID] as! UInt16))
        }
        
        if (commandCode == PROGRAM_ROW) || (commandCode == VERIFY_ROW){
            commandPacketArray.append(UInt8(data[FLASH_ARRAY_ID] as! UInt16))
            commandPacketArray.append(UInt8((data[FLASH_ROW_NUMBER] as! UInt16)>>8))
            commandPacketArray.append(UInt8((data[FLASH_ROW_NUMBER] as! UInt16) & 0b00000000_11111111))
        }
        
        if (commandCode == SEND_DATA) || (commandCode == PROGRAM_ROW) {
            let dataArray = data[ROW_DATA] as! [UInt8]
            
            
            //I think we can cast a string of the format "0x00" as UInt8
            //lets try
            var hexString = "0x50"
            var hexStringCastAsUint8 = UInt8(hexString)
            print()
            
            for element in dataArray{
                //might need to convrert string "0x00" to regular
                commandPacketArray.append(element)
            }
        }
        
        //CALCULATE CHECKSUM
        var checksum = calculateChecksum(packet: commandPacketArray, type: checkSumType!)//with commandPacketArray
        
        //ADD CHECKSUM TO PACKET
        commandPacketArray.append(UInt8(checksum >> 8))
        commandPacketArray.append(UInt8(checksum & 0b00000000_11111111))
        
        //ADD COMMAND_END_BYTE TO PACKET
        commandPacketArray.append(COMMAND_END_BYTE)
        
        //FORMAT PACKET AS NSDATA
        packet = NSData(bytes: &commandPacketArray, length: commandPacketArray.count) as Data
        
        return packet
        
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func calculateChecksum(packet: [UInt8], type: String) -> UInt16
    {
        if type == CHECK_SUM{
            var sum: UInt16 = 0

            for i in 0...packet.count - 1{
                sum += (packet[i] as! UInt16)
            }
            
            return ~sum+1
            
            
        } else {
            
            var sum: UInt16 = 0xffff
            var tmp: UInt16
            
            if packet.count == 0{
                return (~sum)
            }
            
            //need to finish
            
            return sum
        }
    }

}


//garbage blahhhh
extension OTACoordinator
{
    /******************************************************************************/
    //  Process update directly from bluetooth
    /******************************************************************************/
    func handleCharacteristicUpdatesFromDevice(_ notification: Notification)
    {
        let notificationData = notification.userInfo as! [String: AnyObject]
        let data = notificationData["data"] as! [UInt8]
        let responseCode = data[1]
        let characteristicRef = notificationData["characteristic"] as! CBCharacteristic
        
        if responseCode == SUCCESS{
            if let command = commandArray[0]{
                switch command{
                case ENTER_BOOTLOADER: print("")
                getBootloaderDataFromCharacteristic(characteristic: characteristicRef)
                    
                case GET_FLASH_SIZE: print("")
                getFlashDataFromCharacteristic(characteristic: characteristicRef)
                    
                case SEND_DATA: print("")
                isWritePacketDataSuccess = true
                    
                case PROGRAM_ROW: print("")
                isWriteRowDataSuccess = true
                    
                case VERIFY_ROW: print("")
                getRowCheckSumFromCharacteristic(characteristic: characteristicRef)
                    
                case VERIFY_CHECKSUM: print("")
                checkApplicationCheckSumFromCharacteristic(characteristic: characteristicRef)
                    
                default: print("Invalid command")
                }
                
                if completionHandler != nil{
                    respondToUpdatesFromCharacteristic()
                    commandArray.remove(at: 0)
                }
                
            }
            
        } else {
            if let command = commandArray[0]{
                switch command{
                case PROGRAM_ROW: print("")
                isWriteRowDataSuccess = false
                    
                case SEND_DATA: print("")
                isWritePacketDataSuccess = false
                    
                default: print("Invalid Command")
                }
                
                if completionHandler != nil{
                    respondToUpdatesFromCharacteristic()
                    commandArray.remove(at: 0)
                }
            }
        }
        
    }
    
    /******************************************************************************/
    //  Perform appropriate action based on update
    /******************************************************************************/
    func respondToUpdatesFromCharacteristic()
    {
        
    }
    

}






