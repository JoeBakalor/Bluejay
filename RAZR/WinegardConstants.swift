//
//  WinegardConstants.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/5/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit


//struct winegardDeviceParamters
//{
//    let winegardDeviceUUID = "C5D5AF8C-4081-4A41-B0CF-B3938AEFCB28"
//    let winegardBootloaderServiceUUID = "B0054034-E266-46B3-8D35-D4062AE56E7B"
//    let winegardBootloaderCharacteristicUUID = "5379B2DC-B087-4628-89AE-FCBE8D50C907"
//}
//let winegardConstants = winegardDeviceParamters()

//SCAN RESPONSE SERVICE PRESENT, ADC SERVICE 

/**********************************************************************************/
//
//                         Variable, Constants and UIOutlets
//
/**********************************************************************************/

/*============================================================================*/
//  Winegard Colors
/*============================================================================*/
let WINEGARD_PRIMARY_BLUE_COLOR = UIColor(red: 0/255, green: 139/255, blue: 206/255, alpha: 1)
/*============================================================================*/
//  Winegard Service and Characteristic UUIDs
/*============================================================================*/
//let WINEGARD_DEVICE_UUID              = CBUUID(string: "C5D5AF8C-4081-4A41-B0CF-B3938AEFCB28")
//let CUSTOM_BOOT_LOADER_SERVICE_UUID   = CBUUID(string: "0A060000-F8CE-11E4-ABF4-0002A5D5C51B")
//let BOOT_LOADER_CHARACTERISTIC_UUID   = CBUUID(string: "0B060001-F8CE-11E4-ABF4-0002A5D5C51B")
//
//let WINEGARD_OTA_SERVICE               = CBUUID(string: "00060000-F8CE-11E4-ABF4-0002A5D5C51B")
//let WINEGARD_BOOTLOADER_CHARACTERISTIC = CBUUID(string: "00060001-F8CE-11E4-ABF4-0002A5D5C51B")
////I think we only use one characteristic for both directions
////let WINEGARD_OTA_CMD_CHARACTERISTIC   = CBUUID(string: "00060001-F8CE-11E4-ABF4-0002A5D5C51B")
//
//let WINEGARD_INFORMATION_SERVICE            = CBUUID(string: "180A")
//let WINEGARD_MANUFACTURER_NAME_CHAR_UUID    = CBUUID(string: "2A29")
//let WINEGARD_MODEL_NUMBER_CHAR_UUID         = CBUUID(string: "2A24")
//let WINEGARD_SERIAL_NUMBER_CHAR             = CBUUID(string: "2A25")
//let WINEGARD_HARDWARE_REVISION_CHAR_UUID    = CBUUID(string: "2A27")
//let WINEGARD_SOFTWARE_REVISION_CHAR_UUID    = CBUUID(string: "2A28")
//
////let WINEGARD_INFORMATION_CHAR         = CBUUID(string: "00060001-F8CE-11E4-ABF4-0002A5D5C51B")
////var winegardInformationService:         CBService?
////var manufacturerNameChar:               CBCharacteristic?
////var modelNumberChar:                    CBCharacteristic?
////var serialNumberChar:                   CBCharacteristic?
////var hardwareRevsion:                    CBCharacteristic?
////var softwareRevision:                   CBCharacteristic?
//
////Move to single service to two characteristics
//let WINEGARD_SPECTRUMANALYZER_SERVICE = CBUUID(string: "00007AF0-0000-1000-8000-00805F9B34FB")//CBUUID(string: "00060001-F8CE-11E4-ABF4-0002A5D5C51B")
//
//let WINEGARD_SCAN_CONFIGURATION_CHAR  = CBUUID(string: "0000F5B7-0000-1000-8000-00805F9B34FB")
//let WINEGARD_SCAN_DATA_CHAR           = CBUUID(string: "0000BC7B-0000-1000-8000-00805F9B34FB")
//
//let WINEGARD_LOGGING_DATA_CHAR        = CBUUID(string: "F26FFCD9-501A-4564-B4BB-32892DF2E639")
//
//let WINEGARD_CHANNEL_SERVICE          = CBUUID(string: "0006J001-F8CE-11E4-ABF4-0002A1D5C51B")
//let WINEGARD_CHANNEL_CHAR             = CBUUID(string: "0006J011-F8CE-11E4-ABF4-0002A5D5C51B")
//
//let WINEGARD_GENA_SERVICE             = CBUUID(string: "00060001-F8CE-11E4-ABF4-0002A5D5C51B")
//let WINEGARD_GENB_SERVICE             = CBUUID(string: "00060001-F8CE-11E4-ABF4-0002A5D5C51B")
/*============================================================================*/
//  OTA SERVICE CONSTANTS
/*============================================================================*/
//let COMMAND_START_BYTE    = 0x01
//let COMMAND_END_BYTE      = 0x17
////Bootloader command codes
//let VERIFY_CHECKSUM       = 0x31
//let GET_FLASH_SIZE        = 0x32
//let SEND_DATA             = 0x37
//let ENTER_BOOTLOADER      = 0x38
//let PROGRAM_ROW           = 0x39
//let VERIFY_ROW            = 0x3A
//let EXIT_BOOTLOADER       = 0x3B
// Bootloader status/Error codes


