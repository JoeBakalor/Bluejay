//
//  WinegardTableViewCell.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/6/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

class WinegardTableViewCell: UITableViewCell {

    
    let imgUser = UIImageView()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        imgUser.layer.cornerRadius = 10
        imgUser.layer.borderWidth = 2
        imgUser.layer.borderColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1).cgColor
        contentView.addSubview(imgUser)
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
