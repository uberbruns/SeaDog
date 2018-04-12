//
//  NSObject+AssociatedValues.swift
//  SeaDog-iOS
//
//  Created by Karsten Bruns on 12.04.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import Foundation
import ObjectiveC


extension NSObject {
    func setAssociatedValue<T>(_ value: T, forKey associativeKey: UnsafeRawPointer, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        objc_setAssociatedObject(self, associativeKey, value,  policy)
    }
    
    func associatedValue<T>(forKey associativeKey: UnsafeRawPointer) -> T? {
        let value = objc_getAssociatedObject(self, associativeKey)
        return value as? T
    }
}
