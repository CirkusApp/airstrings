///
/// @file airstrings:Command+Additions.swift
/// @author Vadim Shpakovski.
/// @copyright © 2018 Farmers WIFE SL. All rights reserved.
///

import Foundation
import SwiftCLI
import OAuthSwift
import PathKit

enum Verbose {

	/// Shared flag for all commands.
	static let flag: Flag = .init("-v", "--verbose")
}

extension Command {

	/// Adds support for “--verbose” option.
	var verbose: Flag {
		return Verbose.flag
	}

	/// Returns stdout replacement for verbose output.
	var verboseOutput: WriteStream {
		return verbose.value ? .stdout : .null
	}

	/// Returns stdout.
	var standardOutput: WriteStream {
		return .stdout
	}

	/// Returns stderr.
	var errorOutput: WriteStream {
		return .stderr
	}
}

// MARK: -

extension Command {

	/// Google OAuth2 credential data.
	func googleCredential() throws -> OAuthSwiftCredential {
		let credentialsPath = AirStrings.Library.directory + AirStrings.Google.credentialsFilename
		guard let credentialsData = try? credentialsPath.read(), let credential = NSKeyedUnarchiver.unarchiveObject(with: credentialsData) as? OAuthSwiftCredential else {
			throw AirStringsError.missedCredentials(message: "Google credentials are missed at \(credentialsPath.absolute())")
		}
		return credential
	}

	/// Makes a synchronous request and throws in case of error.
	///
	/// - Parameter callback: Client, success and failure handlers for making a request.
	/// - Returns: Response with data from the request.
	/// - Throws: Network error after failed request.
	func syncGoogleRequest(_ callback: (OAuthSwiftClient, @escaping OAuthSwiftHTTPRequest.SuccessHandler, @escaping OAuthSwiftHTTPRequest.Obj_FailureHandler) -> Void) throws -> OAuthSwiftResponse {

		let runLoop = CFRunLoopGetCurrent()
		var response: OAuthSwiftResponse?
		var error: Error?
		callback(OAuthSwiftClient(credential: try googleCredential()), {
			response = $0
			CFRunLoopStop(runLoop)
		}, {
			error = $0
			CFRunLoopStop(runLoop)
		})

		// GET request may return immediately if the token is expired
		if let response = response {
			return response
		} else if let error = error {
			throw error
		} else {
			CFRunLoopRun()
		}

		if let response = response {
			return response
		} else if let error = error {
			throw error
		} else {
			fatalError() // No response and no error?
		}
	}
}
