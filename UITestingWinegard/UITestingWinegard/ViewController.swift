//
//  ViewController.swift
//  UITestingWinegard
//
//  Created by Joe Bakalor on 8/15/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var dropDownView: UIView!
    var fileTableView: UITableView!
    var dropDownShown = false
    
    @IBOutlet weak var fileNameLabel: UILabel!

    //test Array
    let fileArray: [String] = ["fileOne", "fileTwo", "fileThree", "fileFour", "fileFive"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        dropDownButton.layer.cornerRadius = 2
        dropDownView.layer.cornerRadius = 2
    }
    
    override func viewDidLayoutSubviews()
    {
        if fileTableView == nil{
            setupTableView()
        }
    }
    
    func setupTableView()
    {
        let customPoint = CGPoint(x: 0, y: 50)
        let customSize = CGSize(width: self.dropDownView.frame.size.width, height: 0)
        let customFrame = CGRect(origin: customPoint, size: customSize)
        fileTableView = UITableView(frame: customFrame, style: .grouped)
        fileTableView.layer.backgroundColor = UIColor.white.cgColor
        fileTableView.dataSource = self
        fileTableView.delegate = self
        fileTableView.sectionHeaderHeight = 0
        fileTableView.layer.cornerRadius = 2
        fileTableView.reloadData()
        
    }
    
    @IBAction func dropDownSelected(_ sender: UIButton)
    {
        if dropDownShown{
            
            dropDownShown = false
            dropDownButton.isSelected = true
            UIView.setAnimationCurve(.easeOut)
            UIView.animate(withDuration: 1, animations: {
                
                //self.fileTableView.removeFromSuperview()
                self.fileTableView.layer.opacity = 0
                self.dropDownView.frame.size.height -= 200
                self.fileTableView.frame.size.height -= 200
            })
            
        } else {
            
            dropDownShown = true
            dropDownButton.isSelected = false
            UIView.setAnimationCurve(.easeIn)
            UIView.animate(withDuration: 1, animations: {
                self.dropDownView.addSubview(self.fileTableView)
                self.fileTableView.layer.opacity = 1
                self.dropDownView.frame.size.height += 200
                self.fileTableView.frame.size.height += 200
            })
        }
    }

    
    func openCloseFileView(open: Bool)
    {
        if !open {//open
            
            dropDownButton.isSelected = true
            dropDownShown = false
            UIView.animate(withDuration: 1, animations: {
                //self.fileTableView.removeFromSuperview()
                self.fileTableView.layer.opacity = 0
                self.dropDownView.frame.size.height -= 200
                self.fileTableView.frame.size.height -= 200
            })
            
        } else {//close
            
            dropDownButton.isSelected = false
            dropDownShown = true
            UIView.animate(withDuration: 1, animations: {
                self.dropDownView.addSubview(self.fileTableView)
                self.fileTableView.layer.opacity = 1
                self.dropDownView.frame.size.height += 200
                self.fileTableView.frame.size.height += 200
            })
        }
    }
}



extension ViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("Number of cells")
        return fileArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.white
        cell.textLabel?.textColor = UIColor.blue
        cell.textLabel?.font = UIFont (name: (cell.textLabel?.font.fontName)!, size: 18)
        cell.textLabel?.text = fileArray[indexPath.row]
        print("cell text")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        print("Height For Row")
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0
    }
    
}

extension ViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        fileNameLabel.text = fileArray[indexPath.row]
        openCloseFileView(open: false)
        print("cell selected")
    }
}









