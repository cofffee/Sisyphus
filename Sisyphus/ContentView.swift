//
//  ContentView.swift
//  Sisyphus
//
//  Created by Kevin Remigio on 8/11/26.
//

import SwiftUI
import Combine

struct TimeChunk {
    enum Action: String {
        case climbing
        case breaking
    }
    var duration: CGFloat
    var action: Action
}
struct ClimbModel {
    var timeChunk: [TimeChunk]
}
struct ClimbModelTypes {
    let standardPomo: ClimbModel = ClimbModel(
        timeChunk: [TimeChunk(duration: 1500, action: .climbing),
                    TimeChunk(duration: 300, action: .breaking),
                    TimeChunk(duration: 1500, action: .breaking),
                    TimeChunk(duration: 300, action: .breaking),
                    TimeChunk(duration: 1500, action: .breaking),
                    TimeChunk(duration: 300, action: .breaking),
                    TimeChunk(duration: 1500, action: .breaking),
                    TimeChunk(duration: 300, action: .breaking)])

    let testPomo: ClimbModel = ClimbModel(
        timeChunk: [TimeChunk(duration: 5, action: .climbing),
                    TimeChunk(duration: 2, action: .breaking),
                    TimeChunk(duration: 5, action: .breaking),
                    TimeChunk(duration: 2, action: .breaking),
                    TimeChunk(duration: 5, action: .breaking),
                    TimeChunk(duration: 2, action: .breaking),
                    TimeChunk(duration: 5, action: .breaking),
                    TimeChunk(duration: 2, action: .breaking)])
}

@Observable
class ClimbViewModel {
    var timeLeft: CGFloat = 1
    var currentTimeChunk: TimeChunk?
    var climb = ClimbModelTypes().testPomo
    var typeOfWorkString: String {
        guard let chunkOfTime = currentTimeChunk else { return "" }
        return chunkOfTime.action.rawValue
    }
    var roundString: String {
        return "Round: \(climb.timeChunk.count)"
    }
    var timeString: String {
        return formatTime(CGFloat(Int(timeLeft)))
    }
    var timer: Timer? = nil
    var progress: CGFloat {
        guard let chunkOfTime = currentTimeChunk else { return 1 }
        return timeLeft / chunkOfTime.duration
    }
    func recursivePopTimerChunks() {
        if climb.timeChunk.count > 0 {//!climb.timeChunk.isEmpty {
            guard let firstChunkOfTime = climb.timeChunk.first else { return }
            currentTimeChunk = firstChunkOfTime
            timeLeft = firstChunkOfTime.duration
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                [weak self] _ in
                guard let self = self else { return }
                if timeLeft <= 0 {
                    //remove one chunk of time
                    climb.timeChunk.removeFirst()
                    reset()
                    self.recursivePopTimerChunks()
                } else {
                    timeLeft -= 1
                }
            }
        } else {
            // completed
            reset()
        }
    }

    func startClimb() {
        recursivePopTimerChunks()
    }
    func reset() {
        timer?.invalidate()
        timer = nil
    }
    // Helper function to format seconds into MM:SS
    func formatTime(_ seconds: CGFloat) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
struct ContentView: View {
    let climb = ClimbViewModel()
    var body: some View {
        VStack {
            Text(climb.roundString)
                .frame(maxWidth: .infinity)
                .font(.system(size: 40))
            Spacer()
            Text(climb.currentTimeChunk?.action.rawValue ?? "")
            Text("\(climb.progress) \(climb.timeLeft)")
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                Circle()
                    // 2. Trim the path based on the progress state
                    .trim(from: 0.0, to: climb.progress)
                    // 3. Turn the filled circle into an outline stroke
                    .stroke(
                        LinearGradient(
                            colors: [.green, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    // 4. Rotate by -90 degrees so the drawing starts from the top (12 o'clock position)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(
                        .linear(duration: 1.0),
                        value: climb.progress)
                Text(climb.timeString)
                    .frame(maxWidth: .infinity)
                    .font(.system(size:120))
            }
            
            Spacer()
            HStack {
                Button("start") {
                    climb.startClimb()
                }
                // Trigger Button
                Button("stop") {
                    climb.reset()
                }
            }
            
            .frame(maxWidth: .infinity)
            .font(.system(size:44))
        }
        .padding()
        .background(climb.currentTimeChunk?.action == .climbing ? Color.red : Color.yellow)
    }

}

#Preview {
    ContentView()
}
