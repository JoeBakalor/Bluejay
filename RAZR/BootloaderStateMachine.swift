//
//  BootloaderStateMachine.swift
//  RAZR
//
//  Created by Joe Bakalor on 8/8/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth



//
//if characteristic.uuid == <Bootloader Characteristic UUID>{
//    //process notification seperately
//    if error == nil{
//        
//        var otaUpdate: [String: AnyObject]? = [:]
//        var data               : Data?
//        var dataLength         : Int?
//        
//        if characteristic.value != nil{
//            
//            data            = characteristic.value as Data!
//            dataLength      = data!.count as Int!
//            var dataBytes   = [UInt8](repeating: 0, count: data!.count)
//            (data! as NSData).getBytes(&dataBytes, length: data!.count)
//            
//            otaUpdate!["dataBytes"] = dataBytes as AnyObject
//            otaUpdate!["characteristic"] = characteristic as AnyObject
//            otaUpdate!["error"] = error as AnyObject
//            
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "otaCharacteristicUpdateID"), object: self, userInfo: otaUpdate)
//        }
//        
//        
//    } else {
//        
//        //report there was an error
//    }
//}
//
// ADD THIS TO
//
// func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {}


//  BASE CLASS
class BootloaderStateMachine: NSObject
{
    /******************************************************************************/
    // Constants
    /******************************************************************************/
    
    //Bootloader error codes
    let bootloaderErrorCodes: [UInt8: String] =
    [
        0x00 :  "SUCCESS",
        0x01 :  "ERROR_FILE",
        0x02 :  "ERROR_EOF",
        0x03 :  "ERROR_LENGTH",
        0x04 :  "ERROR_DATA",
        0x05 :  "ERROR_COMMAND",
        0x06 :  "ERROR_DEVICE",
        0x07 :  "ERROR_VERSION",
        0x08 :  "ERROR_CHECKSUM",
        0x09 :  "ERROR_ARRAY",
        0x0A :  "ERROR_ROW",
        0x0B :  "ERROR_BOOTLOADER",
        0x0C :  "ERROR_APPLICATION",
        0x0D :  "ERROR_ACTIVE",
        0x0F :  "ERROR_UNKNOWN",
        0xFF :  "ERROR_ABORT"
    ]
    
    //Bootloader Constants
    let COMMAND_START_BYTE  : UInt8          = 0x01
    let COMMAND_END_BYTE    : UInt8          = 0x17
    
    //Bootloader command codes
    let VERIFY_CHECKSUM     : UInt8          = 0x31
    let GET_FLASH_SIZE      : UInt8          = 0x32
    let SEND_DATA           : UInt8          = 0x37
    let ENTER_BOOTLOADER    : UInt8          = 0x38
    let PROGRAM_ROW         : UInt8          = 0x39
    let VERIFY_ROW          : UInt8          = 0x3A
    let EXIT_BOOTLOADER     : UInt8          = 0x3B
    
    // Bootloader status/Error codes
    let SUCCESS: UInt8                       = 0x00
    let ERROR_FILE: UInt8                    = 0x01
    let ERROR_EOF: UInt8                     = 0x02
    let ERROR_LENGTH: UInt8                  = 0x03
    let ERROR_DATA: UInt8                    = 0x04
    let ERROR_COMMAND: UInt8                 = 0x05
    let ERROR_DEVICE: UInt8                  = 0x06
    let ERROR_VERSION: UInt8                 = 0x07
    let ERROR_CHECKSUM: UInt8                = 0x08
    let ERROR_ARRAY: UInt8                   = 0x09
    let ERROR_ROW: UInt8                     = 0x0A
    let ERROR_BOOTLOADER: UInt8              = 0x0B
    let ERROR_APPLICATION: UInt8             = 0x0C
    let ERROR_ACTIVE: UInt8                  = 0x0D
    let ERROR_UNKNOWN: UInt8                 = 0x0F
    let ERROR_ABORT: UInt8                   = 0xFF
    
