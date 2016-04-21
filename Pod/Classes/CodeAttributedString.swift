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
                var range = (self.string as NSString).lineRangeForRange(self.editedRange)
                let tmpStrg = highlightr?.highlight(language, code: (self.string as NSString).substringWithRange(range))
                tmpStrg?.enumerateAttributesInRange(NSMakeRange(0, (tmpStrg?.length)!), options: [], usingBlock: { (attrs, locRange, stop) in
                    let fixedRange = NSMakeRange(range.location+locRange.location, locRange.length)
                    if(fixedRange.location + fixedRange.length < self.stringStorage.length)
                    {
                        self.addAttributes(attrs, range: fixedRange)
                    }else
                    {
                        print("OUT: \(fixedRange)")
                    }
                })
            }
            
        }
    }
    
    
}