import Foundation

public struct RegularExpression: Hashable {

	/// These constants define the regular expression options.
	///
	/// These constants are used by the property `options` and `init(pattern:options:)`.
	public struct Options: OptionSet {

		public var rawValue: UInt

		/// Match letters in the pattern independent of case.
		public static let caseInsensitive = Self(nsOptions: .caseInsensitive)

		/// Ignore whitespace and #-prefixed comments in the pattern.
		public static let allowCommentsAndWhitespace = Self(nsOptions: .allowCommentsAndWhitespace)

		/// Treat the entire pattern as a literal string.
		public static var ignoreMetacharacters = Self(nsOptions: .ignoreMetacharacters)

		/// Allow `.` to match any character, including line separators.
		public static var dotMatchesLineSeparators = Self(nsOptions: .dotMatchesLineSeparators)

		/// Allow `^` and `$` to match the start and end of lines.
		public static var anchorsMatchLines = Self(nsOptions: .anchorsMatchLines)

		/// Treat only `\n` as a line separator (otherwise, all standard line separators are used).
		public static var useUnixLineSeparators = Self(nsOptions: .useUnixLineSeparators)

		/// Use Unicode TR#29 to specify word boundaries (otherwise, traditional regular expression
		/// word boundaries are used).
		public static var useUnicodeWordBoundaries = Self(nsOptions: .useUnicodeWordBoundaries)

		public init(rawValue: UInt) {
			self.rawValue = rawValue
		}

		fileprivate init(nsOptions: NSRegularExpression.Options) {
			self.rawValue = nsOptions.rawValue
		}

		fileprivate var nsOptions: NSRegularExpression.Options {
			return NSRegularExpression.Options(rawValue: rawValue)
		}

	}

	/// The matching options constants specify the reporting, completion and matching rules to the
	/// expression matching methods.
	///
	/// These constants are used by all methods that search for, or replace values, using a regular expression.
	public struct MatchingOptions: OptionSet {

		public var rawValue: UInt

		/// Call the Block periodically during long-running match operations.
		/// This option has no effect for methods other than `enumerateMatches(in:options:range:using:)`.
		///
		/// See `NSRegularExpression.enumerateMatches(in:options:range:using:)` for a description of the constant in context.
		public static var reportProgress = Self(nsOptions: .reportProgress)

		/// Call the Block once after the completion of any matching. This option has no effect
		/// for methods other than `enumerateMatches(in:options:range:using:)`.
		///
		/// See `NSRegularExpression.enumerateMatches(in:options:range:using:)` for a description of the constant in context.
		public static var reportCompletion = Self(nsOptions: .reportCompletion)

		/// Specifies that matches are limited to those at the start of the search range.
		///
		/// See `NSRegularExpression.enumerateMatches(in:options:range:using:)` for a description of the constant in context.
		public static var anchored = Self(nsOptions: .anchored)

		/// Specifies that matching may examine parts of the string beyond the bounds of the search range,
		/// for purposes such as word boundary detection, lookahead, etc.
		/// This constant has no effect if the search range contains the entire string.
		///
		/// See `NSRegularExpression.enumerateMatches(in:options:range:using:)` for a description of the constant in context.
		public static var withTransparentBounds = Self(nsOptions: .withTransparentBounds)

		/// Specifies that `^` and `$` will not automatically match the beginning and end of the search range,
		/// but will still match the beginning and end of the entire string. This constant has no effect
		/// if the search range contains the entire string.
		///
		/// See `NSRegularExpression.enumerateMatches(in:options:range:using:)` for a description of the constant in context.
		public static var withoutAnchoringBounds = Self(nsOptions: .withoutAnchoringBounds)

		public init(rawValue: UInt) {
			self.rawValue = rawValue
		}

		fileprivate init(nsOptions: NSRegularExpression.MatchingOptions) {
			self.rawValue = nsOptions.rawValue
		}

		fileprivate var nsOptions: NSRegularExpression.MatchingOptions {
			return NSRegularExpression.MatchingOptions(rawValue: rawValue)
		}

	}

	/// Set by the Block as the matching progresses, completes, or fails.
	///
	/// Used by the method `enumerateMatches(in:options:range:using:)`.
	public struct MatchingFlags: OptionSet {

		public var rawValue: UInt

