//
//  Highlightr.swift
//  Pods
//
//  Created by Illanes, Juan Pablo on 4/10/16.
//
//

import Foundation
import JavaScriptCore

public class Highlightr
{
    let jsContext : JSContext
    let hljs = "window.hljs"
    let bundle : NSBundle
    var theme : String
    
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
        
        guard let defTheme = bundle.pathForResource("pojoaque.min", ofType: "css") else
        {
            return nil
        }
        theme = try! String.init(contentsOfFile: defTheme)
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
        theme = try! String.init(contentsOfFile: defTheme)
        
        return true
    }
    
    /**
     Takes a String and returns a NSAttributedString with the given language highlighted.
     
     - parameter languageName:   Language name or alias
     - parameter code:           Code to highlight
     
     - returns: NSAttributedString with the detected code highlighted.
     */
    public func highlight(languageName: String, code: String) -> NSAttributedString?
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
        
        string = "<style>"+theme+"</style><pre><code class=\"hljs\">"+string+"</code></pre>"
        let opt = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]

        let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
        let attrString = try! NSMutableAttributedString(data:data,options:opt as! [String:AnyObject],documentAttributes:nil)
        attrString.removeAttribute(NSBackgroundColorAttributeName, range: NSMakeRange(0, attrString.length))
        return attrString
    }
    
    /**
     Returns a list of all the themes available.
     
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
    
}