    //max data length
    let MAX_DATA_SIZE                        = 137
    let COMMAND_PACKET_MIN_SIZE              = 7
    
    //bootloader states
    enum bootloaderStates: UInt8
    {
        case idle                            = 0x00
        case enterBootloader                 = 0x38
        case getFlashSize                    = 0x32
        case sendData                        = 0x37
        case programRow                      = 0x39
        case verifyRow                       = 0x3A
        case verifyChecksum                  = 0x31
        case exitBootloader                  = 0x3B
        case failed                          = 0xFF
    }
    
    /******************************************************************************/
    // Variables
    /******************************************************************************/
    var bootloaderState                      = bootloaderStates.idle
    var checkSumType                         = "checkSum"
    var currentIndex                         = 0
    var currentArrayId                       = 0
    var currentRowNumber                     = 0
    var currentRowDataArray: [String]        = []
    var flashSize: (start: Int, end: Int)    = (0,0)
    var writeRowDataSuccess                  = false
    var writePacketSuccess                   = false
    var fileSelected                         = false
    
    //variable to hold file that will be sent over the air
    var file = (headerData: OTAFileManager.otaFile.headerPayload(),
                dataPayload: [OTAFileManager.otaFile.dataPayload()],
                rowID: [OTAFileManager.otaFile.rowIDPayload()])
    
    var logData: [String] = []
    //var logDataManager = LogDataManager()
    /******************************************************************************/
    // Optionals
    /******************************************************************************/
    
    var bootloaderCharacteristic: CBCharacteristic?

    /******************************************************************************/
    // typedalias
    /******************************************************************************/
    
    typealias fileFormat = (headerData: OTAFileManager.otaFile.headerPayload,
        dataPayload: [OTAFileManager.otaFile.dataPayload],
        rowID: [OTAFileManager.otaFile.rowIDPayload])
    
    /******************************************************************************/
    // Class initializer
    /******************************************************************************/
    init(bootChar: CBCharacteristic)
    {
        super.init()
        bootloaderCharacteristic = bootChar
        
        //Add observer for bootloaderCharacteristic updates
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.processRecievedBootloaderMessages(_:)),
                                               name: NSNotification.Name(rawValue: "otaCharacteristicUpdateID"),
                                               object: nil)
        
        //Enable notifications
        //BLEConnectionManagerSharedInstance.bleService?.subscribeToNotificationsForCharacteristic(bootloaderCharacteristic!)
    }
    

    
}

// ============================= BOOTLOADER ACTIONS ===========================
extension BootloaderStateMachine
{
    /******************************************************************************/
    //  START FILE TRANSFER IF FILE SELECTED
    /******************************************************************************/
    func startBootloader()
    {
        //set current index = 0 since we want to begin at the start of the file
        currentIndex = 0
        
        //make sure a file has been set
        if fileSelected == true{
            bootloaderState = .enterBootloader
            processOutgoingBootloaderMessages()
            //print("Start Bootloader")
        }
        
    }

    /******************************************************************************/
    //  SET FIRMWARE FILE TO SEND
    /******************************************************************************/
    func setFile(fileToSend: fileFormat)
    {
        file = fileToSend
        //print("File To Send = \(fileToSend)")
        fileSelected = true
        startBootloader()
    }
    
    /******************************************************************************/
    //  STOP BOOTLOADER
    /******************************************************************************/
    func stopBootloader()
    {
        
    }
    
}


