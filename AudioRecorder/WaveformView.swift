//
//  WaveformView.swift
//  AudioRecorder
//
//  Created by Joel on 09/05/2025.
//

import SwiftUI

struct WaveformView: View {
    let samples: [Float]
    
    var body: some View {
        Canvas { context, size in
            let path = Path { path in
                let width = size.width
                let height = size.height
                let sampleCount = samples.count
                guard sampleCount > 0 else { return }
                
                let step = width / Double(sampleCount)
                let midY = height / 2
                
                path.move(to: CGPoint(x: 0, y: midY))
                
                for i in 0..<sampleCount {
                    let x = Double(i) * step
                    let amplitude = Double(samples[i]) * height / 2 // Scale to half height
                    path.addLine(to: CGPoint(x: x, y: midY - amplitude))
                    path.addLine(to: CGPoint(x: x, y: midY + amplitude))
                    path.addLine(to: CGPoint(x: x + step, y: midY + amplitude))
                    path.addLine(to: CGPoint(x: x + step, y: midY - amplitude))
                    path.closeSubpath()
                }
            }
            
            context.stroke(path, with: .color(.blue), lineWidth: 2)
        }
        .frame(height: 100) // Fixed height for waveform
        .background(Color.black.opacity(0.1))
    }
}

struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        WaveformView(samples: [0.1, 0.3, 0.5, 0.2, 0.4])
    }
}
