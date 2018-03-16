//
//  OTAViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/2/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//
//  INDEX:
//  extension BASE CLASS: VARIABLES, IBOUTLETS, viewDidLoad
//
//
//

import UIKit
import CoreBluetooth

// ============================== BASE CLASS ======================================
class OTAViewController: UIViewController
{
    //IBOutlets
    @IBOutlet weak var statusText                           : UILabel!
    @IBOutlet weak var percentComplete                      : UILabel!
    @IBOutlet weak var fileNameLabel                        : UILabel!
    @IBOutlet weak var startUpdateButton                    : UIButton!
    @IBOutlet weak var fileSelectionButton                  : UIButton!
    @IBOutlet weak var statusView                           : CounterView!
    @IBOutlet weak var fileSelectionView                    : UIView!
    @IBOutlet weak var logTextView                          : UITextView!
    @IBOutlet weak var textViewConstraint                   : NSLayoutConstraint!
    //Variables
    var fileTableView                                       : UITableView!
    var otaFileManager                                      : OTAFileManager!
    var selectedFileIndex                                   : IndexPath?
    //var bootloader                                          : BootloaderStateMachine?
    var timeStart                                           : Date?
    var dateStart                                           : Date?
    
    var dropDownShown                                       = false
    var setupComplete                                       = false
    var parseCompletionStatus: Float                        = 0
    var bootloaderCompletionStatus: Float                   = 0
    
    var fileArray: [(fileName: String, fileContent: [String])] = []
    //var fileToSend = (headerData: OTAFileManager.otaFile.headerPayload(), dataPayload: [OTAFileManager.otaFile.dataPayload()], rowID: [OTAFileManager.otaFile.rowIDPayload()])

    
    var viewModel: OTAViewModel!
    //
    
}

