//
//  CustomDropDownView.swift
//  RAZR
//
//  Created by Joe Bakalor on 8/30/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//


//
//  DropDownSelectorView.swift
//  CodeBase
//
//  Created by Joe Bakalor on 8/30/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class DropDownSelectorView: UIView
{
    
    @IBInspectable var buttonColor = UIColor.blue
    @IBInspectable var fileSelectionBackgroundColor = UIColor.white
    @IBInspectable var fileSelectionLabelColor = UIColor.lightGray
    
    var selectedFileView: UIView!
    var currentSelectionLabel: UILabel!
    var optionsTableView: UITableView!
    var dropDownButton: UIButton!
    
    
    override func draw(_ rect: CGRect)
    {
        let width = rect.size.width
        let heightMajor = rect.size.height
        let buttonWidth = width * 0.1
        let selectedFileViewWidth = width * 0.9
        let heightMinor = heightMajor * 0.25
        
        //add button
        let buttonOrigin = CGPoint(x: width - buttonWidth, y: 0)
        let buttonSize = CGSize(width: buttonWidth, height: heightMinor)
        dropDownButton = UIButton(frame: CGRect(origin: buttonOrigin, size: buttonSize))
        dropDownButton.backgroundColor = buttonColor
        self.addSubview(dropDownButton)
        dropDownButton.addTarget(self, action: #selector(self.fileSelectionButton), for: .touchDown)
        
        let selectedFileViewOrigin = CGPoint(x: 0, y: 0)
        let selectedFileViewSize = CGSize(width: selectedFileViewWidth, height: heightMinor)
        selectedFileView = UIView(frame: CGRect(origin: selectedFileViewOrigin, size: selectedFileViewSize))
        selectedFileView.backgroundColor = fileSelectionBackgroundColor
        self.addSubview(selectedFileView)
        
        let currentSelectionLabelOrigin = CGPoint(x: 0, y: 0)
        let currentSelectionLableSize = CGSize(width: selectedFileView.frame.size.width, height: selectedFileView.frame.height)
        currentSelectionLabel = UILabel(frame: CGRect(origin: currentSelectionLabelOrigin, size: currentSelectionLableSize))
        currentSelectionLabel.text = "Select Option"
        currentSelectionLabel.textColor = fileSelectionLabelColor
        selectedFileView.addSubview(currentSelectionLabel)
    }
    
    @objc func fileSelectionButton()
    {
        
    }
}













