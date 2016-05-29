//
//  CodeAttributedString.swift
//  Pods
//
//  Created by Illanes, J.P. on 4/19/16.
//
//

import Foundation

@objc public protocol HighlightDelegate {
    /**
     If this method returns *false*, the highlighting process will be skipped for this range.
     
     - parameter range: NSRange
     
     - returns: Bool
     */
    optional func shouldHighlight(range:NSRange) -> Bool
    /**
     Called after a range of the string was highlighted, if there was an error **success** will be *false*.
     
     - parameter range:   NSRange
     - parameter success: Bool
     */
    optional func didHighlight(range:NSRange, success: Bool)
}

public class CodeAttributedString : NSTextStorage
{
    let stringStorage = NSMutableAttributedString(string: "")

        /// Highlightr instace used internally for highlighting. Use this for configuring the theme.
    public let highlightr = Highlightr()!
    
        /// This object will be notified before and after the highlighting.
    public var highlightDelegate : HighlightDelegate?

        ///Language syntax to use for highlighting.
    public var language : String?
    {
        didSet {
            highlight(NSMakeRange(0, stringStorage.length))
        }
    }
    
        /// Returns a standard String based on the current one.
    public override var string: String
    {
        get {
            return stringStorage.string
        }
    }
    
    /**
     Returns the attributes for the character at a given index.
     
     - parameter location: Int
     - parameter range:    NSRangePointer
     
     - returns: Attributes
     */
    public override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [String : AnyObject]
    {
        return stringStorage.attributesAtIndex(location, effectiveRange: range)
    }
    
    /**
     Replaces the characters at the given range with the provided string.
     
     - parameter range: NSRange
     - parameter str:   String
     */
    public override func replaceCharactersInRange(range: NSRange, withString str: String)
    {
        stringStorage.replaceCharactersInRange(range, withString: str)
        self.edited(NSTextStorageEditActions.EditedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
    }
    
    /**
     Sets the attributes for the characters in the specified range to the specified attributes.
     
     - parameter attrs: [String : AnyObject]
     - parameter range: NSRange
     */
    public override func setAttributes(attrs: [String : AnyObject]?, range: NSRange)
    {
        stringStorage.setAttributes(attrs, range: range)
        self.edited(NSTextStorageEditActions.EditedAttributes, range: range, changeInLength: 0)
    }
    
    /**
     Called internally everytime the string was modified.
     */
    public override func processEditing()
    {
        super.processEditing()
        if language != nil {
            if self.editedMask.contains(.EditedCharacters)
            {
                let string = (self.string as NSString)
                let range = string.paragraphRangeForRange(editedRange)
                highlight(range)
            }
        }
    }

    
    func highlight(range: NSRange)
    {
        if(language == nil)
        {
            return;
        }
        
        if let highlightDelegate = highlightDelegate
        {
            let shouldHighlight : Bool? = highlightDelegate.shouldHighlight?(range)
            if(shouldHighlight != nil && !shouldHighlight!)
            {
                return;
            }
        }

        
        let string = (self.string as NSString)
        let line = string.substringWithRange(range)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let tmpStrg = self.highlightr.highlight(self.language!, code: line, fastRender: true)
            dispatch_async(dispatch_get_main_queue(), {
                //Checks to see if this highlighting is still valid.
                if((range.location + range.length) > self.stringStorage.length)
                {
                    self.highlightDelegate?.didHighlight?(range, success: false)
                    return;
                }
                
                if(tmpStrg?.string != self.stringStorage.attributedSubstringFromRange(range).string)
                {
                    self.highlightDelegate?.didHighlight?(range, success: false)
                    return;
                }
                
                self.beginEditing()
                tmpStrg?.enumerateAttributesInRange(NSMakeRange(0, (tmpStrg?.length)!), options: [], usingBlock: { (attrs, locRange, stop) in
                    var fixedRange = NSMakeRange(range.location+locRange.location, locRange.length)
                    fixedRange.length = (fixedRange.location + fixedRange.length < string.length) ? fixedRange.length : string.length-fixedRange.location
                    fixedRange.length = (fixedRange.length >= 0) ? fixedRange.length : 0
                    self.stringStorage.setAttributes(attrs, range: fixedRange)
                })
                self.endEditing()
                self.edited(NSTextStorageEditActions.EditedAttributes, range: range, changeInLength: 0)
                self.highlightDelegate?.didHighlight?(range, success: true)
            })
            
        }
        
    }
    
    
}