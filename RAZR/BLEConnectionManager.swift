
/*===============================================================================================================================*/
//
//  BLEConnectionManager.swift
//
//  Created by Joe Bakalor on 5/7/15.
//  Copyright (c) 2015 Joe Bakalor. All rights reserved.
//
//  The BLEConnectionManager is responsible
/*===============================================================================================================================*/
import Foundation
import CoreBluetooth

let BLEConnectionManagerSharedInstance = BLEConnectionManager();
var isConnectedToPeripheral: Bool?
//add to viewDidLoad for controller you wish to be notified when a peripheral is found
//NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("foundPeripheral:"), name: "foundPeripheralID", object: nil)

//NOTIFICATION DEFINES
let CONNECTION_ATTEMPT_CANCELLED = Notification.Name(rawValue: "connectionAttemptCanceledID")
let CONNECTED_TO_PERIPHERAL = Notification.Name(rawValue: "connectedToPeripheralID")
let CONNECTION_FAILED = Notification.Name(rawValue: "connectionToPeripheralFailedID")
let FOUND_PERIPHERAL = Notification.Name(rawValue: "foundPeripheralID")
let BLUETOOTH_POWERED_ON = Notification.Name(rawValue: "bluetoothNowPoweredOnID")
//  ================================ BASE CLASS =================================
class BLEConnectionManager: NSObject, CBPeripheralDelegate
{
    /******************************************************************************/
    //  VARIABLES
    /******************************************************************************/
    var services: [CBUUID]? //controller needs to set this array before using functionality
    var RSSIread: NSNumber = 0
    var valid: Bool = false;
    var centralManager: CBCentralManager!
    var peripheralBLE: CBPeripheral!  //  Use to store reference to peripheral that is connected
    var peripheralList: [CBPeripheral]? //list of peripherals discovered
    var peripheralPendingConneciton: CBPeripheral?
    var connectionTimeoutTimer = Timer()
    var bleService: BLEServiceManager?//set after a connection is made
    
