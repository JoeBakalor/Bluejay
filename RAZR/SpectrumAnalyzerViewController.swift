//
//  SpectrumAnalyzerViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/6/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit
import CoreBluetooth

//REALLY SHOULDNT BE GLOBAL
var scanManager = ScanManager()

// ============================== Base Class ======================================
class SpectrumAnalyzerViewController: UIViewController
{
    /******************************************************************************/
    //  IBOutlets
    /******************************************************************************/
    @IBOutlet weak var spectrumPlot                     : GraphView!
    @IBOutlet weak var configurationView                : UIView!
    @IBOutlet weak var xTrailing                        : NSLayoutConstraint!
    @IBOutlet weak var showConfigButton                 : UIButton!
    @IBOutlet weak var blurView                         : UIView!
    
    @IBOutlet weak var valueViewSelectionTopConstraint  : NSLayoutConstraint!
    @IBOutlet weak var scanParamterEntryView            : UIView!
    @IBOutlet weak var valueSelectionView               : UIView!
    @IBOutlet weak var valueSelectionTableView          : UITableView!
    @IBOutlet weak var saveButton                       : UIButton!
    @IBOutlet weak var cancelButton                     : UIButton!
    /******************************************************************************/
    //  Constants
    /******************************************************************************/
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    /******************************************************************************/
    //  Variables
    /******************************************************************************/
    var configViewIsShowing                                     = true
    var spectrumDataArray: [(frequency: Int, power: Int)]       = []
    var scanBandwith: (startFrequency: Int, stopFrequency: Int) = (100, 850)
    var setupComplete                                           = false
    var sampleNumber                                            = 0
    var debugPowerArray                                         = [Int](repeating: 0, count: 40)
    var valueSelectionViewIsShown                               = true
    
    var blurEffectView                                          : UIVisualEffectView?
    var utilityTimer                                            : Timer?
    var dataPointCount                                          : Int?
    /******************************************************************************/
    //
    /******************************************************************************/
    var viewModel: SpectrumAnalyzerViewModel!
}

extension SpectrumAnalyzerViewController
{
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        viewModel = SpectrumAnalyzerViewModel()
        setupUI()
        addObservers()
        setupBindings()
        //initializeBluetoothCommunications()
        
