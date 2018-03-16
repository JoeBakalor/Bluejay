
//
//  BLEServiceManager.swift
//
//  Created by Joe Bakalor on 5/7/15.
//  Copyright (c) 2015 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth

let throughputTesting = false
//an instance of BLEServiceManager is created for a peripheral after it has been connected
//manages peripheral activities

//NOTIFICATION DEFINES
let FOUND_SERVICES = Notification.Name(rawValue: "foundServiceID")
let CHAR_VALUE_UPDATED = Notification.Name(rawValue: "characteristicValueWasUpdatedID")
let FOUND_CHARACTERISTICS = Notification.Name(rawValue: "foundCharacteristicID")

protocol CharacteristicUpdateDelegate{
    func newValue(forCharacteristic characteristic: CBCharacteristic)
}


//  ================================ BASE CLASS =================================
class BLEServiceManager: NSObject, CBPeripheralDelegate
{
    //    static var Write(){
    //        return self.writeValueToCharacteristic(<#T##BLEServiceManager#>)
    //    }
    /******************************************************************************/
    //
    /******************************************************************************/
    var peripheral: CBPeripheral?
    var bleServices: [AnyObject]!
    var characteristics: [String : CBUUID]?//the controller should set this based on the characteristics that will be used
    var lastUpdate: Date
    var characteristicUpdateDelegate: CharacteristicUpdateDelegate?
    
    /******************************************************************************/
    //
    /******************************************************************************/
    init(initWithPeripheral peripheral: CBPeripheral)
    {
        lastUpdate = Date()
        super.init()
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        print("BLEServiceManager Initialized")
        
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    deinit
    {
        self.reset()
    }
    
    func setCharacteristicUpdateDelegate(delegate: CharacteristicUpdateDelegate?)
    {
        characteristicUpdateDelegate = delegate
    }
}

//  ================================ =================================
extension BLEServiceManager
{
    /******************************************************************************/
    //
    /******************************************************************************/
    func turnOffNotifications (_ characteristic: CBCharacteristic)
    {
        //print("attempting to turn off notifictions for \(characteristic)")
        self.peripheral!.setNotifyValue(false, for: characteristic)
    }
    
