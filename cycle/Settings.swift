//
//  Settings.swift
//  cycle
//
//  Created by zhangbin on 2018/2/27.
//  Copyright © 2018年 hyice. All rights reserved.
//

import Cocoa

class Settings {
    enum StoringKeys: String {
        case CycleInterval = "cycle_interval"
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
}
