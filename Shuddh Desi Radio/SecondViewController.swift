//
//  SecondViewController.swift
//  Shuddh Desi Radio
//
//  Created by AtlantaLoaner2 on 6/11/19.
//  Copyright © 2019 Shuddh Desi Radio. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialSnackbar

class SecondViewController: UIViewController{

    @IBOutlet weak var RequestorName: UITextField!
    @IBOutlet weak var RequestedSong: UITextField!
    @IBOutlet weak var SpecialMessage: UITextView!
    
    @IBOutlet weak var SendSongButton: UIButton!
    @IBOutlet weak var RequiredSongLabel: UILabel!
    @IBOutlet weak var RequiredNameLabel: UILabel!
    
    
    @IBAction func SendSongRequest(_ sender: Any) {
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = "sdremailsetup@gmail.com"
        smtpSession.password = "beciyrvwxncaqqxw"
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }
        
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "SDR Song Request", mailbox: "info@shuddhdesiradio.com") as Any]
        builder.header.from = MCOAddress(displayName: RequestorName.text, mailbox: "sdremailsetup@gmail.com")
        builder.header.subject = "[Song Request]: Request from Mobile App"
        let song =  "Please play the following song </br> Song Name: <b>" + RequestedSong.text!
        let message = "</b> </br></br> Message: " + SpecialMessage.text!
        let sender = "</br></br></br> Requestor: " + RequestorName.text!
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.setLocalizedDateFormatFromTemplate("MMMMdy")
        let requestedDate = "</br> Requested Date: " + formatter.string(from: date)
        builder.htmlBody = song + message + sender + requestedDate
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation!.start { (error) -> Void in
            if (error != nil) {
                let message = MDCSnackbarMessage()
                message.text = "Error sending email: " + error!.localizedDescription
                MDCSnackbarManager.show(message)
                NSLog("Error sending email: \(error ?? "could not send" as! Error)")
            } else {
                let message = MDCSnackbarMessage()
                message.text = "Your song request is successfully sent!"
                MDCSnackbarManager.show(message)
                self.setInitialState()
 
                NSLog("Successfully sent email!")
            }
        }
    }

    func setInitialState(){
        self.RequestorName.text = ""
        self.RequestedSong.text = ""
        self.SpecialMessage.text = ""
        self.SendSongButton.isEnabled = false
        self.RequiredNameLabel.isHidden = true
        self.RequiredSongLabel.isHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        RequiredSongLabel.isHidden = true
        RequiredNameLabel.isHidden = true
        SendSongButton.isEnabled = false
  
        self.SpecialMessage.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
  
    }

    
    
    @objc private func textDidChange(_ notification: Notification) {
        var formIsValid = true
        
        formIsValid = validate(RequestedSong)
        if formIsValid{
            formIsValid = validate(RequestorName)

        }
    
        
        // Update Save Button
        SendSongButton.isEnabled = formIsValid
    }
    
    @IBAction func ShowHamburgerMenu(_ sender: Any) {
        // Access an instance of AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Reference drawerContainer object declared inside of AppDelegate and call toggleDrawerSide function on it
        appDelegate.drawerController?.toggle(MMDrawerSide.left, animated: true, completion: nil)
    }
    
    func validate(_ textField: UITextField) -> (Bool) {

        print(textField.text as Any)
        if(textField.text == nil || textField.text == textField.placeholder || textField.text == ""){
            return false
        }
        else
        {
            return true
        }
    }

}
extension SecondViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField{
        case RequestorName:
            let valid = validate(textField)
            
            if valid {
                RequestedSong.becomeFirstResponder()
            }
            
            // Show/Hide Password Validation Label
            UIView.animate(withDuration: 0.25, animations: {
                self.RequiredNameLabel.isHidden = valid
            })
           
        case RequestedSong:
            let valid = validate(textField)
            
            if valid {
                SpecialMessage.becomeFirstResponder()
            }
            
            // Show/Hide Password Validation Label
            UIView.animate(withDuration: 0.25, animations: {
                self.RequiredSongLabel.isHidden = valid
            })
           
        default:
             SpecialMessage.resignFirstResponder()
        }
         return true
    }
    
}

extension SecondViewController: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return true
        }
        return true
}
}
