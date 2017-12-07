//
//  Extensions.swift
//  ChatAppEK
//
//  Created by Mac on 12/6/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

extension UIViewController{
    func hideKeyboardOnTap(){
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatTextViewController.clickedSend(_:)))
        view.addGestureRecognizer(tap)
    }
}
