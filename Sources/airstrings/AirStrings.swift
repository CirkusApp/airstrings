///
/// @file airstrings:AirStrings.swift
/// @author Vadim Shpakovski.
/// @copyright © 2018 Farmers WIFE SL. All rights reserved.
///

import Foundation
import SwiftCLI
import PathKit
import OAuthSwift
import AirSecrets

/// Namespace for constants.
enum AirStrings {

	/// Current version of the Package.
	static let version: String = "0.1"

	/// Binary name for the help contents.
	static let name: String = ProcessInfo.processInfo.processName

	/// App description for the help contents.
	static let shortDescription: String = "Air Strings -- export and import Localizable.strings"

	/// Google API keys.
	enum Google {

		/// The client key for Google Sheets API.
		static let clientId: String = GoogleSheets.clientIdentifier

		/// The client secret for Google Sheets API.
		static let clientSecret: String = GoogleSheets.clientSecret

		/// API endpoint for Google Sheets.
		static let sheetsEndpoint: String = "https://sheets.googleapis.com/v4/spreadsheets"

		/// File for saving the access token etc.
		static let credentialsFilename: Path = "google.credentials"
	}

	/// Parameters for saving access token.
	enum Library {

		/// Path to local folder ~/.airstrings for saving the token.
		static let directory: Path = .home + ".\(AirStrings.name)"
	}

	/// Custom errors.
	enum Error: Swift.Error {

		/// Parameter is missed or empty.
		case invalidParameter(name: String, message: String)

		/// Credentials are necessary for command.
		case missedCredentials(message: String)

		/// Google Sheet contents cannot be parsed.
		case invalidData(message: String)
	}
}
