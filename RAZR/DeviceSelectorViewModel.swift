//
//  DeviceSelectorViewModel.swift
//  RAZR
//
//  Created by Joe Bakalor on 3/13/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth
import JABLE


let bleManager = BLEManager()

//MARK: Base class
class DeviceSelectorViewModel: NSObject
{
    enum ConnectionState{
        case disconnected
        case attemptingConnection
        case connectionFailed
        case connected
    }
    
    // Variables
    var discoveredPeripherals: Listen<[(peripheral: CBPeripheral, advData: FriendlyAdvdertismentData)]> = Listen([])
    var connectionState: Listen<ConnectionState> = Listen(ConnectionState.disconnected)
    
    override init() {
        super.init()
        print("BLEManager: STARTED")
        bleManager.setAutoGattDiscoveryDelegate(autoGattDiscoveryDelegate: self)
        
    }
    
    func close(){
        bleManager.stopScanning()
        bleManager.setPeripheralScanDelegate(peripheralScanDelegate: nil)
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: nil)
    }
    
    func open(){
        bleManager.startScan()
        bleManager.setPeripheralScanDelegate(peripheralScanDelegate: self)
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: self)
    }
}


//MARK: Internal access methods
extension DeviceSelectorViewModel: PeripheralConnectionMonitorDelegate, AutoGattDiscoveryDelegate
{
    func connectTo(peripheral: CBPeripheral){
        connectionState.value = .attemptingConnection
        bleManager.connect(toPeripheral: peripheral, withTimeout: 5)
    }
    
    func gattDiscoveryCompleted() {
        connectionState.value = .connected
    }
    
    func updatedRSSI(rssi: Int) {
         
    }
    
    func connected() {
        //wait for gatt discovery to complete to set connected
    }
    
    func disconnected(withReason reason: Error?) {
        connectionState.value = .connectionFailed
    }
    
    func reset(){
        //  Clear discovered peripherals and disconnect peripheral if there is an active connection
        discoveredPeripherals.value = []
        bleManager.diconnect()
        connectionState.value = .disconnected
    }
}

extension DeviceSelectorViewModel: PeripheralScanDelegate
{
    func updatedPeripheralList(peripherals: [(peripheral: CBPeripheral, advData: FriendlyAdvdertismentData)]) {
        print("DeviceSelectorViewModel: Updated Peripheral List")
        discoveredPeripherals.value = peripherals
    }
    
    func scanFinished() {
        
    }
    
}
