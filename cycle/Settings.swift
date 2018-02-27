//
//  Settings.swift
//  cycle
//
//  Created by hyice on 2018/2/27.
//  Copyright © 2018年 hyice. All rights reserved.
//

import Cocoa


enum NotificationType: Int {
    case SoundOnly = 1
    case Alert
    case AlertAndSound
    case NotificationBanner
    case NotificationBannerAndSound
    case DoNotNotify
}


class Settings {
    enum StoringKeys: String {
        case CycleInterval = "cycle_interval"
        case NotificationType = "cycle_notification_type"
        case DontDisplayTimer = "cycle_dont_display_timer"
    }
    
    static var cycleIntervalInSeconds: Int {
        get {
            let interval = UserDefaults.standard.integer(forKey: StoringKeys.CycleInterval.rawValue)
            
            guard interval != 0 else {
                return 25 * 60
            }
            
            return interval
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StoringKeys.CycleInterval.rawValue)
        }
    }
    
    static var notificationType: NotificationType {
        get {
            let notificationTypeValue = UserDefaults.standard.integer(forKey: StoringKeys.NotificationType.rawValue)
            
            return NotificationType(rawValue: notificationTypeValue) ?? .NotificationBanner
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: StoringKeys.NotificationType.rawValue)
        }
    }
    
    static var displayTimer: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: StoringKeys.DontDisplayTimer.rawValue)
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: StoringKeys.DontDisplayTimer.rawValue)
        }
    }
}
