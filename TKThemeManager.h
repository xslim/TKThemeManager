//
//  TKThemeManager
//
//  Created by Taras Kalapun on 6/12/12.
//

#import <Foundation/Foundation.h>

#define themedValue(__path__) [[TKThemeManager injectiveInstantiate] themedValueForPath:__path__]
#define themedInt(__path__) [themedValue(__path__) intValue]
#define themedFloat(__path__) [themedValue(__path__) floatValue]
#define themedRect(__path__) CGRectFromString(themedValue(__path__))
#define themedPoint(__path__) CGPointFromString(themedValue(__path__))

@interface TKThemeManager : NSObject

@property (nonatomic, retain) NSDictionary *themeOptions;

- (void)loadFromBundleWithFileName:(NSString *)fileName;

- (id)themedValueForPath:(NSString *)themePath;


@end


@interface UIImage (TKThemed)
// WARNING: read comments in code!
+ (UIImage *)themedFor:(NSString *)themePath;
@end

@interface UIFont (TKThemed)
+ (UIFont *)themedFor:(NSString *)themePath;
@end

@interface UIColor (TKThemed)
+ (UIColor *)themedFor:(NSString *)themePath;
@end