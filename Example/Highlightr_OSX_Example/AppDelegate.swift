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
    
    var textView : NSTextView!
    let textStorage = CodeAttributedString()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        textStorage.language = "Swift"
        textStorage.theme = "Pojoaque"
        textStorage.highlightr?.theme.codeFont = NSFont(name: "Courier", size: 12)
        
        let code = try! String.init(contentsOfFile: NSBundle.mainBundle().pathForResource("sampleCode", ofType: "txt")!)
        textStorage.setAttributedString(NSAttributedString(string: code))
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size:(window.contentView?.bounds.size)!)
        layoutManager.addTextContainer(textContainer)
        
        
        textView = NSTextView(frame: (window.contentView?.bounds)!, textContainer: textContainer)
        textView.autoresizingMask = [.ViewWidthSizable,.ViewHeightSizable]
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.backgroundColor = (textStorage.highlightr?.theme.themeBackgroundColor)!
        textView.insertionPointColor = NSColor.whiteColor()
        window.contentView?.addSubview(textView)
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

