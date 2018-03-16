//
//  ChannelListViewModel.swift
//  RAZR
//
//  Created by Joe Bakalor on 3/13/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth


class ChannelListViewModel: NSObject
{
    enum ScanModes{
        case individual
        case summary
    }
    
    //  Variables
    var isConnected: Listen<Bool> = Listen(true)
    
    override init() {
        super.init()
        
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
        
        //char = connectedWinegardDevice.winegardGattProfile!.winegardScanConfigurationChar!
        guard let scanConfigurationCharacteristic = rayzarGatt.winegardScanConfigurationCharacteristic else { return }
        var testPacket: [UInt8] = [0x00]
        var data                = Data(bytes: testPacket)
        //writeValueFor(char: char, data: data)
        bleManager.write(value: data, toCharacteristic: scanConfigurationCharacteristic)
        
        //set to default channel range for channel summary scan
        testPacket              = [0x02, 0x02, 0x33]//single channel initiate
        data                    = Data(bytes: testPacket)
        bleManager.write(value: data, toCharacteristic: scanConfigurationCharacteristic)
    }
    
    func updateScanMode(mode: ScanModes){
        guard let scanConfigurationCharacteristic = rayzarGatt.winegardScanConfigurationCharacteristic else { return }
        
        switch mode {
        case .individual:
            
            //clear
            var testPacket: [UInt8] = [0x00]
            var data                = Data(bytes: testPacket)
            bleManager.write(value: data, toCharacteristic: scanConfigurationCharacteristic)
            //writeValueFor(char: char, data: data)
            //BLEConnectionManagerSharedInstance.bleService?.writeValueToCharacteristic(data as Data, characteristic: char )
            
            //set new state
            testPacket              = [0x03, 0x0A]
            data                    = Data(bytes: testPacket)
            bleManager.write(value: data, toCharacteristic: scanConfigurationCharacteristic)
            //writeValueFor(char: char, data: data)
            
        case .summary:
            
            //Clear
            var testPacket: [UInt8] = [0x00]
            var data                = Data(bytes: testPacket)
            bleManager.write(value: data, toCharacteristic: scanConfigurationCharacteristic)
            //BLEConnectionManagerSharedInstance.bleService?.writeValueToCharacteristic(data as Data, characteristic: char)
            
            //set new state
            testPacket              = [0x02, 0x02, 0x33]
            data                    = Data(bytes: testPacket)
            bleManager.write(value: data, toCharacteristic: scanConfigurationCharacteristic)
            
        }
    }
    
    func changeChannel(newChannelDataConfig: Data){
        
        guard let scanConfigurationCharacteristic = rayzarGatt.winegardScanConfigurationCharacteristic else {return}
        bleManager.write(value: newChannelDataConfig, toCharacteristic: scanConfigurationCharacteristic)
    }
    
}

extension ChannelListViewModel: WinegardSpectrumAnalyzerServiceDelegate
{
    func updatedCharacteristicValue(value: Data, characteristic: SpectrumAnalyzerCharacteristics) {
        switch characteristic {
        case .scanDataCharacteristic:
            
            var dataBytes   = [UInt8](repeating: 0, count: value.count)
            (value as NSData).getBytes(&dataBytes, length: value.count)
            
            //submit data for processing
            let result      = scanManager.processNewData(newDataBytes: dataBytes)
            print("Process new data result = \(result)")
            
        case .scanConfigurationCharacteristic:
            print("SpectrumAnalyzerViewModel: Recieved Scan Configuration")
        }
    }
    
}

extension ChannelListViewModel: PeripheralConnectionMonitorDelegate
{
    func updatedRSSI(rssi: Int) {
        
    }
    
    func connected() {
        
    }
    
    func disconnected(withReason reason: Error?) {
         isConnected.value = false
    }
    
    
}
