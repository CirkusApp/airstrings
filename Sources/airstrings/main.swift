import Foundation
import SwiftCLI

let airstrings = CLI.init(name: AirStrings.name, version: AirStrings.version, description: AirStrings.shortDescription)
airstrings.commands = [
	AuthCommand(), // airstrings auth
	PushCommand(), // airstrings push --path ./en/Localizable.strings --spreadhseetId abc123 --tabName "es/Localizable.strings"
	PullCommand(), // airstrings pull --spreadhseetId abc123 --tabName "es/Localizable.strings" --path ./en/Localizable.strings
]
airstrings.globalOptions = [Verbose.flag]
airstrings.helpCommand = nil
airstrings.goAndExit()