        valueSelectionView.isHidden = true//.alpha = 0
        self.configurationView.setNeedsLayout()
        configurationView.layer.cornerRadius = 3
    }
    
    func setupUI(){
        //let maxGraphValue                   = spectrumPlot.graphPoints.max()!
        blurView.isHidden                   = false
        self.blurView.backgroundColor       = UIColor.clear
        blurEffectView                      = UIVisualEffectView(effect: blurEffect)
        blurEffectView!.frame               = self.blurView.bounds
        blurEffectView!.autoresizingMask    = [.flexibleWidth, .flexibleHeight]
        blurEffectView!.alpha               = 0.97
        self.blurView.addSubview(blurEffectView!)
    }
    
    func setupBindings(){
        viewModel.recievedData.bind { (data) in
            self.redrawWithNewData()
        }
        
        viewModel.isConnected.bind { (connected) in
            if !connected{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    
}

// ============================== ======================================
extension SpectrumAnalyzerViewController
{
    /******************************************************************************/
    //  Present value selection view to user for picking value
    /******************************************************************************/
    @objc func switchToValueSelection()
    {
        print("Switch between value selection and entry")
        if valueSelectionViewIsShown{
            
            //value was selected so update options arrays
            scanManager.updateScanParameterOptions()
            //var newPoint = CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude)
            self.valueViewSelectionTopConstraint.constant += self.valueSelectionView.frame.height*1.2
            
            //need to scroll table to expected position
            switch scanManager.selectedScanParameter{
            case .startFrequency: print("No option")//valueSelectionTableView.setContentOffset(newPoint, animated: true)
            case .stopFrequency: print("No option")
            default:  print("No option")
            }
            
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: [.curveEaseIn],
                           animations: {self.view.layoutIfNeeded()},
                           completion: {
                                (result: Bool) in
                                self.valueSelectionView.isHidden = false}
            )

            valueSelectionViewIsShown = false
            
        } else {
            //need to populate value table with appropriate value
            //scanManager.updateScanParameterOptions()
            valueSelectionTableView.reloadData()//values are loaded based on parameterSelected in scanManager
            
            self.valueViewSelectionTopConstraint.constant -= self.valueSelectionView.frame.height*1.2
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: [.curveEaseOut],
                           animations: {self.view.layoutIfNeeded()},
                           completion: nil)
                           valueSelectionViewIsShown = true
        }
    }
    
    //DO ANYTHING AFTER VIEW APPEARS
    override func viewDidAppear(_ animated: Bool)
    {
        switchToValueSelection()
        let button: UIButton = UIButton()
        showConfig(button)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return [.landscapeLeft, .landscapeRight]
    }
    

    override var shouldAutorotate: Bool
    {
        return true
    }


    override func viewWillDisappear(_ animated: Bool)
    {
        //Turn off scanning -- Move to designated function
        
        //BLEConnectionManagerSharedInstance.bleService?.writeValueToCharacteristic(data as Data, characteristic: connectedWinegardDevice.winegardGattProfile!.winegardScanConfigurationChar!)
        
        //1. Turn off notification when leaving
        //BLEConnectionManagerSharedInstance.bleService?.turnOffNotifications(connectedWinegardDevice.winegardGattProfile!.winegardScanDataChar!)
        viewModel.close()
        //2. Remove observers so no notifcations are sent to this class
        removeObservers()
        //.subscribeToNotificationsForCharacteristic(connectedWinegardDevice.winegardGattProfile!.winegardScanDataChar)
        utilityTimer?.invalidate()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(false)
        viewModel.open()
        valueSelectionView.isHidden = true
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    func redrawWithNewData()
    {
        var powerArray: [Int] = []
        for dataPoint in (scanManager.recievedSpecrtalDataArray){
            powerArray.append(dataPoint.power)
        }
        spectrumPlot.graphPoints = powerArray//graphPointsCopy
        spectrumPlot.setNeedsDisplay()
    }

    //  This is called after any scan configuration parameters are set by the user
    func updateScanConfiguration(newConfiguration: Data)
    {
        viewModel.updateScanConfiguration(configuration: newConfiguration)
        print("Process completed successfully")
    }

    //
    /*@objc func newValueReported(_ notification: Notification)
    {
        let characteristicInfo = notification.userInfo as! [String : CBCharacteristic]!
        let characteristicData = characteristicInfo?["characteristicWithNewValue"]
        var data: Data?
        //var dataLength: Int?
        
        if characteristicData!.value != nil{
            
            data = characteristicData!.value as Data!
            //dataLength = data!.count as Int!
            
            var dataBytes = [UInt8](repeating: 0, count: data!.count)
            (data! as NSData).getBytes(&dataBytes, length: data!.count)
            
            //submit data for processing
            print("Data for scan manager = \(String(describing: data?.hexEncodedString()))")
            let result = scanManager.processNewData(newDataBytes: dataBytes)
            //print("Process new data result = \(result)")
            
            if result == "SUCCESS"{
                print("redraw graph")
                redrawWithNewData()//update displayed data
            }
        }
    }*/

}

// ============================== IBACTIONS ======================================
extension SpectrumAnalyzerViewController
{
    //  Show/Hide configuration view to user
    @IBAction func showConfig(_ sender: UIButton)
    {
        
        print("Is this called")
        if !configViewIsShowing{//stateAreReversed accident, need to change
            print("Config view is showing")
            showConfigButton.setTitle("Setup ▶︎", for: .normal)
            self.xTrailing.constant += self.configurationView.frame.width*1.1
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: [.curveEaseOut],
                           animations:{
                            self.blurEffectView!.alpha = 0.97
                            self.view.layoutIfNeeded()},
                           completion: nil)
            configViewIsShowing = true
            
        } else {
            print("Config View is hidden")
            showConfigButton.setTitle("◀︎ Setup", for: .normal)
            self.xTrailing.constant -= self.configurationView.frame.width*1.1
            blurView.isHidden = false
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: [.curveEaseIn],
                           animations:{
                            self.blurEffectView!.alpha = 0
                            self.view.layoutIfNeeded()},
                           completion: nil)
            configViewIsShowing = false
        }
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    @IBAction func saveButton(_ sender: UIButton)
    {
        //1. need to turn off notifications for scan data before sending the new settings
        print("Turn off notifications for scan data before updating config")
        
        //should probably use if let for safety
        //BLEConnectionManagerSharedInstance.bleService?.turnOffNotifications(connectedWinegardDevice.winegardGattProfile!.winegardScanDataChar!)
        
        //2. need to set spectrumScanConfig to pendingSpectrumScanConfig
        let newConfiguration = scanManager.savePendingConfiguration()
        
        //3. send new scan configuration to the Rayzar
        updateScanConfiguration(newConfiguration: newConfiguration)
        
        //4. initialize the graphView to accomodate the new scan configuration
        print("Need to initialize graphView at this point to prepare for new data")
        redrawWithNewData()
        
        
        //5. turn notifications back on for scan data and resume plotting
        //BLEConnectionManagerSharedInstance.bleService?.subscribeToNotificationsForCharacteristic(connectedWinegardDevice.winegardGattProfile!.winegardScanDataChar!)
        
        
        let button: UIButton = UIButton()
        showConfig(button)
    }
    
    
    /******************************************************************************/
    //
    /******************************************************************************/
    @IBAction func cancelButton(_ sender: UIButton)
    {
        //1. Reset pendingSpectrumScanConfig to default values
        
        //2. Update scan paramter selction view labels to defaults
        
        let button: UIButton = UIButton()
        showConfig(button)
    }
}


