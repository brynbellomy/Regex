//
//  Regex.swift
//  Regex
//
//  Created by bryn austin bellomy on 2/10/2015
//  Copyright (c) 2015 bryn austin bellomy. All rights reserved.
//

import Foundation


public extension String
{
    /**
        Searches the receiving `String` with the regex given in `pattern`, returning the match results.
     */
    public func grep (pattern:String) -> Regex.MatchResult {
        return self =~ Regex(pattern)
    }

    /**
        Searches the receiving string with the regex given in `pattern`, replaces the match(es) with `replacement`, and returns the resulting string.
     */
    public func replaceRegex(pattern:String, with replacement:String) -> String {
        return map(self =~ Regex(pattern), replacementTemplate: replacement)
    }
}

extension String
{
    var fullRange:   Range<String.Index> { return startIndex ..< endIndex }
    var fullNSRange: NSRange             { return NSRange(location:0, length:self.characters.count) }

    func substringWithRange (range:NSRange) -> String {
       return substringWithRange(convertRange(range))
    }

    func convertRange (range: Range<Int>) -> Range<String.Index> {
        let start = self.startIndex.advancedBy(range.startIndex)
        let end   = start.advancedBy(range.endIndex - range.startIndex)
        return Range(start: start, end: end)
    }

    func convertRange (nsrange:NSRange) -> Range<String.Index> {
        let start = self.startIndex.advancedBy(nsrange.location)
        let end   = start.advancedBy(nsrange.length)
        return Range(start: start, end: end)
    }
}


/**
    A `Regex` represents a compiled regular expression that can be applied to
    `String` objects to search for (and replace) matched patterns.
 */
public struct Regex
{
    public typealias MatchResult = RegexMatchResult

    private let pattern: String
    private let nsRegex: NSRegularExpression


    /**
        Attempts to create a `Regex` with the provided `pattern`.  If this fails, a tuple `(nil, NSError)` is returned.  If it succeeds, a tuple `(Regex, nil)` is returned.
     */
    public static func create(pattern:String) -> (Regex?, NSError?)
    {
        var err: NSError?
        let regex: Regex?
        do {
            regex = try Regex(pattern: pattern)
        } catch let error as NSError {
            err = error
            regex = nil
        }

        if let err = err            { return (nil, err) }
        else if let regex = regex   { return (regex, nil) }
        else                        { return (nil, NSError(domain: "com.illumntr.Regex", code: 1, userInfo:[NSLocalizedDescriptionKey: "Unknown error."])) }
    }


    /**
        Creates a `Regex` with the provided `String` as its pattern.  If the pattern is invalid, this
        function calls `fatalError()`.  Hence, it is recommended that you use `Regex.create()` for more
        descriptive error messages.

        - parameter p: A string containing a regular expression pattern.
     */
    public init(_ p:String)
    {
        pattern = p

        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions(rawValue: 0))
        } catch _ as NSError {
            fatalError("Invalid regex: \(p)")
        }
        
        if let regex = regex {
            nsRegex = regex
        } else {
            fatalError("Invalid regex: \(p)")
        }
    }


    /**
        Creates a `Regex` with the provided `String` as its pattern.  If the pattern is invalid, this
        function initializes an `NSError` into the provided `NSErrorPointer`.  `Regex.create()` is recommended,
        as it wraps this constructor and handles the `NSErrorPointer` dance for you.

        - parameter p: A string containing a regular expression pattern.
        - parameter error: An `NSErrorPointer` that will contain an `NSError` if initialization fails.
     */
    public init (pattern p:String) throws
    {
        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        pattern = p

        var err: NSError?
        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions(rawValue: 0))
        } catch let error as NSError {
            err = error
            regex = nil
        }
        if let regex = regex {
            nsRegex = regex
        }
        else {
            nsRegex = NSRegularExpression()
            if let err = err {
                error = err
            }
            throw error
        }
    }


    /**
        Searches in `string` for the regular expression pattern represented by the receiver.

        - parameter string: The string in which to search for matches.
     */
    public func match (string:String) -> MatchResult
    {
        var matches  = [NSTextCheckingResult]()
        let all      = NSRange(location: 0, length: string.characters.count)
        let moptions = NSMatchingOptions(rawValue: 0)

        nsRegex.enumerateMatchesInString(string, options:moptions, range:all) {
            (result: NSTextCheckingResult?, flags: NSMatchingFlags, ptr: UnsafeMutablePointer<ObjCBool>) in
            
            if let result = result {
                matches.append(result)
            }
        }

        return MatchResult(regex:nsRegex, searchString:string, items: matches)
    }


    /**
        Searches `string` for the regular expression pattern represented by the receiver.  Any matches are replaced using
        the provided `replacement` string, which can contain substitution patterns like `"$1"`, etc.

        - parameter string: The string to search.
        - parameter replacement: The replacement pattern to apply to any matches.
        - returns: A 2-tuple containing the number of replacements made and the transformed search string.
     */
    public func replaceMatchesIn (string:String, with replacement:String) -> (replacements:Int, string:String)
    {
        let mutableString = NSMutableString(string:string)
        let replacements  = nsRegex.replaceMatchesInString(mutableString, options:NSMatchingOptions(rawValue: 0), range:string.fullNSRange, withTemplate:replacement)

        return (replacements:replacements, string:String(mutableString))
    }


    /**
        Searches `string` for the regular expression pattern represented by the receiver.  Any matches are replaced using
        the provided `replacement` string, which can contain substitution patterns like `"$1"`, etc.

        - parameter string: The string to search.
        - parameter replacement: The replacement pattern to apply to any matches.
        - returns: The transformed search string.
     */
    public func replaceMatchesIn (string:String, with replacement:String) -> String {
        return map((string =~ self), replacementTemplate: replacement)
    }
}


