//
//  AudioController.swift
//  GymJim
//
//  Created by Rodrigo Villatoro on 1/5/15.
//  Copyright (c) 2015 RVD. All rights reserved.
//

import Foundation
import AVFoundation

class AudioController: NSObject {

    var audioSession = AVAudioSession.sharedInstance()
    var backgroundMusicPlayer = AVAudioPlayer()
    
    override init() {
        super.init()
        configureAudioSession()
        configureAudioPlayer()
    }

    func configureAudioSession() {
        audioSession.setCategory(AVAudioSessionCategoryAmbient, error: nil)
    }
    
    func configureAudioPlayer() {
        let backgroundMusicPath = NSBundle.mainBundle().pathForResource("bgMusic1", ofType: "wav")
        let backgroundMusicURL = NSURL.fileURLWithPath(backgroundMusicPath!)
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusicURL, error: nil)
        backgroundMusicPlayer.numberOfLoops = -1
    }
    
    func tryPlayingMusic() {
        
        if audioSession.otherAudioPlaying {
            return
        }
        
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    }



}