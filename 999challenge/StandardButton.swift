//
//  StandardButton.swift
//  999challenge
//
//  Created by Simon Lovelock on 17/03/2016.
//  Copyright © 2016 haloApps. All rights reserved.
//

import UIKit

class StandardButton: UIButton {

    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
        self.backgroundColor = UIColor(red: 0/255, green: 155/255, blue: 255/255, alpha: 0.87)
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }

}
