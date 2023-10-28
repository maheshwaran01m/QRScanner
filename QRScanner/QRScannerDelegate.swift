//
//  QRScannerDelegate.swift
//  QRScanner
//
//  Created by MAHESHWARAN on 28/10/23.
//

import SwiftUI
import AVKit

class QRScannerDelegate: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
  
  @Published var scannedCode: String?
  
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    
    guard let metaData = metadataObjects.first,
          let readableObject = metaData as? AVMetadataMachineReadableCodeObject,
          let scannerCode = readableObject.stringValue else {
      return
    }
    scannedCode = scannerCode
  }
}
