//
//  MarkdownAutomaticLink.swift
//  Pods
//
//  Created by Ivan Bruel on 19/07/16.
//
//
import Foundation

open class MarkdownAutomaticLink: MarkdownLink {
  override open func regularExpression() throws -> NSRegularExpression {
    return try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
  }

  override open func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
    let originalString = attributedString.string as NSString
    let matchRange = match.range

    // Skip if the match is within an explicit markdown link (e.g., [text](url))
    let precedingText = originalString.substring(to: matchRange.location)
    if precedingText.contains("[") && precedingText.contains("](") {
      return // Avoid processing explicit links
    }

    let linkURLString = originalString.substring(with: matchRange)
    formatText(attributedString, range: matchRange, link: linkURLString)
    addAttributes(attributedString, range: matchRange)
  }
}