		/// Set when the Block is called to report progress during a long-running match operation.
		public static var progress = Self(nsFlags: .progress)

		///Set when the Block is called after matching has completed.
		public static var completed = Self(nsFlags: .completed)

		/// Set when the current match operation reached the end of the search range.
		public static var hitEnd = Self(nsFlags: .hitEnd)

		/// Set when the current match depended on the location of the end of the search range.
		public static var requiredEnd = Self(nsFlags: .requiredEnd)

		/// Set when matching failed due to an internal error.
		public static var internalError = Self(nsFlags: .internalError)

		public init(rawValue: UInt) {
			self.rawValue = rawValue
		}

		fileprivate init(nsFlags: NSRegularExpression.MatchingFlags) {
			self.rawValue = nsFlags.rawValue
		}

		fileprivate var nsFlags: NSRegularExpression.MatchingFlags {
			return NSRegularExpression.MatchingFlags(rawValue: rawValue)
		}

	}

	/// A regular expression match.
	public struct Match {

		fileprivate let textCheckingResult: NSTextCheckingResult

		// Needed to convert NSRange into Range<String.Index>.
		private let _string: String

		/// The range of the result that the receiver represents.
		public var range: Range<String.Index> {
			return Range(textCheckingResult.range, in: _string)!
		}

		/// The number of ranges.
		public var rangeCount: Int {
			return textCheckingResult.numberOfRanges
		}

		@available(*, unavailable, message: "Use rangeCount instead.")
		public var numberOfRanges: Int {
			return 0
		}

		/// The range at the specified index. The range at index `0` is always equal to `range`.
		/// Additional ranges, if any, will have indexes from `1` to `rangeCount - 1`.
		public func range(at index: Int) -> Range<String.Index> {
			return Range(textCheckingResult.range(at: index), in: _string)!
		}

		/// The range of the capture group with the specified name. If no range with the name exists, `nil`.
		@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, macCatalyst 13.0, *)
		public func range(withName name: String) -> Range<String.Index>? {
			return Range(textCheckingResult.range(withName: name), in: _string)
		}

		/// The regular expression for this match.
		public var regularExpression: RegularExpression {
			return RegularExpression(textCheckingResult.regularExpression!)
		}

		/// Returns a match after adjusting the ranges as specified by the offset.
		/// - Parameter offset: The amount the ranges are adjusted.
		/// - Returns: A new `Match` instance with the adjusted range or ranges.
		public func adjustingRanges(offset: Int) -> Self {
			return Self(textCheckingResult: textCheckingResult.adjustingRanges(offset: offset), in: _string)
		}

		/// Initialize a `Match` from an `NSTextCheckingResult`.
		fileprivate init(textCheckingResult: NSTextCheckingResult, in string: String) {
			assert(textCheckingResult.resultType == .regularExpression)
			self.textCheckingResult = textCheckingResult
			_string = string
		}

		/// The matched text for the specified numbered capture group. Index `0` will return the full match text.
		public subscript(_ index: Int) -> Substring {
			return _string[range(at: index)]
		}

		/// The matched text for the specified named capture group.
		@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, macCatalyst 13.0, *)
		public subscript(_ name: String) -> Substring? {
			guard let range = range(withName: name) else { return nil }
			return _string[range]
		}

	}

	/// The underlying `NSRegularExpression`.
	public let nsRegularExpression: NSRegularExpression

	/// The regular expression's pattern.
	public var pattern: String {
		return nsRegularExpression.pattern
	}

	/// The regular expression's options.
	public var options: Options {
		return Options(nsOptions: nsRegularExpression.options)
	}

	/// The number of capture groups.
	public var captureGroupCount: Int {
		return nsRegularExpression.numberOfCaptureGroups
	}

	@available(*, unavailable, message: "Use captureGroupCount instead.")
	public var numberOfCaptureGroups: Int {
		return 0
	}

	/// Initialize a regular expression with the specified pattern and options.
	/// - Parameters:
	///   - pattern: The pattern.
	///   - options: The options. See `RegularExpression.Options` for possible values.
	/// - Throws: An error if `pattern` is invalid.
	public init(pattern: String, options: Options = []) throws {
		nsRegularExpression = try NSRegularExpression(pattern: pattern, options: options.nsOptions)
	}

	/// Initialize a `RegularExpression` from an `NSRegularExpression`.
	public init(_ nsRegex: NSRegularExpression) {
		nsRegularExpression = nsRegex
	}

}

