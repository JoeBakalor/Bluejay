
//  ScanManager.swift
//  RAZR
//
//  Created by Joe Bakalor on 7/6/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//
/*
 MODE 1 - SPECTRUM ANALYZER
 
 ---SCAN CONFIGURATION PACKET FORMAT---
 BYTE 0 -  [0 = STOP, 1 = START SPECTRUM , 2 = START CHANNEL SCAN, 3 = START SINGLE CHANNEL SCAN]
 BYTE 1 -  [MSB START FREQUENCY]
 BYTE 2 -  [START FREQUENCY BYTE 2]
 BYTE 3 -  [START FREQUENCY BYTE 3]
 BYTE 4 -  [LSB START FREQUENCY]
 BYTE 5 -  [MSB STOP  FREQUENCY]
 BYTE 6 -  [STOP  FREQUENCY BYTE 2]
 BYTE 7 -  [START FREQUENCY BYTE 3]
 BYTE 8 -  [LSB STOP FREQUENCY]
 BYTE 9 -  [MSB RESOLUTION]
 BYTE 10 - [RESOLUTION BYTE 2]
 BYTE 11 - [RESOLUTION BYTE 3]
 BYTE 12 - [LSB RESOLUTION]
 BYTE 13 - [SUGGESTED CHECKSUM]
 
 ---RESPONSE DATA PACKET FORMAT---
 BYTE 0 -  [1 = SPECTRUM MODE, 2 = CHANNEL MODE, 3 = INDIVIDUAL CHANNEL MODE]
 BYTE 1 -  [MSB FIRST FREQUENCY]
 BYTE 2 -  [FIRST FREQUENCY BYTE 2]
 BYTE 3 -  [FIRST FREQUENCY BYTE 3]
 BYTE 4 -  [LSB FIRST FREQUENCY]
 BYTE 5 -  [FIRST FREQUENCY POWER]
 BYTE 6 -  [(FIRST FREQUENCY + RESOLUTION) POWER]
 
 MODE 2 - CHANNEL SCAN
 
 ---SCAN CONFIGURATION PACKET FORMAT---
 BYTE 0 -  [0 = STOP, 1 = START SPECTRUM , 2 = START CHANNEL SCAN, 3 = START SINGLE CHANNEL SCAN]
 BYTE 1 -  [START CHANNEL NUMBER]
 BYTE 2 -  [END   CHANNEL NUMBER]
 
 ---RESPONSE DATA PACKET FORMAT---
 BYTE 0 -  [1 = SPECTRUM MODE, 2 = CHANNEL MODE, 3 = INDIVIDUAL CHANNEL MODE]
 BYTE 1 -  [CHANNEL X]
 BYTE 2 -  [CHANNEL X POWER]
 BYTE 3 -  [CHANNEL X + 1]
 BYTE 4 -  [(CHANNEL X + 1) POWER]
 BYTE 5 -  [..]
 BYTE 6 -  [..]
 BYTE 7 -  [..]
 BYTE 8 -  [..]
 BYTE 9 -  [..]
 BYTE 10 - [..]
 BYTE 11 - [..]
 BYTE 12 - [..]
 BYTE 13 - [..]
 BYTE 14 - [..]
 BYTE 15 - [..]
 BYTE 16 - [CHANNEL N-1]
 BYTE 17 - [(CHANNEL N-1) POWER]
 BYTE 18 - [CHANNEL N]
 BYTE 19 - [CHANNEL N POWER]
 
 MODE 3 - INDIVIDUAL CHANNEL SCAN
 
 ---SCAN CONFIGURATION PACKET FORMAT---
 BYTE 0 -  [0 = STOP, 1 = START SPECTRUM , 2 = START CHANNEL SCAN, 3 = START SINGLE CHANNEL SCAN]
 BYTE 1 -  [CHANNEL TO SCAN]
 
 ---RESPONSE DATA PACKET FORMAT---
 BYTE 0 -  [1 = SPECTRUM MODE, 2 = CHANNEL MODE, 3 = INDIVIDUAL CHANNEL MODE]
 BYTE 1 -  [CHANNEL NUMBER]
 BYTE 2 -  [CHANNEL POWER]
 */

import Foundation

