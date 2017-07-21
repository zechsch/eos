//
//  SecondViewController.swift
//  eos
//
//  Created by Zechariah Schneider on 7/17/17.
//  Copyright © 2017 Zechariah Schneider. All rights reserved.
//

import UIKit
import AVFoundation

class SecondViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let outputTypes = [AVMetadataObjectTypeUPCECode,
                       AVMetadataObjectTypeCode39Code,
                       AVMetadataObjectTypeCode39Mod43Code,
                       AVMetadataObjectTypeCode93Code,
                       AVMetadataObjectTypeCode128Code,
                       AVMetadataObjectTypeEAN8Code,
                       AVMetadataObjectTypeEAN13Code,
                       AVMetadataObjectTypeAztecCode,
                       AVMetadataObjectTypePDF417Code,
                       AVMetadataObjectTypeQRCode]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        session = AVCaptureSession()
        
        // Set capture device
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // create the input object
        let videoInput: AVCaptureDeviceInput?
        do{
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        // add input to session
        if(session.canAddInput(videoInput)) {
            session.addInput(videoInput)
        } else {
            scanNotPossible()
        }
        
        // create output object
        let metadata = AVCaptureMetadataOutput()
        
        // add output to session
        if(session.canAddOutput(metadata)) {
            session.addOutput(metadata)
            
            //send data to output delegate
            metadata.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            metadata.metadataObjectTypes = outputTypes
            
        } else {
            scanNotPossible()
        }
        
        // add preview layer and show data
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // start it bitch
        session.startRunning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(session?.isRunning == false) {
            session.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(session?.isRunning == true){
            session.stopRunning()
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        //get the first object from the metadataobjects array
        if let barcodeData = metadataObjects.first {
            
            // turn it into machine readable code
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject;
            
            if let readableCode = barcodeReadable {
                
                //send it to barcodeDetected(string)
                barcodeDetected(code: readableCode.stringValue)
                
            }
            
            // vibrate to give user feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            //stop vibrating
            session.stopRunning()
        }
    }
    
    func barcodeDetected(code: String) {
        
        //tell user we found something
        let alert = UIAlertController(title: "Found a barcode!", message: code, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Search", style: UIAlertActionStyle.destructive, handler: { action in
            
            // TODO: Search API
            
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func scanNotPossible() {
        // Tell user scanning isn't possible with the device
        let alert = UIAlertController(title: "Can't scan.", message: "Scanning barcodes with eos requires a device with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        session = nil
    }


}

