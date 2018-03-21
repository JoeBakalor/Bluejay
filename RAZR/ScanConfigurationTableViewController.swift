//
//  ScanConfigurationTableViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 7/10/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

class ScanConfigurationTableViewController: UITableViewController {

    @IBOutlet weak var startFrequencySetting: UITextField!
    @IBOutlet weak var startFrequencyLabel: UILabel!
    @IBOutlet weak var stopFrequencyLabel: UILabel!
    @IBOutlet weak var resolutionLabel: UILabel!
    @IBOutlet weak var quickSettingsLabel: UILabel!
    
    var selectedScanParameter: ScanManager.selectableScanParamters = .noSelection

    override func viewDidLoad(){
        super.viewDidLoad()
        
        let notificationName = NSNotification.Name(rawValue: "scanParameterUpdatedID")
        let selector = #selector(self.updateLabels)
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName , object: nil)
        
        tableView.scrollsToTop = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    

    @objc func updateLabels(){
        quickSettingsLabel.text = "\(scanManager.quickSettings[scanManager.currentQuickSetting.rawValue].settingName)"
        startFrequencyLabel.text = "\(Float(scanManager.pendingSpectrumScanConfig.startFrequency)/1_000_000) MHz"
        stopFrequencyLabel.text = "\(Float(scanManager.pendingSpectrumScanConfig.stopFrequency)/1_000_000) MHz"
        resolutionLabel.text = "\(Float(scanManager.pendingSpectrumScanConfig.scanResolution)/1_000_000) MHz"
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("EDIT FREQUENCY")
        
        tableView.cellForRow(at: indexPath)!.isSelected = false
        
        switch indexPath.row{
        case 1: print("Quick Settings")
            scanManager.updateSelectedParameter(newParameter: .quickSettings)
            
        case 3: print("Start Frequency")
            scanManager.updateSelectedParameter(newParameter: .startFrequency)
            
        case 5: print("Stop Frequency")
            scanManager.updateSelectedParameter(newParameter: .stopFrequency)
            
        case 7: print("Scan Resolution")
            scanManager.updateSelectedParameter(newParameter: .scanResolution)
            
        case 9: print("Scans Per Frequency")
            scanManager.updateSelectedParameter(newParameter: .scansPerFrequency)
            
        default: print("invalid selection")
            scanManager.updateSelectedParameter(newParameter: .noSelection)
        }
        scanManager.updateScanParameterOptions()
        //scanManager.updateSelectedParameter(newParameter: .noSelection)
        //tableView.cellForRow(at: indexPath).
    }
    

}
