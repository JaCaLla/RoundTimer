//
//  AudioManager.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 19/2/24.
//

import Foundation
import AVFAudio

protocol AudioManagerProtocol {
    func pause()
    func rest()
    func work()
    func finish()
}

final class AudioManager {
    var audioPlayer: AVAudioPlayer?
    private let volume: Float = 0.05
    static let shared = AudioManager()
}


extension AudioManager: AudioManagerProtocol {
    
    func start() {
        play("start")
    }
    
    func pause() {
        play("pause")
    }
    
    func rest() {
        play("rest")
    }
    
    func work() {
        play("work")
    }
    
    func finish() {
        play("finish")
    }
    
    fileprivate func play(_ filename: String) {
        guard let soundURL = Bundle.main.url(forResource: filename, withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = volume
            audioPlayer?.play()
        } catch {
            print("Error al inicializar el reproductor de audio: \(error.localizedDescription)")
        }
    }
}
