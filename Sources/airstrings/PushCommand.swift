///
/// @file airstrings:PushCommand.swift
/// @author Vadim Shpakovski.
/// @copyright © 2018 Farmers WIFE SL. All rights reserved.
///

import Foundation
import SwiftCLI
import PathKit

/// Reads Localizable.strings and uploads them into the Google Sheet.
class PushCommand: Command {

	let name: String = "push"
	let shortDescription: String = "Uploads localized strings to the Google Sheet"

	/// Local path to read strings from.
	let stringsPath: Key<String> = .init("-p", "--path", description: "Absolute or relative file name with localized strings")

	/// Google Sheet identifier copied from the address bar in Safari.
	let spreadsheetId: Key<String> = .init("-s", "--spreadsheetId", description: "Google Sheet document identifier from its URL")

	/// The name of tab in the Google Sheet.
	let tabName: Key<String> = .init("-t", "--tabName", description: "Tab name in the Google Sheet document")

	func execute() throws {

		// Validate command line arguments
		guard let stringsPath = stringsPath.value, stringsPath.hasSuffix(".strings") else {
			throw AirStrings.Error.invalidParameter(name: "path", message: "You must provide path with extension .strings")
		}
		guard let spreadsheetId = spreadsheetId.value, !spreadsheetId.isEmpty else {
			throw AirStrings.Error.invalidParameter(name: "spreadsheetId", message: "Sheet identifier is necessary for uploading localized strings")
		}
		guard let tabName = tabName.value, !tabName.isEmpty else {
			throw AirStrings.Error.invalidParameter(name: "tabName", message: "Tab name is necessary for pushing localized strings")
		}
		verboseOutput <<< "Fetching \(tabName) from \(spreadsheetId)…"

		// Read naïve strings from the argument file
		verboseOutput <<< "Reading strings from \(Path(stringsPath).absolute())…"
		let contents: String = try Path(stringsPath).absolute().read()
		var sheetRows: [SheetRow] = contents.split(separator: "\n").compactMap {
			var line = $0

			// Extract comment
			var comment: String?
			if let commentRange = line.range(of: "\";\\s*//", options: .regularExpression)  {
				comment = line.suffix(from: commentRange.upperBound).trimmingCharacters(in: .whitespaces)
			} else {
				verboseOutput <<< "Comment is missed in \(line)"
			}

			// Exclude comment from the rest of the line
			if let lineRange = line.range(of: "\";")  {
				line = line.prefix(upTo: lineRange.upperBound)
			} else {
				standardOutput <<< "Value in \(line) doesn’t have a terminating semicolon"
				return nil
			}

			// Extract key and value
			guard let assignRange = line.range(of: "=") else {
				standardOutput <<< "Assignment character is missed in \(line)"
				return nil
			}

			// Cleanup localization key
			var key = line.prefix(upTo: assignRange.lowerBound).trimmingCharacters(in: .whitespaces)
			guard key.hasPrefix("\""), key.hasSuffix("\"") else {
				standardOutput <<< "Key in \(line) is not a valid string"
				return nil
			}
			key.removeFirst()
			key.removeLast()

			// Cleanup translation
			var value = line.suffix(from: assignRange.upperBound).trimmingCharacters(in: .whitespaces)
			guard value.hasPrefix("\""), value.hasSuffix("\";") else {
				standardOutput <<< "Value in \(line) is not a valid string or doesn’t have a terminating semicolon"
				return nil
			}
			value.removeFirst()
			value.removeLast()
			value.removeLast()

			return .init(key: key, value: value, comment: comment)
		}

		// Quit if the .strings file is empty
		guard sheetRows.count > 0 else {
			throw AirStrings.Error.invalidData(message: "File with strings does not have any key-value entries")
		}
		verboseOutput <<< "\(sheetRows.count) item\(sheetRows.count == 1 ? " was" : "s were") found"

		// Fetch spreadsheet information
		let fetchSpreadheetUrlString = "\(AirStrings.Google.sheetsEndpoint)/\(spreadsheetId)"
		verboseOutput <<< "Downloading Google Sheet information from \(fetchSpreadheetUrlString)"
		let response = try syncGoogleRequest { client, success, failure in
			_ = client.get(fetchSpreadheetUrlString, parameters: ["includeGridData": "false"], success: success, failure: failure)
		}
		verboseOutput <<< "Parsing downloaded Google Sheet…"
		let spreadsheet = try JSONDecoder().decode(Spreadsheet.self, from: response.data)

		// Find out if the tab with the same name is already existing
		if spreadsheet.sheets.contains(where: { $0.properties.title == tabName }) {

			// Ask user permission to rewrite data in existing Tab
			standardOutput <<< "The tab “\(tabName)” already exists, replace data? y/n"
			guard Input.readBool() else {
				return
			}

			// Clear data before adding strings
			let clearTabUrlString = "\(AirStrings.Google.sheetsEndpoint)/\(spreadsheetId)/values/\(tabName.stringByAddingPercentEncodingForRFC3986()):clear"
			verboseOutput <<< "Removing data in the tab at \(clearTabUrlString)…"
			_ = try syncGoogleRequest { client, success, failure in
				_ = client.post(clearTabUrlString, success: success, failure: failure)
			}

		} else {

			// Create new tab with the given name
			let addTabUrlString = "\(AirStrings.Google.sheetsEndpoint)/\(spreadsheetId):batchUpdate"
			let json = ["requests": [["addSheet": ["properties": ["title": tabName]]]]]
			verboseOutput <<< "Adding a new tab at \(addTabUrlString) using \(json)…"
			let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
			_ = try syncGoogleRequest { client, success, failure in
				_ = client.post(addTabUrlString, headers: ["Content-Type": "application/json"], body: jsonData, success: success, failure: failure)
			}
		}

		// Insert "Key"-"Value"-"Comment" as the first row and build JSON with data
		sheetRows.insert(SheetRow(key: "Localization Key", value: "Translation", comment: "Optional Comment"), at: 0)
		let values = sheetRows.map { sheetRow -> [String] in
			var keyValue = [sheetRow.key, sheetRow.value]
			if let comment = sheetRow.comment, comment.count > 0 {
				keyValue.append(comment)
			}
			return keyValue
		}
		let json: [String: Any] = ["majorDimension": "ROWS", "values": values]
		let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])

		// Upload strings to the Google Sheet
		let urlString = "\(AirStrings.Google.sheetsEndpoint)/\(spreadsheetId)/values/\(tabName.stringByAddingPercentEncodingForRFC3986())?includeValuesInResponse=false&valueInputOption=RAW"
		verboseOutput <<< "Uploading strings at \(urlString)"
		_ = try syncGoogleRequest { client, success, failure in
			_ = client.put(urlString, headers: ["Content-Type": "application/json"], body: jsonData, success: success, failure: failure)
		}
		standardOutput <<< "\(sheetRows.count) item\(sheetRows.count == 1 ? " was" : "s were") successfully uploaded at \(spreadsheet.spreadsheetUrl)"
	}
}
