//
//  InformationViewModel.swift
//  RAZR
//
//  Created by Joe Bakalor on 3/13/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation


class InformationViewModel: NSObject{
    
    //  Variables
    var deviceName: Listen<String> = Listen("Rayzer")
    var manufacturerName: Listen<String?> = Listen(nil)
    var modelNumber: Listen<String?> = Listen(nil)
    var serialNumber: Listen<String?> = Listen(nil)
    var hardwareRevision: Listen<String?> = Listen(nil)
    var softwareRevsion: Listen<String?> = Listen(nil)
    var isConnected: Listen<Bool> = Listen(true)

    override init() {
        super.init()
    }
}

extension InformationViewModel
{
    
    func open(){
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: self)
        bleManager.setServiceDelegate(delegate: self, forService: .informationService)
        readDeviceInformation()
    }
    
    func close(){
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: nil)
        bleManager.setServiceDelegate(delegate: nil, forService: .spectrumAnalyzerService)
    }
    
    func readDeviceInformation(){
        
        if let name = bleManager.connectedPeripheralName{
            deviceName.value = name
        }
        
        if let softwareRevisionCharacteristic = rayzarGatt.winegardSoftwareRevisionCharacteristic{
            bleManager.read(valueFor: softwareRevisionCharacteristic)
        }
        
        if let manufactureNameCharacteristic = rayzarGatt.winegardManufacturerNameCharacteristic{
            bleManager.read(valueFor: manufactureNameCharacteristic)
        }
        
        if let modelNumberCharacteristic = rayzarGatt.winegardModelNumberCharacteristic{
            bleManager.read(valueFor: modelNumberCharacteristic)
        }
        
        if let serialNumberCharacteristic = rayzarGatt.winegardSerialNumberCharacteristic{
            bleManager.read(valueFor: serialNumberCharacteristic)
        }
        
        if let hardwareRevisionCharacteristic = rayzarGatt.winegardHardwareRevisionCharacteristic{
            bleManager.read(valueFor: hardwareRevisionCharacteristic)
        }
    }
    
    func updateName(newName: String){
        
        let count = UInt8(newName.count)
        guard let data = (newName as NSString).data(using: String.Encoding.ascii.rawValue) else { return }
        var copy = data
        copy.insert(count, at: 0)
        copy.insert(0x01, at: 0)
        print("New Name Data")
        
        guard let configChar = rayzarGatt.winegardConfigurationCharacteristic else { return }
        bleManager.write(value: copy, toCharacteristic: configChar)
        //  Send new name to winegard device
    }
    
    func resetName(){
        
    }
}

extension InformationViewModel: WinegardInformationServiceDelegate
{
    func updatedCharacteristicValue(value: Data, characteristic: InformationServiceCharacteristics) {
        
        let valueString = String(data: value, encoding: .utf8)!
        
        switch characteristic {
        case .hardwareRevision:
            hardwareRevision.value = valueString
            
        case .manufacturerName:
            manufacturerName.value = valueString
            
        case .modelNumber:
            modelNumber.value = valueString
            
        case .serialNumber:
            serialNumber.value = valueString
            
        case .softwareRevsion:
            softwareRevsion.value = valueString
        }
    }
}

extension InformationViewModel: PeripheralConnectionMonitorDelegate
{
    func updatedRSSI(rssi: Int) {
        
    }
    
    func connected() {
        
    }
    
    func disconnected(withReason reason: Error?) {
        isConnected.value = false
    }
}











