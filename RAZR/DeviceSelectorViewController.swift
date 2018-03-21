//
//  DeviceSelectorViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/5/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//
//  Summary: 
//

import UIKit
import CoreBluetooth
import JABLE

let debug = false
//var connectedWinegardDevice = WinegardDevice()
var workingPeripheral: CBPeripheral?
let winegardServerDataManager = WinegardServerDataManager()
var globalLocationManager: LocationManager?
var logFileCreated = true

let testing = true

//MARK: BASE CLASS
class DeviceSelectorViewController: UIViewController //CustomNavigationBarDelegate
{
    let RELOAD_TABLE_DATA               = #selector(DeviceSelectorViewController.reloadTableData)
    
    //IBOUTLETS
    @IBOutlet weak var availableDevicesTable    : UITableView!
    @IBOutlet weak var connectionStatusView     : UIView!
    @IBOutlet weak var connectionStatusViewLabel: UILabel!
    @IBOutlet weak var connectionStatusIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deviceManagerTabItem     : UITabBarItem!
    @IBOutlet weak var widgetsTabItem           : UITabBarItem!
    @IBOutlet weak var tabBar                   : UITabBar!
    
    // Variables
    var timer                               = Timer()
    var discoveredPeripherals: [(peripheral: CBPeripheral, advData: FriendlyAdvdertismentData)] = []
    var testOtaFileDownload                 = FirmwareUpdateManager()
    var viewModel: DeviceSelectorViewModel!
    var tableUpdateTimer: Timer?
}


//MARK:  View setup and teardown
extension DeviceSelectorViewController
{
    override func viewDidLoad(){
        
        super.viewDidLoad()
        viewModel = DeviceSelectorViewModel()
        
        setupUI()
        globalLocationManager = LocationManager()
    }
    
    func setupUI(){
        
        tabBar.selectedItem = tabBar.items![0]
        connectionStatusView.isHidden = true
        
        //Add gradient to background
        let gradient                    = CAGradientLayer()
        gradient.frame                  = self.view.bounds
        gradient.colors                 = [UIColor.white.cgColor, UIColor.extraLightGray.cgColor]
        self.view.layer.insertSublayer(gradient, at: UInt32(0))
    }
    
    //  Do any setup just before view appears
    override func viewWillAppear(_ animated: Bool){
        
        logDataManager.logFileManager!.createNewFileWithName(name: "SYS_LOG \(Date().formatted)")
        connectionStatusView.isHidden = true
        tableUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: RELOAD_TABLE_DATA, userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("DeviceSelectorViewController: viewDidAppear")
        viewModel.open()
        setupBindings()
    }
    
    override func viewWillDisappear(_ animated: Bool){
        
        print("DeviceSelectorViewController: viewWillDisappear")
        removeBindings()
        viewModel.close()
    }
    
    //  Orientation setup
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        
        //Set supported orienations to portrait only
        return [.portrait]
    }
    
    //  Set autorotate
    override var shouldAutorotate: Bool{
        
        //Set autorotate to true
        return true
    }
}
extension DeviceSelectorViewController
{
    //  Create binding for viewModel properties
    func setupBindings(){
        
        //  Add binding to discovered peripherals
        viewModel.discoveredPeripherals.bind(listener:
        { (updatedPeripheralList) in
            
            self.discoveredPeripherals = updatedPeripheralList
            //self.availableDevicesTable.reloadData()
        })
        
        //  Add binding to connection state
        viewModel.connectionState.bind(listener:
        { (connectionState) in
            
            switch connectionState{
            case .attemptingConnection:
                
                print("DeviceSelectorViewController: Connection state updated to \(connectionState)")
                self.connectionStatusView.isHidden = false
                self.connectionStatusViewLabel.text = "Connecting"
                self.connectionStatusIndicator.startAnimating()
                
            case .connectionFailed:
                
                print("DeviceSelectorViewController: Connection state updated to \(connectionState)")
                self.connectionStatusViewLabel.text = "Connection Failed"
                self.connectionStatusIndicator.stopAnimating()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    self.connectionStatusView.isHidden = true
                    self.tableUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: self.RELOAD_TABLE_DATA, userInfo: nil, repeats: true)
                })
                
            case .connected:
                
                print("DeviceSelectorViewController: Connection state updated to \(connectionState)")
                print("IS THIS WHAT IS BEING CALLED")
                self.timer.invalidate()
                //Move to widgets view
                let newView = self.storyboard?.instantiateViewController(withIdentifier: "widgetsViewController") as! WidgetsViewController!
                self.navigationController?.show(newView!, sender: self)
                
            case .disconnected:
                print("DeviceSelectorViewController: Connection state updated to \(connectionState)")
            }
        })
    }
    
    func removeBindings(){
        
        viewModel.discoveredPeripherals.bind(listener: nil)
        viewModel.connectionState.bind(listener: nil)
    }
    
    //  Reload Winegard Device Table
    @objc func reloadTableData(){
        
        availableDevicesTable.reloadData()
    }
}

