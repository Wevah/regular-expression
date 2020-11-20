# RegularExpression

A Swifty overlay of `NSRegularExpression`.

Conforms to `ExpressibleByStringLiteral` and `Codable`, and supports pattern matching.

Most methods are similar to the Objective-C versions, with the following changes:

- Custom `Match` type for matches.
- Passing `nil` for a range parameter will use the whole string.
- Ranges for invalid/missing ranges will be `nil` instead of `{NSNotFound, 0}`.

`Match` type is subscriptable by `Int` (for numbered capture groups) or by `String` (for named capture groups), returning the substring with the match text (vs. the `range` methods).

---

© 2020 Nate Weaver