//NOTIFICATION DEFINES
let CHANNEL_SUMMARY_DATA_UPDATED = Notification.Name(rawValue: "channelDataUpdatedID")
let SPECTRAL_DATA_UPDATED = Notification.Name(rawValue: "spectralDataUpdatedID")
let INDIVIDUAL_CHANNEL_DATA_UPDATED = Notification.Name(rawValue: "individualChannelDataUpdatedID")
let SCAN_PARAMETER_SELECTED = Notification.Name(rawValue: "scanParameterSelectedID")

//MARK: BASE CLASS
class ScanManager: NSObject
{
    /******************************************************************************/
    //  Constants
    /******************************************************************************/
    let defaultSpectrumScanConfig: (_: UInt32, _: UInt32, _: UInt32 ) = (122_000_000,
                                                                        820_500_000,
                                                                        2_000_000)//Todd want 2MHz to be default, check view controller to make sure setting it here will not cause any problems
    //Quick Spectrum Scan Settings
    let lowVHFQuickSettings: (_: UInt32, _: UInt32, _: UInt32 )      = (50_000_000,
                                                                        90_000_000,
                                                                        1_000_000)
    
    let highVHFQuickSettings: (_: UInt32, _: UInt32, _: UInt32 )     = (170_000_000,
                                                                        220_000_000,
                                                                        1_000_000)
    
    let UHFQuickSettings: (_: UInt32, _: UInt32, _: UInt32 )         = (450_000_000,
                                                                        700_000_000,
                                                                        1_000_000)
    
    let scanResolutionOptions: [UInt32]                              = [1_000_000,
                                                                        1_250_000,
                                                                        1_500_000,
                                                                        1_750_000,
                                                                        2_000_000]
    
    let quickSettings: [(settingName: String, settingValues: (_: UInt32, _: UInt32, _: UInt32 ))] = [
        ("Default", (122_000_000, 820_500_000,2_000_000)),
        ("Low VHF", (50_000_000, 90_000_000, 1_000_000)),
        ("High VHF", (170_000_000, 220_000_000, 1_000_000)),
        ("UHF", (450_000_000, 700_000_000, 1_000_000))]
    
    public enum quickSettingSelected: Int{
        case defaultValue = 0
        case lowVHF = 1
        case highVHF = 2
        case uhf = 3
    }
    var currentQuickSetting = quickSettingSelected.defaultValue
    
    let scanScanPerFrequencyOptions: [UInt32] = [1, 2, 3]
    let powerSamplesToAverage = 5//20
    /******************************************************************************/
    // Variables
    /******************************************************************************/
    //State Variables
    enum scanMode{
        case stopped
        case error
        case spectrum
        case allChannels
        case singleChannel
    }
    
    public enum selectableScanParamters{
        case startFrequency
        case stopFrequency
        case scanResolution
        case scansPerFrequency
        case quickSettings
        case noSelection
    }
    
    var selectedScanParameter: selectableScanParamters = .noSelection
    var currentMode: scanMode = .stopped
    
    //number of graph points, this will be calculated when the configuration is set
    var numberOfSprectrumPoints: UInt32?
    
    
    //Data Containers
    typealias ChannelSummaryData = [(channel: Int, power: Int)]
    typealias SpectralData = [(frequncy: Int, power: Int)]
    
    var recievedSpecrtalDataArray: SpectralData = []
    var recievedChannelDataArray: ChannelSummaryData = []
    
    //Variables for single channel scan mode
    var singleChannelSumPower = 0
    var singleChannelAveragePower = 0
    var sampleNumber = 0
    
    //Configuration Variables, DEFAULT SETTINGS 122MHz, 820.5MHz, 1.75MHz
    var spectrumScanConfig: (startFrequency: UInt32, stopFrequency: UInt32, scanResolution: UInt32) = (122_000_000, 820_500_000, 2_000_000){
        didSet{
            numberOfSprectrumPoints = (spectrumScanConfig.stopFrequency - spectrumScanConfig.startFrequency)/spectrumScanConfig.scanResolution
            print("spectrumScanConfig updated, number of graph points = \(numberOfSprectrumPoints!)")
            let initializeArrayElements = Array(repeating: (0, 0), count: Int(numberOfSprectrumPoints!))
            recievedSpecrtalDataArray = initializeArrayElements
        }
    }
    