    /******************************************************************************/
    //  start discovering services for connected peripheral
    /******************************************************************************/
    func startDiscoveringServices(_ serviceToDiscover: [CBUUID]!)
    {
        //print("start discovering services for \(self.peripheral!) for \(serviceToDiscover)")
        self.peripheral!.discoverServices(nil)//serviceToDiscover)//BLEServiceUUIDofInterest as [CBUUID!])
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func writeValueToCharacteristic(_ value: Data, characteristic: CBCharacteristic)//, type: CBCharacteristicWriteType)
    {
        print("Trying to write value for characteristic \(characteristic)")
        //  Write value to specified Characteristic
        peripheral?.writeValue(value, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        
    }
    
    /******************************************************************************/
    //  Read value for specified characteristic
    /******************************************************************************/
    func readCharacteristicValue (_ characteristic: CBCharacteristic)
    {
        //print("readCharacteristicValue called")
        if let peripheralToReadFrom = peripheral{
            peripheralToReadFrom.readValue(for: characteristic)
        }
    }
    
    /******************************************************************************/
    //  subscribe to Notifications for specified characteristic
    /******************************************************************************/
    func subscribeToNotificationsForCharacteristic(_ characteristic: CBCharacteristic!)
    {
        //print("getting ready to subscribe to notifications")
        //this works for both notifications and indications, yes, that is confusing
        self.peripheral!.setNotifyValue(true, for: characteristic)
        print("subscribed to notifications for \(characteristic)")
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        //print("found a service: \(String(describing: peripheral.services))")
        
        //peripheral.services.removeAll(keepCapacity: true)
        bleServices = peripheral.services
        let count = peripheral.services!.count
        //print("how many service \(count)")
        
        //if the peripheral services were discovered for is not the current peripheral then return
        if (peripheral != self.peripheral){print("reported as wrong peripheral");return}
        
        //if there is an error, report it
        if (error != nil){print("there was an error \(String(describing: error))");return}
        
        //if the peripheral doesn't have any serivices, report it and return
        if ((peripheral.services == nil) || (peripheral.services!.count == 0)){print("no services found");return}
        
        //let testVar = peripheral.services
        
        //save the service reference to service and send it to the notification observer
        //print("set user details")
        let service = ["service": bleServices as! [CBService], "count": count as AnyObject] as [String : Any]
        //print("user details set")
        
        //controller should add an observer for this notification to informed of services found
        NotificationCenter.default.post(name: FOUND_SERVICES, object: self, userInfo: service)
        //print("posted notification for found service")
        
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?)
    {
        print("Updated notification for \(characteristic)")
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
    {
        print("DID WRITE VALUE FOR CHAR \(characteristic)")
        if let writeError = error
        {
            print("ERROR WRITING TO CHARACTERISTIC = \(writeError)")
        }
    }
    
    //  Called when characteristic value updated on peripheral
    /******************************************************************************/
    //
    /******************************************************************************/
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        //print("CHARACTERISTIC DATA RECIEVED for \(characteristic)")
        //Custom handler for OTA Process
        if characteristic.uuid == WINEGARD_BOOTLOADER_CHARACTERISTIC{
            //process notification seperately
            if error == nil{
                print("Recieved bootloader char update at BLE SERVICE MANAGER")
                var otaUpdate: [String: AnyObject]? = [:]
                var data               : Data?
                var dataLength         : Int?
                
                if characteristic.value != nil{
                    
                    data            = characteristic.value as Data!
                    dataLength      = data!.count as Int!
                    var dataBytes   = [UInt8](repeating: 0, count: data!.count)
                    (data! as NSData).getBytes(&dataBytes, length: data!.count)
                    
                    otaUpdate!["dataBytes"] = dataBytes as AnyObject
                    otaUpdate!["characteristic"] = characteristic as AnyObject
                    otaUpdate!["error"] = error as AnyObject
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "otaCharacteristicUpdateID"), object: self, userInfo: otaUpdate)
                }
            } else {
                print("Error recieving bootloader char")
            }
            
        } else if characteristic.uuid == WINEGARD_LOGGING_DATA_CHAR {
            
            var data               : Data?
            var dataLength         : Int?
            
            data            = characteristic.value as Data!
            dataLength      = data!.count as Int!
            
            let asciiValue = (NSString(bytes: (data! as NSData).bytes, length: dataLength!, encoding: String.Encoding.ascii.rawValue)! as String)
            
            let trimmed =  asciiValue.replacingOccurrences(of: "\r", with: "")//, options: .regularExpression)
            logDataManager.logFileManager?.writeTextToLog(text: trimmed)
            
        } else {
            
            if throughputTesting{
                //var data: Data?
                //var dataLength: Int?
                //var characteristicData = characteristic.value as Data!
                //let data = characteristic.value as! Data
                //let dataLength = data.count as Int
                
                //var dataBytes = [UInt8](repeating: 0, count: data!.count)
                //(data! as NSData).getBytes(&dataBytes, length: data!.count)
                //print("\(Date().timeIntervalSince(lastUpdate))")
                //print("\(Date().timeIntervalSince(lastUpdate)): Bytes Recieved: \(dataLength)")
                //lastUpdate = Date()
                
            } else {
                //print("New Char Data")
                var characteristicDetails: [String: AnyObject]?
                
                //this should replace the rest//this is redundant, its the same thing with two names, bad coding. Make sure we can delete the first one before deleting
                //characteristicDetails = ["characteristicThatWasUpdated": characteristic]//use this to verify we recieve an update for the right characteristic
                characteristicDetails = ["characteristicWithNewValue": characteristic]
                
                //send out notification// user application should add an observer for this notification
                NotificationCenter.default.post(name: CHAR_VALUE_UPDATED, object: self, userInfo: characteristicDetails)
                
                if let delegate = characteristicUpdateDelegate{
                    delegate.newValue(forCharacteristic: characteristic)
                }
            }
        }
        
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        //print("found a characteristic\(service.characteristics)")//debug, report the characteristics found for the service
        
        if (peripheral != self.peripheral){print("wrong peripheral");return}
        if (error != nil){print("error");return}
        
        let characteristic = ["characteristic" as NSObject: service.characteristics as AnyObject, "ownerService" as NSObject: service as AnyObject]
        
        //controller should add an observer for this notification
        NotificationCenter.default.post(name: FOUND_CHARACTERISTICS, object: self, userInfo: characteristic)
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func reset()
    {
        print("reset called")
        //clear peripheral
        if peripheral != nil{peripheral = nil}
    }
    
}

extension Date
{
    var formatted: String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'hh:mm:ss.SS' "//use HH for 24 hour scale and hh for 12 hour scale
        formatter.timeZone = TimeZone.autoupdatingCurrent//(forSecondsFromGMT: 4)
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}





