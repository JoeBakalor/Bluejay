//
//  WidgetsViewDataModel.swift
//  RAZR
//
//  Created by Joe Bakalor on 3/13/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation

class WidgetsViewDataModel: NSObject{
    
    // Variables
    var isConnected: Listen<Bool> = Listen(true)
    
    override init() {
        super.init()
        logDataManager.loggingEnable(enable: true)
    }
    
    func open(){
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: self)
    }
    
    func close(){
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: nil)
    }
}

extension WidgetsViewDataModel: PeripheralConnectionMonitorDelegate
{
    func updatedRSSI(rssi: Int) {
        
    }
    
    //  This should never be called here
    func connected() {}
    
    
    func disconnected(withReason reason: Error?) {
        isConnected.value = false
    }
}
