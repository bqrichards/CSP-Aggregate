//
//  SettingsViewController.swift
//  CSP Aggregate
//
//  Created by nazda on 4/1/19.
//  Copyright © 2019 FRC 6317. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var uploadIpTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        uploadIpTextView.delegate = self
        uploadIpTextView.text = urlString
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(SettingsViewController.doneButtonAction))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        uploadIpTextView.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        urlString = textView.text
        UserDefaults.standard.set(urlString, forKey: "REMOTE-URL")
    }
}
