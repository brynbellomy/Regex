//
//  RegexTests.swift
//  RegexTests
//
//  Created by bryn austin bellomy on 2015 Jan 5.
//  Copyright (c) 2015 bryn austin bellomy. All rights reserved.
//

import Cocoa
import XCTest
import Regex

class RegexTests: XCTestCase
{
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testStringReplaceRegex() {
        let name = "Winnie the Pooh"
        let darkName = name.replaceRegex("Winnie the ([a-zA-Z]+)", with: "Darth $1")
        XCTAssertEqual(darkName, "Darth Pooh")
    }
    
    func testStringGrep() {
        let name = "Winnie the Pooh"
        let matchResult = name.grep("\\s+([a-z]+)\\s+")
        XCTAssertTrue(matchResult.boolValue)
        XCTAssertEqual(matchResult.searchString, "Winnie the Pooh")
        
        XCTAssertEqual(matchResult.captures.count, 2)
        XCTAssertEqual(matchResult.captures[0], " the ")
        XCTAssertEqual(matchResult.captures[1], "the")
    }
    
    func testMapFunction() {
        let replaced = map("Winnie the Pooh" =~ Regex("([a-zA-Z]+)\\s+(the)(.*)"), replacementTemplate: "$2 $1")
        XCTAssertEqual(replaced, "the Winnie")
    }
}