//======================== BOOTLOADER OUTGOING MESSAGE PROCESSING ======================
extension BootloaderStateMachine
{
    //NOTIFICATIONS SHOULD ALREADY BE ACTIVATED BEFORE THIS IS CALLED
    func processOutgoingBootloaderMessages()
    {
        switch bootloaderState{
        //==================  BOOTLOADER IDLE  =====================
        case .idle: print("Recieved data, bootloader in idle state")
            
        //=============  ENTER BOOTLOADER OUTGING  =================
        case .enterBootloader:
            
            //get checksum type from file selected and set
            if Int(file.headerData.checkSumType)! > 0{
                checkSumType = CRC_16
            } else {
                checkSumType = CHECK_SUM
            }
            //checkSumType = ((Int(file.headerData.checkSumType) == 1) ? CRC_16 : CHECK_SUM)
        
            //create ENTER_BOOTLOADER command packet as NSData
            let packet = createCommandPacket(dataLength: 0, data: nil)
            print("Created Packet = \(packet)")
        
            sendPacket(packet: packet)
            print("Sent enter bootloader packet")
            logDataManager.log(logString: "ENTER BOOTLOADER OUTGOING")
            
        //=============  GET FLASH SIZE OUTGOING  =================
        case .getFlashSize:
        
            //get current row data
            let rowData = file.dataPayload[currentIndex]
            let dataDictionary = [FLASH_ARRAY_ID: rowData.arrayID]
        
            //set currentArrayId
            currentArrayId = Int(rowData.arrayID)!
        
            //create command packet with GET_FLASH_SIZE command and data dictionary
            let packet = createCommandPacket(dataLength: 1, data: dataDictionary)
        
            //write created packet to bootloader characteristic
            sendPacket(packet: packet)
        
            logDataManager.log(logString: "GET FLASH SIZE OUTGOING")
            
        //=============  SEND DATA OUTGOING  ========================
        case .sendData: // only used if the rowData is larger than max allowed
            
            //create command packet with SEND_DATA command
            let rowData = file.dataPayload[currentIndex]
        
            //have to send data in more than one packet, segment packet to fit
            let subRangeDataArray = Array(currentRowDataArray[0...(MAX_DATA_SIZE - 1)])
            let dataDictionary: [String: Any]? = [FLASH_ARRAY_ID: rowData.arrayID, FLASH_ROW_NUMBER: rowData.rowNumber, ROW_DATA : subRangeDataArray]
        
            //create command packet with SEND_DATA command and data dictionary
            let packet = createCommandPacket(dataLength: UInt16(MAX_DATA_SIZE), data: dataDictionary)

            //write created packet to bootloader characteristic
            sendPacket(packet: packet)
        
            //remove portion of data that was sent from the currentRowDataArray
            let range = currentRowDataArray.startIndex..<(MAX_DATA_SIZE)
            currentRowDataArray.removeSubrange(range)
            
        //=============  PROGRAM ROW OUTGOING ========================
        case .programRow:
            
            //createCommandPacket for PROGRAM_ROW withCurrentRowData
            let rowData = file.dataPayload[currentIndex]
        
            var notificationInfo: [String: AnyObject]?
            let currentStatus = ((Float(currentIndex) / Float(file.dataPayload.count))*100)
            print("Percent Complete = \(currentStatus)%")
            notificationInfo = ["status" : currentStatus as AnyObject]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateBootloaderStatusID"), object: self, userInfo: notificationInfo)
        
            let dataDictionary: [String: Any]? = [FLASH_ARRAY_ID: rowData.arrayID, FLASH_ROW_NUMBER: rowData.rowNumber, ROW_DATA : currentRowDataArray]
        
            let packet = createCommandPacket(dataLength: UInt16(currentRowDataArray.count) + 3, data: dataDictionary)
        
            //write command packet to bootloader characteristic
            sendPacket(packet: packet)
            
        //==============  VERIFY ROW OUTGOING  ==================
        case .verifyRow:
                
            //create VERIFY_ROW command packet
            let rowData = file.dataPayload[currentIndex]
        
            let dataDictionary: [String: Any]? = [FLASH_ARRAY_ID: rowData.arrayID, FLASH_ROW_NUMBER: rowData.rowNumber]
            let packet = createCommandPacket(dataLength: 3, data: dataDictionary)
        
            //write command packet to bootloader characteristic
            sendPacket(packet: packet)
            
        //============  VERIFY CHECKSUM OUTGOING =================
        case .verifyChecksum:
            
            //create VERIFY_CHECKSUM command packet
            let packet = createCommandPacket(dataLength: 0, data: nil)
            
            //write command packet to bootloader characteristic
            sendPacket(packet: packet)
            
        //============  EXIT BOOTLOADER OUTGOING  =================
        case .exitBootloader:
        
            //write command packet to bootloader characteristic
            let packet = createCommandPacket(dataLength: 0, data: nil)
        
            //create EXIT_BOOTLOADER command packet
            sendPacket(packet: packet)
        
            logDataManager.log(logString: "PROGRAMMING COMPLETED SUCCESFULLY")
            //print("Percent Complete = \((i/totalCount)*100)%")

            NotificationCenter.default.post(name: Notification.Name(rawValue: "completeID"), object: self, userInfo: nil)
            
        default: print("Unknown bootloader state")
        }
    }
    
