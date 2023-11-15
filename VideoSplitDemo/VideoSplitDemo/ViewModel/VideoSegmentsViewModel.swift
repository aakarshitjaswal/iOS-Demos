//
//  UploadManager.swift
//  VideoSplitDemo
//
//  Created by aakarshit on 20/09/23.
//

import Foundation
import FirebaseStorage
import BackgroundTasks
import UIKit

protocol UploadProgressDelegate: AnyObject {
    //Update Progress method
    ///progress :- Float for current progress
    ///currentItem:- Int for tracking the current item being uploaded
    ///totalItems:- Int for tracking total items to be uploaded
    ///message:- String for setting the upload status message
    ///complete:- Bool for knowing if upload is complete or not
    func updateProgress(progress: Float, currentItem: Int, totalItems: Int, message: String, complete: Bool)
}

class VideoSegmentsViewModel  {
    //Singleton instance
    static let shared = VideoSegmentsViewModel()

    private init() {

    }
    //Background task identifier
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    //Delegate for updating the upload progress
    weak var delegate:UploadProgressDelegate?

    private var videoSegments: [VideoSegment] = []
    
    //Gives the count of video segments
    var count: Int {videoSegments.count}
    
    func removeAllSegments() {
        videoSegments.removeAll()
    }
    
    //Appends the video the array
    func addVideoSegment(segment: VideoSegment) {
        videoSegments.append(segment)
    }
    
    //Sorts the videos in order of segment number to maintain the order of the videos with the actual video
    func sortVideoSegments() {
        self.videoSegments.sort{$0.segment ?? 0 < $1.segment ?? 0}
    }
    
    //Prints all indices for checking the sequence
    func printAllindices() {
        for segment in videoSegments {
            print("Segment INDEX: \(segment.segment)")
        }
    }
    
    //Gets the segment at the given index
    subscript(atSegment index:Int)->VideoSegment?{
        return self.videoSegments[index]
    }
    
    func startUploadProcess() {
        
        // Keep track of the current index
        var currentIndex = 0
        let uuid = UUID()
        
        //Requesting additional time for uploading the videos in background, the os might end the execution if the upload takes too long
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        //Calling the method for the first time
        uploadNextVideoToFirebaseStorage()
        
        //Method uploads videos one by one so as to maintain the order of the videos in Firebase Storage
        func uploadNextVideoToFirebaseStorage() {
            
            //Serves as base condition for uploading videos and stops uploading videos once currentIndex == to videosSegments.count
            guard currentIndex < videoSegments.count else {
                currentIndex = 0
                self.removeAllSegments()

                self.delegate?.updateProgress(progress: 0, currentItem: currentIndex, totalItems: videoSegments.count, message: "Upload Finished", complete: true)
                print("All videos uploaded")
                
                //End the background task once the uploads are complete
                endBackgroundTask()
                
                return
            }
            
            //Getting storage reference
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let vidSeg = videoSegments[currentIndex]
           
            //Adding the video to the Firebase Storage
            let videoRef = storageRef.child("videos/video\(uuid)/video\(currentIndex).mp4")
            
            let metadata = StorageMetadata()
            metadata.contentType = "video/mp4"
            
            // Upload the video
            guard let vidUrl = vidSeg.url else {return}
            let uploadTask = videoRef.putFile(from: vidUrl, metadata: metadata) { [weak self] metadata, error in
                
                if let error = error {
                    //Ending background task if there's an error
                    self?.endBackgroundTask()
                    print("Error uploading video: \(error.localizedDescription)")
                } else {
                    // Video uploaded successfully
                    print("Video uploaded at index \(currentIndex).")
                    
                    // Get the download URL
                    videoRef.downloadURL { (url, error) in
                        if let downloadURL = url {
                            //The download url of the videos in Firebase Storage
                            print("Download URL for video at index \(currentIndex): \(downloadURL)")
                        } else {
                            print("Error getting download URL for video at index \(currentIndex): \(error?.localizedDescription ?? "")")
                        }
                        
                        // Move to the next video
                        currentIndex += 1
                        uploadNextVideoToFirebaseStorage()
                    }
                }
            }
            
            // Monitoring the progress
            uploadTask.observe(.progress) { [weak self] snapshot in
                let completedCount = Float(snapshot.progress?.completedUnitCount ?? 0)
                let totalCount = Float(snapshot.progress?.totalUnitCount ?? 0)
                self?.delegate?.updateProgress(progress: completedCount / totalCount, currentItem: currentIndex, totalItems: self?.videoSegments.count ?? 0, message: "Upload in progress", complete: false)
            }
        }
        
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
}
