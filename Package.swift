// swift-tools-version:4.0

import PackageDescription

let package = Package(
	name: "airstrings",
	dependencies: [
		.package(url: "https://github.com/jakeheis/SwiftCLI", from: "5.0.0"),
		.package(url: "https://github.com/kylef/PathKit", from: "0.9.1"),
		.package(url: "https://github.com/OAuthSwift/OAuthSwift", from: "1.2.1"),
	],
	targets: [
		.target(name: "AirSecrets"),
		.target(name: "airstrings", dependencies: ["AirSecrets", "SwiftCLI", "PathKit", "OAuthSwift"]),
	]
)