    var pendingSpectrumScanConfig: (startFrequency: UInt32, stopFrequency: UInt32, scanResolution: UInt32) = (122_000_000, 820_500_000,2_000_000){
        didSet{updateScanParameterOptions()}}
    
    var channelScanConfig: (startChannel: Int, endChannel: Int) = (2, 52)
    var singleChannelScanChannel = 2//default value
    
    //Arrays to hold values available for user selection for spectral scan configuration paramters
    var scanStartFrequencyOptions: [UInt32] = []
    var scanStopFrequencyOptions: [UInt32] = []

    /******************************************************************************/
    //
    /******************************************************************************/
    override init()
    {
        super.init()
        updateScanParameterOptions()
    }
}

// =================================  Data Processing ===============================
extension ScanManager
{
    /******************************************************************************/
    //
    /******************************************************************************/
    func processNewData(newDataBytes: [UInt8]) -> String
    {
        //let result      = scanManager.processNewData(newDataBytes: dataBytes)
        var result = ""
        guard newDataBytes.count > 0 else { return ""}
        switch newDataBytes[0]
        {
        case 0: print("Recieved Error")
            
        case 1: //print//("Recieved new spectrum data")
            result = updateSpectralData(data: newDataBytes)
            
        case 2: //print("Recieved new channel data")
            result = updateChannelData(data: newDataBytes)
            
        case 3: print("Recieved individual channel data")
            result = updateIndividualChannelData(data: newDataBytes)
            
        default: print("Unrecognized data")
        }
        return result
    }
    
    //  Process updated spectral data
    func updateSpectralData(data: [UInt8]) -> String
    {
        guard data.count > 1 else { return ""}
        print("SPECTRUM DATA = \(data)")
        var frequency: UInt32 = 0x00000000
        frequency = frequency | (UInt32(data[1]) << 24)
        frequency = frequency | (UInt32(data[2]) << 16)
        frequency = frequency | (UInt32(data[3]) << 8)
        frequency = frequency | UInt32(data[4])
        
        //let startFrequency: UInt32 = 0x07459280 //
        let resolution: UInt32 = 0x001ab3f0
        
        if frequency > spectrumScanConfig.startFrequency{
            let currentIndex = (frequency - spectrumScanConfig.startFrequency)/spectrumScanConfig.scanResolution
            let newElements: [(frequncy: Int, power: Int)] = [(Int(frequency),
                                                               Int(data[5])),
                                                               ((Int(frequency + resolution)),
                                                               Int(data[6]))]
            var secondaryIndex = currentIndex + 1
            if secondaryIndex > numberOfSprectrumPoints! - 1{ secondaryIndex = 0}
            
            if secondaryIndex != 0{
                recievedSpecrtalDataArray.replaceSubrange(Int(currentIndex)...Int(secondaryIndex),
                                                          with: newElements)
            } else {
                if recievedSpecrtalDataArray.indices.contains(Int(currentIndex)){
                    recievedSpecrtalDataArray.replaceSubrange(Range(Int(currentIndex)...Int(currentIndex)),
                                                              with: [(Int(frequency), Int(data[5]))])
                    
                    recievedSpecrtalDataArray.replaceSubrange(Range(0...0),
                                                              with: [(Int(frequency + resolution), Int(data[6]))])
                }
            }
            //Correspoinding view Controller should add observer for this notification
            
            NotificationCenter.default.post(name: SPECTRAL_DATA_UPDATED, object: self, userInfo: nil)
        }
        return "SUCCESS"
    }
    
    
    //
    func updateChannelData(data: [UInt8]) -> String
    {
        recievedChannelDataArray = []
            
        var i = 1
        while i < data.count - 1{
            if data[i] != 0 {
            recievedChannelDataArray.append((Int(data[i]), Int(data[i+1])))
            }
            i += 2
        }
        //print("CHANNEL ARRAY = \(recievedChannelDataArray)")
        //Correspoinding view Controller should add observer for this notification
    
        NotificationCenter.default.post(name: CHANNEL_SUMMARY_DATA_UPDATED, object: self, userInfo: nil)
        return "SUCCESS"
    }
    
