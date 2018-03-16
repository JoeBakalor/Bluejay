//
//  SpectrumAnalyzerViewModel.swift
//  RAZR
//
//  Created by Joe Bakalor on 3/13/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation


class SpectrumAnalyzerViewModel: NSObject{
    
    // Variables
    var recievedData: Listen<Data?> = Listen(nil)
    var isConnected: Listen<Bool> = Listen(true)
    
    override init() {
        super.init()
        open()
    }
    
    func open(){
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: self)
        bleManager.setServiceDelegate(delegate: self, forService: .spectrumAnalyzerService)
        //  Enable notifications on scan data characteristic
        guard let scanDataCharacteristic = rayzarGatt.winegardScanDataCharacteristic else {return}
        bleManager.enableNotifications(forCharacteristic: scanDataCharacteristic)
        configureDefaultScanSettings()
    }
    
    func close(){
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: nil)
        guard let scanDataCharacteristic = rayzarGatt.winegardScanDataCharacteristic else {return}
        bleManager.disableNotifications(forCharacteristic: scanDataCharacteristic)
        bleManager.setServiceDelegate(delegate: nil, forService: .spectrumAnalyzerService)
    }
    
    func configureDefaultScanSettings(){
        
        guard let scanConfigurationCharacteristic = rayzarGatt.winegardScanConfigurationCharacteristic else {return}
        scanManager.spectrumScanConfig = scanManager.defaultSpectrumScanConfig
        
        // Send test packet
        let testPacket: [UInt8] = [0x01, 0x07, 0x45, 0x92, 0x80, 0x30, 0xE7, 0xD6, 0x20, 0x00, 0x1A, 0xB3, 0xF0, 0x01]
        let data = Data(bytes: testPacket)
        bleManager.write(value: data, toCharacteristic: scanConfigurationCharacteristic)
    }
    
    func updateScanConfiguration(configuration: Data){
        guard let scanConfigurationCharacteristic = rayzarGatt.winegardScanConfigurationCharacteristic else {return}
        
        bleManager.write(value: configuration, toCharacteristic: scanConfigurationCharacteristic)
    }
}


//MARK: Winegard Spectrum Analyzer Service Delegate
extension SpectrumAnalyzerViewModel: WinegardSpectrumAnalyzerServiceDelegate
{
    func updatedCharacteristicValue(value: Data, characteristic: SpectrumAnalyzerCharacteristics) {
        switch characteristic {
        case .scanDataCharacteristic:
            print("SpectrumAnalyzerViewModel: Received Scan Data")
            //var data: Data?
            //var dataLength: Int?
            
            //if characteristicData!.value != nil{
            
                //data = characteristicData!.value as Data!
                //dataLength = data!.count as Int!
            
                var dataBytes = [UInt8](repeating: 0, count: value.count)
                (value as NSData).getBytes(&dataBytes, length: value.count)
            
                //submit data for processing
                print("Data for scan manager = \(String(describing: value.hexEncodedString()))")
                let result = scanManager.processNewData(newDataBytes: dataBytes)
                //print("Process new data result = \(result)")
            
                if result == "SUCCESS"{
                    print("redraw graph")
                    recievedData.value = value//redrawWithNewData()//update displayed data
                }
            //}
        case .scanConfigurationCharacteristic:
            print("SpectrumAnalyzerViewModel: Recieved Scan Configuration")
        }
    }
    
    
}


//MARK: Peripheral Connection Monitor Delegate
extension SpectrumAnalyzerViewModel: PeripheralConnectionMonitorDelegate
{
    func updatedRSSI(rssi: Int) {
        
    }
    
    func connected() {
        
    }
    
    func disconnected(withReason reason: Error?) {
        isConnected.value = false
    }
    
    
}
