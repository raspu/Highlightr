//
//  ViewController.swift
//  Highlightr
//
//  Created by Illanes, Juan Pablo on 04/10/2016.
//  Copyright (c) 2016 Illanes, Juan Pablo. All rights reserved.
//

import UIKit
import Highlightr

class ViewController: UIViewController {
    var hig : Highlightr!
    var textStorage : CodeAttributedString!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        hig = Highlightr()

        let code = try! String.init(contentsOfFile: NSBundle.mainBundle().pathForResource("sampleCode", ofType: "txt")!)
        var text : NSAttributedString
        let methodStart = NSDate()
        text = hig.highlight("swift", code: code, fastRender: true)!
        for _ in 0 ..< 100
        {
            let start = NSDate()
            text = hig.highlight("swift", code: code, fastRender: true)!
            let end = NSDate()
            let time = Float(end.timeIntervalSinceDate(start));
            NSLog("Current :\(time)")


        }
        let methodFinish = NSDate()
        let executionTime = Float(methodFinish.timeIntervalSinceDate(methodStart))/100.0;
        NSLog("AVG:\(executionTime)")
        
        textStorage = CodeAttributedString()
        textStorage.language = "swift"
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: view.bounds.size)
        layoutManager.addTextContainer(textContainer)
        
        textView = UITextView(frame: view.bounds, textContainer: textContainer)
        textView.backgroundColor = UIColor.darkGrayColor()
        textView.autocorrectionType = UITextAutocorrectionType.No
        textView.autocapitalizationType = UITextAutocapitalizationType.None
        textView.textColor = UIColor(white: 0.8, alpha: 1.0)
        self.view.addSubview(textView)
        
        label.attributedText = text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

