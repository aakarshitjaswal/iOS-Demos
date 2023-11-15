#  Video Splitter

The project accomplishes everything mentioned in the task descriptions as described below:

Select a video from the Simulator. 
    
    Using the UIImagePickerController to pick the videos
    
Split the video into 10-sec portions (eg. 25-second. videos should be split between 10-10-5 secs.).
    
    Used Temporary storage to store the split videos using the AVAssetExportSession
    
Upload those videos to Firebase.
    
    Uploaded the videos to the firebase storage and and printed the download url's to the videos as well. The videos are being stored in the same order as the actual video.

It must pass the following test cases:
 
1. Videos should be sent in the same sequence (and must not repeat) as its been recorded.
    (Passed)
    To achieve the same I am uploading the videos one after the other, which maintains the sequence of the videos and doesn't reapeat, I have kept track of the current index being uploaded and moved to the next upon successful upload of the current video. 
    
    
2. Must be able to send videos even if the app is in the background.
    (Passed)
    I have created a background task identifier for the same and used to the UIApplication.shared.beginBackgroundTask which gives us a little more time than the default 30 seconds alloted by the operating system for background tasks.