extension OTAViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        statusView.layer.cornerRadius = 100
        //otaFileManager = OTAFileManager()
        //fileArray = otaFileManager.loadAvailableOtaFiles()
        viewModel = OTAViewModel()
        setupBindings()
        //bootloader = BootloaderStateMachine()
        addObservers()
        //initializeBluetoothCommunications()
    }
    
    func setupUI(){
        
        let gradient                    = CAGradientLayer()
        gradient.frame                  = self.view.bounds
        gradient.colors                 = [UIColor.white.cgColor, UIColor.winegardBlueOp.cgColor]
        self.view.layer.insertSublayer(gradient, at: UInt32(0))
        
        fileSelectionButton.layer.cornerRadius = 2
    }
    
    func setupBindings(){
        
        viewModel.fileArray.bind { (newFileArray) in
             self.fileArray = newFileArray
        }
        
        viewModel.fileName.bind { (fileName) in
            self.fileNameLabel.text = fileName
        }
        
        viewModel.percentComplete.bind { (percentComplete) in
            guard let percentage = percentComplete else { return }
            //Notification recieved from background queue, move ui updates to main thread
            DispatchQueue.main.async{
                self.logTextView.text = logDataManager.debugString
                let bottom = NSMakeRange(self.logTextView.text.lengthOfBytes(using: .utf8) - 1, 1)
                self.logTextView.scrollRangeToVisible(bottom)
                self.statusText.text = "Sending File..."
                self.percentComplete.text = "\(Int(percentage))%"
                self.statusView.percentComplete = CGFloat(percentage)
                self.statusView.setNeedsDisplay()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.open()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.close()
    }
    
    //
    override func viewDidLayoutSubviews()
    {
        setupTableView()
    }
    
}

extension OTAViewController
{
    //
    @IBAction func starTransfer(_ sender: UIButton)
    {
        viewModel.startOtaUpdate()
        
        /*dateStart = Date()
        //escape if no file selected yet
        guard let fileIndexToProcess = selectedFileIndex else {print("Please Select File"); return}
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.otaFileManager.getOtaFormattedFile(forFileContent: self.fileArray[fileIndexToProcess.row].fileContent, completion:
                {
                    (header, data, row) in
                    self.bootloader!.setFile(fileToSend: (header, data, row))
                })
        }*/
    }
    
    //  Button to expand file selection view
    @IBAction func selectFileButton(_ sender: UIButton)
    {
        if dropDownShown{
            
            dropDownShown = false
            fileSelectionButton.isSelected = true
            
            UIView.animate(withDuration: 0.75, animations: {
                
                self.fileTableView.layer.opacity = 0
                
                self.logTextView.frame.size.height += 100
                self.logTextView.frame.origin.y -= 100
                
                self.fileSelectionView.frame.size.height -= 100
                self.fileTableView.frame.size.height -= 100
            })
            
        } else {
            
            dropDownShown = true
            fileSelectionButton.isSelected = false
            
            UIView.animate(withDuration: 0.75, animations: {
                
                self.fileSelectionView.addSubview(self.fileTableView)
                self.fileTableView.layer.opacity = 1
                
                self.logTextView.frame.size.height -= 100
                self.logTextView.frame.origin.y += 100
                
                self.fileSelectionView.frame.size.height += 100
                self.fileTableView.frame.size.height += 100
            })
        }
    }
    
    /******************************************************************************/
    //  Open and close file selection view
    /******************************************************************************/
    func openCloseFileView(open: Bool)
    {
        if !open {//open
            
            fileSelectionButton.isSelected = true
            dropDownShown = false
            UIView.animate(withDuration: 0.75, animations: {
                //self.fileTableView.removeFromSuperview()
                self.fileTableView.layer.opacity = 0
                //self.logTextView.frame.size.height -= 100
                self.fileSelectionView.frame.size.height -= 100
                self.fileTableView.frame.size.height -= 100
            })
            
        } else {//close
            
            fileSelectionButton.isSelected = false
            dropDownShown = true
            UIView.animate(withDuration: 0.75, animations: {
                self.fileSelectionView.addSubview(self.fileTableView)
                self.fileTableView.layer.opacity = 1
                self.fileSelectionView.frame.size.height += 100
                self.fileTableView.frame.size.height += 100
            })
        }
    }
    
    
}

// ============================== NOTIFICATION SETUP ===============================
extension OTAViewController
{
    /******************************************************************************/
    //  Add notification observers
    /******************************************************************************/
    func addObservers()
    {
        //need to add notifications for bootloader status reports
        var notificationName = NSNotification.Name(rawValue: "updateParseStatusID")
        var selector =  #selector(self.updateStatus(_:))
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName, object: nil)
        
        notificationName = NSNotification.Name(rawValue: "updateBootloaderStatusID")
        selector = #selector(self.updateStatus(_:))
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName, object: nil)

        notificationName = NSNotification.Name(rawValue: "completeID")
        selector = #selector(self.finished)
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName, object: nil)

    }

    /******************************************************************************/
    //  Remove notification observers
    /******************************************************************************/
    func removeObservers()
    {
        var notificationName = NSNotification.Name(rawValue: "updateParseStatusID")
        NotificationCenter.default.removeObserver(self, name: notificationName, object:nil)
        
        notificationName = NSNotification.Name(rawValue: "updateBootloaderStatusID")
        NotificationCenter.default.removeObserver(self, name: notificationName, object:nil)
        
        notificationName = NSNotification.Name(rawValue: "completeID")
        NotificationCenter.default.removeObserver(self, name: notificationName, object:nil)
        
    }
}

// ============================== BOOTLOADER UPDATES ==================================
extension OTAViewController
{
    /******************************************************************************/
    //  Called after firmware update has completed
    /******************************************************************************/
    @objc func finished()
    {
        //let timeToComplete = Date().timeIntervalSince(dateStart!)
        //statusText.text = "Update Completed in \(Int(timeToComplete))"
        percentComplete.text = "\(100)%"
        
        //statusText.text = "Update Finished in \(Int(timeToComplete))!"
        statusView.percentComplete = 99.9999
        statusView.setNeedsDisplay()
        
        logTextView.text = logDataManager.debugString
        let bottom = NSMakeRange(self.logTextView.text.lengthOfBytes(using: .utf8) - 1, 1)
        logTextView.scrollRangeToVisible(bottom)
    }
    
