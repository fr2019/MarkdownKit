//
//  MarkdownLink.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//
import Foundation

open class MarkdownLink: MarkdownLinkElement {
  // Regex ensures underscores and parentheses are captured correctly
  fileprivate static let regex = "\\[([^\\]]+)\\]\\(([^\\s\\)]*[^\\s\\)]+)\\)"
  private let schemeRegex = "([a-z]{2,20}):\\/\\/"
  open var font: MarkdownFont?
  open var color: MarkdownColor?
  open var defaultScheme: String?
  open var linkFontSize: CGFloat

  open var regex: String {
    return MarkdownLink.regex
  }

  open func regularExpression() throws -> NSRegularExpression {
    // This pattern specifically handles URLs that contain parentheses
    let pattern = "\\[([^\\]]+)\\]\\(((?:[^\\(\\)]|\\([^\\(\\)]*\\))*)\\)"
    return try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
  }

  public init(font: MarkdownFont? = nil,
              color: MarkdownColor? = MarkdownLink.defaultColor,
              linkFontSize: CGFloat = MarkdownLink.defaultFontSize) {
    self.font = font
    self.color = color
    self.linkFontSize = linkFontSize
  }

  open func formatText(_ attributedString: NSMutableAttributedString, range: NSRange, link: String) {
    let regex = try? NSRegularExpression(pattern: schemeRegex, options: .caseInsensitive)
    let hasScheme = regex?.firstMatch(
      in: link,
      options: .anchored,
      range: NSRange(location: 0, length: link.count)
    ) != nil

    let urlWithScheme = hasScheme ? link : "\(defaultScheme ?? "https://")\(link)"

    if let encodedURL = urlWithScheme.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
       let url = URL(string: encodedURL) {
      attributedString.addAttribute(NSAttributedString.Key.link, value: url, range: range)
    }
    else if let url = URL(string: urlWithScheme) {
      attributedString.addAttribute(NSAttributedString.Key.link, value: url, range: range)
    }
  }

  open func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
    let originalString = attributedString.string as NSString
    let fullRange = match.range

    guard match.numberOfRanges >= 3 else {
      return
    }

    let displayTextRange = match.range(at: 1)
    let urlRange = match.range(at: 2)

    guard displayTextRange.location != NSNotFound, urlRange.location != NSNotFound else {
      return
    }

    let displayText = originalString.substring(with: displayTextRange)
    let urlString = originalString.substring(with: urlRange)

    // Create replacement text with link
    let replacement = NSMutableAttributedString(string: displayText)
    addAttributes(replacement, range: NSRange(location: 0, length: replacement.length))
    formatText(replacement, range: NSRange(location: 0, length: replacement.length), link: urlString)

    // Replace only the matched link portion
    attributedString.replaceCharacters(in: fullRange, with: replacement)
  }

  open func addAttributes(_ attributedString: NSMutableAttributedString, range: NSRange) {
    attributedString.addAttributes(attributes, range: range)
    let baseFont = font ?? .systemFont(ofSize: linkFontSize)
    let resizedFont = baseFont.withSize(linkFontSize)
    attributedString.addAttribute(.font, value: resizedFont, range: range)
  }
}
