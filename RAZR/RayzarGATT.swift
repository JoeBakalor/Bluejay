//
//  RayzarGATT.swift
//  RAZR
//
//  Created by Joe Bakalor on 2/21/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation
import JABLE
import CoreBluetooth


//  GATT Instance.  Access services and characteristics through this
var rayzarGatt = RayzarGATT()

//  BOOTLOADER SERVICE AND CHARACTERISTICS
let WINEGARD_OTA_SERVICE                   = CBUUID(string: "00060000-F8CE-11E4-ABF4-0002A5D5C51B")
    let WINEGARD_BOOTLOADER_CHARACTERISTIC = CBUUID(string: "00060001-F8CE-11E4-ABF4-0002A5D5C51B")

//  WINEGARD INFORMATION SERVICE AND CHARACTERISTICS
let WINEGARD_INFORMATION_SERVICE                = CBUUID(string: "180A")
    let WINEGARD_MANUFACTURER_NAME_CHAR_UUID    = CBUUID(string: "2A29")
    let WINEGARD_MODEL_NUMBER_CHAR_UUID         = CBUUID(string: "2A24")
    let WINEGARD_SERIAL_NUMBER_CHAR             = CBUUID(string: "2A25")
    let WINEGARD_HARDWARE_REVISION_CHAR_UUID    = CBUUID(string: "2A27")
    let WINEGARD_SOFTWARE_REVISION_CHAR_UUID    = CBUUID(string: "2A28")

//  WINEGARD CUSTOM SERVICE AND CHARACTERISTICS, INCLUDES SCAN DATA, SCAN CONFIGURATION, AND LOG DATA
let WINEGARD_SPECTRUMANALYZER_SERVICE     = CBUUID(string: "00007AF0-0000-1000-8000-00805F9B34FB")//CBUUID(string: "00060001-F8CE-11E4-ABF4-0002A5D5C51B")
    let WINEGARD_SCAN_CONFIGURATION_CHAR  = CBUUID(string: "0000F5B7-0000-1000-8000-00805F9B34FB")
    let WINEGARD_SCAN_DATA_CHAR           = CBUUID(string: "0000BC7B-0000-1000-8000-00805F9B34FB")
    let WINEGARD_LOGGING_DATA_CHAR        = CBUUID(string: "F26FFCD9-501A-4564-B4BB-32892DF2E639")

let WINEGARD_CONFGURATION_SERVICE         = CBUUID(string: "539E1F0A-06A6-427A-9168-65ABCE80385B")
    let WINEGARD_CONFIGURATION_CHAR       = CBUUID(string: "0000F5B7-0000-1000-8000-00805F9B34FB")


class RayzarGATT: NSObject{
    
    /*Define variables for discovered services and characteristics to be assigned by JABLE*/
    var winegardOtaService: CBService?
        var winegardBootloaderCharacteristic: CBCharacteristic?
    
    var winegardInformationService: CBService?
        var winegardManufacturerNameCharacteristic: CBCharacteristic?
        var winegardModelNumberCharacteristic: CBCharacteristic?
        var winegardSerialNumberCharacteristic: CBCharacteristic?
        var winegardHardwareRevisionCharacteristic: CBCharacteristic?
        var winegardSoftwareRevisionCharacteristic: CBCharacteristic?
    
    var winegardSpectrumAnalyzerService: CBService?
        var winegardScanConfigurationCharacteristic: CBCharacteristic?
        var winegardScanDataCharacteristic: CBCharacteristic?
        var winegardDataLoggingCharacteristic: CBCharacteristic?
    
    var winegardConfigurationService: CBService?
        var winegardConfigurationCharacteristic: CBCharacteristic?

    var jableGattProfile: JABLE_GATT.JABLE_GATTProfile?
    
