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
    let stringStorage = NSMutableAttributedString()
    
    public var language : String?
    public var theme : String?
    
    public override var string: String {
        get {
            return stringStorage.string
        }
    }
    
    public override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [String : AnyObject] {
        return stringStorage.attributesAtIndex(location, effectiveRange: range)
    }
    
    public override func replaceCharactersInRange(range: NSRange, withString str: String) {
        self.beginEditing()
        stringStorage.replaceCharactersInRange(range, withString: str)
        self.endEditing()
        self.edited(NSTextStorageEditActions.EditedCharacters, range: range, changeInLength: str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - range.length)
    }
    
    public override func setAttributes(attrs: [String : AnyObject]?, range: NSRange) {
        self.beginEditing()
        stringStorage.setAttributes(attrs, range: range)
        self.endEditing()
        self.edited(NSTextStorageEditActions.EditedAttributes, range: range, changeInLength: 0)
    }
    
    public override func processEditing() {
        super.processEditing()
        //TODO: DO THE MAGIC HERE!
    }
    
    
}