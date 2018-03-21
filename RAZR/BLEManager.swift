//
//  BLEManager.swift
//  RAZR
//
//  Created by Joe Bakalor on 3/13/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation
import JABLE
import CoreBluetooth



//  Peripheral scan delegate protocol
protocol PeripheralScanDelegate{
    func updatedPeripheralList(peripherals: [(peripheral: CBPeripheral, advData: FriendlyAdvdertismentData)])
    func scanFinished()
}

protocol PeripheralScanDelegateSingle {
    func foundPeripheral(peripheral: (peripheral: CBPeripheral, advData: FriendlyAdvdertismentData))
}

//  Peripheral connection monitor delegate protocol
protocol PeripheralConnectionMonitorDelegate {
    func updatedRSSI(rssi: Int)
    func connected()
    func disconnected(withReason reason: Error?)
}

protocol AutoGattDiscoveryDelegate{
    func gattDiscoveryCompleted()
    //func gattDiscoveryFaild()
}


//  Define service specific delegate protocols

//  Winegard information service delegate protocol
enum InformationServiceCharacteristics{
    case manufacturerName
    case modelNumber
    case serialNumber
    case hardwareRevision
    case softwareRevsion
}
protocol WinegardInformationServiceDelegate{
    func updatedCharacteristicValue(value: Data, characteristic: InformationServiceCharacteristics)
}



//  Winegard bootloader service delegate protocol
enum BootloaderServiceCharacteristics{
    case winegardBootloaderCharacteristic
}
protocol WinegardBootloaderServiceDelegate{
    func updatedCharacteristicValue(value: Data, characteristic: BootloaderServiceCharacteristics)
}


//  Winegard spectrum analyzer service delegate protocol
enum SpectrumAnalyzerCharacteristics{
    case scanConfigurationCharacteristic
    case scanDataCharacteristic
}
protocol WinegardSpectrumAnalyzerServiceDelegate{
    func updatedCharacteristicValue(value: Data, characteristic: SpectrumAnalyzerCharacteristics)
}

protocol WinegardLogServiceDelegate{
    func newLogData(value: Data)
}

enum ServiceDelegates{
    case informationService
    case bootloaderService
    case spectrumAnalyzerService
    case logServiceDelegate
}


//MARK: Base class
class BLEManager: JABLE
{
    enum ScanStatus{
        case scanning
        case stopped
        case pendingStart
    }
    
    enum ConnectionState{
        case pendingConnection
        case disconnected
        case connected
        case uknown
    }
    
    //  Gatt Instance
    //private var _gatt: JABLE_GATT.JABLE_GATTProfile?
    
    //  Protocol instances
    private var _peripheralScanDelegate: PeripheralScanDelegate?
    private var _peripheralScanDelegateSingle: PeripheralScanDelegateSingle?
    private var _peripheralConnectionMonitorDelegate: PeripheralConnectionMonitorDelegate?
    private var _autoGattDiscoveryDelegate: AutoGattDiscoveryDelegate?
    
    //  Service delegates
    private var _informationServiceDelegate: WinegardInformationServiceDelegate?
    private var _spectrumAnalayzerServiceDelegate: WinegardSpectrumAnalyzerServiceDelegate?
    private var _bootloaderServiceDelegate: WinegardBootloaderServiceDelegate?
    private var _logServiceDelegate: WinegardLogServiceDelegate?
    // Internal reference variables
    private var _discoveredPeripherals: [(peripheral: CBPeripheral, advData: FriendlyAdvdertismentData)] = []
    
    //  State variables
    var _ready: Bool = false
    var connectedPeripheralName: String?
    
    // Public getter variables
    var scanStatus: Listen<ScanStatus> = Listen(ScanStatus.stopped)//ScanStatus{ return self._scanStatus }
    var connectionState: Listen<ConnectionState> = Listen(ConnectionState.disconnected)//ConnectionState{ return self._connectionState }
    