    override init() {
        super.init()
        
        jableGattProfile = JABLE_GATT.JABLE_GATTProfile(
            services:
            [
                /*Add Winegard OTA Service*/
                JABLE_GATT.JABLE_Service(
                    serviceUUID: WINEGARD_OTA_SERVICE,
                    whenFound: assignTo(&winegardOtaService),
                    characteristics:
                    [
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: WINEGARD_BOOTLOADER_CHARACTERISTIC,
                            whenFound: assignTo(&winegardBootloaderCharacteristic),
                            descriptors: nil)
                    ]),
                
                /*Add Winegard Spectrum Analyzer Service*/
                JABLE_GATT.JABLE_Service(
                    serviceUUID: WINEGARD_SPECTRUMANALYZER_SERVICE,
                    whenFound: assignTo(&winegardSpectrumAnalyzerService),
                    characteristics:
                    [
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: WINEGARD_SCAN_CONFIGURATION_CHAR,
                            whenFound: assignTo(&winegardScanConfigurationCharacteristic),
                            descriptors: nil),
                        
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: WINEGARD_SCAN_DATA_CHAR,
                            whenFound: assignTo(&winegardScanDataCharacteristic),
                            descriptors: nil),
                        
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: WINEGARD_LOGGING_DATA_CHAR,
                            whenFound: assignTo(&winegardDataLoggingCharacteristic),
                            descriptors: nil),
                    ]),
                
                /*Add Winegard Information Service*/
                JABLE_GATT.JABLE_Service(
                    serviceUUID: WINEGARD_INFORMATION_SERVICE,
                    whenFound: assignTo(&winegardInformationService),
                    characteristics:
                    [
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: WINEGARD_MANUFACTURER_NAME_CHAR_UUID,
                            whenFound: assignTo(&winegardManufacturerNameCharacteristic),
                            descriptors: nil),
                        
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: WINEGARD_MODEL_NUMBER_CHAR_UUID,
                            whenFound: assignTo(&winegardModelNumberCharacteristic),
                            descriptors: nil),
                        
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: WINEGARD_SERIAL_NUMBER_CHAR,
                            whenFound: assignTo(&winegardSerialNumberCharacteristic),
                            descriptors: nil),
                        
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: WINEGARD_HARDWARE_REVISION_CHAR_UUID,
                            whenFound: assignTo(&winegardHardwareRevisionCharacteristic),
                            descriptors: nil),
                        
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: WINEGARD_SOFTWARE_REVISION_CHAR_UUID,
                            whenFound: assignTo(&winegardSoftwareRevisionCharacteristic),
                            descriptors: nil)
                    ]),
                
                /*Add Winegard Configuration Service*/
                JABLE_GATT.JABLE_Service(
                    serviceUUID: WINEGARD_CONFGURATION_SERVICE,
                    whenFound: assignTo(&winegardConfigurationService),
                    characteristics:
                    [
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: WINEGARD_CONFIGURATION_CHAR,
                            whenFound: assignTo(&winegardConfigurationCharacteristic),
                            descriptors: nil)
                    ])
            ])
    }
    
}























// Boneyard