    //  SEND PACKET --> ADDED TO DECREASE CODE ABOVE
    func sendPacket(packet: Data){
        
        guard let bootChar = rayzarGatt.winegardBootloaderCharacteristic else { return }
        bleManager.write(value: packet, toCharacteristic: bootChar)
        print("SENT PACKET TO BOOTLOADER CHAR")
    }
    
}

//TASK--> NEED TO ADD ERROR LOGGING FOR REPORTING FAILURE
// ============================  BOOTLOADER RECIEVED MESSAGE PROCESSING ===============================
extension BootloaderStateMachine
{
    //RECIEVED MESSAGES FROM BLUETOOTH PERIPHERAL
    @objc func processRecievedBootloaderMessages(_ notification: Notification){
        
        print("RECIEVE BOOTLOADER MESSAGE")
        //check if error reported
        let error = notification.userInfo?["error"] as? NSError
        
        print("Error = \(String(describing: error))")
        if error == nil{
            
            let notificationData = notification.userInfo as! [String: AnyObject]
            let dataBytes = notificationData["dataBytes"] as! [UInt8]
            let responseCode = dataBytes[1]
            
            //print("Recieved data = \(dataBytes)")
            
            if responseCode == SUCCESS {
                
                switch bootloaderState{
                //===================  BOOTLOADER IDLE =========================
                case .idle: print("Bootloader idle, recieved message")
                    
                //==============  ENTER BOOTLOADER INCOMING ====================
                case .enterBootloader:
                    
                    logDataManager.log(logString: "ENTER BOOTLOADER RECIEVED")
                    //check silicon id and revision matches value returned from chip
                    if (verifySiliconIdandRevision(data: dataBytes)){
                        //set next bootloader state
                        bootloaderState = .getFlashSize
                        processOutgoingBootloaderMessages()
                    } else {
                        //error
                        bootloaderState = .failed
                        print("Silicon ID and/or Revision Mismatch")
                    }
                    
                //================  GET FLASH SIZE INCOMING  ====================
                case .getFlashSize:
                
                    logDataManager.log(logString: "GET FLASH SIZE RECIEVED")
                    //save flash information, should probably be also checking flash size now
                    //instead of later
                    saveFlashInformation(data: dataBytes)
                
                    //make sure currentArrayId = arrayID-->probably dont need this
                    let rowData = file.dataPayload[currentIndex]
                    var rowNumber = rowData.rowNumber.hexa2Bytes
                
                    //get current row number on join to make UInt16
                    let bytes = [rowNumber[1], rowNumber[0]]
                    let newData = UnsafePointer(bytes).withMemoryRebound(to: UInt16.self, capacity: 1){
                        $0.pointee
                    }; currentRowNumber = Int(newData)
                
                    if currentRowNumber >= flashSize.start && currentRowNumber <= flashSize.end{
                        
                        currentRowDataArray = rowData.dataArray
                        //print("currentRowDataArray count = \(currentRowDataArray.count)")
                        if currentRowDataArray.count > MAX_DATA_SIZE{
                            
                            //need to segment the data because it is too long
                            bootloaderState = .sendData
                            processOutgoingBootloaderMessages()
                            
                        } else { //if we can fit in one write packet
                            
                            bootloaderState = .programRow
                            processOutgoingBootloaderMessages()
                            //send normal
                        }
                    } else {
                        
                        bootloaderState = .failed
                        print("Flash size mismatch")
                        //report error, flah size mismatch
                    }
                
                //=================  SEND DATA INCOMING  =================
                case .sendData:
                    
                    logDataManager.log(logString: "SEND DATA RECIEVED")
                
                    //recieved response, so packet was sent successfully
                    if currentRowDataArray.count > MAX_DATA_SIZE{
                        //dont change state
                        processOutgoingBootloaderMessages()
                    
                    } else { //this will be called, cypress has no condition otherwise
                        bootloaderState = .programRow
                        processOutgoingBootloaderMessages()
                    }
                    
                //=============== PROGRAM ROW INCOMING  ================
                case .programRow:
                    
                    logDataManager.log(logString: "PROGRAM ROW RECIEVED")
                
                    //writeRowData was successful, dont think
                    //we need this variable, wouldnt make it here
                    //if wasnt success
                    writeRowDataSuccess = true
                
                    //change state to verify row
                    bootloaderState = .verifyRow
                
                    //process outgoing messeges
                    processOutgoingBootloaderMessages()
            
                //============== VERIFY ROW INCOMING  ================
                case .verifyRow:
                
                    //make sure value return by device matches
                    if (verifyRowCheckSum(data: dataBytes)){
                    
                        logDataManager.log(logString: "ROW PROGRAMMED SUCCESFULLY")
                        //update user visible status percentage
                        currentIndex += 1 //increment index
                        
                        //check if we are done sending
                        if currentIndex < file.dataPayload.count{
                            
                            //still have more data, update the currentRowDataArray with 
                            //data for currentIndex
                            let rowData = file.dataPayload[currentIndex]
                            currentRowDataArray = rowData.dataArray
                            
                            if currentRowDataArray.count > MAX_DATA_SIZE{
                                
                                //need to segment the data because it is to larger
                                bootloaderState = .sendData
                                processOutgoingBootloaderMessages()
                                
                            } else { //if we can fit in one write packet
                                
                                bootloaderState = .programRow
                                processOutgoingBootloaderMessages()
                                //send normal
                            }
                        } else {
                            bootloaderState = .verifyChecksum
                            processOutgoingBootloaderMessages()
                        }
                    } else {
                        //error
                        print("RowCheckSum mismatch")
                        bootloaderState = .failed
                    }
                    
                //=================  VERIFGY CHECKSUM INCOMING ====================
                case .verifyChecksum:
                    
                logDataManager.log(logString: "VERIFY CHECKSUM RECIEVED")
                    if (verifyApplicationCheckSum(data: dataBytes)){
                    
                        bootloaderState = .exitBootloader
                        processOutgoingBootloaderMessages()
                        
                    } else {
                        
                        print("Application checksum invalid, update failed")
                        //report error
                        bootloaderState = .failed
                    }
                    
                //==================  EXIT BOOTLOADER INCOMING  ==================
                case .exitBootloader: print("EXIT BOOTLOADER RECIEVED")
                    
                    //This won't ever be entered.  Looks like cypress does
                    //not confirm exit of the bootloader
                    
                case .failed: print("Bootloader failed")
                }
                
            } else {
                print("Error code = \(bootloaderErrorCodes[responseCode]!))")
                
                switch bootloaderState{
                //===============  PROGRAM ROW FAILED INCOMING  ===================
                case .programRow:
                    
                    writeRowDataSuccess = false
                    bootloaderState = .failed
                    
                //===============  SEND DATA FAILED INCOMING  =====================
                case .sendData:
                    
                    writePacketSuccess = false
                    bootloaderState = .failed
                    
                default: print("UNKNOWN FAILURE STATE")
                    
                }
            }
        }
    }
}


