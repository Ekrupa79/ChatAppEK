//
//  ChatTextViewController.swift
//  ChatAppEK
//
//  Created by Mac on 12/4/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SlideMenuControllerSwift

class ChatTextViewController: UIViewController{
    
    @IBOutlet weak var chatTableView:UITableView!
    @IBOutlet weak var chatToolBar:UIToolbar!
    @IBOutlet weak var tbBottomConstraint:NSLayoutConstraint!
    @IBOutlet weak var chatTextField:UITextField!
    @IBOutlet weak var sendBtn:UIBarButtonItem!
    @IBOutlet weak var menuBtn:UIButton!
    
    var originalConstraintPosition:CGFloat?
    var ref:DatabaseReference!
    var messageList:[Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Gesture recognizer to close keyboard from anywhere else
        self.hideKeyboardOnTap()
        
        //Database
        ref = Database.database().reference()
        
        self.getChats(completion: {
            (msgs, error) in
            guard let msgs = msgs else {return}
            self.messageList = msgs

            DispatchQueue.main.async {
                self.chatTableView.reloadData()
                self.scrollToBottom()
            }
        })

        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self
        self.chatTextField.delegate = self
        
        originalConstraintPosition = tbBottomConstraint.constant
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillAppear(_ sender:AnyObject){
        guard let notificationInfo = (sender as? NSNotification)?.userInfo else{return}
        guard let duration = notificationInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double else {return}
        guard let keyboardFrame = (notificationInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        
        animateConstraint(to: keyboardFrame.size.height, duration: duration)
    }
    
    @objc func keyboardWillDisappear(_ sender:AnyObject){
        guard let notificationInfo = (sender as? NSNotification)?.userInfo else{return}
        guard let duration = notificationInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double else {return}
        guard let keyboardFrame = (notificationInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
     
        animateKeyboardClose(to: keyboardFrame.size.height, duration: duration)
    }
    
    func sendToCloseKeyBoard(_ sender:AnyObject){
        guard let notificationInfo = (sender as? NSNotification)?.userInfo else{return}
        guard let duration = notificationInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double else {return}
        guard let keyboardFrame = (notificationInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        
        animateKeyboardClose(to: keyboardFrame.size.height, duration: duration)
    }

    func animateConstraint(to height:CGFloat, duration:Double){
        UIView.animate(withDuration: duration) {
            self.tbBottomConstraint.constant = -height
            self.view.layoutIfNeeded()
            let offset = CGPoint(x: 0, y: height)
            self.chatTableView.setContentOffset(offset, animated: false)
        }
        self.scrollToBottom()
        
    }
    func animateKeyboardClose(to height:CGFloat, duration:Double){
        UIView.animate(withDuration: duration) {
            self.tbBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        self.scrollToBottom()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getChats(completion:@escaping([Message]?,Error?) -> ()){
        var tempMsgs:[Message] = []
        ref.child("Groups").child("Chat1").child("Messages").observe(.value, with: { (snapshot) in
            for message in snapshot.children.allObjects as! [DataSnapshot]{
                let tempKey = message.key
                let messageObj = message.value as? [String:String]
                let sender = messageObj?["Sender"]
                let message = messageObj?["Message"]

                guard let combo = Message(sender: sender, message: message ?? "", key: tempKey) else {return}
                tempMsgs.append(combo)
            }
            self.chatTableView.reloadData()
            completion(tempMsgs,nil)
        })
        
    }
    func getUser(user:String, completion:@escaping(String?,Error?) -> ()){
        ref.child("Users").child(user).observe(.value, with: { (snapshot) in
            guard let user = snapshot.value as? [String:Any] else{
                print("ERROR")
                return
            }
            let returnVal = "\(user["First"] ?? "")"
            completion(returnVal,nil)
        })
    }
    
    func getSingleUser(user:String) -> String{
        var userName:String?
        ref.child("Users").child(user).observe(.value, with: { (snapshot) in
            guard let user = snapshot.value as? [String:Any] else{return}
            userName = "\(user["First"] ?? "")"
        })
        print("USERNAME: \(userName ?? "")")
        return userName ?? ""
    }
    
    @IBAction func clickedSend(_ sender:AnyObject){
        print("Send Clicked")
        chatTextField.resignFirstResponder()
        chatTextField.text = ""
        
        
    }
    
    @IBAction func menuSlide(_ sender:AnyObject){
        print("MENU")
        chatTextField.resignFirstResponder()
        chatTextField.text = ""
        self.slideMenuController()?.openLeft()
    }

}

typealias TableViewFunctions = ChatTextViewController
extension TableViewFunctions: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = chatTableView.dequeueReusableCell(withIdentifier: "MessageCell") else {fatalError("NO CELL")}
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1.0
        cell.layer.backgroundColor = UIColor.red.cgColor
        
        cell.textLabel?.text = messageList[indexPath.row].message ?? ""
        self.getUser(user: messageList[indexPath.row].sender ?? "") { (userName, error) in
            guard let userName = userName else {return}
            DispatchQueue.main.async {
                cell.detailTextLabel?.text = userName
            }
        }
        
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    func scrollToBottom(){
        let indexPath = IndexPath(row: messageList.count - 1, section: 0)
        self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

typealias TextFieldFunctions = ChatTextViewController
extension TextFieldFunctions: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string)
        if self.chatTextField.text != nil{
            guard string != "\n" else {
                self.clickedSend(self)
                chatTextField.resignFirstResponder()
                return false
            }
            return true
        }
        return false
        //Allows for user to see what they have in textfield
        //return true
    }
}
