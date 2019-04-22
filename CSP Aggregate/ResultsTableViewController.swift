//
//  ResultsTableViewController.swift
//  CSP Aggregate
//
//  Created by nazda on 3/25/19.
//  Copyright © 2019 FRC 6317. All rights reserved.
//

import UIKit

var results: [String] = []
var urlString: String = "http://ec2-3-214-19-72.compute-1.amazonaws.com:5000/submit/"

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

class ResultsTableViewController: UITableViewController {
    override func viewDidLoad() {
        urlString = UserDefaults.standard.string(forKey: "REMOTE-URL") ?? "http://ec2-18-191-38-225.us-east-2.compute.amazonaws.com:5000/submit/matchscouting"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @IBAction func clear(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to clear this data?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (alertAction) in
            results.removeAll()
            self.tableView.reloadData()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func upload(_ sender: UIBarButtonItem) {
        let numberOfPendingUploads = results.count
        
        if numberOfPendingUploads == 0 {
            return
        }
    
        let alert = UIAlertController(title: "Confirm", message: "\(numberOfPendingUploads) matches are about to be uploaded. Are you sure you want to do this?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
            
            let combinedMatches = results.joined(separator: "~~~~~")
            guard let url = URL(string: urlString) else {
                print("Error generating url")
                return
            }
            print("Asking for url \(urlString)")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let parameters: [String: String] = [
                "csvdata": combinedMatches
            ]
            
            request.httpBody = parameters.percentEscaped().data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil else {        // check for fundamental networking error
                        print("error", error ?? "Unknown error")
                        return
                }
                
                guard (200 ... 299) ~= response.statusCode else {      // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    return
                }
                
                let responseString = String(data: data, encoding: .utf8)
                if responseString == String(results.count) {
                    print("Worked!")
                    results.removeAll()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            
            task.resume()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Scanned Matches"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScannedCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = results[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            results.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoResultDetail" {
            let destination = segue.destination as! ResultDetailViewController
            guard let selectedIndex = tableView.indexPathForSelectedRow?.row else { return }
            destination.data = results[selectedIndex]
        }
    }
}
