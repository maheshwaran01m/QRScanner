//
//  ContentView.swift
//  QRScanner
//
//  Created by MAHESHWARAN on 28/10/23.
//

import SwiftUI
import AVKit

struct ContentView: View {
  
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = ScannerViewModel()
  
  var body: some View {
    mainView
      .overlay(alignment: .topLeading, content: headerView)
      .safeAreaInset(edge: .bottom, content: scanButton)
      .onAppear(perform: viewModel.checkAccessForCamera)
  }
  
  private var mainView: some View {
    GeometryReader { proxy in
      mainView(proxy)
    }
  }
  
  private func mainView(_ proxy: GeometryProxy) -> some View {
    roundRectangleView(proxy)
    .background {
      scannerView(proxy)
    }
    .alert("Camera Disabled", isPresented: $viewModel.showCameraAlert) {
      Button("Cancel") {}
      if let url = URL(string: UIApplication.openSettingsURLString) {
        Link("Settings", destination: url)
      }
    } message: {
      Text("Please Enable Camera access for QRScanner")
    }
    .onReceive(NotificationCenter.default.publisher(
      for: UIApplication.didEnterBackgroundNotification)) { _ in
        viewModel.stopRunning()
      }
      .accessibilityElement(children: .contain)
  }
  
  private func roundRectangleView(_ proxy: GeometryProxy) -> some View {
    ZStack {
      ForEach(0...3, id: \.self) { index in
        RoundedRectangle(cornerRadius: 16, style: .circular)
          .trim(from: 0.58, to: 0.66)
          .stroke(Color.primary,
                  style: .init(lineWidth: 2, lineCap: .round, lineJoin: .round))
          .rotationEffect(.init(degrees: Double(index) * 90))
      }
    }
    .frame(width: 320, height: 320)
    .preference(key: SizeKey.self, value: proxy.size)
    .onPreferenceChange(SizeKey.self) {
      viewModel.updateOutputRectOfInterest($0)
    }
    .ignoresSafeArea(.all)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  
  
  private func scannerView(_ proxy: GeometryProxy) -> some View {
    ZStack {
      if let cameraLayer = viewModel.previewLayer {
        ScannerInputView(
          frameSize: .init(width: proxy.size.width, height: proxy.size.height),
          cameraLayer: cameraLayer)
        .background(Color.gray)
      }
    }
  }
}

extension ContentView {
  func headerView() -> some View {
    VStack(spacing: 8) {
      titleView
      placeholderTextView
      qrCodeTextView
      
    }
    .frame(maxWidth: .infinity)
    .overlay(alignment: .topLeading, content: cancelButton)
    .padding(.horizontal, 10)
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityElement(children: .contain)
  }
  
  private var titleView: some View {
    Text("Scanner")
      .font(.title3)
      .foregroundStyle(Color.primary)
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(Color.gray.opacity(0.5))
      .clipShape(Capsule())
  }
  
  private var placeholderTextView: some View {
    Text("Keep the QR code inside the frame")
      .font(.headline)
      .foregroundStyle(Color.primary)
      .padding(10)
      .background(Color.gray.opacity(0.5))
      .clipShape(Capsule())
  }
  
  @ViewBuilder
  private var qrCodeTextView: some View {
    if let scannedCode = viewModel.scannedCode {
      Text(scannedCode)
        .font(.headline)
        .foregroundStyle(Color.primary)
        .padding()
        .background(Color.blue.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
        .padding(.top, 25)
    }
  }
  
  private func cancelButton() -> some View {
    Button {
      dismiss()
    } label: {
      Image(systemName: "chevron.left")
    }
  }
  
  private func scanButton() -> some View {
    Button {
      viewModel.startSession()
    } label: {
      Image(systemName: "qrcode.viewfinder")
        .font(.largeTitle)
        .foregroundStyle(Color.primary)
    }
  }
}

extension ContentView {
  
  struct SizeKey: PreferenceKey {
    static var defaultValue = CGSize.zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
      value = nextValue()
    }
  }
}

#Preview {
  ContentView()
}
