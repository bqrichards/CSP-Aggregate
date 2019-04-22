//
//  ScanViewController.swift
//  CSP Aggregate
//
//  Created by nazda on 3/25/19.
//  Copyright © 2019 FRC 6317. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var video = AVCaptureVideoPreviewLayer()
    var session = AVCaptureSession()
    
    override func viewDidLoad() {
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("ERROR")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        } catch {
            print("error grabbing video camera device")
        }
        
        let output = AVCaptureMetadataOutput()
        
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.qr]
        video = AVCaptureVideoPreviewLayer(session: session)
        
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 1 {
            // Temporaryly stop scanning so we can process this.
            session.stopRunning()
            
            let qrObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if qrObject.type != .qr {
                return
            }
            
            guard let csvdata = qrObject.stringValue else { return }
            
            // Check to see if this data is already contained
            if results.contains(csvdata) {
                let alert = UIAlertController(title: "Duplicate", message: "This match has already been scanned", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { alertAction in
                    self.session.startRunning()
                }))
                present(alert, animated: true, completion: nil)
                return
            }
            
            results.append(csvdata)
            self.tabBarController?.selectedIndex = 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        session.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        session.stopRunning()
    }
}
