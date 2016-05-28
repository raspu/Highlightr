//
//  Highlightr.swift
//  Pods
//
//  Created by Illanes, J.P. on 4/10/16.
//
//

import Foundation
import JavaScriptCore

/// Utility class for generating a highlighted NSAttributedString from a String.
public class Highlightr
{
    /// Returns the current Theme.
    public var theme : Theme!
    
    private let jsContext : JSContext
    private let hljs = "window.hljs"
    private let bundle : NSBundle
    private let htmlStart = "<"
    private let spanStart = "span class=\""
    private let spanStartClose = "\">"
    private let spanEnd = "/span>"
    private let htmlEscape = try! NSRegularExpression(pattern: "&#?[a-zA-Z0-9]+?;", options: .CaseInsensitive)
    
    /**
     Default init method, generates a JSContext instance and the default Theme.
     
     - returns: Highlightr instance.
     */
    public init?()
    {
        jsContext = JSContext()
        jsContext.evaluateScript("var window = {};")
        bundle = NSBundle(forClass: Highlightr.self)
        guard let hgPath = bundle.pathForResource("highlight.min", ofType: "js") else
        {
            return nil
        }
        
        let hgJs = try! String.init(contentsOfFile: hgPath)
        let value = jsContext.evaluateScript(hgJs)
        if !value.toBool()
        {
            return nil
        }
        
        guard setTheme("pojoaque") else
        {
            return nil
        }
        
    }
    
    /**
     Set the theme to use for highlighting.
     
     - parameter name: String, theme name.
     
     - returns: true if it was posible to set the given theme, false otherwise.
     */
    public func setTheme(name: String) -> Bool
    {
        guard let defTheme = bundle.pathForResource(name+".min", ofType: "css") else
        {
            return false
        }
        let themeString = try! String.init(contentsOfFile: defTheme)
        theme =  Theme(themeString: themeString)

        
        return true
    }
    
    /**
     Takes a String and returns a NSAttributedString with the given language highlighted.
     
     - parameter languageName:   Language name or alias
     - parameter code:           Code to highlight
     - parameter fastRender:     If *true* will use the custom made html parser rather than Apple's solution.
     
     - returns: NSAttributedString with the detected code highlighted.
     */
    public func highlight(languageName: String, code: String, fastRender: Bool) -> NSAttributedString?
    {
        var fixedCode = code.stringByReplacingOccurrencesOfString("\\",withString: "\\\\");
        fixedCode = fixedCode.stringByReplacingOccurrencesOfString("\'",withString: "\\\'");
        fixedCode = fixedCode.stringByReplacingOccurrencesOfString("\"", withString:"\\\"");
        fixedCode = fixedCode.stringByReplacingOccurrencesOfString("\n", withString:"\\n");
        fixedCode = fixedCode.stringByReplacingOccurrencesOfString("\r", withString:"");

        let command =  String.init(format: "%@.highlight(\"%@\",\"%@\").value;", hljs,languageName, fixedCode)
        let res = jsContext.evaluateScript(command)
        guard var string = res!.toString() else
        {
            return nil
        }
        
        let returnString : NSAttributedString
        if(fastRender)
        {
            returnString = processHTMLString(string)!
        }else
        {
             string = "<style>"+theme.lightTheme+"</style><pre><code class=\"hljs\">"+string+"</code></pre>"
             let opt = [
             NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
             NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
             ]
            
             let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
             returnString = try! NSMutableAttributedString(data:data,options:opt as! [String:AnyObject],documentAttributes:nil)

        }
        
        return returnString
    }
    
    /**
     Returns a list of all the available themes.
     
     - returns: Array of Strings
     */
    public func availableThemes() -> [String]
    {
        let paths = bundle.pathsForResourcesOfType("css", inDirectory: nil) as [NSString]
        var result = [String]()
        for path in paths {
            result.append(path.lastPathComponent.stringByReplacingOccurrencesOfString(".min.css", withString: ""))
        }
        
        return result
    }
    
    /**
     Returns a list of all supported languages.
     
     - returns: Array of Strings
     */
    public func supportedLanguages() -> [String]
    {
        let command =  String.init(format: "%@.listLanguages();", hljs)
        let res = jsContext.evaluateScript(command)
        return res.toArray() as! [String]
    }
    
    //Private & Internal
    private func processHTMLString(string: String) -> NSAttributedString?
    {
        let scanner = NSScanner(string: string)
        scanner.charactersToBeSkipped = nil
        var scannedString = NSString?()
        let resultString = NSMutableAttributedString(string: "")
        var propStack = ["hljs"]
        
        while !scanner.atEnd
        {
            var ended = false
            if scanner.scanUpToString(htmlStart, intoString: &scannedString)
            {
                if scanner.atEnd
                {
                    ended = true
                }
            }
            
            if scannedString != nil && scannedString!.length > 0 {
                let attrScannedString = theme.applyStyleToString(scannedString! as String, styleList: propStack)
                resultString.appendAttributedString(attrScannedString)
                if ended
                {
                    continue
                }
            }
            
            scanner.scanLocation += 1
            
            let string = scanner.string as NSString
            let nextChar = string.substringWithRange(NSMakeRange(scanner.scanLocation, 1))
            if(nextChar == "s")
            {
                scanner.scanLocation += (spanStart as NSString).length
                scanner.scanUpToString(spanStartClose, intoString:&scannedString)
                scanner.scanLocation += (spanStartClose as NSString).length
                propStack.append(scannedString! as String)
            }
            else if(nextChar == "/")
            {
                scanner.scanLocation += (spanEnd as NSString).length
                propStack.popLast()
            }else
            {
                let attrScannedString = theme.applyStyleToString("<", styleList: propStack)
                resultString.appendAttributedString(attrScannedString)
                scanner.scanLocation += 1
            }
            
            scannedString = nil
        }
        
        let results = htmlEscape.matchesInString(resultString.string,
                                               options: [.ReportCompletion],
                                               range: NSMakeRange(0, resultString.length))
        var locOffset = 0
        for result in results
        {
            let fixedRange = NSMakeRange(result.range.location-locOffset, result.range.length)
            let entity = (resultString.string as NSString).substringWithRange(fixedRange)
            if let decodedEntity = HTMLUtils.decode(entity)
            {
                resultString.replaceCharactersInRange(fixedRange, withString: String(decodedEntity))
                locOffset += result.range.length-1;
            }
            

        }

        return resultString
    }
    
}
