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
    let highlightr = Highlightr()
    
    public var language : String?
    public var theme : String? {
        didSet {
            if let theme = theme {
                highlightr?.setTheme(theme)
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
        self.edited(NSTextStorageEditActions.EditedCharacters, range: range, changeInLength: str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - range.length)
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
                let editedRange = self.editedRange
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var range = string.paragraphRangeForRange(editedRange)
                    print(string.substringWithRange(range))
                    let tmpStrg = self.highlightr?.highlight(language, code: string.substringWithRange(range))
                    tmpStrg?.enumerateAttributesInRange(NSMakeRange(0, (tmpStrg?.length)!), options: [], usingBlock: { (attrs, locRange, stop) in
                        var fixedRange = NSMakeRange(range.location+locRange.location, locRange.length)
                        fixedRange.length = (fixedRange.location + fixedRange.length < string.length) ? fixedRange.length : string.length-fixedRange.location
                        self.stringStorage.addAttributes(attrs, range: fixedRange)
                    })
                })
            }
            
        }
    }
    
    
}