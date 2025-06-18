//
//  Shims.swift
//  Pods
//
//  Created by Kabir Oberai on 19/06/18.
//
//

import Foundation

#if os(OSX)
    import AppKit
#elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    import UIKit
#endif

#if swift(>=4.2)
    public typealias AttributedStringKey = NSAttributedString.Key
#else
    public typealias AttributedStringKey = NSAttributedStringKey
#endif

#if swift(>=4.2) && (os(iOS) || os(tvOS) || os(watchOS) || os(visionOS))
    public typealias TextStorageEditActions = NSTextStorage.EditActions
#else
    public typealias TextStorageEditActions = NSTextStorageEditActions
#endif
