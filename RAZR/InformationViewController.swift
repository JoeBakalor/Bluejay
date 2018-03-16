//
//  InformationViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 8/29/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit
import CoreBluetooth


let BLUETOOTH_NAME = "Bluetooth Name"
let MANUFACTURER_NAME = "Manufacturer Name"
let MODEL_NUMBER = "Model Number"
let SERIAL_NUMBER = "Serial Number"
let HARDWARE_REVISION = "Hardware Revision"
let SOFTWARE_REVISION = "Software Revision"

//MARK: BASE CLASS
class InformationViewController: UIViewController//, CharacteristicUpdateDelegate
{
    
    @IBOutlet weak var informationViewTable: UITableView!
    
    var informationOrderArray = [BLUETOOTH_NAME, MANUFACTURER_NAME, MODEL_NUMBER, SERIAL_NUMBER, HARDWARE_REVISION, SOFTWARE_REVISION]
    var deviceInformation: [String: String] =
    [
        BLUETOOTH_NAME : "Rayzar",
        MANUFACTURER_NAME : "Winegard",
        MODEL_NUMBER: "NA",
        SERIAL_NUMBER: "NA",
        HARDWARE_REVISION: "NA",
        SOFTWARE_REVISION: "NA"
    ]
    
    var viewModel: InformationViewModel!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        viewModel = InformationViewModel()
        setupBindings()
        //readInformationFromCharacteristics()
        //BLEConnectionManagerSharedInstance.bleService?.setCharacteristicUpdateDelegate(delegate: self as CharacteristicUpdateDelegate)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.close()
        //BLEConnectionManagerSharedInstance.bleService?.setCharacteristicUpdateDelegate(delegate: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.open()
    }
    
    func setupBindings(){
        
        viewModel.serialNumber.bind { (serialNumber) in
            guard let validValue = serialNumber else { return }
            self.deviceInformation[SERIAL_NUMBER] = validValue
            self.informationViewTable.reloadData()
        }
        
        viewModel.modelNumber.bind { (modelNumber) in
            guard let validValue = modelNumber else { return }
            self.deviceInformation[MODEL_NUMBER] = validValue
            self.informationViewTable.reloadData()
        }
        
        viewModel.softwareRevsion.bind { (softwareRevision) in
            guard let validValue = softwareRevision else { return }
            self.deviceInformation[SOFTWARE_REVISION] = validValue
            self.informationViewTable.reloadData()
        }
        
        viewModel.manufacturerName.bind { (manufacturerName) in
            guard let validValue = manufacturerName else { return }
            self.deviceInformation[MANUFACTURER_NAME] = validValue
            self.informationViewTable.reloadData()
        }
        
        viewModel.hardwareRevision.bind { (hardwareRevision) in
            guard let validValue = hardwareRevision else { return }
            self.deviceInformation[HARDWARE_REVISION] = validValue
            self.informationViewTable.reloadData()
        }
        
        viewModel.isConnected.bind { (connected) in
            if !connected{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
    }
}

extension InformationViewController
{
    /*func newValue(forCharacteristic characteristic: CBCharacteristic)
    {
        var data: Data?
        switch characteristic.uuid{

        //============================================
        case WINEGARD_SERIAL_NUMBER_CHAR:
        
        data = connectedWinegardDevice.winegardGattProfile!.serialNumberChar!.value
        deviceInformation[SERIAL_NUMBER] = String(data: data!, encoding: .utf8)!
            
        //============================================
        case WINEGARD_MODEL_NUMBER_CHAR_UUID:
        
        data = connectedWinegardDevice.winegardGattProfile!.modelNumberChar!.value
        deviceInformation[MODEL_NUMBER] = String(data: data!, encoding: .utf8)!
            
        //============================================
        case WINEGARD_SOFTWARE_REVISION_CHAR_UUID:
            
        data = connectedWinegardDevice.winegardGattProfile!.softwareRevision!.value
        deviceInformation[SOFTWARE_REVISION] = String(data: data!, encoding: .utf8)!
            
        //============================================
        case WINEGARD_MANUFACTURER_NAME_CHAR_UUID:
            
        data = connectedWinegardDevice.winegardGattProfile!.manufacturerNameChar!.value
        deviceInformation[MANUFACTURER_NAME] = String(data: data!, encoding: .utf8)!
            
        //============================================
        case WINEGARD_HARDWARE_REVISION_CHAR_UUID:
            
        data = connectedWinegardDevice.winegardGattProfile!.hardwareRevsion!.value
        deviceInformation[HARDWARE_REVISION] = String(data: data!, encoding: .utf8)!
            
        //============================================
        default:
            print("unknown characteristic")
        }
        
        informationViewTable.reloadData()
    }*/
}

//MARK: UITABLE VIEW DATA SOURCE
extension InformationViewController: UITableViewDataSource
{
    //NUMBER OF SECITON IN TABLE
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 1
        switch section{
        case 0:print("")
            count = 1
        case 1:print("")
            count = informationOrderArray.count - 1//informationDictionary.count - 1
        case 2:print("")
            count = 0
        default: print("")
        }
        return count
    }
    
    //
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        switch indexPath.section{
        case 0: print("")
        
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = informationOrderArray[indexPath.row]//informationDictionary[indexPath.row].item
            cell.detailTextLabel?.text = deviceInformation[informationOrderArray[indexPath.row]]//informationDictionary[indexPath.row].value
            cell.isUserInteractionEnabled = true
            
            
        case 1: print("")
            
            cell.textLabel?.text = informationOrderArray[indexPath.row + 1]
            cell.detailTextLabel?.text = deviceInformation[informationOrderArray[indexPath.row + 1]]//informationDictionary[indexPath.row + 1].value
            cell.isUserInteractionEnabled = false
            cell.selectionStyle = .none
            
        default: print("")
        }
        
        return cell
    }
    
}

// ============================== ======================================

extension InformationViewController: UITableViewDelegate
{
    /******************************************************************************/
    //
    /******************************************************************************/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let cellText = informationViewTable.cellForRow(at: indexPath)?.textLabel?.text  else { return }
        switch cellText{
        case "Bluetooth Name": print("User wants to edit name")
        default: print("Value is not editable")
        }
    }
}
















