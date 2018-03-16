//: Playground - noun: a place where people can play

import UIKit



//var str = "Hello, playground"
//
//let COMMAND_START_BYTE: UInt8          = 0x01
//let COMMAND_END_BYTE: UInt8            = 0x17
//
//let VERIFY_CHECKSUM: UInt8             = 0x31
//let GET_FLASH_SIZE: UInt8              = 0x32
//let SEND_DATA: UInt8                   = 0x37
//let ENTER_BOOTLOADER: UInt8            = 0x38
//let PROGRAM_ROW: UInt8                 = 0x39
//let VERIFY_ROW: UInt8                  = 0x3A
//let EXIT_BOOTLOADER: UInt8             = 0x3B
//
//var arrayID: [String: Any]? = ["id": "00"]
//
//var packet                      = Data()
//var commandPacketArray: [UInt8] = [0]
//
//commandPacketArray.append(COMMAND_START_BYTE)
//commandPacketArray.append(SEND_DATA)
//var newString = ((arrayID?["id"] as! String).hexa2Bytes[0])
//commandPacketArray.append(newString)
extension String {
    var hexa2Bytes: [UInt8] {
        let hexa = Array(characters)
        return stride(from: 0, to: characters.count, by: 2).flatMap { UInt8(String(hexa[$0..<$0.advanced(by: 2)]), radix: 16) }
    }
}

let data2: [String: Any]? = ["FLASH_ROW_NUMBER": "0037"]

let flashRowNumber = (data2?["FLASH_ROW_NUMBER"] as! String).hexa2Bytes
flashRowNumber