// ============================ BOOTLOADER HELPER FUNCTIONS ===============================
extension BootloaderStateMachine
{

    // Check to make sure the siliconID and revision match the file that has been
    // selected to upload
    func verifySiliconIdandRevision(data: [UInt8]) -> Bool{
        
        //get siliconId from recieved data
        var siliconId = ""
        for i in stride(from: 7, through: 4, by: -1) { siliconId += String(format: "%02X", data[i])}
        
        //get siliconRevision from recieved data
        let siliconRevision = String(format: "%02X", data[8])
        
        //Check siliconID and siliconRevision for match to file
        if file.headerData.siliconID == siliconId && file.headerData.siliconRevision == siliconRevision{
            return true
        } else {
            return false
        }
        
    }
    
    //   Calculate row checksum and comapare to checksum recieved from device
    func verifyRowCheckSum(data: [UInt8]) -> Bool{
        
        //recieved checksum
        let rowCheckSum = data[4]//checksum returned from device
        
        let rowCheckSumFromFile = (file.dataPayload[currentIndex].checkSumOta).hexa2Bytes[0]
        let arrayIdFromFile = (file.dataPayload[currentIndex].arrayID).hexa2Bytes[0]
        let rowNumberFromFile = (file.dataPayload[currentIndex].rowNumber).hexa2Bytes//two bytes
        let dataLengthFromFile = (file.dataPayload[currentIndex].dataLength).hexa2Bytes//two bytes
        
        //Swift doesn't allow overflow by default for Integer types.  
        // Use &+ for addition with overflow
        // Use &- for subtraction with overflow
        // Use &* for multiplication with overflow
        let sum: UInt8 = rowCheckSumFromFile &+ arrayIdFromFile &+ rowNumberFromFile[0] &+ rowNumberFromFile[1] &+ dataLengthFromFile[0] &+ dataLengthFromFile[1]
        
        return (sum == rowCheckSum)
    }
    
