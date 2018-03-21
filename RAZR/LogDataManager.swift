//
//  LogDataManager.swift
//  RAZR
//
//  Created by Joe Bakalor on 8/15/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth
let logDataManager = LogDataManager()


let enableLogging: [UInt8] = [0x01]//, 0x45, 0x92, 0x80, 0x30, 0xE7, 0xD6, 0x20, 0x00, 0x1A, 0xB3, 0xF0]
let disableLogging: [UInt8] = [0x00]
let ENABLE_LOGGING = Data(bytes: enableLogging) as Data
let DISABLE_LOGGING = Data(bytes: disableLogging) as Data
var dataLoggingEnabled = true

//

//  =============================  BASE CLASS  ====================================
class LogDataManager: NSObject
{
    /******************************************************************************/
    //  Class instances
    /******************************************************************************/
    var logFileManager: LogFileManager?
    var logDataStructures: LogDataStructures?
    var foundLogDataCharacteristic = false
    /******************************************************************************/
    //
    /******************************************************************************/
    var debugString: String = ""
    
    override init()
    {
        logFileManager = LogFileManager()
        debugString = ""
        
    }

}

//  ============================= BASIC LOGGING METHODS =============================
extension LogDataManager
{
    func loggingEnable(enable: Bool)
    {
        print("LogDataManager: Attempting to enable logging")
        guard let loggingChar = rayzarGatt.winegardDataLoggingCharacteristic else { return }
            if enable{
                print("LogDataManager: Enable notifications on logging char")
                bleManager.enableNotifications(forCharacteristic: loggingChar)
            //BLEConnectionManagerSharedInstance.bleService?.subscribeToNotificationsForCharacteristic(connectedWinegardDevice.winegardGattProfile!.winegardDataLoggingChar)
                print("LogDataManager: Send enable command for logging characteristic")
                bleManager.write(value: ENABLE_LOGGING, toCharacteristic: loggingChar)
                //BLEConnectionManagerSharedInstance.bleService?.writeValueToCharacteristic(ENABLE_LOGGING, characteristic: connectedWinegardDevice.winegardGattProfile!.winegardDataLoggingChar!)
                dataLoggingEnabled = true
            } else {
                dataLoggingEnabled = false
                bleManager.disableNotifications(forCharacteristic: loggingChar)
                //BLEConnectionManagerSharedInstance.bleService?.turnOffNotifications(connectedWinegardDevice.winegardGattProfile!.winegardDataLoggingChar!)
                //BLEConnectionManagerSharedInstance.bleService?.writeValueToCharacteristic(DISABLE_LOGGING, characteristic: connectedWinegardDevice.winegardGattProfile!.winegardDataLoggingChar!)
                bleManager.write(value: DISABLE_LOGGING, toCharacteristic: loggingChar)
            }
    }
    
    func log(logString: String)
    {
        debugString = debugString + "\r\(logString)"
    }
    
    func clearLog()
    {
        debugString = ""
    }
}

extension LogDataManager
{
    /******************************************************************************/
    // Called when the correct characteristic we were looking for is found,
    // save reference to characteristic
    /******************************************************************************/
//    @objc func foundCharacteristic(_ notification: Notification)
//    {
//        //TASK:  Add parameter to set when all charcteristics needed have been found
//        //(added setupComplet variable)
//        let characteristicList = (notification.userInfo as! [String: AnyObject])["characteristic"] as! [CBCharacteristic]
//
//        //if i do this it breaks the bootloader service??
//        for characteristic in characteristicList{
//
//            switch characteristic.uuid {
//
//            //only characteristic we are interested in
//            case WINEGARD_LOGGING_DATA_CHAR:
//                print("found logging data characteristic, subscribing to notifications")
//                connectedWinegardDevice.winegardGattProfile!.winegardDataLoggingChar = characteristic
//                //BLEConnectionManagerSharedInstance.bleService?.subscribeToNotificationsForCharacteristic(connectedWinegardDevice.winegardGattProfile!.winegardDataLoggingChar)
//                NotificationCenter.default.removeObserver(logDataManager, name: NSNotification.Name(rawValue: "foundCharacteristicID"), object:nil)
//                foundLogDataCharacteristic = true
//                //loggingEnable(enable: true)
//
//            default:
//                print("")
//            }
//        }
//
//    }
}
