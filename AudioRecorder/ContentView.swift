//
//  ContentView.swift
//  AudioRecorder
//
//  Created by Joel on 08/05/2025.
//
import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var viewModel = AudioRecorderViewModel()
    @State private var isRecording = false
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                isRecording.toggle()
                viewModel.toggleRecording()
            }) {
                Text(isRecording ? "Stop" : "Record")
                    .font(.title)
                    .padding()
                    .background(isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .onAppear {
            requestMicrophonePermission()
        }
    }
    
    private func requestMicrophonePermission() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if !granted {
                print("Microphone access denied")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
