//
//  LogFilesViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 8/19/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit
import CoreBluetooth

class LogFilesViewController: UIViewController {

    @IBOutlet weak var logFilesTable: UITableView!
    var availableLogFiles: [String] = []
    var indexToDelete: IndexPath?
    var fileToDelete: String?
    
    let ERROR_DELETEING_FILE = #selector(LogFilesViewController.cantDeleteCurrentLogFile)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        availableLogFiles = logDataManager.logFileManager!.returnListOfLogFiles()
        
        
    }

    func viewFile()
    {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: ERROR_DELETEING_FILE, name: CANT_DELETE_CURRENT_LOG_FILE, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        NotificationCenter.default.removeObserver(self, name: CANT_DELETE_CURRENT_LOG_FILE, object:nil)
    }

}

//===================  TABLE VIEW DATA SOURCE ===================
extension LogFilesViewController: UITableViewDataSource
{
    /******************************************************************************/
    //
    /******************************************************************************/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return availableLogFiles.count
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! LogFileTableViewCell//UITableViewCell(style: .default, reuseIdentifier: "cell") as! LogFileTableViewCell
        cell.textLabel?.text = availableLogFiles[indexPath.row]
        return cell
    }
    
    
}

extension LogFilesViewController
{
    @objc func cantDeleteCurrentLogFile()
    {
        let alert = UIAlertController(title: "NOTE!", message: "Not allowed to delete current log file", preferredStyle: .actionSheet)
        let DeleteAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        
        alert.addAction(DeleteAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 1.0, y: 1.0, width: CGFloat(self.view.bounds.size.width / 2.0), height: self.view.bounds.size.height / 2.0)//CGRect(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteAllFiles(_ sender: UIBarButtonItem)
    {
        logDataManager.logFileManager?.deleteAllFiles()
        availableLogFiles = logDataManager.logFileManager!.returnListOfLogFiles()
        logFilesTable.reloadData()
        
    }
}

//=================== TABLE VIEW DELEGATE =======================
extension LogFilesViewController: UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            indexToDelete = indexPath
            fileToDelete = availableLogFiles[indexPath.row]
            confirmDelete()
        }
    }
    
    func confirmDelete()
    {
        let alert = UIAlertController(title: "Delete Log File", message: "Are you sure you want to permanently delete this Log?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteRow)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteRow)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 1.0, y: 1.0, width: CGFloat(self.view.bounds.size.width / 2.0), height: self.view.bounds.size.height / 2.0)//CGRect(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleDeleteRow(action: UIAlertAction)
    {
        logDataManager.logFileManager?.deleteFile(fileName: fileToDelete!)
        availableLogFiles = logDataManager.logFileManager!.returnListOfLogFiles()
        logFilesTable.reloadData()
        //historicalDataInstance.removeEntryAt(index: indexToDelete!.row)
        //historicalDataTableView.reloadData()
    }
    
    func cancelDeleteRow(action: UIAlertAction)
    {
        fileToDelete = nil
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedFile = availableLogFiles[indexPath.row]//.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        logDataManager.logFileManager?.setSelectedFile(fileName: selectedFile)
        
        let transistion = CATransition()
        transistion.subtype = kCATransitionFade
        view.window!.layer.add(transistion, forKey: kCATransition)
        let newView = self.storyboard?.instantiateViewController(withIdentifier: "fileViewerViewController") as! FileViewerViewController!
        self.navigationController?.show(newView!, sender: self)
    }
}

extension LogFilesViewController
{
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func addObservers()
    {
        

    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func removeObservers()
    {

        
    }
    

}
