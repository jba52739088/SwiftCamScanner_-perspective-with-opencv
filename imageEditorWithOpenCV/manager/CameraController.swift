//
//  CameraController.swift
//  customCamera
//
//  Created by 黃恩祐 on 2018/1/29.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraController {
    
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var flashMode = AVCaptureDevice.FlashMode.off
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            let cameras = AVCaptureDevice.devices(for: AVMediaType.video)
            for camera in cameras {
                if camera.position == AVCaptureDevice.Position.front {
                    self.frontCamera = camera
                }else if camera.position == AVCaptureDevice.Position.back {
                    self.rearCamera = camera
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        
        func configureDeviceInput() throws {
            guard let captureSession = self.captureSession
                else {throw CameraControllerError.captureSessionIsMissing}
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                if captureSession.canAddInput(self.rearCameraInput!) {
                    captureSession.addInput(self.rearCameraInput!)
                    
                }
                self.currentCameraPosition = .rear
            }else if let frontCamera = self.frontCamera{
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                if captureSession.canAddInput(self.frontCameraInput!) {
                    captureSession.addInput(self.frontCameraInput!)
                }
                self.currentCameraPosition = .front
            }else{
                throw CameraControllerError.noCamerasAvailable
            }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession
                else {throw CameraControllerError.captureSessionIsMissing}
            self.stillImageOutput = AVCaptureStillImageOutput()
            self.stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession.canAddOutput(self.stillImageOutput!) {
                captureSession.addOutput(self.stillImageOutput!)
                captureSession.sessionPreset = AVCaptureSession.Preset.photo
            }
            captureSession.startRunning()
        }
        
        
        DispatchQueue(label: "prepare").async {
            do{
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInput()
                try configurePhotoOutput()
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView) throws{
        guard let captureSession = self.captureSession, captureSession.isRunning
            else { throw CameraControllerError.captureSessionIsMissing }
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.layer.bounds
    }
    
    func switchCameras() throws {
        
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning
            else { throw CameraControllerError.captureSessionIsMissing}
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {
            let inputs = captureSession.inputs
            guard let rearCameraInput = self.rearCameraInput,
            inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else{ throw CameraControllerError.invalidOperation}
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            captureSession.removeInput(rearCameraInput)
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                self.currentCameraPosition = .front
            }else {
                throw CameraControllerError.invalidOperation
            }
        }
        
        func switchToRearCamera() throws {
            let inputs = captureSession.inputs
            guard let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCameraPosition = .rear
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
        case .rear:
            try switchToFrontCamera()
        }
        captureSession.commitConfiguration()
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning
            else{ completion(nil, CameraControllerError.captureSessionIsMissing); return }
        guard let stillImageOutput = self.stillImageOutput
            else{ print("stillImageOutput error"); return }
        if let videoConnection = stillImageOutput.connection(with: AVMediaType.video) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (CMSampleBuffer, Error) in
                if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(CMSampleBuffer!) {
                    
                    if let cameraImage = UIImage(data: imageData) {
                        completion(cameraImage, CameraControllerError.unknown)
                    }
                }
            })
        }

    }

    
}


extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }

    public enum CameraPosition {
        case front
        case rear
    }
}
