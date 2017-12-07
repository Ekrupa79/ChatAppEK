//
//  ChatLoginViewController.swift
//  ChatAppEK
//
//  Created by Mac on 12/3/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class ChatLoginViewController: UIViewController {
    
    @IBOutlet weak var userTextField:UITextField!
    @IBOutlet weak var passTextField:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.userTextField.delegate = self
        self.passTextField.delegate = self
        
        userTextField.text = "ek@testmac.com"
        passTextField.text = "ek7macchat"
        
        passTextField.becomeFirstResponder()
        
        userTextField.layer.borderWidth = 0.8
        userTextField.layer.borderColor = UIColor.black.cgColor
        userTextField.layer.cornerRadius = 5.0
        userTextField.layer.masksToBounds = true
        passTextField.layer.borderWidth = 0.8
        passTextField.layer.borderColor = UIColor.black.cgColor
        passTextField.layer.cornerRadius = 5.0
        passTextField.layer.masksToBounds = true
        
        //UserDefaults
        guard let email = UserDefaults.standard.object(forKey: Constants.kUserNameKey) as? String else {return}
        userTextField.text = email
        guard LoginInfo.shared.isLoggedIn else {return}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func logInToFirebase(){
        guard let userText = userTextField.text else {return}
        guard let passText = passTextField.text else {return}
        LoginInfo.shared.sharedAuth.signIn(withEmail: userText, password: passText){
            (user, error) in
            guard error == nil else {
                //self.sendAlert(message: error!.localizedDescription)
                return
            }
            guard let user = user else {return}
            guard let email = user.email else {return}
            LoginInfo.shared.user = User(email: email, uid: user.uid)
            
            print("\(user.uid)")
            
            //User Defaults
            let userDefault = UserDefaults.standard
            userDefault.set(email, forKey: Constants.kUserNameKey)
            
            self.allValid()
        }
    }
}

typealias TextFieldDelegates = ChatLoginViewController
extension TextFieldDelegates:UITextFieldDelegate{
    enum AlertTypes{
        case Email
        case Password
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === passTextField{
            textField.resignFirstResponder()
            guard isValidEmail(email: userTextField.text ?? "") else {
                showAlert(alertType: AlertTypes.Email, textField: textField)
                return false
            }
            guard isValidPassword(password: passTextField.text ?? "") else {
                showAlert(alertType: AlertTypes.Password, textField: textField)
                return false
            }
            logInToFirebase()
        }else{
            textField.resignFirstResponder()
            passTextField.becomeFirstResponder()
        }
        return false
    }
    
    func isValidEmail(email:String)->Bool {
        guard NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: email) else {return false}
        return true
    }
    
    func isValidPassword(password:String)->Bool{
        return NSPredicate(format:"SELF MATCHES %@", "^(?=.*[0-9]).{6,}").evaluate(with: password)
    }
    
    func showAlert(alertType: AlertTypes, textField:UITextField){
        let alert:UIAlertController
        switch alertType{
        case .Email:
            alert = UIAlertController(title: "Invalid Email", message: "Email must be a valid email", preferredStyle: .alert)
            userTextField.layer.backgroundColor = UIColor.red.cgColor
        case .Password:
            alert = UIAlertController(title: "Invalid Password", message: "Password must be at least 6 characters and contain 1 number", preferredStyle: .alert)
            passTextField.layer.backgroundColor = UIColor.red.cgColor
            passTextField.text = ""
        }
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func allValid(){
        let alert = UIAlertController(title: "AUTHENTICATED!", message: "Username and Password meet the criteria", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default){
            (alert: UIAlertAction) in
            //Push to next view
            Constants.kUser = UserDefaults.standard.object(forKey: Constants.kUserNameKey) as? String
            self.performSegue(withIdentifier: "ToChat", sender: self)
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}
