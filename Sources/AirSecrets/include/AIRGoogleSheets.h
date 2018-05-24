///
/// @file AirSecrets:AIRGoogleSheets.h
/// @author Vadim Shpakovski.
/// @copyright © 2018 Farmers WIFE SL. All rights reserved.
///

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Secrets for Google Sheets API.
NS_SWIFT_NAME(GoogleSheets)
@interface AIRGoogleSheets: NSObject

/// Google Sheets API client identifier i.e. OAuth username.
@property (class, nonatomic, copy, readonly) NSString *clientIdentifier;

/// Google Sheets API client secret i.e. OAuth password.
@property (class, nonatomic, copy, readonly) NSString *clientSecret;

@end

NS_ASSUME_NONNULL_END
