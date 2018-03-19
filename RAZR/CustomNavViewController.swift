//
//  CustomNavViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/13/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

class CustomNavViewController: UINavigationController {

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var shouldAutorotate: Bool
    {
        return (visibleViewController?.shouldAutorotate)!
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return(visibleViewController?.supportedInterfaceOrientations)!
    }
}
