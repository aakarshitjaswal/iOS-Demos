//
//  ViewController.swift
//  VideoSplitDemo
//
//  Created by aakarshit on 19/09/23.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import AVFoundation
import Photos
import AVKit

class VideoSegmentsController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chooseVideoBtn: UIButton!
    @IBOutlet weak var uploadVideosBtn: UIButton!
    @IBOutlet weak var progressLbl: UILabel!
    
    var viewModel = VideoSegmentsViewModel.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.setProgress(0, animated: true)
        progressLbl.isHidden = true
        progressBar.isHidden = true
        uploadVideosBtn.isHidden = true
    
        // Do any additional setup after loading the view.
    }

    @IBAction func chooseVideo(_ sender: Any) {
        //Remove all segments as a new video is to be chosen
        viewModel.removeAllSegments()
        progressLbl.text = ""
        tableView.reloadData()
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = [UTType.movie.identifier] // Ensure only videos are selectable
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func uploadVideo(_ sender: Any) {
        guard viewModel.count > 0 else { return }
        viewModel.delegate = self
        viewModel.startUploadProcess()
    }
    
    

    // MARK: - UIImagePickerControllerDelegate Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        //Pick videos
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == UTType.movie.identifier {
                if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                    print("Selected Video URL: \(videoURL)")
                    uploadVideosBtn.isHidden = false
                    splitVideoIntoSegments(videoURL: videoURL, segmentDuration: 10.0)
                }
            }
        }
    }
    
    
    func apiCall(completion:@escaping(_ msg: String) -> Void){

        
        completion("test")
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Function to split a video into segments
    func splitVideoIntoSegments(videoURL: URL, segmentDuration: Double) {
        let asset = AVAsset(url: videoURL)
        //Getting the duration of the video
        let duration = CMTimeGetSeconds(asset.duration)

        // Calculate the number of segments required
        let numSegments = Int(ceil(duration / segmentDuration))

        //Splitting video
        for segmentIndex in 0..<numSegments {
            let startTime = CMTime(seconds: Double(segmentIndex) * segmentDuration, preferredTimescale: 600)
            let endTime = CMTime(seconds: min(Double(segmentIndex + 1) * segmentDuration, duration), preferredTimescale: 600)
            
            let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
            let uniqueID = UUID()
            
            //For each video the segment index and a unique id is given, the segment index helps in keeping track of the videos' order as mentioned in the task.
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(uniqueID)_\(segmentIndex).mp4")
            
            //Printing the output url for debuggin
            print("\u{1F496}->",outputURL)
            
            exportSession?.outputURL = outputURL
            exportSession?.outputFileType = .mp4
            exportSession?.timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
            exportSession?.exportAsynchronously { [weak self] in
                
                guard let strongSelf = self else {return}
                
                switch(exportSession?.status) {
                 case .completed:
                    DispatchQueue.main.async {
                        
                        //Getting the last component of the output url
                        let segmentCompWithExt = outputURL.absoluteString.components(separatedBy: "_").last
                        let segment = segmentCompWithExt?.components(separatedBy: ".").first
                        
                        //Adding the segment number in video
                        let videoSegment = VideoSegment(segment: Int(segment ?? "0") ?? 0, url: outputURL)
                        
                        //Append the video to the array
                        strongSelf.viewModel.addVideoSegment(segment: videoSegment)
                        
                        
                        if strongSelf.viewModel.count == numSegments {
                            strongSelf.viewModel.sortVideoSegments()
                            strongSelf.tableView.reloadData()
                            
                            // All segments have been processed
                            // Printing the URLs of the segmented videos in videoSegments array
                            strongSelf.viewModel.printAllindices()
                        }
                    }
                 case .failed:
                    if let error = exportSession?.error {
                            print("Export failed with error: \(error)")
                        }
                     //
                 case .cancelled:
                    print("Cancelled")
                     //
                 default: break
                 }
            }
        }
    }
    
    //plays the video from the url passed
    func playVideo(from url: URL?) {
        guard let url = url else {
            print("Failed to play as url not available")
            return
        }
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
}

extension VideoSegmentsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "VideoSegmentCell") as? VideoSegmentCell {
            cell.item = viewModel[atSegment: indexPath.row]
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = viewModel[atSegment: indexPath.row]?.url else {return}
        playVideo(from: url)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension VideoSegmentsController: UploadProgressDelegate {
    
    
    func updateProgress(progress: Float, currentItem: Int, totalItems: Int, message: String, complete: Bool) {
        
        //Updating the state of UI depending upon the progress
        progressBar.setProgress(progress, animated: true)
        if complete {
            progressLbl.text = "All Items uploaded successfully"
            uploadVideosBtn.isHidden = true
            chooseVideoBtn.isHidden = false
            tableView.isHidden = false
            progressBar.isHidden = true
            progressLbl.isHidden = false
            tableView.reloadData()
        } else {
            uploadVideosBtn.isHidden = true
            chooseVideoBtn.isHidden = true
            tableView.isHidden = true
            progressBar.isHidden = false
            progressLbl.isHidden = false
            progressLbl.text = "Uploading item: \(currentItem) of \(totalItems), \(message)"
        }
        
    }
    
    
}

