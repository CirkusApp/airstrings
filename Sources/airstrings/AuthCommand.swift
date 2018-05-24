///
/// @file airstrings:AuthCommand.swift
/// @author Vadim Shpakovski.
/// @copyright © 2018 Farmers WIFE SL. All rights reserved.
///

import Foundation
import SwiftCLI
import PathKit
import OAuthSwift

/// Asks for Google Sheets access by launching Safari.
class AuthCommand: Command {
	
	let name: String = "auth"
	let shortDescription: String = "Manages an access token for Google Sheets"

	/// Provide this flag to remove the token saved before.
	let clean: Flag = .init("-e", "--erase", description: "Erases access token for Google Sheets")

	func execute() throws {

		// Remove cached credentials when --erase is passed as argument
		let credentialsDirectory = AirStrings.Library.directory
		let credentialsPath = credentialsDirectory + AirStrings.Google.credentialsFilename
		if clean.value {
			if credentialsPath.exists {
				verboseOutput <<< "Deleting credentials from \(credentialsPath)"
				try credentialsPath.delete()
				verboseOutput <<< "Credentials for Google Sheets were removed"
			} else {
				verboseOutput <<< "There were no credentials at \(credentialsPath)"
			}
			return
		}

		// Print cached credentials if they’re available
		verboseOutput <<< "Reading credentials from \(credentialsPath)"
		if let googleCredential = try? googleCredential() {
			standardOutput <<< "Current credentials have a token \(googleCredential.oauthToken)"
			return
		}

		// Ask customer to generate cached token if it’s not available
		standardOutput <<< "Generate access code for Google Sheets? y/n"
		guard Input.readBool() else {
			return
		}

		// Use macOS browser to request access code from Google
		verboseOutput <<< "Launching Google in desktop browser…"
		let oauth = OAuth2Swift(consumerKey: AirStrings.Google.clientId, consumerSecret: AirStrings.Google.clientSecret, authorizeUrl: "https://accounts.google.com/o/oauth2/v2/auth", accessTokenUrl: "https://www.googleapis.com/oauth2/v4/token?redirect_uri=urn:ietf:wg:oauth:2.0:oob", responseType: "code")
		oauth.authorize(withCallbackURL: "urn:ietf:wg:oauth:2.0:oob", scope: "https://www.googleapis.com/auth/spreadsheets", state: "", success: { _, _, _ in }, failure: { _ in })

		// Verify that access token is pasted into the console
		standardOutput <<< "Insert token here: "
		let deviceToken = Input.readLine()
		guard deviceToken.count > 0 else {
			return
		}

		// Use access code to request access credentials from Google
		verboseOutput <<< "Trying to request credentials from Google…"
		let runLoop = CFRunLoopGetCurrent()
		oauth.authorize(deviceToken: deviceToken, grantType: "authorization_code", success: { [weak self] newCredential in

			let newCredentialsData = NSKeyedArchiver.archivedData(withRootObject: newCredential)
			do {
				// Save the access token locally at ~/.airstrings/access_token.txt
				try credentialsDirectory.mkpath()
				try credentialsPath.write(newCredentialsData)

				self?.standardOutput <<< "Access code is saved"
			} catch {
				self?.errorOutput <<< "Cannot save credentials: \(error.localizedDescription)"
			}

			CFRunLoopStop(runLoop)
		}, failure: { [weak self] error in
			self?.errorOutput <<< "Cannot access credentials: \(error.localizedDescription)"
			CFRunLoopStop(runLoop)
		})
		CFRunLoopRun()
	}
}