let SILICON_ID            = "SiliconID"
let SILICON_REV           = "SiliconRev"
let CHECKSUM_TYPE         = "CheckSumType"
let FLASH_ARRAY_ID        = "flashArrayID"
let FLASH_ROW_NUMBER      = "flashRowNumber"
let ROW_ID                = "RowID"
let ROW_COUNT             = "RowCount"
let ARRAY_ID              = "ArrayID"
let ROW_NUMBER            = "RowNumber"
let DATA_LENGTH           = "DataLength"
let DATA_ARRAY            = "DataArray"
let CHECKSUM_OTA          = "CheckSum"

let CHECK_SUM             = "checkSum"
let CRC_16                = "crc_16"
let ROW_DATA              = "rowData"

//US Channels
//2 THRU 6
//7 THRU 13
//14 THRU 51


let CHANNEL_DICTIONAIRY: [(channel: Int, range: CountableRange<Int>)] =
    [
    (2, 54..<60),
    (3, 60..<66),
    (4, 66..<72),
    (5, 76..<82),
    (6, 82..<88),
    (7, 174..<180),
    (8, 180..<186),
    (9, 186..<192),
    (10, 192..<198),
    (11, 198..<204),
    (12, 204..<210),
    (13, 210..<216),
    (14, 470..<476),
    (15, 476..<482),
    (16, 482..<488),
    (17, 488..<494),
    (18, 494..<500),
    (19, 500..<506),
    (20, 506..<512),
    (21, 512..<518),
    (22, 518..<524),
    (23, 524..<530),
    (24, 530..<536),
    (25, 536..<542),
    (26, 542..<548),
    (27, 548..<554),
    (28, 554..<560),
    (29, 560..<566),
    (30, 566..<572),
    (31, 572..<578),
    (32, 578..<584),
    (33, 584..<590),
    (34, 590..<596),
    (35, 596..<602),
    (36, 602..<608),
    (37, 608..<614),
    (38, 614..<620),
    (39, 620..<626),
    (40, 626..<632),
    (41, 632..<638),
    (42, 638..<644),
    (43, 644..<650),
    (44, 650..<656),
    (45, 656..<662),
    (46, 662..<668),
    (47, 668..<674),
    (48, 674..<680),
    (49, 680..<686),
    (50, 686..<692),
    (51, 692..<698),
    (52, 698..<704),
    (53, 704..<710),
    (54, 710..<716),
    (55, 716..<722),
    (56, 722..<728),
    (57, 728..<734),
    (58, 734..<740),
    (59, 740..<746),
    (60, 746..<752),
    (61, 752..<758),
    (62, 758..<764),
    (63, 764..<770),
    (64, 770..<776),
    (65, 776..<782),
    (66, 782..<788),
    (67, 788..<794),
    (68, 794..<800),
    (69, 800..<806),
    (70, 806..<812),
    (71, 812..<818),
    (72, 818..<824),
    (73, 824..<830),
    (74, 830..<836),
    (75, 836..<842),
    (76, 842..<848),
    (77, 848..<854),
    (78, 854..<860),
    (79, 860..<866),
    (80, 866..<872),
    (81, 872..<878),
    (82, 878..<884),
    (83, 884..<890)]



extension UIColor
{
    static var winegardGreen: UIColor{
        return UIColor(red: 58/255, green: 158/255, blue: 66/255, alpha: 1.0)
    }
    
    static var winegardRed: UIColor{
        return UIColor(red: 210/255, green: 35/255, blue: 42/255, alpha: 1.0)
    }
        
    static var winegardYellow: UIColor{
        return UIColor(red: 255/255, green: 203/255, blue: 5/255, alpha: 1.0)
    }
    
    static var winegardNavyBlue: UIColor{
        return UIColor(red: 0/255, green: 64/255, blue: 113/255, alpha: 1.0)
    }
    
    static var winegardBlue: UIColor{
        return UIColor(red: 0/255, green: 139/255, blue: 206/255, alpha: 1.0)
    }
    
    static var winegardBlueOp: UIColor{
        return UIColor(red: 205/255, green: 245/255, blue: 255/255, alpha: 1.0)
    }
    
    static var winegardLightBlue: UIColor{
        return UIColor(red: 245/255, green: 245/255, blue: 255/255, alpha: 1.0)
    }
    
    static var extraLightGray: UIColor{
        return UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1.0)
    }
}



//<a href="https://icons8.com/icon/8880/Device-Manager-Filled">Device manager filled icon credits</a>

//<a href="https://icons8.com/icon/53226/Small-Icons">Small icons icon credits</a>


//<a href="https://icons8.com/icon/8111/Thumbnails-Filled">Thumbnails filled icon credits</a>










