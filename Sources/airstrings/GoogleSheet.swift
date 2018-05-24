///
/// @file airstrings:GoogleSheet.swift
/// @author Vadim Shpakovski.
/// @copyright © 2018 Farmers WIFE SL. All rights reserved.
///

import Foundation

/// Root JSON dictionary.
struct SheetRange: Decodable {

	/// Vertical or horizontal dimension for data.
	enum Dimension: String, Decodable {

		/// Server decides what’s best.
		case unspecified = "DIMENSION_UNSPECIFIED"

		/// Return array of row ranges.
		case rows = "ROWS"

		/// Return array of column ranges.
		case columns = "COLUMNS"
	}

	/// Requested range.
	let range: String

	/// Requested dimension.
	let majorDimension: Dimension

	private let _values: [SheetRow]
	private enum CodingKeys: String, CodingKey {
		case range
		case majorDimension
		case _values = "values"
	}

	/// Rows of key-value-comment strings.
	var values: [SheetRow] {
		return Array(_values.dropFirst())
	}
}

// MARK: -

/// Key-value-comment range from the Google Sheet.
struct SheetRow: Decodable {

	/// Localization key.
	let key: String

	/// Translated key.
	let value: String

	/// Optional comment.
	let comment: String?

	/// Creates a new entry from key, value and comment.
	///
	/// - Parameters:
	///   - key: Localization key.
	///   - value: Translated value.
	///   - comment: Optional comment.
	init(key: String, value: String, comment: String? = nil) {
		self.key = key
		self.value = value
		self.comment = comment
	}

	init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()
		key = try container.decode(String.self)
		value = try container.decode(String.self)
		comment = try container.decodeIfPresent(String.self)
	}
}

// MARK: -

extension SheetRow {

	/// Represented range as "key" = "value"; // comment.
	var asString: String {
		return "\"\(key)\" = \"\(value)\";\(comment.flatMap { " // " + $0 } ?? "")"
	}
}

// MARK: -

/// Information about tabs.
struct Spreadsheet: Decodable {

	/// General information about Google Sheet.
	struct Properties: Decodable {

		/// Spreadsheet title.
		let title: String

		/// Spreadsheet locale.
		let locale: String
	}

	/// Information about tab in the Google Sheet.
	struct Sheet: Decodable {

		/// Common information about one Tab.
		struct Properties: Decodable {

			/// Tab title.
			let title: String
		}

		/// Tab properties.
		let properties: Properties
	}

	/// Spreadsheet identifier.
	let spreadsheetId: String

	/// Spreadsheet web address.
	let spreadsheetUrl: String

	/// Spreadsheet properties.
	let properties: Properties

	/// Array of tabs in the Google Sheet.
	let sheets: [Sheet]
}

// MARK: -

extension String {

	/// Converts spaces in the sheet name into percent-escaped characters.
	func stringByAddingPercentEncodingForRFC3986() -> String {
		let unreserved = "-._~/?"
		var allowed = CharacterSet.alphanumerics
		allowed.formUnion(.init(charactersIn: unreserved))
		return addingPercentEncoding(withAllowedCharacters: allowed)!
	}
}
