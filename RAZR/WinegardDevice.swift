//
//  WinegardDevice.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/8/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth


//Winegard device information database
//Primary used for storing references to items in GATT database
class WinegardDevice: NSObject
{
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    struct gattProfile
    {
        //OTA Service
        var winegardOTAService:                 CBService?
        var winegardBootloaderChar:             CBCharacteristic?
        
        //Information Service
        var winegardInformationService:         CBService?
        var manufacturerNameChar:               CBCharacteristic?
        var modelNumberChar:                    CBCharacteristic?
        var serialNumberChar:                   CBCharacteristic?
        var hardwareRevsion:                    CBCharacteristic?
        var softwareRevision:                   CBCharacteristic?
        //var winegardInformationChar:            CBCharacteristic?
        
        //Winegard Spectrum Analyzer Service
        var winegardSpectrumAnalyzerService:    CBService?
        var winegardSpectrumAnalyzerChar:       CBCharacteristic?
        var winegardDataLoggingChar:            CBCharacteristic?
        
        var winegardScanConfigurationChar:      CBCharacteristic?
        var winegardScanDataChar:               CBCharacteristic?
        var winegardChannelService:             CBService?
        var winegardChannelCharacteristic:      CBCharacteristic?
        
        
    }
    
    var winegardDevice: CBPeripheral?
    var winegardGattProfile: gattProfile?
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    override init()
    {
        winegardGattProfile = gattProfile()
    }
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
}
