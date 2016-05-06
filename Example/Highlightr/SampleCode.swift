//
//  SampleCode.swift
//  Highlightr
//
//  Created by Illanes, J.P. on 5/5/16.
//

import UIKit
import Highlightr
import ActionSheetPicker_3_0

enum pickerSource : Int {
    case theme = 0
    case language
}

class SampleCode: UIViewController
{
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var viewPlaceholder: UIView!
    var textView : UITextView!
    @IBOutlet var textToolbar: UIToolbar!
    
    @IBOutlet weak var languageName: UILabel!
    @IBOutlet weak var themeName: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var highlightr : Highlightr!
    let textStorage = CodeAttributedString()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicator.hidden = true
        languageName.text = "Swift"
        themeName.text = "Pojoaque"
        
        textStorage.language = languageName.text?.lowercaseString
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: view.bounds.size)
        layoutManager.addTextContainer(textContainer)
        
        textView = UITextView(frame: viewPlaceholder.bounds, textContainer: textContainer)
        textView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        textView.autocorrectionType = UITextAutocorrectionType.No
        textView.autocapitalizationType = UITextAutocapitalizationType.None
        textView.textColor = UIColor(white: 0.8, alpha: 1.0)
        textView.inputAccessoryView = textToolbar
        viewPlaceholder.addSubview(textView)
        
        let code = try! String.init(contentsOfFile: NSBundle.mainBundle().pathForResource("sampleCode", ofType: "txt")!)
        textView.text = code
        
        highlightr = textStorage.highlightr
        
        updateColors()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func pickLanguage(sender: AnyObject)
    {
        let languages = highlightr.supportedLanguages()
        let indexOrNil = languages.indexOf(languageName.text!.lowercaseString)
        let index = (indexOrNil == nil) ? 0 : indexOrNil!
        
        ActionSheetStringPicker.showPickerWithTitle("Pick a Language",
                                                    rows: languages,
                                                    initialSelection: index,
                                                    doneBlock:
            { picker, index, value in
                let language = value! as! String
                self.textStorage.language = language
                self.languageName.text = language.capitalizedString
            },
                                                    cancelBlock: nil,
                                                    origin: toolBar)

    }

    @IBAction func performanceTest(sender: AnyObject)
    {
        let code = textStorage.string
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
        {
            let start = NSDate()
            for _ in 0...100
            {
                self.highlightr.highlight(self.languageName.text!, code: code, fastRender: true)
            }
            let end = NSDate()
            let time = Float(end.timeIntervalSinceDate(start));
            
            let avg = String(format:"%0.4f", time/100)
            let total = String(format:"%0.3f", time)
            
            let alert = UIAlertController(title: "Performance test", message: "This code was highlighted 100 times. \n It took an average of \(avg) seconds to process each time,\n with a total of \(total) seconds", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(okAction)
            
            dispatch_async(dispatch_get_main_queue(),
            {
                self.activityIndicator.hidden = true
                self.activityIndicator.stopAnimating()
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
        
    }
    
    @IBAction func pickTheme(sender: AnyObject)
    {
        hideKeyboard(nil)
        let themes = highlightr.availableThemes()
        let indexOrNil = themes.indexOf(themeName.text!.lowercaseString)
        let index = (indexOrNil == nil) ? 0 : indexOrNil!
        
        ActionSheetStringPicker.showPickerWithTitle("Pick a Theme",
                                                    rows: themes,
                                                    initialSelection: index,
                                                    doneBlock:
            { picker, index, value in
                let theme = value! as! String
                self.textStorage.theme = theme
                self.themeName.text = theme.capitalizedString
                self.updateColors()
            },
                                                    cancelBlock: nil,
                                                    origin: toolBar)
        
    }
    
    @IBAction func hideKeyboard(sender: AnyObject?)
    {
        textView.resignFirstResponder()
    }
    
    func updateColors()
    {
        textView.backgroundColor = highlightr.theme.themeBackgroundColor
        navBar.barTintColor = highlightr.theme.themeBackgroundColor
        navBar.tintColor = invertColor(navBar.barTintColor!)
        languageName.textColor = navBar.tintColor
        themeName.textColor = navBar.tintColor.colorWithAlphaComponent(0.5)
        toolBar.barTintColor = navBar.barTintColor
        toolBar.tintColor = navBar.tintColor
    }
    
    func invertColor(color: UIColor) -> UIColor
    {
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: nil)
        return UIColor(red:1.0-r, green: 1.0-g, blue: 1.0-b, alpha: 1)
    }
}