    /******************************************************************************/
    //  Update parsing file status, will extend to other types of updates, ie 
    //  ota update progress
    /******************************************************************************/
    @objc func updateStatus(_ notification: Notification)
    {
        switch notification.name.rawValue {
        case "updateParseStatusID": print("Parse Status updated")
        case "updateBootloaderStatusID": print("Bootloader Status Updated")
        
            let newStatus = notification.userInfo!["status"] as! Float
            bootloaderCompletionStatus = newStatus
        
            //Notification recieved from background queue, move ui updates to main thread
            DispatchQueue.main.async{
                self.logTextView.text = logDataManager.debugString
                let bottom = NSMakeRange(self.logTextView.text.lengthOfBytes(using: .utf8) - 1, 1)
                self.logTextView.scrollRangeToVisible(bottom)
                self.statusText.text = "Sending File..."
                self.percentComplete.text = "\(Int(newStatus))%"
                self.statusView.percentComplete = CGFloat(newStatus)
                self.statusView.setNeedsDisplay()
            }
            
        default: print("Unknown sender")
        }
        
    }
}


// =================================== BLUETOOTH ==================================
extension OTAViewController
{
    /******************************************************************************/
    //
    /******************************************************************************/
//    func initializeBluetoothCommunications()
//    {
//        let char = connectedWinegardDevice.winegardGattProfile!.winegardBootloaderChar
//        //initialize bootloader with bootloader characteristic
//        bootloader = BootloaderStateMachine(bootChar: char!)
//
//    }
}

// ============================== TABLE VIEW  =====================================
extension OTAViewController: UITableViewDataSource
{

    /******************************************************************************/
    //  Setup tableview
    /******************************************************************************/
    func setupTableView()
    {
        let tableOrigin = CGPoint(x: 0, y: fileSelectionView.frame.size.height)
        let tableSize = CGSize(width: fileSelectionView.frame.size.width, height: 0)
        let tableFrame = CGRect(origin: tableOrigin, size: tableSize)
        fileTableView = UITableView(frame: tableFrame, style: .grouped)
        fileTableView.backgroundColor = UIColor.white
        fileTableView.dataSource = self
        fileTableView.delegate = self
        fileTableView.reloadData()
    }
    /******************************************************************************/
    //  TableView number of rows in table
    /******************************************************************************/
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int
    {
        return fileArray.count
    }
    /*============================================================================*/
    //  TableView cell data and formatting
    /*============================================================================*/
    /******************************************************************************/
    //
    /******************************************************************************/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        //let cellData = fileArray[indexPath.row]

        cell.textLabel?.textColor = UIColor.black//(red: 0/255, green: 139/255, blue: 206/255, alpha: 1)
        cell.textLabel?.font = UIFont (name: (cell.textLabel?.font.fontName)!, size: 18)
        //cell.layer.cornerRadius = 10
        //cell.layer.borderWidth = 1
        //cell.layer.borderColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1).cgColor
        cell.textLabel?.text = fileArray[indexPath.row].fileName
        cell.selectionStyle = .none
        
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
    /*============================================================================*/
}

// Mark: Table View Delegate
extension OTAViewController: UITableViewDelegate
{
    /******************************************************************************/
    //
    /******************************************************************************/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("File Selected")
        fileNameLabel.text = fileArray[indexPath.row].fileName
        timeStart = Date()
        selectedFileIndex = indexPath
        
        viewModel.selectFileIndex(index: indexPath)
        openCloseFileView(open: false)

    }
    /*============================================================================*/
    
}


