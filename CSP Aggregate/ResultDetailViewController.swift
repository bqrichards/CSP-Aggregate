//
//  ResultDetailViewController.swift
//  CSP Aggregate
//
//  Created by nazda on 3/25/19.
//  Copyright © 2019 FRC 6317. All rights reserved.
//

import UIKit

class ResultDetailViewController: UIViewController {
    var data: String!
    @IBOutlet weak var dataTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Scanned Detail"
        dataTextView.text = data
    }
    
    @IBAction func uploadData(_ sender: UIButton) {
        let alert = UIAlertController(title: "WIP", message: "Individual uploads will be available in a future release", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
