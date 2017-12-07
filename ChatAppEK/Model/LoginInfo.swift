//
//  LoginInfo.swift
//  ChatAppEK
//
//  Created by Mac on 12/3/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

class LoginInfo{
    static let shared = LoginInfo()
    var user:User?
    var isLoggedIn:Bool{
        get {return user != nil}
    }
    let sharedAuth = Auth.auth()
    init(){
        sharedAuth.addStateDidChangeListener { (auth, user) in
            guard let user = user else {return}
            guard let email = user.email else {return}
            self.user = User(email: email, uid: user.uid)
        }
    }
}

struct User{
    typealias UserEmail = String
    typealias UserUID = String
    let email:UserEmail
    let uid:UserUID
}
