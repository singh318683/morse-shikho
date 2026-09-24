import SwiftUI
import AVFoundation

@main
struct MorseShikhoApp: App {
    init() {
        // Play Morse tones even when the iPhone's silent switch is on,
        // without stopping music or podcasts the user has playing.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