    /******************************************************************************/
    //
    /******************************************************************************/
    override init()
    {
        //super.viewDidLoad()
        //print("did init central manager")
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BLEConnectionManager
{
    /******************************************************************************/
    //
    /******************************************************************************/
    func startScanning(_ servicesToLookFor: [CBUUID])
    {
        //print("entered start scanning loop")
        print("\(centralManager)")
        
        let servicesOfInterest = [CBUUID(string: "CAB5")]//, CBUUID(string: "CBBB"), CBUUID(string: "7AF0") ]
        
        print("servicesOfInterest = \(servicesOfInterest)")
        print("servicesToLookFor = \(servicesToLookFor)")
        
        if let central = centralManager
        {
            //print("started scanning")//debug, remove for release
            //central.scanForPeripherals(withServices: servicesToLookFor, options: nil)
            if !testing{
            central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
            }
            //print("are we getting stuck before this")
        }
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func stopScanning()
    {
        if let central = centralManager{central.stopScan()}
    }
    
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func connectToPeripheral(_ peripheralToConnect: CBPeripheral?)
    {
        peripheralPendingConneciton = peripheralToConnect
        connectionTimeoutTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.connectionTimeout), userInfo: nil, repeats: false);
        
        if let newPeripheral: CBPeripheral = peripheralToConnect
        {
            self.peripheralBLE = peripheralToConnect//save peripheral for service operations
            centralManager?.connect(newPeripheral, options: nil)//connect to peripheral
            print("connecting to peripheral so stop scanning")
            self.stopScanning()
        }
    }
    
    //  DESCRIPTION:  invalidates connection timer and calls cancel connection attempt.  THIS FUNCTION IS REDUNDANT, SHOULD USE
    /******************************************************************************/
    //
    /******************************************************************************/
    @objc func connectionTimeout()
    {
        connectionTimeoutTimer.invalidate()//timer.invalidate()
        cancelConnectionAttempt()
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func disconnectPeripheral()
    {
        if let peripheral = self.peripheralBLE
        {
            if let central = centralManager
            {
                central.cancelPeripheralConnection(peripheral)
            }
        }
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func cancelConnectionAttempt()
    {
        print("Cancel Connection Attempt")
        
        if let central = centralManager
        {
            central.cancelPeripheralConnection(peripheralPendingConneciton!)
        }
        
        NotificationCenter.default.post(name: CONNECTION_ATTEMPT_CANCELLED, object: self, userInfo: nil)
    }
    
    // This should be implimented by getter and setter at the variable definition maybe
    /******************************************************************************/
    //
    /******************************************************************************/
    func getPeripheral() -> CBPeripheral?
    {
        var workingPeripheralVar: CBPeripheral?
        let peripheralToReturn = peripheralBLE
        
        if peripheralToReturn != nil
        {
            workingPeripheralVar = peripheralToReturn!
        }
        else
        {
            print("Peripheral Not found")
        }
        return workingPeripheralVar
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func getRSSI() -> NSString
    {
        //need to update this function to accomodate deprication of RSSI
        if let currentPeripheral = self.peripheralBLE
        {
            print("made it to read RSSI")
            currentPeripheral.readRSSI()
            if let _ = currentPeripheral.rssi
            {
                print("\(currentPeripheral.rssi)")
                RSSIread = currentPeripheral.rssi!
            }
            valid = true
        }
        
        if valid == false {return "not read"}
        else{valid = false; return "\(RSSIread)" as NSString}
        
    }
    
    //  DESCRIPTION:  Clear peripheral and associated GATT data// Looks unsafe, need to revise probably
    /******************************************************************************/
    //
    /******************************************************************************/
    func clearDevices()
    {
        self.bleService = nil
        self.peripheralBLE = nil
    }
    
    
}

//  ====================== CENTRAL MANAGER DELEGATE  ==============================
extension BLEConnectionManager:  CBCentralManagerDelegate
{
    /******************************************************************************/
    //
    /******************************************************************************/
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        
        print("max write value = \(peripheral.maximumWriteValueLength(for: .withResponse))")
        //  Connection successful so cancel timeout timer
        connectionTimeoutTimer.invalidate()
        isConnectedToPeripheral = true
        print("connected to peripheral")
        if (peripheral as CBPeripheral? == nil){return}
        
        // Create new service class
        if (peripheral == self.peripheralBLE)
        {
            print("create service class")
            self.bleService = BLEServiceManager(initWithPeripheral: peripheral)//creates a class instance of BLEservices assigned to self.bleService//nameing could be more clear here
        }
        NotificationCenter.default.post(name: CONNECTED_TO_PERIPHERAL, object: self, userInfo: nil)
        
        // Stop scanning for new devices
        central.stopScan()
    }
    
    //centralmangaer
    /******************************************************************************/
    //
    /******************************************************************************/
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
    {
        NotificationCenter.default.post(name: CONNECTION_FAILED, object: self, userInfo: nil)
        if (peripheral as CBPeripheral? == nil){return}
        
        isConnectedToPeripheral = false
        print("disconnected from peripheral with error \(error)")
        
        // See if it was our peripheral that disconnected
        if (peripheral == self.peripheralBLE)
        {
            self.bleService = nil
            self.peripheralBLE = nil
        }
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        // Be sure to retain the peripheral or it will fail during connection.
        //print("peripheral found")
        let peripheralCopy: CBPeripheral? = peripheral
        var peripheralDetails: [String: AnyObject]?
        
        //print advertisement data for debugging
        //print("advertisement data\(advertisementData)")
        
        //make sure peripheral is valid and then start populating peripheral details to pass
        if let newPeripheral = peripheralCopy
        {
            peripheralDetails = ["peripheralFound": newPeripheral, "RSSI": RSSI, "addData": advertisementData as AnyObject]
        }
        
        //check if connectable data present and add to details if it is
        if let connectable: AnyObject? = advertisementData["kCBAdvDataIsConnectable"] as AnyObject??
        {
            //print("connectable: \(connectable!)")
            peripheralDetails!["connectable"] = connectable
        }
        
        //check if local device name is present
        if let deviceLocalName: AnyObject? = advertisementData["kCBAdvDataLocalName"] as AnyObject??
        {
            //print("local device name: \(deviceLocalName)")
            if deviceLocalName == nil
            {
                peripheralDetails!["localName"] = "Unknown Name" as AnyObject?
            }
            else
            {
                peripheralDetails!["localName"] = deviceLocalName
            }
        }
        
        //check if there are advertised services present in advertisement
        if let advertisedServices = advertisementData["kCBAdvDataServiceUUIDs"] as! [CBUUID]!
        {
            //print("advertised services: \(advertisedServices)")
            peripheralDetails!["advertisedServices"] = advertisedServices as AnyObject?
        }
        
        //check if TX power is present in advertisement
        if let advertisedTxPower = advertisementData["kCBAdvDataTxPowerLevel"] as! Int!
        {
            //print("advertised TX power: \(advertisedTxPower)")
            peripheralDetails!["advertisedTXpower"] = advertisedTxPower as AnyObject?
        }
        
        //check if manufacture data is present in advertisement
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as! Data!
        {
            //print("manufacturer data: \(manufacturerData)")
            peripheralDetails!["manufacturerData"] = manufacturerData as AnyObject?
        }
        
        //send notification out to observer with newly discovered peripheral details
        NotificationCenter.default.post(name: FOUND_PERIPHERAL, object: self, userInfo: peripheralDetails )
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        switch (central.state)
        {
        case CBManagerState.poweredOff://CBCentralManagerState.poweredOff:
            self.clearDevices()
            break
        case CBManagerState.unauthorized:
            // Indicate to user that the iOS device does not support BLE.
            break
        case CBManagerState.unknown:
            // Wait for another event
            break
        case CBManagerState.poweredOn:
            print("does this get called")
            //  User app needs to add observer for this and cannot start scanning until reveiving this notification
            NotificationCenter.default.post(name: BLUETOOTH_POWERED_ON, object: self, userInfo: nil )
            break
        case CBManagerState.resetting:
            //self.clearDevices()
            break
        case CBManagerState.unsupported:
            break
        }
    }
    
}


extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
































