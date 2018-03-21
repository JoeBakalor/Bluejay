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
    
    // Variables, these are the variables available to the view controller for binding
    var discoveredPeripherals: Listen<[(peripheral: CBPeripheral, advData: FriendlyAdvdertismentData)]> = Listen([])
    var connectionState: Listen<ConnectionState> = Listen(ConnectionState.disconnected)
    
    override init() {
        super.init()
        print("BLEManager: STARTED")
        bleManager.setAutoGattDiscoveryDelegate(autoGattDiscoveryDelegate: self)
    }
}

//MARK: Methods available for view controller to use
extension DeviceSelectorViewModel
{
    //  Perform anything necessary to close connection and or dependancies
    func close(){
        bleManager.stopScanning()
        bleManager.setPeripheralScanDelegate(peripheralScanDelegate: nil)
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: nil)
    }
    
    //  Do any setup necessary
    func open(){
        
        //  Set delegates first!!
        bleManager.setPeripheralScanDelegate(peripheralScanDelegate: self)
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: self)
        bleManager.diconnect()
        connectionState.value = .disconnected
        bleManager.startScan()
    }
    
    func connectTo(peripheral: CBPeripheral){
        connectionState.value = .attemptingConnection
        bleManager.connect(toPeripheral: peripheral, withTimeout: 5)
    }
}


//MARK: PeripheralConnectionMonitorDelegate, AutoGattaDiscoveryDelegate.  Manage connection changes,
//and completion of the Gatt Discovery process
extension DeviceSelectorViewModel: PeripheralConnectionMonitorDelegate, AutoGattDiscoveryDelegate
{
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


//MARK: PeripheralScanDelegate.  Manage scanning messages recieved from BLEManager
extension DeviceSelectorViewModel: PeripheralScanDelegate
{
    func updatedPeripheralList(peripherals: [(peripheral: CBPeripheral, advData: FriendlyAdvdertismentData)]) {
        //print("DeviceSelectorViewModel: Updated Peripheral List")
        discoveredPeripherals.value = peripherals
    }
    
    func scanFinished() {
        
    }
    
}
