import Foundation

public struct RegularExpression: Hashable {

	public struct Options: OptionSet {

		public var rawValue: UInt
		
		public static let caseInsensitive = Self(nsOptions: .caseInsensitive)
		public static let allowCommentsAndWhitespace = Self(nsOptions: .allowCommentsAndWhitespace)
		public static var ignoreMetacharacters = Self(nsOptions: .ignoreMetacharacters)
		public static var dotMatchesLineSeparators = Self(nsOptions: .dotMatchesLineSeparators)
		public static var anchorsMatchLines = Self(nsOptions: .anchorsMatchLines)
		public static var useUnixLineSeparators = Self(nsOptions: .useUnixLineSeparators)
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

	public struct MatchingOptions: OptionSet {

		public var rawValue: UInt

		public static var reportProgress = Self(nsOptions: .reportProgress)

		public static var reportCompletion = Self(nsOptions: .reportCompletion)

		public static var anchored = Self(nsOptions: .anchored)

		public static var withTransparentBounds = Self(nsOptions: .withTransparentBounds)

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

	public struct MatchingFlags: OptionSet {

		public var rawValue: UInt

		public static var progress = Self(nsFlags: .progress)
		public static var completed = Self(nsFlags: .completed)
		public static var hitEnd = Self(nsFlags: .hitEnd)
		public static var requiredEnd = Self(nsFlags: .requiredEnd)
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

	public struct Match {

		fileprivate let textCheckingResult: NSTextCheckingResult

		// Needed to convert NSRange into Range<String.Index>.
		private let _string: String

		public var range: Range<String.Index> {
			return Range(textCheckingResult.range, in: _string)!
		}

		public var rangeCount: Int {
			return textCheckingResult.numberOfRanges
		}

		public func range(at index: Int) -> Range<String.Index> {
			return Range(textCheckingResult.range(at: index), in: _string)!
		}

		@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, macCatalyst 13.0, *)
		public func range(withName name: String) -> Range<String.Index>? {
			return Range(textCheckingResult.range(withName: name), in: _string)
		}

		public var regularExpression: RegularExpression {
			return RegularExpression(textCheckingResult.regularExpression!)
		}

		public func adjustingRanges(offset: Int) -> Self {
			return Self(textCheckingResult: textCheckingResult.adjustingRanges(offset: offset), in: _string)
		}

		fileprivate init(textCheckingResult: NSTextCheckingResult, in string: String) {
			assert(textCheckingResult.resultType == .regularExpression)
			self.textCheckingResult = textCheckingResult
			_string = string
		}

		public subscript(_ index: Int) -> Substring {
			return _string[range(at: index)]
		}

		@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, macCatalyst 13.0, *)
		public subscript(_ name: String) -> Substring? {
			guard let range = range(withName: name) else { return nil }
			return _string[range]
		}

	}

	public let nsRegularExpression: NSRegularExpression

	public var pattern: String {
		return nsRegularExpression.pattern
	}

	public var options: Options {
		return Options(nsOptions: nsRegularExpression.options)
	}

	public var captureGroupCount: Int {
		return nsRegularExpression.numberOfCaptureGroups
	}

	public init(pattern: String, options: Options = []) throws {
		nsRegularExpression = try NSRegularExpression(pattern: pattern, options: options.nsOptions)
	}

	public init(_ nsRegex: NSRegularExpression) {
		nsRegularExpression = nsRegex
	}

}

public extension RegularExpression {

	func numberOfMatches(in string: String, options: MatchingOptions = [], range: Range<String.Index>? = nil) -> Int {
		let nsRange = NSRange(range, in: string)
		return nsRegularExpression.numberOfMatches(in: string, options: options.nsOptions, range: nsRange)
	}

	func enumerateMatches(in string: String, options: MatchingOptions = [], range: Range<String.Index>? = nil, using block: (Match?, MatchingFlags, inout Bool) -> Void) {
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

	func matches(in string: String, options: MatchingOptions = [], range: Range<String.Index>? = nil) -> [Match] {
		let results = nsRegularExpression.matches(in: string, options: options.nsOptions, range: NSRange(range, in: string))
		return results.map { Match(textCheckingResult: $0, in: string) }
	}

	func firstMatch(in string: String, options: MatchingOptions = [], range: Range<String.Index>? = nil) -> Match? {
		guard let result = nsRegularExpression.firstMatch(in: string, options: options.nsOptions, range: NSRange(range, in: string)) else {
			return nil
		}

		return Match(textCheckingResult: result, in: string)
	}

	func rangeOfFirstMatch(in string: String, options: MatchingOptions = [], range: Range<String.Index>? = nil) -> Range<String.Index>? {
		let nsRange = nsRegularExpression.rangeOfFirstMatch(in: string, options: options.nsOptions, range: NSRange(range, in: string))
		return Range(nsRange, in: string)
	}

}

public extension RegularExpression {

	@discardableResult
	func replaceMatches(in string: inout String, options: MatchingOptions = [], range: Range<String.Index>? = nil, withTemplate template: String) -> Int {
		let mutableString = NSMutableString(string: string)

		let result = nsRegularExpression.replaceMatches(in: mutableString, options: options.nsOptions, range: NSRange(range, in: string), withTemplate: template)

		string = String(mutableString)

		return result
	}

	func replacingMatches(in string: String, options: MatchingOptions = [], range: Range<String.Index>? = nil, withTemplate template: String) -> String {
		return nsRegularExpression.stringByReplacingMatches(in: string, options: options.nsOptions, range: NSRange(range, in: string), withTemplate: template)
	}

}

public extension RegularExpression {

	func replacementString(for match: Match, in string: String, offset: Int, template: String) -> String {
		return nsRegularExpression.replacementString(for: match.textCheckingResult, in: string, offset: offset, template: template)
	}

}

public extension RegularExpression {

	func escapedTemplate(for string: String) -> String {
		return NSRegularExpression.escapedTemplate(for: string)
	}

	func escapedPattern(for string: String) -> String {
		return NSRegularExpression.escapedPattern(for: string)
	}

}

public extension RegularExpression {

	static func ~= (lhs: RegularExpression, rhs: String) -> Bool {
		return lhs.rangeOfFirstMatch(in: rhs) != nil
	}

}

extension RegularExpression: ExpressibleByStringLiteral {

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
	///   - region: The range to convert. If `nil`, will use the entire string.
	///   - string: The string from which to convert.
	init<R: RangeExpression, S: StringProtocol>(_ region: R?, in string: S) where R.Bound == String.Index {
		if let region = region {
			self.init(region, in: string)
		} else {
			self.init(string.startIndex..<string.endIndex, in: string)
		}
	}

}
