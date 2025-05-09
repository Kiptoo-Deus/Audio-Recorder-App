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
    
    init() {
        setupAudioEngine()
    }
    
    func toggleRecording() {
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioSamples.removeAll()
        } else {
            setupAudioEngine()
        }
    }
    
    private func setupAudioEngine() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, time in
            guard let channelData = buffer.floatChannelData else { return }
            let frameLength = Int(buffer.frameLength)
            let samples = Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))
            DispatchQueue.main.async {
                self.audioSamples.append(contentsOf: samples)
                if self.audioSamples.count > 1000 { // Limit buffer size
                    self.audioSamples.removeFirst(self.audioSamples.count - 1000)
                }
                print("Captured \(frameLength) samples")
            }
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }
}
