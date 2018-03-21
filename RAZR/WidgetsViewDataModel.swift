//
//  WidgetsViewDataModel.swift
//  RAZR
//
//  Created by Joe Bakalor on 3/13/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation

class WidgetsViewDataModel: NSObject{
    
    // Variables, these are the variables available to the view controller for binding
    var isConnected: Listen<Bool> = Listen(true)
    
    override init() {
        super.init()
        if startingInBlootloaderMode == false{
            logDataManager.loggingEnable(enable: true)
        }
    }
}

//MARK: Methods available for view controller to use
extension WidgetsViewDataModel
{
    func open(){
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: self)
    }
    
    func close(){
        bleManager.setPeripheralConnectionMonitorDelegate(peripheralConnectionMonitorDelegate: nil)
    }
}


//MARK: PeripheralConnectionMonitorDelegate, monitor changes in connecetion state and signal strength
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
