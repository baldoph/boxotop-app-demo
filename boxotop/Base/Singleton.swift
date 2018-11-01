//
//  Singleton.swift
//  nink-ios
//
//  Created by Baldoph on 22/01/17.
//  Copyright © 2017 Noranda. All rights reserved.
//

import Foundation

public protocol Singleton: class {
    init()
}

private var SharedKey: UInt8 = 0

extension Singleton {
    private static var _shared: Self? {
        get { return objc_getAssociatedObject(self, &SharedKey) as? Self }
        set { objc_setAssociatedObject(self, &SharedKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }

    public static var shared: Self! {
        get {
            if _shared == nil { _shared = Self.init() }
            return _shared
        }
        set {
            _shared = newValue
        }
    }

    public static func isLoaded() -> Bool {
        return _shared != nil
    }
}
