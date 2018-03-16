//
//  SettingsViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 8/23/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController
{
    /******************************************************************************/
    //
    /******************************************************************************/
    @IBOutlet weak var loggingEnableSwitch: UISwitch!
    
    /******************************************************************************/
    //
    /******************************************************************************/
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if dataLoggingEnabled{
            loggingEnableSwitch.isOn = true
        } else {
            loggingEnableSwitch.isOn = false
        }
        // Do any additional setup after loading the view.
    }


}

extension SettingsViewController
{
    
    /******************************************************************************/
    //
    /******************************************************************************/
    @IBAction func enableLoggingSwitch(_ sender: UISwitch)
    {
        if sender.isOn{
            dataLoggingEnabled = true
            logDataManager.loggingEnable(enable: true)
        } else {
            dataLoggingEnabled = false
            logDataManager.loggingEnable(enable: false)
        }
    }
    
}
