//
//  SkyBookReaderViewController+MediaBox.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import Foundation

// MARK: - SkyBookReaderViewController+MediaBox
extension SkyBookReaderViewController {
    // MediaOverlay && TTS
    func showMediaBox() {
        if setting.mediaOverlay == true {
            self.view.addSubview(mediaBox)
            applyThemeToMediaBox(theme: currentTheme)
            mediaBox.frame.origin.x = titleLabel.frame.origin.x
            mediaBox.frame.origin.y = listButton.frame.origin.y - 7
            mediaBox.isHidden = false
            titleLabel.isHidden = true
        }
    }
    
    func hideMediaBox() {
        self.mediaBox.removeFromSuperview()
        mediaBox.isHidden = true
        titleLabel.isHidden = false
    }
    
    func changePlayAndPauseButton() {
        if !rv.isPlayingStarted() {
            playButton.setImage(UIImage(named: "play"), for: .normal)
        } else if rv.isPlayingPaused() {
            playButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "pause"), for: .normal)
        }
    }
    
    // MediaBox buttons.
    // when prev butotn presed.
    @IBAction func prevPressed(_ sender: Any) {
        self.playPrev()
    }
    
    @IBAction func playPressed(_ sender: Any) {
        self.playAndPause()
    }
    
    @IBAction func stopPressed(_ sender: Any) {
        self.stopPlaying()
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        self.playNext()
    }
    
    
    // play or pause the parallel of MediaOverlay or TTS.
    func playAndPause() {
        if !rv.isPlayingStarted() {
            rv.playFirstParallelInPage()
            isAutoPlaying = true
        } else if rv.isPlayingPaused() {
            rv.resumePlayingParallel()
            isAutoPlaying = true
        } else {
            rv.pausePlayingParallel()
            isAutoPlaying = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.changePlayAndPauseButton()
        }
    }
    
    // stop playing the parallel.
    func stopPlaying() {
        rv.stopPlayingParallel()
        if !rv.isTTSEnabled() {
            rv.restoreElementColor()
        } else {
            rv.removeParallelHighlights()
        }
        isAutoPlaying = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.changePlayAndPauseButton()
        }
    }
    
    // play the previous parallel.
    func playPrev() {
        rv.playPrevParallel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.changePlayAndPauseButton()
        }
    }
    
    // play the next paralle.
    func playNext() {
        rv.playNextParallel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.changePlayAndPauseButton()
        }
    }
}
