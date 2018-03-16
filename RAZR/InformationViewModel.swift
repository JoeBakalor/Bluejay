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
    var manufacturerName: Listen<String?> = Listen(nil)
    var modelNumber: Listen<String?> = Listen(nil)
    var serialNumber: Listen<String?> = Listen(nil)
    var hardwareRevision: Listen<String?> = Listen(nil)
    var softwareRevsion: Listen<String?> = Listen(nil)
    var isConnected: Listen<Bool> = Listen(true)

    override init() {
        super.init()
       
    }
    
    func open(){
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: self)
        bleManager.setServiceDelegate(delegate: self, forService: .informationService)
        readDeviceInformation()
    }
    
    func close(){
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: nil)
        bleManager.setServiceDelegate(delegate: nil, forService: .spectrumAnalyzerService)
    }
}

extension InformationViewModel
{
    func readDeviceInformation(){
        
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











