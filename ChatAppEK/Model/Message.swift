//
//  Message.swift
//  ChatAppEK
//
//  Created by Mac on 12/6/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

struct Message{
    var sender:String?
    var message:String?
    var key:String?
    
    init?(sender:String?, message:String?, key:String?) {
        self.sender = sender
        self.message = message
        self.key = key
    }
}
