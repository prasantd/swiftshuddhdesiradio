//
//  FirstViewController.swift
//  Shuddh Desi Radio
//
//  Created by AtlantaLoaner2 on 6/11/19.
//  Copyright © 2019 Shuddh Desi Radio. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import ImageSlideshow
import MarqueeLabel

class FirstViewController: UIViewController {

    var player: AVPlayer!
    var afNetworkingSource = [AFURLSource(urlString: "https://static.wixstatic.com/media/b24c02_cd9a0e75d812419fb296a192f8246ba2~mv2.png")!]
    var currentInfoTimer: Timer?

    @IBOutlet weak var SDRPlayerButton: UIButton!
    @IBOutlet weak var sponsorSlideShow: ImageSlideshow!
    
    @IBOutlet weak var CurrentTrackInfo: MarqueeLabel!
    
    
    @IBAction func PlayRadio(_ sender: UIButton) {
        playSDR()
      
        
    }
    

    override func viewDidLoad() {
        
        // Do any additional setup after loading the view.
        guard let url = URL(string: "https://streamer.radio.co/se30891e37/low") else {
            return
        }
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        player = AVPlayer(url: url)
        setupRemoteTransportControls()
        setupNotifications()
        currentInfoTimer = Timer.scheduledTimer(
            timeInterval: 10,
            target: self,
            selector: #selector(setupNowPlaying),
            userInfo: nil,
            repeats: true)
        
        super.viewDidLoad()
        displaySponsors()
        playSDR()
  
    }
    
    func playSDR()
    {
        if(self.player.rate == 0.0){
            self.player.play()
            setupNowPlaying()
        }
        else{
            self.player.pause()
            setupNowPlaying()
        }
        
        toggleimage()
    }
    
    func toggleimage()
    {
        if self.player.rate == 0.0{
            SDRPlayerButton.setImage( UIImage.init(named: "play"), for: .normal)

        }
        else
        {
            SDRPlayerButton.setImage( UIImage.init(named: "pause"), for: .normal)
        }
        
        
    }
    func displaySponsors(){
        //Populate Sponsors array
        sponsorSlideShow.slideshowInterval = 6.0

        sponsorSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFit
        sponsorSlideShow.circular = true

        
        let mySponsors = DataExtractor()
        mySponsors.GetSponsorsList(companyCompletionHandler:{ sponsorLogos, error in
            
            for item in sponsorLogos!
            {
                if (item != ""){
                    self.afNetworkingSource.append(AFURLSource(urlString: item)!)
                }
                
            }
            DispatchQueue.main.async{
                self.sponsorSlideShow.setImageInputs(self.afNetworkingSource)
            }
            
        })

    }

    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player.rate == 0.0 {
                self.player.play()
                self.toggleimage()
                self.setupNowPlaying()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                self.player.pause()
                self.toggleimage()
                self.setupNowPlaying()
                return .success
            }
            return .commandFailed
        }
    }
    
    @objc func setupNowPlaying() {
         var nowPlayingInfo = [String : Any]()
        // Define Now Playing Info
        var isCurrentTrackReqd = true
        if self.player.rate == 0.0{
            isCurrentTrackReqd = false
        }

        
        if(isCurrentTrackReqd){
       let oldTitle = CurrentTrackInfo.text
        
        CurrentTrackInfo.type = .continuous
        CurrentTrackInfo.speed = .duration(15)
        CurrentTrackInfo.animationCurve = .easeInOut
        CurrentTrackInfo.fadeLength = 10.0
        CurrentTrackInfo.leadingBuffer = 10.0
        CurrentTrackInfo.trailingBuffer = 20.0
        //`CurrentTrackInfo.restartLabel()
        
        let radioPlayingInfo = DataExtractor()
        radioPlayingInfo.GetPlayingInfoTitle(RadioPlayingInfoCompletionHandler:{ currentTrack, error in
           if(currentTrack != oldTitle){
            DispatchQueue.main.async{
            
            nowPlayingInfo[MPMediaItemPropertyTitle] = currentTrack
            self.CurrentTrackInfo.text = currentTrack
            // Set the metadata
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
            }
        })
        }
        else{
            self.CurrentTrackInfo.text = "Click Play button to listen to radio"
            nowPlayingInfo[MPMediaItemPropertyTitle] = "Click Play button to listen to radio"
            // Set the metadata
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
      
        

    }

    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: AVAudioSession.interruptionNotification,
            object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleRouteChange),
                                       name: AVAudioSession.routeChangeNotification,
                                       object: nil)
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            // Interruption began, take appropriate actions
            self.player.pause()
            self.toggleimage()
            self.setupNowPlaying()
            
        }
        else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Interruption Ended - playback should resume
                    self.player.play()
                    self.toggleimage()
                    self.setupNowPlaying()
                } else {
                    // Interruption Ended - playback should NOT resume
                    self.player.pause()
                    self.toggleimage()
                    self.setupNowPlaying()
                }
            }
        }
    }
    
    
    @IBAction func HamburgerMenu(_ sender: Any) {
        
        // Access an instance of AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Reference drawerContainer object declared inside of AppDelegate and call toggleDrawerSide function on it
        appDelegate.drawerController?.toggle(MMDrawerSide.left, animated: true, completion: nil)

    }
    
    @objc func handleRouteChange(notification: Notification) {
        var headphonesConnected: Bool!
        
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
        }
        switch reason {
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                headphonesConnected = true
                break
            }
        case .oldDeviceUnavailable:
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                    headphonesConnected = false
                    break
                }
            }
        default: ()
        }
}
    

}