infix operator =~ {}

/**
    Searches `searchString` using `regex` and returns the resulting `Regex.MatchResult`.
*/
public func =~ (searchString: String, regex:Regex) -> Regex.MatchResult {
    return regex.match(searchString)
}


/**
    An object representing the result of searching a given `String` using a `Regex`.
 */
public struct RegexMatchResult: SequenceType, BooleanType
{
    /** Returns `true` if the number of matches is greater than zero. */
    public var boolValue: Bool { return items.count > 0 }

    public let regex: NSRegularExpression
    public let searchString: String
    public let items: [NSTextCheckingResult]

    /** An array of the captures as `String`s.  Ordering is the same as the return value of Javascript's `String.match()` method. */
    public let captures: [String]


    /**
        The designated initializer.

        - parameter regex: The `NSRegularExpression` that was used to create this `RegexMatchResult`.
        - parameter searchString: The string that was searched by `regex` to generate these results.
        - parameter items: The array of `NSTextCheckingResult`s generated by `regex` while searching `searchString`.
    */
    public init (regex r:NSRegularExpression, searchString s:String, items i:[NSTextCheckingResult])
    {
        regex = r
        searchString = s
        items = i

        captures = items.flatMap { result in
            (0 ..< result.numberOfRanges).map { i in
                let nsrange = result.rangeAtIndex(i)
                return s.substringWithRange(nsrange)
            }
        }
    }


    /**
        Returns the `i`th match as an `NSTextCheckingResult`.
     */
    subscript (i: Int) -> NSTextCheckingResult {
        get { return items[i] }
    }


    /**
        Returns the captured text of the `i`th match as a `String`.
     */
    subscript (i: Int) -> String {
        get { return captures[i] }
    }


    /**
        Returns a `Generator` that iterates over the captured matches as `NSTextCheckingResult`s.
     */
    public func generate() -> AnyGenerator<NSTextCheckingResult> {
        var gen = items.generate()
        return anyGenerator { gen.next() }
    }


    /**
        Returns a `Generator` that iterates over the captured matches as `String`s.
     */
    public func generateCaptures() -> AnyGenerator<String> {
        var gen = captures.generate()
        return anyGenerator { gen.next() }
    }
}


/**
    Returns the `String` created by replacing the regular expression matches in `regexResult` using `replacementTemplate`.
 */
public func map (regexResult:Regex.MatchResult, replacementTemplate:String) -> String
{
    let searchString = NSMutableString(string: regexResult.searchString)
    let fullRange    = regexResult.searchString.fullNSRange
    regexResult.regex.replaceMatchesInString(searchString, options: NSMatchingOptions(rawValue: 0), range:fullRange, withTemplate:replacementTemplate)
    return String(searchString)
}


