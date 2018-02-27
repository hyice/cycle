//
//  AppDelegate.swift
//  cycle
//
//  Created by hyice on 2016/12/23.
//  Copyright © 2016年 hyice. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Property -
    @IBOutlet weak var window: NSWindow!

    let barItemManager = CycleManager()
}