//jableGattProfile_Improved = new
/*print("Improved Gatt Profile = \(jableGattProfile_Improved)")
 
 //  BUILD JABLE_GATT SERVICES AND CHARACTERISTICS
 //==========================================================================================
 let serviceOne                      = JABLE_GATT.service(       uuid: WINEGARD_OTA_SERVICE,
 whenFound: assignTo(&winegardOtaService))//{self.winegardOtaService = $0})
 
 let serviceOneCharacteristicOne     = JABLE_GATT.characteristic(uuid: WINEGARD_BOOTLOADER_CHARACTERISTIC,
 enableNotifications: false,
 descriptors: nil,
 whenFound: assignTo(&winegardBootloaderCharacteristic))//{self.winegardBootloaderCharacteristic = $0})
 //  Grouping for readablitiy
 let serviceOneCharacteristics       =                           [serviceOneCharacteristicOne]
 //==========================================================================================
 let serviceTwo                      = JABLE_GATT.service(       uuid: WINEGARD_INFORMATION_SERVICE,
 whenFound: assignTo(&winegardInformationService))//{self.winegardInformationService = $0})
 
 let serviceTwoCharacteristicOne     = JABLE_GATT.characteristic(uuid: WINEGARD_MANUFACTURER_NAME_CHAR_UUID,
 enableNotifications: false,
 descriptors: nil,
 whenFound: assignTo(&winegardManufacturerNameCharacteristic))//{self.winegardManufacturerNameCharacteristic = $0})
 
 let serviceTwoCharacteristicTwo     = JABLE_GATT.characteristic(uuid: WINEGARD_MODEL_NUMBER_CHAR_UUID,
 enableNotifications: false,
 descriptors: nil,
 whenFound: assignTo(&winegardModelNumberCharacteristic))//{self.winegardModelNumberCharacteristic = $0})
 
 let serviceTwoCharacteristicThree   = JABLE_GATT.characteristic(uuid: WINEGARD_SERIAL_NUMBER_CHAR,
 enableNotifications: false,
 descriptors: nil,
 whenFound: assignTo(&winegardSerialNumberCharacteristic))//{self.winegardSerialNumberCharacteristic = $0})
 
 let serviceTwoCharacteristicFour    = JABLE_GATT.characteristic(uuid: WINEGARD_HARDWARE_REVISION_CHAR_UUID,
 enableNotifications: false,
 descriptors: nil,
 whenFound: assignTo(&winegardHardwareRevisionCharacteristic))//{self.winegardHardwareRevisionCharacteristic = $0})
 
 let serviceTwoCharacteristicFive    = JABLE_GATT.characteristic(uuid: WINEGARD_SOFTWARE_REVISION_CHAR_UUID,
 enableNotifications: false,
 descriptors: nil,
 whenFound: assignTo(&winegardSoftwareRevisionCharacteristic))//{self.winegardSoftwareRevisionCharacteristic = $0})
 //  Grouping for readability
 let serviceTwoCharacteristics       =                           [serviceTwoCharacteristicOne,
 serviceTwoCharacteristicTwo,
 serviceTwoCharacteristicThree,
 serviceTwoCharacteristicFour,
 serviceTwoCharacteristicFive]
 //==========================================================================================
 let serviceThree                    = JABLE_GATT.service(       uuid: WINEGARD_SPECTRUMANALYZER_SERVICE,
 whenFound: assignTo(&winegardSpectrumAnalyzerService))//{self.winegardSpectrumAnalyzerService =  $0})
 
 let serviceThreeCharacteristicOne   = JABLE_GATT.characteristic(uuid: WINEGARD_SCAN_CONFIGURATION_CHAR,
 enableNotifications: false,
 descriptors: nil,
 whenFound: assignTo(&winegardScanConfigurationCharacteristic))//{self.winegardScanConfigurationCharacteristic = $0})
 
 let serviceThreeCharacteristicTwo   = JABLE_GATT.characteristic(uuid: WINEGARD_SCAN_DATA_CHAR,
 enableNotifications: false,
 descriptors: nil,
 whenFound: assignTo(&winegardScanDataCharacteristic))//{self.winegardScanDataCharacteristic = $0})
 
 let serviceThreeCharacteristicThree = JABLE_GATT.characteristic(uuid: WINEGARD_LOGGING_DATA_CHAR,
 enableNotifications: false,
 descriptors: nil,
 whenFound: assignTo(&winegardDataLoggingCharacteristic))//{self.winegardDataLoggingCharacteristic = $0})
 //  Grouping for readability
 let serviceThreeCharacteristics     =                           [serviceThreeCharacteristicOne,
 serviceThreeCharacteristicTwo,
 serviceThreeCharacteristicThree]
 //==========================================================================================
 let serviceFour                     = JABLE_GATT.service(       uuid: WINEGARD_CONFGURATION_SERVICE,
 whenFound: assignTo(&winegardConfigurationService))//{self.winegardConfigurationService = $0})
 
 let serviceFourCharacteristicOne    = JABLE_GATT.characteristic(uuid: WINEGARD_CONFIGURATION_CHAR,
 enableNotifications: false,
 descriptors: nil,
 whenFound: assignTo(&winegardConfigurationCharacteristic))//{self.winegardConfigurationCharacteristic = $0})
 
 let serviceFourCharacteristics      =                           [serviceFourCharacteristicOne]
 //==========================================================================================
 
 //  Create JABLE specific service structs
 let jableServiceOne     = JABLE_GATT.JABLE_Service(service: serviceOne,     characteristics: serviceOneCharacteristics)
 let jableServiceTwo     = JABLE_GATT.JABLE_Service(service: serviceTwo,     characteristics: serviceTwoCharacteristics)
 let jableServiceThree   = JABLE_GATT.JABLE_Service(service: serviceThree,   characteristics: serviceThreeCharacteristics)
 let jableServiceFour    = JABLE_GATT.JABLE_Service(service: serviceFour,    characteristics: serviceFourCharacteristics)
 let jableServices = [jableServiceOne, jableServiceTwo, jableServiceThree, jableServiceFour]
 
 //  Create Gatt profile structure to pass to the JABLE framework
 jableGattProfile = JABLE_GATT.JABLE_GATTProfile(services: jableServices)*/



