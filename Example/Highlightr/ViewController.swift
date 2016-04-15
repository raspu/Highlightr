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

    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        hig = Highlightr()
        let code = try! String.init(contentsOfFile: NSBundle.mainBundle().pathForResource("sampleCode", ofType: "txt")!)
        var text : NSAttributedString
        let methodStart = NSDate()
        text = hig.highlight("swift", code: code)!
        /*for _ in 0 ..< 100
        {
            NSLog("INIT")
            text = hig.highlight("swift", code: code)!
            NSLog("END")

        }*/
        let methodFinish = NSDate()
        let executionTime = Float(methodFinish.timeIntervalSinceDate(methodStart))/100.0;
        NSLog("AVG:\(executionTime)")
        
        print(hig.availableThemes())
        print(hig.supportedLanguages())


        label.attributedText = text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