    init(){
        
        // Initialize Gatt profile to pass to JABLE framework
        //_gatt = RayzarGATT.init().jableGattProfile
        
        //  Initialize JABLE with our gatt profile and set autodiscovery to true
        print("BLEManager: JABLE INTIALIZED")
        
        //super.init(jableDelegate: self, gattProfile: &rayzarGatt.jableGattProfile, autoGattDiscovery: true)
        super.init(jableDelegate: self, gattProfile: &rayzarGatt.jableGattProfile, autoGattDiscovery: true)
    }
    
}

//MARK: Access methods
extension BLEManager
{
    func setPeripheralScanDelegate(peripheralScanDelegate: PeripheralScanDelegate?){
        _peripheralScanDelegate = peripheralScanDelegate
    }
    
    func setPeripheralScanDelegateSingle(peripheralScanDelegateSingle: PeripheralScanDelegateSingle?){
        _peripheralScanDelegateSingle = peripheralScanDelegateSingle
    }
    
    func setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: PeripheralConnectionMonitorDelegate?){
        _peripheralConnectionMonitorDelegate = peripheralConnectionMonitorDelegate
    }
    
    func setAutoGattDiscoveryDelegate( autoGattDiscoveryDelegate: AutoGattDiscoveryDelegate){
        _autoGattDiscoveryDelegate = autoGattDiscoveryDelegate
    }
    
    func setServiceDelegate(delegate: Any?, forService: ServiceDelegates){

        switch forService {
        case .bootloaderService:
            _bootloaderServiceDelegate = (delegate as? WinegardBootloaderServiceDelegate)
            print("BLEManager: Set WinegardBootloaderServiceDelegate")
        case .informationService:
            _informationServiceDelegate = (delegate as? WinegardInformationServiceDelegate)
            print("Set informatoin service delegate")
        case .spectrumAnalyzerService:
            _spectrumAnalayzerServiceDelegate = (delegate as? WinegardSpectrumAnalyzerServiceDelegate)
        case .logServiceDelegate:
            _logServiceDelegate = (delegate as? WinegardLogServiceDelegate)
        }
        
    }
    
    func startScan(){
        if !_ready{
            scanStatus.value = .pendingStart
        }else{
            super.startScanningForPeripherals(withServiceUUIDs: nil)
        }
        
    }
    
    func stopScan(){
        if scanStatus.value == .scanning{
            super.stopScanning()
            scanStatus.value = .stopped
        }
    }
}

//MARK: JABLEDelegate
extension BLEManager: JABLEDelegate
{
    func jable(isReady: Void) {
        print("BLEManager: JABLE READY, START SCANNING")
        _ready = true
        if scanStatus.value == .pendingStart{
            super.startScanningForPeripherals(withServiceUUIDs: nil)
            scanStatus.value = .scanning
        }
    }
    
    func jable(foundPeripheral peripheral: CBPeripheral, advertisementData: FriendlyAdvdertismentData) {
        //  Check for duplicate, if duplicate then update data
        
        _peripheralScanDelegateSingle?.foundPeripheral(peripheral: (peripheral: peripheral, advData: advertisementData))
        var duplicate = false
        let new = _discoveredPeripherals.map({ (oldPeripheral, oldAdvDa)  -> (CBPeripheral, FriendlyAdvdertismentData) in
            
            if oldPeripheral == peripheral{// duplicate found
                duplicate = true
                var advDataCopy = advertisementData
                advDataCopy.seen = oldAdvDa.seen + 1
                advDataCopy.advIntervalEstimate = (advertisementData.timeStamp!.timeIntervalSince(oldAdvDa.timeStamp!)/Double(advDataCopy.seen)*1000*(1.2))
                advDataCopy.timeStamp = oldAdvDa.timeStamp
                return (peripheral, advDataCopy)// advertisementData)
                
            }else{//  not a duplicate
                
                return (oldPeripheral, oldAdvDa)
            }
        })

        //  Use new list if duplicate else append new peripheral
        guard duplicate == false else {
            //print("Duplicate found")
            _discoveredPeripherals = new
            return
        }
        _discoveredPeripherals.append((peripheral: peripheral, advertisementData))
        _peripheralScanDelegate?.updatedPeripheralList(peripherals: _discoveredPeripherals)

    }
    
