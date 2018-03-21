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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        viewModel.close()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        viewModel.open()
    }
}

//MARK: Binding setup for viewModel
extension InformationViewController
{
    func setupBindings(){
        
        viewModel.deviceName.bind(listener:
        { (name) in
            self.deviceInformation[BLUETOOTH_NAME] = name
        })
        
        viewModel.serialNumber.bind(listener:
        { (serialNumber) in
            guard let validValue = serialNumber else { return }
            self.deviceInformation[SERIAL_NUMBER] = validValue
            self.informationViewTable.reloadData()
        })
        
        viewModel.modelNumber.bind(listener:
        { (modelNumber) in
            guard let validValue = modelNumber else { return }
            self.deviceInformation[MODEL_NUMBER] = validValue
            self.informationViewTable.reloadData()
        })
        
        viewModel.softwareRevsion.bind(listener:
        { (softwareRevision) in
            guard let validValue = softwareRevision else { return }
            self.deviceInformation[SOFTWARE_REVISION] = validValue
            self.informationViewTable.reloadData()
        })
        
        viewModel.manufacturerName.bind(listener:
        { (manufacturerName) in
            guard let validValue = manufacturerName else { return }
            self.deviceInformation[MANUFACTURER_NAME] = validValue
            self.informationViewTable.reloadData()
        })
        
        viewModel.hardwareRevision.bind(listener:
        { (hardwareRevision) in
            guard let validValue = hardwareRevision else { return }
            self.deviceInformation[HARDWARE_REVISION] = validValue
            self.informationViewTable.reloadData()
        })
        
        viewModel.isConnected.bind(listener:
        { (connected) in
            if !connected{
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
        
    }
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
            
        case 0:
        
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = informationOrderArray[indexPath.row]//informationDictionary[indexPath.row].item
            cell.detailTextLabel?.text = deviceInformation[informationOrderArray[indexPath.row]]//informationDictionary[indexPath.row].value
            cell.isUserInteractionEnabled = true
            
            
        case 1:
            
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
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        guard let cellText = informationViewTable.cellForRow(at: indexPath)?.textLabel?.text  else { return }
        switch cellText{
            
        case "Bluetooth Name": print("User wants to edit name")
            
            
            let nameChangeAlert = UIAlertController(title: "Change Name", message: "Please Enter a New Name", preferredStyle: .alert)
        
            nameChangeAlert.addTextField(configurationHandler: {(newName) in newName.text = "Name"})
            nameChangeAlert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {[weak nameChangeAlert] (_) in
                if let newName = nameChangeAlert?.textFields![0].text{
                print("New Name \(newName)")
                self.viewModel.updateName(newName: newName)
                self.deviceInformation[BLUETOOTH_NAME] = newName
                self.informationViewTable.reloadData()
                }
            }))
        
            nameChangeAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            self.present(nameChangeAlert, animated: true, completion: nil)
            
        default: print("Value is not editable")
        }
    }
}
















