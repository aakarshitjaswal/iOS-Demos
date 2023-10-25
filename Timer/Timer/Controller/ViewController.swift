//
//  ViewController.swift
//  Timer
//
//  Created by Aakarshit Jaswal on 24/10/23.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var timerBtn: UIButton!
    
    var timer: Timer?
    var notificationTimer: Timer?
    var millisecondsElapsed = 0
    var notificationBody = ""
    var notificationSent = false
    var notificationIdentifier = "timerNotification"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTimerLabel()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onStart(_ sender: UIButton) {
        if timer == nil {
            
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            sender.setTitle("Stop", for: .normal)
            //Set up a separate timer for notification with a timer interval of 0.001 second for updating millisecond info on label
            timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            //Set up a separate timer for notification with a timer interval of 1 second
            notificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sendNotification), userInfo: nil, repeats: true)

        } else {
            sender.setTitle("Start", for: .normal)
            timer?.invalidate()
            notificationTimer?.invalidate()
            notificationTimer = nil
            timer = nil
        }
        
        
    }
    
    @IBAction func resetTimer(_ sender: UIButton) {
        timerBtn.setTitle("Start", for: .normal)
        timer?.invalidate()
        notificationTimer?.invalidate()
        timer = nil
        notificationTimer = nil
        millisecondsElapsed = 0
        updateTimerLabel()
        notificationSent = false
        
    }
    
    @objc func updateTimer() {
        millisecondsElapsed += 1
        updateTimerLabel()
    }
    
    func updateTimerLabel() {
        let milliseconds = (millisecondsElapsed % 1000) / 10
        let seconds = (millisecondsElapsed / 1000) % 60
        let minutes = (millisecondsElapsed / 60000) % 60
        let hours = (millisecondsElapsed / 3600000)
        
        timerLbl.text = String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, milliseconds)
        
        notificationBody = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    @objc func sendNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "Timer is running!"
        content.subtitle = "The clock is ticking!"
        content.body = notificationBody
        print("Notification Body", notificationBody)
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1,
                                                        repeats: false)
        
        let requestIdentifier = notificationIdentifier
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        if !notificationSent {
            UNUserNotificationCenter.current().add(request,
                                                   withCompletionHandler: { (error) in
                guard error == nil else {
                    print("ERROR: \(String(describing: error))")
                    return
                }
                
                print("Notification Delivered")
                self.notificationSent = true
                // Handle error
            })
        } else {
            UNUserNotificationCenter.current()
             .removeAllPendingNotificationRequests()
            
            UNUserNotificationCenter.current().add(request,
                                                   withCompletionHandler: { (error) in
                
                guard error == nil else {
                    print("ERROR: \(String(describing: error))")
                    return
                }
                
                print("Updated Notification Delivered")
                self.notificationSent = true
                // Handle error
            })

        }
        

    }
}

