//
//  AudioRecorderViewModel.swift
//  AudioRecorder
//
//  Created by Joel on 09/05/2025.
//

import Foundation
import AVFoundation

class AudioRecorderViewModel: ObservableObject {
    private let audioEngine = AVAudioEngine()
    @Published var audioSamples: [Float] = []
    @Published var isRecording = false
    @Published var errorMessage: String?
    
    init() {
        configureAudioSession()
    }
    
    func toggleRecording() {
        if isRecording {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioSamples.removeAll()
            isRecording = false
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                errorMessage = "Failed to deactivate audio session: \(error)"
            }
        } else {
            setupAudioEngine()
        }
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true)
            print("Audio session configured: \(audioSession.sampleRate) Hz")
        } catch {
            errorMessage = "Failed to configure audio session: \(error)"
            print(errorMessage!)
        }
    }
    
    private func setupAudioEngine() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        // Validate format
        guard format.sampleRate > 0, format.channelCount > 0 else {
            errorMessage = "Invalid audio format: sampleRate=\(format.sampleRate), channels=\(format.channelCount)"
            print(errorMessage!)
            isRecording = false
            return
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, time in
            guard let channelData = buffer.floatChannelData else { return }
            let frameLength = Int(buffer.frameLength)
            let samples = Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))
            DispatchQueue.main.async {
                self.audioSamples.append(contentsOf: samples)
                if self.audioSamples.count > 1000 {
                    self.audioSamples.removeFirst(self.audioSamples.count - 1000)
                }
                print("Captured \(frameLength) samples at \(buffer.format.sampleRate) Hz")
            }
        }
        
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "Audio engine failed to start: \(error)"
            print(errorMessage!)
            isRecording = false
        }
    }
}