public extension RegularExpression {

	/// Retrieve the number of matches in a specified range of a string.
	/// - Parameters:
	///   - string: The string to match.
	///   - options: The matching ptions to use. See `RegularExpression.MatchingOptions` for possible values.
	///   - range: The range of the string to match within. Passing `nil` will use the range of the entire string.
	/// - Returns: The number of matches.
	func numberOfMatches(in string: String, options: MatchingOptions = [], range: Range<String.Index>? = nil) -> Int {
		let nsRange = NSRange(range, in: string)
		return nsRegularExpression.numberOfMatches(in: string, options: options.nsOptions, range: nsRange)
	}

	/// Enumerates the string allowing the Block to handle each regular expression match.
	/// - Parameters:
	///   - string: The string to match against.
	///   - options: The matching options to report. See `RegularExpression.MatchingOptions` for possible values.
	///   - range: The range of the string to match within. Passing `nil` willuse the range of the entire string.
	///   - block: The block enumerates the matches of the in the string.
	///   - match: The regular expression match.
	///   - flags: The current state of the matching progress. See `RegularExpression.MatchingFlags` for the possible values.
	///   - stop: An `inout` `Boolean` value. The block can set the value to true to stop further processing of the array.
	///     The stop argument is an out-only argument. You should only ever set this Boolean to true within the Block.
	func enumerateMatches(in string: String, options: MatchingOptions = [], range: Range<String.Index>? = nil, using block: (_ match: Match?, _ flags: MatchingFlags, _ stop: inout Bool) -> Void) {
		nsRegularExpression.enumerateMatches(in: string, options: options.nsOptions, range: NSRange(range, in: string)) { (result, flags, stop) in
			var swiftStop = false

			var match: Match? = nil

			if let result = result {
				match = Match(textCheckingResult: result, in: string)
			}

			block(match, MatchingFlags(nsFlags: flags), &swiftStop)

			stop.pointee = ObjCBool(swiftStop)
		}
	}

	/// Get all the matches of the regular expression in the string.
	/// - Parameters:
	///   - string: The string to match against.
	///   - options: The matching options to use. See `RegularExpression.MatchingOptions` for possible values.
	///   - range: The range of the string to match within. Passing `nil` will use the range of the entire string.
	/// - Returns: An array of `Match` structures.
	func matches(in string: String, options: MatchingOptions = [], range: Range<String.Index>? = nil) -> [Match] {
		let results = nsRegularExpression.matches(in: string, options: options.nsOptions, range: NSRange(range, in: string))
		return results.map { Match(textCheckingResult: $0, in: string) }
	}

	/// Get the first match of the regular expression within the specified range of the string.
	/// - Parameters:
	///   - string: The string to match against.
	///   - options: The matching options to use. See `RegularExpression.MatchingOptions` for possible values.
	///   - range: The range of the string to match within. Passing `nil` will use the range of the entire string.
	/// - Returns: A `Match` structure describing the first match.
	func firstMatch(in string: String, options: MatchingOptions = [], range: Range<String.Index>? = nil) -> Match? {
		guard let result = nsRegularExpression.firstMatch(in: string, options: options.nsOptions, range: NSRange(range, in: string)) else {
			return nil
		}

		return Match(textCheckingResult: result, in: string)
	}

	/// Get the range of the first match of the regular expression within the specified range of the string.
	/// - Parameters:
	///   - string: The string to match against.
	///   - options: The matching options to use. See `RegularExpression.MatchingOptions` for possible values.
	///   - range: The range of the string to match within. Passing `nil` will use the range of the entire string.
	/// - Returns: The range of the first match. Returns `nil` if no match is found.
	func rangeOfFirstMatch(in string: String, options: MatchingOptions = [], range: Range<String.Index>? = nil) -> Range<String.Index>? {
		let nsRange = nsRegularExpression.rangeOfFirstMatch(in: string, options: options.nsOptions, range: NSRange(range, in: string))
		return Range(nsRange, in: string)
	}

}

public extension RegularExpression {

