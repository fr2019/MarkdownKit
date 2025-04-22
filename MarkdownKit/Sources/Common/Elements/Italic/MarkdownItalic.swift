//
//  MarkdownItalic.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//
import Foundation

open class MarkdownItalic: MarkdownCommonElement {
  // Modified regex to avoid matching underscores in URLs
  fileprivate static let regex = "(?<!\\]\\([^\\)]*)(.?|^)(\\*|_)(?=\\S)(.+?)(?<![\\*_\\s])(\\2)(?![^\\(]*\\))"

  open var font: MarkdownFont?
  open var color: MarkdownColor?

  open var regex: String {
    return MarkdownItalic.regex
  }

  public init(font: MarkdownFont? = nil, color: MarkdownColor? = nil) {
    self.font = font
    self.color = color
  }

  public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
    // Check if we're inside a URL before proceeding
    let fullRange = match.range
    let fullString = attributedString.string as NSString
    let matchText = fullString.substring(with: fullRange)

    // Skip if the match appears to be inside a URL
    if fullString.contains("[") && fullString.contains("](") && fullString.contains(")") {
      let before = fullString.substring(with: NSRange(location: 0, length: max(0, fullRange.location)))
      let after = fullString.substring(with: NSRange(location: fullRange.location + fullRange.length,
                                                     length: fullString.length - (fullRange.location + fullRange.length)))

      // Crude check if we're inside a URL part of a Markdown link
      if before.contains("[") && before.contains("](") && !before.contains(")") && after.contains(")") {
        return
      }
    }

    attributedString.deleteCharacters(in: match.range(at: 4))

    var attributes = self.attributes

    attributedString.enumerateAttribute(.font, in: match.range(at: 3)) { value, range, _ in
      guard let currentFont = value as? MarkdownFont else { return }
      if let customFont = self.font {
        attributes[.font] = currentFont.isBold() ? customFont.bold().italic() : customFont.italic()
      } else {
        attributedString.addAttribute(
          NSAttributedString.Key.font,
          value: currentFont.italic(),
          range: range
        )
      }
    }

    attributedString.addAttributes(attributes, range: match.range(at: 3))

    attributedString.deleteCharacters(in: match.range(at: 2))
  }
}