    //  Verify Application checksum recieved from device
    func verifyApplicationCheckSum(data: [UInt8]) -> Bool{
        
        let applicationChecksum = data[4]
        return ((applicationChecksum > 0))
    }
    
    //  Save flash information received from connected device
    func saveFlashInformation(data: [UInt8]){
        
        //Flash start
        var bytes = [data[4], data[5]]
        var newData = UnsafePointer(bytes).withMemoryRebound(to: UInt16.self, capacity: 1){
            $0.pointee
        }
        flashSize.start = Int(newData)
        
        //Flash end
        bytes = [data[6], data[7]]
        newData = UnsafePointer(bytes).withMemoryRebound(to: UInt16.self, capacity: 1){
            $0.pointee
        }
        flashSize.end = Int(newData)
    }
    
    //  Create command packet with data using current bootloaderState
    func createCommandPacket(dataLength: UInt16, data: [String: Any]?) -> Data{
        
        //create packet to stored final packet after converting to type: Data
        var packet                      = Data()
        var commandPacketArray: [UInt8] = []
        
        //populate start byte, command byte, and data length
        commandPacketArray.append(COMMAND_START_BYTE)
        commandPacketArray.append(bootloaderState.rawValue)
        commandPacketArray.append(UInt8(dataLength & 0b00000000_11111111))//lower byte
        commandPacketArray.append(UInt8(dataLength>>8))//upper byte
        
        if bootloaderState == .getFlashSize{

            commandPacketArray.append(((data?[FLASH_ARRAY_ID] as! String).hexa2Bytes)[0])
        }
        
        if (bootloaderState == .programRow) || (bootloaderState == .verifyRow){
            
            //populate flash arrayId
            commandPacketArray.append((data?[FLASH_ARRAY_ID] as! String).hexa2Bytes[0])
            
            //get bytes as hex bytes from string bytes
            let flashRowNumber = (data?[FLASH_ROW_NUMBER] as! String).hexa2Bytes
            
            //populate into command packet
            commandPacketArray.append(flashRowNumber[1])//LOWER
            commandPacketArray.append(flashRowNumber[0])//UPPER
            
        }
        
        if (bootloaderState == .sendData) || (bootloaderState == .programRow){
            
            let stringDataArray = data?[ROW_DATA] as! [String]
            //convert string respresentation of hex value to hex values
            for stringData in stringDataArray{
                commandPacketArray.append(stringData.hexa2Bytes[0])
            }
            
        }
        
        //CALCULATE CHECKSUM
        let checksum = calculateChecksum(packet: commandPacketArray, type: checkSumType)//with commandPacketArray
        
        //ADD CHECKSUM TO PACKET
        commandPacketArray.append(UInt8(checksum & 0b00000000_11111111))
        commandPacketArray.append(UInt8(checksum >> 8))
        
        //ADD COMMAND_END_BYTE TO PACKET
        commandPacketArray.append(COMMAND_END_BYTE)
        
        //print("Command packet array = \(commandPacketArray))")
        
        //FORMAT PACKET AS NSDATA
        packet = NSData(bytes: &commandPacketArray, length: commandPacketArray.count) as Data
        
        return packet
    }
    