	/// Replaces regular expression matches within the `inout` string using the template string.
	/// - Parameters:
	///   - string: The string to match against.
	///   - options: The matching options to use. See `RegularExpression.MatchingOptions` for possible values.
	///   - range: The range of the string to search. Passing `nil` will use the range of the entire string.
	///   - template: The substitution template used when replacing matching instances.
	/// - Returns: The number of matches.
	@discardableResult
	func replaceMatches(in string: inout String, options: MatchingOptions = [], range: Range<String.Index>? = nil, withTemplate template: String) -> Int {
		let mutableString = NSMutableString(string: string)

		let result = nsRegularExpression.replaceMatches(in: mutableString, options: options.nsOptions, range: NSRange(range, in: string), withTemplate: template)

		string = String(mutableString)

		return result
	}

	/// Returns a new string containing matching regular expressions replaced with the template string.
	/// - Parameters:
	///   - string: The string to match against.
	///   - options: The matching options to use. See `RegularExpression.MatchingOptions` for possible values.
	///   - range: The range of the string to search. Passing `nil` will use the range of the entire string.
	///   - template: The substitution template used when replacing matching instances.
	/// - Returns: A string with matching regular expressions replaced by the template string.
	func replacingMatches(in string: String, options: MatchingOptions = [], range: Range<String.Index>? = nil, withTemplate template: String) -> String {
		return nsRegularExpression.stringByReplacingMatches(in: string, options: options.nsOptions, range: NSRange(range, in: string), withTemplate: template)
	}

}

public extension RegularExpression {

	/// Used to perform template substitution for a single result for clients implementing their own replace functionality.
	/// - Parameters:
	///   - match: The result of the single match.
	///   - string: The string from which the result was matched.
	///   - offset: The offset to be added to the location of the result in the string.
	///   - template: The substitution template used when replacing matching instances.
	/// - Returns: A replacement string.
	func replacementString(for match: Match, in string: String, offset: Int, template: String) -> String {
		return nsRegularExpression.replacementString(for: match.textCheckingResult, in: string, offset: offset, template: template)
	}

}

public extension RegularExpression {

	/// Returns a template string by adding backslash escapes as necessary to protect any characters
	/// that would match as pattern metacharacters.
	/// - Parameter string: The template string.
	/// - Returns: The escaped template string.
	static func escapedTemplate(for string: String) -> String {
		return NSRegularExpression.escapedTemplate(for: string)
	}

	/// Returns a string by adding backslash escapes as necessary to protect any characters that would match as pattern metacharacters.
	/// - Parameter string: The string.
	/// - Returns: The escaped string.
	static func escapedPattern(for string: String) -> String {
		return NSRegularExpression.escapedPattern(for: string)
	}

}

public extension RegularExpression {

	/// Returns a `Boolean` value indicating whether a string matches a regular expression.
	static func ~= (lhs: RegularExpression, rhs: String) -> Bool {
		return lhs.rangeOfFirstMatch(in: rhs) != nil
	}

}

extension RegularExpression: ExpressibleByStringLiteral {

	/// Initializes a regular expression from a string literal.
	///
	/// An invalid regular expression pattern will cause a fatal runtime error.
	public init(stringLiteral value: String) {
		self = try! Self.init(pattern: value)
	}

}

extension RegularExpression: Codable {

	private enum CodingKeys: CodingKey {
		case pattern
		case options
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(pattern, forKey: .pattern)
		try container.encode(options.rawValue, forKey: .options)
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let pattern = try container.decode(String.self, forKey: .pattern)
		let options = try Options(rawValue: container.decode(UInt.self, forKey: .options))
		try self.init(pattern: pattern, options: options)
	}

}

extension RegularExpression.Match: CustomStringConvertible {

	public var description: String {
		return String(self[0])
	}

}

fileprivate extension NSRange {

	/// Initialize an `NSRange` from a Swift `RangeExpression` and a `String`.
	///
	/// - Parameters:
	///   - region: The range to convert. If `nil`, will use the range of the entire string.
	///   - string: The string from which to convert.
	init<R: RangeExpression, S: StringProtocol>(_ region: R?, in string: S) where R.Bound == String.Index {
		if let region = region {
			self.init(region, in: string)
		} else {
			self.init(string.startIndex..<string.endIndex, in: string)
		}
	}

}
