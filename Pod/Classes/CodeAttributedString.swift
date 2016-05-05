//
//  CodeAttributedString.swift
//  Pods
//
//  Created by Illanes, Juan Pablo on 4/19/16.
//
//

import Foundation

public class CodeAttributedString : NSTextStorage
{
    let stringStorage = NSMutableAttributedString(string: "")

    public let highlightr = Highlightr()
    public var language : String? {
        didSet {
            highlight(NSMakeRange(0, stringStorage.length))
        }
    }

    
        /// Use this property to update the theme.
    public var theme : String? {
        didSet {
            if let theme = theme {
                highlightr?.setTheme(theme)
                highlight(NSMakeRange(0, stringStorage.length))
            }
        }
    }
    
    public override var string: String {
        get {
            return stringStorage.string
        }
    }
    
    public override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [String : AnyObject] {
        return stringStorage.attributesAtIndex(location, effectiveRange: range)
    }
    
    public override func replaceCharactersInRange(range: NSRange, withString str: String) {
        stringStorage.replaceCharactersInRange(range, withString: str)
        self.edited(NSTextStorageEditActions.EditedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
    }
    
    public override func setAttributes(attrs: [String : AnyObject]?, range: NSRange) {
        stringStorage.setAttributes(attrs, range: range)
        self.edited(NSTextStorageEditActions.EditedAttributes, range: range, changeInLength: 0)
    }
    
    public override func processEditing() {
        super.processEditing()
        if let language = language {
            if self.editedMask.contains(.EditedCharacters)
            {
                let string = (self.string as NSString)
                var range = string.paragraphRangeForRange(editedRange)
                highlight(range)
            }
            
        }
    }

    
    func highlight(range: NSRange)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let string = (self.string as NSString)
            var line = string.substringWithRange(range)
            let tmpStrg = self.highlightr?.highlight(self.language!, code: line, fastRender: true)
            dispatch_async(dispatch_get_main_queue(), {
                self.beginEditing()
                tmpStrg?.enumerateAttributesInRange(NSMakeRange(0, (tmpStrg?.length)!), options: [], usingBlock: { (attrs, locRange, stop) in
                    var fixedRange = NSMakeRange(range.location+locRange.location, locRange.length)
                    fixedRange.length = (fixedRange.location + fixedRange.length < string.length) ? fixedRange.length : string.length-fixedRange.location
                    fixedRange.length = (fixedRange.length >= 0) ? fixedRange.length : 0
                    self.stringStorage.setAttributes(attrs, range: fixedRange)
                })
                self.endEditing()
                self.edited(NSTextStorageEditActions.EditedAttributes, range: range, changeInLength: 0)
            })
            
        }
        
    }
    
    
}