///
/// @file AirSecrets:AIRGoogleSheets.m
/// @author Vadim Shpakovski.
/// @copyright © 2018 Farmers WIFE SL. All rights reserved.
///

#import "include/AIRGoogleSheets.h"

// Reusable macros for converting Build Settings into strings
#define STRINGIZE(macro) #macro
#define STRINGIFY(macro) STRINGIZE(macro)

// Generate literal AIRGoogleSheetsClientIdentifier if AIR_GOOGLE_SHEETS_CLIENT_IDENTIFIER is available
#ifdef AIR_GOOGLE_SHEETS_CLIENT_IDENTIFIER
#define AIRGoogleSheetsClientIdentifier @ STRINGIFY(AIR_GOOGLE_SHEETS_CLIENT_IDENTIFIER)
#endif

// Generate literal AIRGoogleSheetsClientSecret if AIR_GOOGLE_SHEETS_CLIENT_SECRET is available
#ifdef AIR_GOOGLE_SHEETS_CLIENT_SECRET
#define AIRGoogleSheetsClientSecret @ STRINGIFY(AIR_GOOGLE_SHEETS_CLIENT_SECRET)
#endif

@implementation AIRGoogleSheets

+ (NSString *)clientIdentifier {
	return AIRGoogleSheetsClientIdentifier;
}

+ (NSString *)clientSecret {
	return AIRGoogleSheetsClientSecret;
}

@end
