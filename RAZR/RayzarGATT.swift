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

//DEFINE STIDGET SERVICE AND CHARACTERISTIC UUIDS
let JABLE_PRIMARY_SERVICE_UUID = CBUUID(string: "f79b4eb3-1b6e-41f2-8d65-d346b4ef5685")
let JABLE_RGB_LED_CHARACTERISTIC_UUID = CBUUID(string: "f79b4eb4-1b6e-41f2-8d65-d346b4ef5685")
let JABLE_ACCEL_RPM_GYRO_CHARACTERISTIC_UUID = CBUUID(string: "f79b4eb5-1b6e-41f2-8d65-d346b4ef5685")
let JABLE_TEMP_CHARACTERISTIC_UUID = CBUUID(string: "2A6E")

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
    
    //  DEFINE ACCESS VARIABLE NAMES FOR SERVICES AND CHARACTERISTICS
    var WinegardService: CBService?
    var winegardOtaService: CBService?//{
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
        //  BUILD GATT SERVICES AND CHARACTERISTICS
        //=============================================
        let serviceOne = JABLE_GATT.service(service: &winegardOtaService, uuid: WINEGARD_OTA_SERVICE, assigner: {service in self.winegardOtaService =  service})
        let serviceOneCharacteristicOne = JABLE_GATT.characteristic(characteristic: &winegardBootloaderCharacteristic,
                                                                    uuid: WINEGARD_BOOTLOADER_CHARACTERISTIC,
                                                                    enableNotifications: false,
                                                                    descriptors: nil,
                                                                    characteristicCompletion: {characteristic in self.winegardBootloaderCharacteristic = characteristic})
        //  Grouping for readablitiy
        let serviceOneCharacteristics = [serviceOneCharacteristicOne]
        
        //=============================================
        let serviceTwo = JABLE_GATT.service(service: &winegardInformationService, uuid: WINEGARD_INFORMATION_SERVICE, assigner: {service in self.winegardInformationService =  service})
        let serviceTwoCharacteristicOne = JABLE_GATT.characteristic(characteristic: &winegardManufacturerNameCharacteristic,
                                                                    uuid: WINEGARD_MANUFACTURER_NAME_CHAR_UUID,
                                                                    enableNotifications: false,
                                                                    descriptors: nil,
                                                                    characteristicCompletion: {characteristic in self.winegardManufacturerNameCharacteristic = characteristic})
        
        let serviceTwoCharacteristicTwo = JABLE_GATT.characteristic(characteristic: &winegardModelNumberCharacteristic,
                                                                    uuid: WINEGARD_MODEL_NUMBER_CHAR_UUID,
                                                                    enableNotifications: false,
                                                                    descriptors: nil,
                                                                    characteristicCompletion: {characteristic in self.winegardModelNumberCharacteristic = characteristic})
        
        let serviceTwoCharacteristicThree = JABLE_GATT.characteristic(characteristic: &winegardSerialNumberCharacteristic,
                                                                      uuid: WINEGARD_SERIAL_NUMBER_CHAR,
                                                                      enableNotifications: false,
                                                                      descriptors: nil,
                                                                      characteristicCompletion: {characteristic in self.winegardSerialNumberCharacteristic = characteristic})
        
        let serviceTwoCharacteristicFour = JABLE_GATT.characteristic(characteristic: &winegardHardwareRevisionCharacteristic,
                                                                     uuid: WINEGARD_HARDWARE_REVISION_CHAR_UUID,
                                                                     enableNotifications: false,
                                                                     descriptors: nil,
                                                                     characteristicCompletion: {characteristic in self.winegardHardwareRevisionCharacteristic = characteristic})
        
        let serviceTwoCharacteristicFive = JABLE_GATT.characteristic(characteristic: &winegardSoftwareRevisionCharacteristic,
                                                                     uuid: WINEGARD_SOFTWARE_REVISION_CHAR_UUID,
                                                                     enableNotifications: false,
                                                                     descriptors: nil,
                                                                     characteristicCompletion: {characteristic in self.winegardSoftwareRevisionCharacteristic = characteristic})
        //  Grouping for readability
        let serviceTwoCharacteristics = [serviceTwoCharacteristicOne, serviceTwoCharacteristicTwo, serviceTwoCharacteristicThree, serviceTwoCharacteristicFour, serviceTwoCharacteristicFive]
        
        //=============================================
        let serviceThree = JABLE_GATT.service(service: &winegardSpectrumAnalyzerService, uuid: WINEGARD_SPECTRUMANALYZER_SERVICE, assigner: {service in self.winegardSpectrumAnalyzerService =  service})
        let serviceThreeCharacteristicOne = JABLE_GATT.characteristic(characteristic: &winegardScanConfigurationCharacteristic,
                                                                      uuid: WINEGARD_SCAN_CONFIGURATION_CHAR,
                                                                      enableNotifications: false,
                                                                      descriptors: nil,
                                                                      characteristicCompletion: {characteristic in self.winegardScanConfigurationCharacteristic = characteristic})
        
        let serviceThreeCharacteristicTwo = JABLE_GATT.characteristic(characteristic: &winegardScanDataCharacteristic,
                                                                      uuid: WINEGARD_SCAN_DATA_CHAR,
                                                                      enableNotifications: false,
                                                                      descriptors: nil,
                                                                      characteristicCompletion: {characteristic in self.winegardScanDataCharacteristic = characteristic})
        
        let serviceThreeCharacteristicThree = JABLE_GATT.characteristic(characteristic: &winegardDataLoggingCharacteristic,
                                                                        uuid: WINEGARD_LOGGING_DATA_CHAR,
                                                                        enableNotifications: false,
                                                                        descriptors: nil,
                                                                        characteristicCompletion: {characteristic in self.winegardDataLoggingCharacteristic = characteristic})
        //  Grouping for readability
        let serviceThreeCharacteristics = [serviceThreeCharacteristicOne, serviceThreeCharacteristicTwo, serviceThreeCharacteristicThree]
        
        //=============================================
        let serviceFour = JABLE_GATT.service(service: &winegardConfigurationService, uuid: WINEGARD_CONFGURATION_SERVICE, assigner: {service in self.winegardConfigurationService =  service})
        let serviceFourCharacteristicOne = JABLE_GATT.characteristic(characteristic: &winegardConfigurationCharacteristic,
                                                                     uuid: WINEGARD_CONFIGURATION_CHAR,
                                                                     enableNotifications: false,
                                                                     descriptors: nil,
                                                                     characteristicCompletion: {characteristic in self.winegardConfigurationCharacteristic = characteristic})
        let serviceFourCharacteristics = [serviceFourCharacteristicOne]
        
        //  Create JABLE specific service structs
        let jableServiceOne     = JABLE_GATT.JABLE_Service(service: serviceOne,     characteristics: serviceOneCharacteristics)
        let jableServiceTwo     = JABLE_GATT.JABLE_Service(service: serviceTwo,     characteristics: serviceTwoCharacteristics)
        let jableServiceThree   = JABLE_GATT.JABLE_Service(service: serviceThree,   characteristics: serviceThreeCharacteristics)
        let jableServiceFour    = JABLE_GATT.JABLE_Service(service: serviceFour,    characteristics: serviceFourCharacteristics)
        let jableServices = [jableServiceOne, jableServiceTwo, jableServiceThree, jableServiceFour]
        
        //  Create Gatt profile structure to pass to the JABLE framework
        jableGattProfile = JABLE_GATT.JABLE_GATTProfile(services: jableServices)
    }
    
}