    /******************************************************************************/
    //  Individual channel power update
    /******************************************************************************/
    func updateIndividualChannelData(data: [UInt8]) -> String
    {
        let newPower = data[2]
        
        if sampleNumber < powerSamplesToAverage{
            singleChannelSumPower += Int(newPower)
            sampleNumber += 1
        } else {
            singleChannelAveragePower = singleChannelSumPower/powerSamplesToAverage
            singleChannelSumPower = 0
            sampleNumber = 0
        }
        
        //Corresponding View Controller should add observer for this notification
        NotificationCenter.default.post(name: INDIVIDUAL_CHANNEL_DATA_UPDATED, object: self, userInfo: nil)
        return "SUCCESS"
    }
}


// ============================  SCAN CONFIGURATION ===============================
extension ScanManager
{
    
    /*============================================================================*/
    //  Called when paramter selected from ScanConfigurationTableViewController
    //  Send notification to SpectrumAnalyzerViewController to display valueSelectionTableView
    //  for user to select new paramter to use
    /*============================================================================*/
    func updateSelectedParameter(newParameter: selectableScanParamters)
    {
        self.selectedScanParameter = newParameter
        NotificationCenter.default.post(name: SCAN_PARAMETER_SELECTED, object: self, userInfo: nil)
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func savePendingConfiguration() -> Data
    {
        //save pendindSpectrumScanConfiguration to spectrumScanConfiguration
        spectrumScanConfig = pendingSpectrumScanConfig
        
        var scanConfigBytes: [UInt8] = []
        
        //start frequency
        scanConfigBytes.append(0x01)//scan mode
        scanConfigBytes.append(UInt8(truncatingIfNeeded: spectrumScanConfig.startFrequency >> 24))
        scanConfigBytes.append(UInt8(truncatingIfNeeded: spectrumScanConfig.startFrequency >> 16))
        scanConfigBytes.append(UInt8(truncatingIfNeeded: spectrumScanConfig.startFrequency >> 8))
        scanConfigBytes.append(UInt8(truncatingIfNeeded: spectrumScanConfig.startFrequency))
        
        //stop frequency
        scanConfigBytes.append(UInt8(truncatingIfNeeded: spectrumScanConfig.stopFrequency >> 24))
        scanConfigBytes.append(UInt8(truncatingIfNeeded: spectrumScanConfig.stopFrequency >> 16))
        scanConfigBytes.append(UInt8(truncatingIfNeeded: spectrumScanConfig.stopFrequency >> 8))
        scanConfigBytes.append(UInt8(truncatingIfNeeded: spectrumScanConfig.stopFrequency))
        
        //resolution
        scanConfigBytes.append(UInt8(truncatingIfNeeded: spectrumScanConfig.scanResolution >> 24))
        scanConfigBytes.append(UInt8(truncatingIfNeeded: spectrumScanConfig.scanResolution >> 16))
        scanConfigBytes.append(UInt8(truncatingIfNeeded: spectrumScanConfig.scanResolution >> 8))
        scanConfigBytes.append(UInt8(truncatingIfNeeded: spectrumScanConfig.scanResolution))
        
        scanConfigBytes.append(0x01)
        
        
        var hexArray = ""
        for byte in scanConfigBytes{
            hexArray += String(format:"%2X", byte) + " "
        }
        print("SCAN CONFIGURATION = \(hexArray)")
        let formattedConfigPacket = Data(bytes: scanConfigBytes)
        return formattedConfigPacket
        
    }

    /******************************************************************************/
    // Update user selectable scan paramters, should be called after any paramter
    // is updated by user
    /******************************************************************************/
    func updateScanParameterOptions()
    {
        scanStartFrequencyOptions = []//
        scanStopFrequencyOptions = []
        //Populate Start Frequency options array
        //this array will always begin at the lowest possible value and end at the stop frequency
        scanStartFrequencyOptions.append(122_000_000)
        
        while scanStartFrequencyOptions.last! < pendingSpectrumScanConfig.stopFrequency{
            scanStartFrequencyOptions.append(scanStartFrequencyOptions.last! + pendingSpectrumScanConfig.scanResolution)
        }
        //print("Start Frequency Options = \(scanStartFrequencyOptions)")
        
        scanStopFrequencyOptions.append(pendingSpectrumScanConfig.startFrequency + pendingSpectrumScanConfig.scanResolution)
        
        while scanStopFrequencyOptions.last! < 820_500_000{
            scanStopFrequencyOptions.append(scanStopFrequencyOptions.last! + pendingSpectrumScanConfig.scanResolution)
        }
        
    }
}

