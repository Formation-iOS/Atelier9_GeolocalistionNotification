//
//  NotificationManager.swift
//  Atelier9_Geolocalosation_Notifications
//
//  Created by CedricSoubrie on 23/10/2017.
//  Copyright © 2017 CedricSoubrie. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationManager: NSObject {
    static let shared = NotificationManager()
    let center = UNUserNotificationCenter.current()
    
    func setupNotification () {
        center.removeAllPendingNotificationRequests()
        center.delegate = self
        askNotificationPermisson()
    }

    private func askNotificationPermisson () {
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if granted {
                print ("Notification accepted")
            }
        }
    }
    
    func sendNotification (for locationTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "Vous êtes prêt de : \(locationTitle). Enjoy !"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let notification = UNNotificationRequest(identifier: "request", content: content, trigger: trigger)
        center.add(notification, withCompletionHandler: { (error) in
            if let error = error {
                print ("Notif Error \(error)")
            }
            else {
                print ("Notif success")
            }
        })
    }
}

extension NotificationManager : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        print ("Will present notification \(notification.request.content.title)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        print ("User responded \(response.actionIdentifier) to notification \(response.notification.request.content.title)")
    }
}
