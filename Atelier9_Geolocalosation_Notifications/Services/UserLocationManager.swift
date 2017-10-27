//
//  UserLocationManager.swift
//  Atelier9_Geolocalosation_Notifications
//
//  Created by CedricSoubrie on 23/10/2017.
//  Copyright © 2017 CedricSoubrie. All rights reserved.
//

import UIKit
import CoreLocation

class UserLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = UserLocationManager()
    
    lazy var locationManager : CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    } ()
}

// Permission
extension UserLocationManager {
    func askUserLocationPermission () {
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print ("didChangeAuthorization \(status.rawValue)")
        switch status {
        case .restricted, .denied, .authorizedWhenInUse:
            // Disable location features
            disableLocationFeatures()
        case .authorizedAlways:
            // Enable basic location features
            enableLocationFeatures()
        default :
            break
            
        }
    }
    
    private func enableLocationFeatures () {
        self.monitorInterestingPoints()
    }
    
    private func disableLocationFeatures () {
        print ("On peut pas vous logger correctement si vous acceptez pas Always :'(")
    }
}

// Region monitoring
extension UserLocationManager {
    static let monitoringDistance : CLLocationDistance = 500000
    
    private func monitorInterestingPoints () {
        for point in FunMapPoint.allMapPoints {
            monitor(point: point)
        }
    }
    
    private func monitor (point : FunMapPoint) {
        let region = CLCircularRegion(center: point.coordinate, radius: UserLocationManager.monitoringDistance, identifier: point.title)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print ("Enter region \(region)")
        self.notifyUserFor(region: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print ("Exit region \(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print ("MonitoringDidFailFor region \(region?.identifier ?? "Unknown") \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print ("DidStartMonitoringFor region \(region.identifier)")
        if let region = region as? CLCircularRegion,
            let location = manager.location {
            if region.contains(location.coordinate) {
                self.notifyUserFor(region: region)
            }
        }
    }
    
    func notifyUserFor (region: CLRegion) {
        NotificationManager.shared.sendNotification(for: region.identifier)
    }
}