// ============================== ======================================
extension SpectrumAnalyzerViewController
{
    /******************************************************************************/
    //
    /******************************************************************************/
    func addObservers()
    {
        var notificationName = NSNotification.Name(rawValue: "characteristicValueWasUpdatedID")
        //var selector = #selector(SpectrumAnalyzerViewController.newValueReported(_:))
        //NotificationCenter.default.addObserver(self, selector: selector, name: CHAR_VALUE_UPDATED, object: nil)

        notificationName = NSNotification.Name(rawValue: "scanParameterSelectedID")
        let selector = #selector(SpectrumAnalyzerViewController.switchToValueSelection)
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName, object: nil)
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func removeObservers()
    {
        var notificationName = NSNotification.Name(rawValue: "characteristicValueWasUpdatedID")
        //NotificationCenter.default.removeObserver(self, name: CHAR_VALUE_UPDATED, object:nil)

        notificationName = NSNotification.Name(rawValue: "scanParameterSelectedID")
        NotificationCenter.default.removeObserver(self, name: notificationName, object:nil)
    }
}

// ============================== ======================================
extension SpectrumAnalyzerViewController: UITableViewDataSource
{
    /******************************************************************************/
    //
    /******************************************************************************/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var count = 0
        //return count of specifiecd value array
        switch scanManager.selectedScanParameter{
            
        case .quickSettings: print("Quick Settings, don't do anything right now")
            count = scanManager.quickSettings.count
            
        case .startFrequency: print("Load start frequency array count")
            count = scanManager.scanStartFrequencyOptions.count
            
        case .stopFrequency: print("Load stop frequency array count")
            count = scanManager.scanStopFrequencyOptions.count
            
        case .scanResolution: print("Load scan resolution array count")
            count = scanManager.scanResolutionOptions.count
            
        case .scansPerFrequency: print("Load scans per frequency count")
            count = scanManager.scanScanPerFrequencyOptions.count
            
        case .noSelection: print("No selection")
            
        //default: print("No Selection")
    
        }
        return count
    }

    /******************************************************************************/
    //
    /******************************************************************************/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.textColor = UIColor.black//(red: 0/255, green: 139/255, blue: 206/255, alpha: 1)
        cell.textLabel?.font = UIFont (name: (cell.textLabel?.font.fontName)!, size: 18)

        switch scanManager.selectedScanParameter{
            
        case .quickSettings: print("Quick Settings selected")
            cell.textLabel?.text = scanManager.quickSettings[indexPath.row].settingName
            
        case .startFrequency: //print("Load start frequency array")
            cell.textLabel?.text = "\((Float(scanManager.scanStartFrequencyOptions[indexPath.row])/1_000_000)) MHz"
            
        case .stopFrequency: ///print("Load stop frequency array")
            cell.textLabel?.text = "\((Float(scanManager.scanStopFrequencyOptions[indexPath.row])/1_000_000)) MHz"
            
        case .scanResolution: //print("Load scan resolution array")
            cell.textLabel?.text = "\((Float(scanManager.scanResolutionOptions[indexPath.row])/1_000_000)) MHz"
            
        case .scansPerFrequency: //print("Load scans per frequency")
            cell.textLabel?.text = "\(scanManager.scanScanPerFrequencyOptions[indexPath.row])"
            
        case .noSelection: print("No selection")
            cell.textLabel?.text = "Error"

        }
        
        return cell
    }

    /******************************************************************************/
    //
    /******************************************************************************/
    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let view:UIView = UIView()
        view.alpha = 0
        return view
    }

}

