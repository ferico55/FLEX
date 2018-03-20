//
//  AudioRecorderViewController.swift
//  Tokopedia
//
//  Created by Sakshi Chauhan on 24/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import AVFoundation
import Crashlytics
import UIKit
internal class AudioRecorderViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet private weak var activityLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!
    private let audioDuration = 10
    private var recordingSession: AVAudioSession?
    private var audioRecorder: AVAudioRecorder?
    //    MARK:- lifecycle
    internal override func viewDidLoad() {
        super.viewDidLoad()
        self.activityLabel.text = "Starting recording..."
        self.setupRecording()
    }
    //MARK:- Actions
    @IBAction private func doneButtonClicked (_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    //    MARK: Private
    private func checkPermission() {
        guard let session = self.recordingSession else {return}
        if session.recordPermission() == AVAudioSessionRecordPermission.undetermined {
            self.requestPermission()
        } else if session.recordPermission() == AVAudioSessionRecordPermission.granted {
            self.recordAudio()
        } else {
            self.activityLabel.text = "Microphone access denied."
            self.showAlertView()
        }
    }
    private func requestPermission() {
        guard let session = self.recordingSession else {return}
        session.requestRecordPermission() { [weak self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self?.recordAudio()
                } else {
                    self?.activityLabel.text = "Microphone access denied."
                }
            }
        }
    }
    private func recordAudio() {
        self.audioRecorder = nil
        self.activityLabel.text = "Listening..."
        self.startRecording()
    }
    private func showAlertView() {
        let alert = UIAlertController(title: "Permission Denied", message: "Microphone access is denied. Please allow to record.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            UIApplication.shared.openURL(settingsUrl)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    private func setupRecording() {
        self.recordingSession = AVAudioSession.sharedInstance()
        do {
            guard let session = self.recordingSession else {return}
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
            self.checkPermission()
        } catch {
            self.activityLabel.text = "Some error occured while recording..."
            Crashlytics.sharedInstance().recordError(NSError(domain: NSCocoaErrorDomain, code: 999, userInfo: ["NSLocalizedDescriptionKey" : "Failed to start audio session"]))
        }
    }
    private func getDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    private func startRecording() {
        if let audioFileName = getDocumentsDirectory() {
            let audioFile = audioFileName.appendingPathComponent("recording.wav")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            if let recorder = try? AVAudioRecorder(url: audioFile, settings: settings) {
                recorder.record(forDuration: TimeInterval(self.audioDuration))
                self.audioRecorder = recorder
                recorder.delegate = self
            }
        }
    }
    private func finishRecording() {
        guard let recorder = self.audioRecorder else {return}
        recorder.stop()
    }
    private func verifyShake() {
        guard let recorder = self.audioRecorder else {return}
        AudioCampaignService().verifyShake(url: recorder.url, isAudio: true, onCompletion: {
            self.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    //MARK:-AVAudioRecorderDelegate
    internal func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.finishRecording()
        if flag {
            self.activityLabel.text = "Successfully Recorded"
            self.verifyShake()
        } else {
            self.activityLabel.text = "Recording failed, try again"
        }
    }
}
