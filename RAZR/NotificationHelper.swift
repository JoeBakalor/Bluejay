//
//  NotificationHelper.swift
//  RAZR
//
//  Created by Joe Bakalor on 3/19/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation


import Foundation
import UIKit


/* Example usage
 * var notificationHelper = NotficationHelper()
 *
 * let alertMessage = "New Alert"
 * let newAlert = notificationHelper.createNewAlert(withTitle: "New Alert", alertMessage: alertMessage )
 *
 * notificationHelper.addDestructiveAlertAction(to: newAlert, withTitle: "OK", handler: { (alert) in
 *  self.navigationController?.popToRootViewController(animated: true)
 *  })
 *
 * self.present(newAlert, animated: true)
 */

struct NotificationHelper
{
    func createNewAlert(withTitle alertTitle: String,  alertMessage: String) -> UIAlertController{
        let newAlert = UIAlertController(title: alertTitle , message: alertMessage, preferredStyle: .alert)
        return newAlert
    }
    
    func addDestructiveAlertAction(to uiAlertController: UIAlertController, withTitle alertActionTitle: String, handler: @escaping (UIAlertAction) -> Void){
        let newAction = UIAlertAction(title: alertActionTitle, style: .destructive, handler: handler)
        uiAlertController.addAction(newAction)
    }
}