//MARK: TAB BAR ACTION ITEMS
extension DeviceSelectorViewController: UITabBarDelegate
{
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        
        print("\(item.title!)")
        switch item.title!
        {
        case "Device Manager": print("Device manager")
        case "Widgets": print("Try to go directly to widgets, this will likely break")
//        timer.invalidate()
//        removeObservers()
//
//        //Move to widgets view
//        let newView = self.storyboard?.instantiateViewController(withIdentifier: "widgetsViewController") as! WidgetsViewController!
//        self.navigationController?.show(newView!, sender: self)
        default: print("Unrecognized TAB selected")
        }
    }
}

// =============================== Table Views ====================================
extension DeviceSelectorViewController: UITableViewDataSource
{
    //  TableView number of rows in table
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        //return listOfPeripherals.count
        return discoveredPeripherals.count
    }
    
    //  TableView cell data and formatting
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = UITableViewCell()
    
        //Tableview cell formatting
        cell.textLabel?.textColor = UIColor(red: 0/255, green: 139/255, blue: 206/255, alpha: 1)
        cell.textLabel?.font = UIFont (name: (cell.textLabel?.font.fontName)!, size: 18)
        
        var cellData = ""
        var numberOfLinesNeeded = 2
        
        // Retrieve peripheral entry for index
        let peripheralData = discoveredPeripherals[indexPath.row]
        
        //  Populate name if available
        if let localName = peripheralData.advData.localName{
            numberOfLinesNeeded += 1
            cellData = cellData + "\(localName)"
        } else if let name = peripheralData.peripheral.name {
            numberOfLinesNeeded += 1
            cellData = cellData + "\(name)"
        }
        
        //  Populate RSSI if available
        if let rssi = peripheralData.advData.rssi{
            numberOfLinesNeeded += 1
            cellData = cellData + "\rRSSI: [\(rssi)]"
        }
        
        let image = UIImage(named: "winegardIcon.png")
        let newImage = resizeImage(image: image!, toTheSize: CGSize(width: 75,height: 75))
        let cellImageLayer: CALayer?    = cell.imageView?.layer//.cellImage.layer
        
        cellImageLayer!.cornerRadius    = cellImageLayer!.frame.size.width / 2
        cellImageLayer!.masksToBounds   = true
        
        cell.imageView?.image           = newImage
        cell.textLabel?.numberOfLines   = numberOfLinesNeeded
        cell.textLabel?.text            = cellData
        cell.backgroundColor            = UIColor.clear
        
        let falseCellBackground = UIView(frame: CGRect(x: 5, y: 5, width: availableDevicesTable.frame.width - 10, height: 110))
        falseCellBackground.layer.cornerRadius      = 10
        falseCellBackground.layer.shadowColor       = UIColor.darkGray.cgColor
        falseCellBackground.layer.shadowOffset      = CGSize(width: 1, height: 2)
        falseCellBackground.layer.shadowRadius      = 2.0
        falseCellBackground.layer.shadowOpacity     = 1.0
        falseCellBackground.layer.masksToBounds     = false
        falseCellBackground.layer.backgroundColor   = UIColor.white.cgColor//??, why do i have this twice
        
        cell.addSubview(falseCellBackground)
        cell.sendSubview(toBack: falseCellBackground)
        
        return cell
    }
    
    //RESIZE IMAGE CELL
    func resizeImage(image:UIImage, toTheSize size:CGSize)->UIImage{
        
        let scale = CGFloat(max(size.width/image.size.width, size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;
        let rr:CGRect = CGRect(x: 0,y: 0,width: width,height: height);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!
    }
    
    //SET ROW HEIGHT
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //let height = (tableView.cellForRow(at: indexPath)?.imageView?.frame.height)!*2
        return 120//CGFloat(height)
    }
    
    //REMOVE SECTION FOOTERS
    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        let view:UIView = UIView()
        view.alpha = 0
        return view
    }
    
}

//MARK: Table Delegate
extension DeviceSelectorViewController: UITableViewDelegate
{
    //USER SELECTED TABLE ROW
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //try to connect to peripheral

        tableUpdateTimer?.invalidate()
        bleManager.stopScanning()
        viewModel.connectTo(peripheral: discoveredPeripherals[indexPath.row].peripheral)
    }    
}