// ============================== ======================================
extension SpectrumAnalyzerViewController: UITableViewDelegate
{
    /******************************************************************************/
    //
    /******************************************************************************/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch scanManager.selectedScanParameter{
        
        case .quickSettings: print("Quick Settings, set pending configuration to quick setting")
            //will need to update all of the labes for start, stop, resolution etc for quick setting
            //options
            scanManager.pendingSpectrumScanConfig = scanManager.quickSettings[indexPath.row].settingValues
            
               //let val = indexPath.row
            let state: ScanManager.quickSettingSelected = ScanManager.quickSettingSelected(rawValue: indexPath.row)!
            scanManager.currentQuickSetting = state
            
        case .startFrequency: print("Load start frequency array selection")
            //Lets use a temporary struct to store user selections and not commit them until user selects save!!
        
            //scanManager.spectrumScanConfig.startFrequency = scanManager.scanStartFrequencyOptions[indexPath.row]
            scanManager.pendingSpectrumScanConfig.startFrequency = scanManager.scanStartFrequencyOptions[indexPath.row]

        case .stopFrequency: print("Load stop frequency array selection")
        
            //scanManager.spectrumScanConfig.stopFrequency = scanManager.scanStopFrequencyOptions[indexPath.row]
            scanManager.pendingSpectrumScanConfig.stopFrequency = scanManager.scanStopFrequencyOptions[indexPath.row]

        case .scanResolution: print("Load scan resolution array selection")
        
            //scanManager.spectrumScanConfig.scanResolution = scanManager.scanResolutionOptions[indexPath.row]
            scanManager.pendingSpectrumScanConfig.scanResolution = scanManager.scanResolutionOptions[indexPath.row]
            
        case .scansPerFrequency: print("Load scans per frequency, no setup currently")
        //cell.textLabel?.text = scanManager.scanScanPerFrequencyOptions[indexPath.row]
            
        case .noSelection: print("No selection")
        //cell.textLabel?.text = "Error"
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "scanParameterUpdatedID"), object: self, userInfo: nil)
        //User Select value, now set value in scanManager based on currentlySelectedParameter
        print("\(indexPath.row)")
        switchToValueSelection()
    }

}