    //  Calculate Checksum for correct setting
    func calculateChecksum(packet: [UInt8], type: String) -> UInt16{
        
        if type == CHECK_SUM{
            
            var sum: UInt16 = 0
            
            for i in 0...packet.count - 1{
                sum = sum &+ (UInt16(packet[i]))
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

// ============================ STRING EXTENSION TO HANDLE HEX STRING CONVERSION ===============================
extension String {
    var hexa2Bytes: [UInt8] {
        let hexa = Array(characters)
        return stride(from: 0, to: characters.count, by: 2).flatMap { UInt8(String(hexa[$0..<$0.advanced(by: 2)]), radix: 16) }
    }
}


// ============================ FUNCTIONS FOR DEBUGGING ===============================
extension BootloaderStateMachine
{
    func createTestPackets()
    {
        for i in 0...file.dataPayload.count - 1{
            print("\rTEST PACKET FOR ROW NUMBER\(file.dataPayload[i].rowNumber)")
            bootloaderState = .sendData
            
            let rowData = file.dataPayload[i]
            
            currentRowDataArray = file.dataPayload[i].dataArray///Array(rowData.dataArray[0...(MAX_DATA_SIZE - 1)])
            
            let subRangeDataArray = Array(currentRowDataArray[0...(MAX_DATA_SIZE - 1)])
            
            var dataDictionary: [String: Any]? = [FLASH_ARRAY_ID: rowData.arrayID, FLASH_ROW_NUMBER: rowData.rowNumber, ROW_DATA : subRangeDataArray]
            
            var packet = createCommandPacket(dataLength: UInt16(MAX_DATA_SIZE), data: dataDictionary)
            
            print("\rsend data packet = \(packet.hexEncodedString())")
            
            let range = currentRowDataArray.startIndex..<(MAX_DATA_SIZE)
            
            currentRowDataArray.removeSubrange(range)
            
            bootloaderState = .programRow
            
            dataDictionary = [FLASH_ARRAY_ID: rowData.arrayID, FLASH_ROW_NUMBER: rowData.rowNumber, ROW_DATA : currentRowDataArray]
            
            packet = createCommandPacket(dataLength: UInt16(currentRowDataArray.count) + 3, data: dataDictionary)
            
            print("\rsend command packet = \(packet.hexEncodedString())")
        }
    }
}



