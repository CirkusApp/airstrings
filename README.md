# Air Strings

Air Strings is a command-line tool for translating localizable strings in Google Sheets.

### 1. Prepare localization e.g. Localizable.strings

Tis is usually done in Xcode or AppCode. The preferred format is `"key" = "value"; // comment`:

<img src="Images/StringsEn@2x.png" alt="Localizable.strings English" width="500px" height="280px" />

### 2. “Push” Localizable.strings to Google Sheets

The command like `airstrings push --path en/Localizable.strings` will upload key-value pairs with their comments into the Google spreadsheet.

<img src="Images/SheetEn@2x.png" alt="Google Sheet with English strings" width="500px" height="280px" />

### 3. Translate strings in Google Sheets

Then you translate strings into any language. By the way, Google Sheets are perfect for collaboration!

<img src="Images/SheetRu@2x.png" alt="Google Sheet with Russian strings" width="500px" height="280px" />

### 3. “Pull” translations as new Localizable.strings

Once translation is done, download all strings back using a command like `airstrings pull --path ru/Localizable.strings`.

<img src="Images/StringsRu@2x.png" alt="Localizable.strings Russian" width="500px" height="280px" />

####  🎉 Done!

# Building

In order to build an executable you need a client identifier and a secret for Google Sheets API. Please follow instructions at [https://developers.google.com/sheets/api/guides/authorizing#OAuth2Authorizing](https://developers.google.com/sheets/api/guides/authorizing#OAuth2Authorizing) to generate something like this:

<img src="Images/Credentials@2x.png" alt="Google Sheets API Credentials UI" width="500px" height="180px" />

Once generated, copy and replace string values `CLIENT_ID` and `CLIENT_SECRET` in the following script:

```bash
git clone git@github.com:CirkusApp/airstrings.git && cd airstrings
CLIENT_ID=1234567890-abcdefg0987654321.apps.googleusercontent.com CLIENT_SECRET=abcdefgh123456789
echo "GCC_PREPROCESSOR_DEFINITIONS = \$(inherited) AIR_GOOGLE_SHEETS_CLIENT_IDENTIFIER=$CLIENT_ID AIR_GOOGLE_SHEETS_CLIENT_SECRET=$CLIENT_SECRET" > AirSecrets.xcconfig
swift package generate-xcodeproj --xcconfig-overrides AirSecrets.xcconfig
xcodebuild -project airstrings.xcodeproj -target airstrings -configuration Release
cd build/Release
```

# Running

Read a manual by performing the following command:

```bash
build/Release/airstrings <command> [options]
```

# Roadmap

- Write `make build` with `swift build` which gets `.xcconfig` parameters via `-Xcc`
- Release a binary for public to add support for `brew install airstrings`
- Use [OysterKit](https://github.com/SwiftStudies/OysterKit) for parsing `.strings`
- Add support for parsing `.properties` using `OysterKit`
- Open the website Cirkus Open Source at [https://cirkusapp.github.io](https://cirkusapp.github.io)
- Move Air Strings to [https://cirkusapp.github.io/airstrings](https://cirkusapp.github.io/airstrings)
- Build API URLs using [URITemplate.swift](https://github.com/kylef/URITemplate.swift)
- Describe output format using [Stencil](https://github.com/stencilproject/Stencil) or the like

# Thanks

- [SwiftCLI](https://github.com/jakeheis/SwiftCLI) — cool processor for command-line interfaces
- [PathKit](https://github.com/kylef/PathKit) — nice helpers for writing and reading local files
- [OAuthSwift](https://github.com/OAuthSwift/OAuthSwift) — native Swift library for Google Auth

# Contact

Vadim [@Shpakovski](https://github.com/shpakovski).

# License

Air Strings is licensed under [MIT License](LICENSE).
