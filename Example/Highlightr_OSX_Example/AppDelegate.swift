//
//  AppDelegate.swift
//  Highlightr_OSX_Example
//
//  Created by Illanes, Juan Pablo on 5/14/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Cocoa
import Highlightr

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var scrollview : NSScrollView!
    var textView : NSTextView!
    let textStorage = CodeAttributedString()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        textStorage.language = "Swift"
        textStorage.highlightr.setTheme(to: "Pojoaque")
        textStorage.highlightr.theme.codeFont = NSFont(name: "Courier", size: 12)
        
        let code = try! String.init(contentsOfFile: Bundle.main.path(forResource: "sampleCode", ofType: "txt")!)
        textStorage.setAttributedString(NSAttributedString(string: code))
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)

        // Setting Up the Scroll View
        scrollview = NSScrollView(frame: (window.contentView?.bounds)!)
        scrollview.borderType = .noBorder
        scrollview.hasVerticalScroller = true
        scrollview.hasHorizontalScroller = false
        scrollview.autoresizingMask = [.width,.height]

        let contentSize = scrollview.contentSize

        textView = NSTextView(frame: (window.contentView?.bounds)!, textContainer: textContainer)
        textView.minSize = NSMakeSize(0.0, contentSize.height)
        textView.maxSize = NSMakeSize(CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer!.containerSize = NSMakeSize(contentSize.width, CGFloat.greatestFiniteMagnitude)
        textView.textContainer!.widthTracksTextView = true
        textView.backgroundColor = (textStorage.highlightr.theme.themeBackgroundColor)!
        textView.insertionPointColor = NSColor.white

        scrollview.documentView = textView;
        window.contentView?.addSubview(scrollview)
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

