
# Regex.swift

[![Build Status](https://travis-ci.org/brynbellomy/Regex.svg?branch=0.2.1)](https://travis-ci.org/brynbellomy/Regex)
[![CocoaPods](https://img.shields.io/cocoapods/v/Regex.svg?style=flat)](http://cocoadocs.org/docsets/Regex)
[![CocoaPods](https://img.shields.io/cocoapods/p/Regex.svg?style=flat)](http://cocoadocs.org/docsets/Regex)
[![CocoaPods](https://img.shields.io/cocoapods/l/Regex.svg?style=flat)](http://cocoadocs.org/docsets/Regex)
[![GitHub tag](https://img.shields.io/github/tag/brynbellomy/Regex.svg?style=flat)]()

# install

Use [CocoaPods](https://cocoapods.org/).

Add to your `Podfile`:

```ruby
pod 'Regex'
```

And then run `pod install` from the shell:

```sh
$ pod install
```


# usage

### Simple use cases: `String` extension methods

**String.grep()**

This method is modeled after Javascript's `String.match()`.  It returns a `Regex.MatchResult` object.  The object's `captures` property is an array of `String`s much as one would expect from its Javascript equivalent.

```swift
let result = "Winnie the Pooh".grep("\\s+([a-z]+)\\s+")

result.searchString == "Winnie the Pooh"
result.captures.count == 2
result.captures[0] == " the "
result.captures[1] == "the"
result.boolValue == true       // `boolValue` is `true` if there were more than 0 matches

// You can use `grep()` in conditionals because of the `boolValue` property its result exposes
let emailAddress = "bryn&typos.org"
if !emailAddress.grep("@") {
    // that's not an email address!
}
```

**String.replaceRegex()**

This method is modeled after the version of Javascript's `String.replace()` that accepts a Regex parameter.  

```swift
let name = "Winnie the Pooh"
let darkName = name.replaceRegex("Winnie the ([a-zA-Z]+)", with: "Darth $1")
// darkName == "Darth Pooh"
```


### Advanced use cases: `Regex` object and operators

**operator =~**

You can use the `=~` operator to search a `String` (the left operand) for a `Regex` (the right operand).  It's the same as calling `theString.grep("the regex pattern")`, but might be more clear in some cases.  It returns the same `Regex.MatchResult` object as `String.grep()`.

```swift
"Winnie the Pooh" =~ Regex("\\s+(the)\\s+")  // returns a Regex.MatchResult
```

Quickly loop over a `Regex`'s captures:

```swift
for capture in ("Winnie the Pooh" =~ Regex("\\s+(the)\\s+")).captures {
    // capture is a String
}
```

# Overriden `map()` function for substitution

A more "functional programming" way of doing string replacement is possible via an override for `map()`.  In keeping with the overall aim to avoid reinventing a perfectly good wheel (i.e., `NSRegularExpression`), this function simply calls through to `NSRegularExpression.replaceMatchesInString()`.

```swift
func map (regexResult:Regex.MatchResult, replacementTemplate:String) -> String
```

You can use it like so:

```swift
let stageName = map("Winnie the Pooh" =~ Regex("([a-zA-Z]+)\\s+(the)(.*)"), "$2 $1")
// stageName == "the Winnie"
```

Or if you have some functional operators lying around (for example: <https://github.com/brynbellomy/Funky>), it's a little less wordy:

```swift
("Winnie the Pooh" =~ Regex("([a-zA-Z]+)\\s+(the)(.*)")) |> map‡("$2 $1")
```

... but you have to be as crazy as me to find that more readable than `"Winnie".replaceRegex(_:withString:)`, so no pressure.




# contributors / authors

- bryn austin bellomy (<bryn.bellomy@gmail.com>)
