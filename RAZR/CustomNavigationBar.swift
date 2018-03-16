//
//  CustomNavigationBar.swift
//  RAZR
//
//  Created by Joe Bakalor on 9/19/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

protocol CustomNavigationBarDelegate {
    func buttonPressed(buttonTitle: String, buttonIndex: Int)
}

@IBDesignable
class CustomNavigationBar: UIView
{
    @IBInspectable var numberOfTabs: Int = 2
    @IBInspectable var tabButtonTitles: [String] = ["Devics", "Widgets"]//, "TBD"]
    @IBInspectable var tabButtonSpacing: CGFloat = 2
    @IBInspectable var backgroundViewColor: UIColor = UIColor.winegardBlue
    @IBInspectable var buttonColor: UIColor = UIColor.winegardBlue
    var delegate: CustomNavigationBarDelegate?
    //var tabButtons: [UIButton] = []
    
    override func awakeFromNib()
    {
        layer.backgroundColor = backgroundViewColor.cgColor
    }
    
    override func draw(_ rect: CGRect)
    {
        let spacingTotal = tabButtonSpacing * CGFloat(numberOfTabs + 1)
        let width   = rect.size.width
        let height  = rect.size.height
        let baseOrgion = rect.origin
        let buttonWidth = (width - spacingTotal)/CGFloat(numberOfTabs)
        let buttonHeight = height - (2 * tabButtonSpacing)
        
        if tabButtonTitles.count == 0{
            
            for i in 0..<numberOfTabs{
                let buttonOrigon = CGPoint(x: baseOrgion.x + (tabButtonSpacing * CGFloat(i) + (buttonWidth * CGFloat(i))) + tabButtonSpacing, y: height/2 -  buttonHeight/2)
                let buttonSize = CGSize(width: buttonWidth, height: buttonHeight)
                let newButton = UIButton(frame: CGRect(origin: buttonOrigon, size: buttonSize))
                newButton.setTitle("Button\(i)", for: .normal)
                newButton.backgroundColor = buttonColor
                //newButton.addTarget(self, action: #selector(self.buttonPressed(button: newButton)), for: .touchDown)
                self.addSubview(newButton)
            }
            
        }else{
            
            for i in 0..<numberOfTabs{
                let buttonOrigon = CGPoint(x: baseOrgion.x + (tabButtonSpacing * CGFloat(i) + (buttonWidth * CGFloat(i))) + tabButtonSpacing, y: height/2 -  buttonHeight/2)
                let buttonSize = CGSize(width: buttonWidth, height: buttonHeight)
                let newButton = UIButton(frame: CGRect(origin: buttonOrigon, size: buttonSize))
                newButton.setTitle(tabButtonTitles[i], for: .normal)
                newButton.backgroundColor = buttonColor
                newButton.sendActions(for: .touchDown)
                //newButton.addTarget(self, action: #selector(self.buttonPressed(button: newButton)), for: .touchDown)
                self.addSubview(newButton)
            }
        }
        
    }
    
    //HANDLE TAB BAR BUTTON PRESSED
    @objc
    func buttonPressed(button: UIButton)
    {
        print("Tab Button Pressed")
    }
 

}