    func jable(completedGattDiscovery: Void) {
        _autoGattDiscoveryDelegate?.gattDiscoveryCompleted()
    }
    
    func jable(updatedRssi rssi: Int) {
        
    }
    
    //  These won't be called since we are using the autoGattDiscovery feature
    func jable(foundServices services: [CBService]) {}
    
    //  These won't be called since we are using the autoGattDiscovery feature
    func jable(foundCharacteristicsFor service: CBService, characteristics: [CBCharacteristic]) {}
    
    //  These won't be called since we are using the autoGattDiscovery feature
    func jable(foundDescriptorsFor characteristic: CBCharacteristic, descriptors: [CBDescriptor]) {}
    
    //  Called whenever a characteristic value is updated or changed or read, etc...
    func jable(updatedCharacteristicValueFor characteristic: CBCharacteristic, value: Data) {
        
        //  Call appropriate delegate depending on which characteristic was updated
        switch characteristic.uuid{
        case WINEGARD_BOOTLOADER_CHARACTERISTIC:
            print("BLEManager: Received update for characteristic")
            _bootloaderServiceDelegate?.updatedCharacteristicValue(value: value, characteristic: .winegardBootloaderCharacteristic)
            
        case WINEGARD_MANUFACTURER_NAME_CHAR_UUID:
            print("BLEManager: Received update for name characteristic")
            _informationServiceDelegate?.updatedCharacteristicValue(value: value, characteristic: .manufacturerName)
            
        case WINEGARD_MODEL_NUMBER_CHAR_UUID:
            print("BLEManager: Received update model for characteristic")
            _informationServiceDelegate?.updatedCharacteristicValue(value: value, characteristic: .modelNumber)
            
        case WINEGARD_SERIAL_NUMBER_CHAR:
            print("BLEManager: Received update for characteristic")
            _informationServiceDelegate?.updatedCharacteristicValue(value: value, characteristic: .serialNumber)
            
        case WINEGARD_HARDWARE_REVISION_CHAR_UUID:
            print("BLEManager: Received update for characteristic")
            _informationServiceDelegate?.updatedCharacteristicValue(value: value, characteristic: .hardwareRevision)
            
        case WINEGARD_SOFTWARE_REVISION_CHAR_UUID:
            print("BLEManager: Received update for characteristic")
            _informationServiceDelegate?.updatedCharacteristicValue(value: value, characteristic: .softwareRevsion)
            
        case WINEGARD_SCAN_CONFIGURATION_CHAR:
            print("BLEManager: Received update for characteristic")
            _spectrumAnalayzerServiceDelegate?.updatedCharacteristicValue(value: value, characteristic: .scanConfigurationCharacteristic)
            
        case WINEGARD_SCAN_DATA_CHAR:
            print("BLEManager: Received update for characteristic")
            _spectrumAnalayzerServiceDelegate?.updatedCharacteristicValue(value: value, characteristic: .scanDataCharacteristic)
            
        case WINEGARD_LOGGING_DATA_CHAR:
            print("BLEManager: Received update for characteristic")
            _logServiceDelegate?.newLogData(value: value)//updatedCharacteristicValue(value: value, characteristic: .dataLoggingCharacteristic)
            
            let asciiValue = (NSString(bytes: (value as NSData).bytes, length: value.count, encoding: String.Encoding.ascii.rawValue)! as String)
            
            let trimmed =  asciiValue.replacingOccurrences(of: "\r", with: "")//, options: .regularExpression)
            logDataManager.logFileManager?.writeTextToLog(text: trimmed)
            
        default:
            print("Unknown Char")
        }
        
    }
    
    func jable(updatedDescriptorValueFor descriptor: CBDescriptor, value: Data) {
        
    }
    
    func jable(connected: Void) {
        print("Connected")
        connectionState.value = .connected

        self.connectedPeripheralName = super.peripheralName()

        //_connectionState = .connected
        _peripheralConnectionMonitorDelegate?.connected()
    }
    
    func jable(disconnectedWithReason reason: Error?) {
        connectionState.value = .disconnected
        //_connectionState = .disconnected
        _peripheralConnectionMonitorDelegate?.disconnected(withReason: reason)
    }
}
