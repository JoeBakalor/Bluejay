//
//  OTAViewModel.swift
//  RAZR
//
//  Created by Joe Bakalor on 3/13/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth
import JABLE

class OTAViewModel: NSObject
{
    
    // Variables
    var isConnected: Listen<Bool> = Listen(true)
    var fileName: Listen<String?> = Listen(nil)
    var updateStartTime: Listen<Date?> = Listen(nil)
    var updateEndTime: Listen<Date?> = Listen(nil)
    var currentStatus: Listen<String?> = Listen(nil)
    var percentComplete: Listen<Float?> = Listen(nil)
    
    
    var otaFileManager: OTAFileManager!
    var bootloader: BootloaderStateMachine?
    var fileArray: Listen<[(fileName: String, fileContent: [String])]> = Listen([])
    var selectedFileIndex: IndexPath?
    var firmwareUpdateChecker: FirmwareUpdateManager!
    
    override init() {
        super.init()
        
        firmwareUpdateChecker = FirmwareUpdateManager()
        otaFileManager = OTAFileManager()
        fileArray.value = otaFileManager.loadAvailableOtaFiles()
    
        enterIntoBootloaderMode()
        
    }
    func returnFromDisconnection(){
        
        guard let bootChar = rayzarGatt.winegardBootloaderCharacteristic else { return }
        print("OTAViewModel: Enabled Notifications on Bootloader Characteristic")
        bleManager.enableNotifications(forCharacteristic: bootChar)
        bootloader = BootloaderStateMachine(bootChar: bootChar)
    }
    
    func open(){
        firmwareUpdateChecker.checkForNewFirmware()
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: self)
        bleManager.setServiceDelegate(delegate: self, forService: .bootloaderService)
        
    }
    
    func close(){
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: nil)
        bleManager.setServiceDelegate(delegate: nil, forService: .bootloaderService)
    }
    
    
    
}

extension OTAViewModel
{
    
    func startOtaUpdate(){
        
        guard let fileIndex = selectedFileIndex else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.otaFileManager.getOtaFormattedFile(forFileContent: self.fileArray.value[fileIndex.row].fileContent, completion:
                {
                    (header, data, row) in
                    self.bootloader?.setFile(fileToSend: (header, data, row))
            })
        }
    }
    
    func selectFileIndex(index: IndexPath){
        selectedFileIndex = index
    }
    
}

extension OTAViewModel: WinegardBootloaderServiceDelegate
{
    func updatedCharacteristicValue(value: Data, characteristic: BootloaderServiceCharacteristics) {
        
        print("Recieved bootloader char update at BLE SERVICE MANAGER")
        var otaUpdate: [String: AnyObject]? = [:]
        
        var dataBytes   = [UInt8](repeating: 0, count: value.count)
        (value as NSData).getBytes(&dataBytes, length: value.count)
                
        otaUpdate!["dataBytes"] = dataBytes as AnyObject
        otaUpdate!["characteristic"] = characteristic as AnyObject
        otaUpdate!["error"] = nil //as AnyObject
                
        NotificationCenter.default.post(name: Notification.Name(rawValue: "otaCharacteristicUpdateID"), object: self, userInfo: otaUpdate)
    }
    
    func enterIntoBootloaderMode(){
        
        guard let configChar = rayzarGatt.winegardConfigurationCharacteristic else { return }
        let testPacket: [UInt8] = [0x02]
        let data = Data(bytes: testPacket)
        print("OTAViewModel: Send packet to reset razyar into bootloader mode")
        bleManager.write(value: data, toCharacteristic: configChar)
    }
    
}

extension OTAViewModel: PeripheralConnectionMonitorDelegate
{
    func updatedRSSI(rssi: Int) {
        
    }
    
    //  This should never be called here
    func connected() {
        returnFromDisconnection()
        print("OTAViewModel: RE-CONNECTED TO RAYZAR PERIPHERAL")
        
    }
    
    
    func disconnected(withReason reason: Error?) {
        print("OTAViewModel: DISCONNECTED FROM RAYZAR PERIPHERAL")
        bleManager.setPeripheralScanDelegateSingle(peripheralScanDelegateSingle: self)
        bleManager.startScan()
        //isConnected.value = false
    }
}

extension OTAViewModel: PeripheralScanDelegateSingle
{
    func foundPeripheral(peripheral: (peripheral: CBPeripheral, advData: FriendlyAdvdertismentData)) {
        guard let name = peripheral.advData.localName else { return }
        if name == "RAYZAR"{
            bleManager.stopScan()
            bleManager.connect(toPeripheral: peripheral.peripheral, withTimeout: 5)
        }
    }
}










