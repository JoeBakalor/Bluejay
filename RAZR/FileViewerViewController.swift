//
//  FileViewerViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 9/5/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

class FileViewerViewController: UIViewController
{

    @IBOutlet weak var fileTextView: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        fileTextView.text = logDataManager.logFileManager?.getContentForSelectedFile()
        // Do any additional setup after loading the view.
    }

    @IBAction func shareLogFile(_ sender: UIBarButtonItem)
    {
        let activityItem =  NSURL(fileURLWithPath: selectedFileUrl.path)
        displayShareSheet(shareContent: activityItem)
        //displayShareContent()
        //let test = NSURL(
    }
    
    func displayShareSheet(shareContent:NSURL)
    {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSURL, "Data Log" as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    
}
