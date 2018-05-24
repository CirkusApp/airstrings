///
/// @file airstrings:PullCommand.swift
/// @author Vadim Shpakovski.
/// @copyright © 2018 Farmers WIFE SL. All rights reserved.
///

import Foundation
import SwiftCLI
import PathKit

/// Downloads translations from the Google Sheet and writes them into Localizable.strings.
class PullCommand: Command {

	let name: String = "pull"
	let shortDescription: String = "Downloads localized strings from the Google Sheet"

	/// Google Sheet identifier copied from the address bar in Safari.
	let spreadsheetId: Key<String> = .init("-s", "--spreadsheetId", description: "Google Sheet document identifier from its URL")

	/// The name of tab in the Google Sheet.
	let tabName: Key<String> = .init("-t", "--tabName", description: "Tab name in the Google Sheet document")

	/// Local path to save downloaded strings.
	let stringsPath: Key<String> = .init("-p", "--path", description: "Absolute or relative file name to save localized strings")

	func execute() throws {

		// Validate command line arguments
		guard let spreadsheetId = spreadsheetId.value, !spreadsheetId.isEmpty else {
			throw AirStringsError.invalidParameter(name: "spreadsheetId", message: "Sheet identifier is necessary for pulling localized strings")
		}
		guard let tabName = tabName.value, !tabName.isEmpty else {
			throw AirStringsError.invalidParameter(name: "tabName", message: "Tab name is necessary for pulling localized strings")
		}
		guard let stringsPath = stringsPath.value, stringsPath.hasSuffix(".strings") else {
			throw AirStringsError.invalidParameter(name: "path", message: "You must provide path with extension .strings")
		}
		verboseOutput <<< "Fetching \(tabName) from \(spreadsheetId)…"

		// Download localized strings
		let urlString = "\(AirStrings.Google.sheetsEndpoint)/\(spreadsheetId)/values/\(tabName.stringByAddingPercentEncodingForRFC3986())"
		verboseOutput <<< "Downloading strings from \(urlString)"
		let response = try syncGoogleRequest { client, success, failure in
			_ = client.get(urlString, parameters: ["majorDimension": "ROWS", "valueRenderOption": "UNFORMATTED_VALUE"], success: success, failure: failure)
		}

		// Parse Google Sheet contents
		verboseOutput <<< "Parsing downloaded strings…"
		let values = try JSONDecoder().decode(SheetRange.self, from: response.data).values
		let contents = values.map { $0.asString }.joined(separator: "\n")

		// Write result as .strings
		verboseOutput <<< "Saving strings file…"
		let contentsPath = Path(stringsPath).absolute()
		try contentsPath.parent().mkpath()
		try contentsPath.write(contents + "\n")
		standardOutput <<< "\(values.count) item\(values.count == 1 ? " is" : "s are") saved at \(contentsPath.url)"
	}
}
