//
//  TKThemeManager
//
//  Created by Taras Kalapun on 6/12/12.
//

#import "TKThemeManager.h"
#import "IJContext.h"

#define UIColorFromRGBA(rgbValue, alphaValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
    blue:((float)(rgbValue & 0xFF)) / 255.0 \
    alpha:alphaValue])
#define UIColorFromRGB(rgbValue) (UIColorFromRGBA((rgbValue), 1.0))


@implementation TKThemeManager

injective_register_singleton(TKThemeManager)

@synthesize themeOptions = _themeOptions;

- (id)themedValueForPath:(NSString *)themePath
{
    return [self.themeOptions valueForKeyPath:themePath];
}

- (void)loadFromBundleWithFileName:(NSString *)fileName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    self.themeOptions = [NSDictionary dictionaryWithContentsOfFile:path];
}

@end


@implementation UIImage (TKThemed)

// WARNING: read comments!
+ (UIImage *)themedFor:(NSString *)themePath {
    
    UIImage *img = nil;
    
    // if we have '.' in path - route it to plist
    // if not - get image directly
    if ([themePath rangeOfString:@"."].location != NSNotFound) {
        // Does contain the substring
        NSString *imgName = themedValue(themePath);
        img = [UIImage imageNamed:imgName];
        
        if (!img) NSLog(@"[TKThemeManager] No Image %@ for %@", imgName, themePath);
    } else {
        img = [UIImage imageNamed:themePath];
        if (!img) NSLog(@"[TKThemeManager] No Image %@", themePath);
    }
    
    return img;
}

@end

@implementation UIFont (TKThemed)

+ (UIFont *)themedFor:(NSString *)themePath {
    NSString *fontData = themedValue(themePath);
    NSArray *fa = [fontData componentsSeparatedByString:@":"];

    NSString *fontName = [fa objectAtIndex:0];
    CGFloat fontSize = [[fa objectAtIndex:1] floatValue];
    
    if (fontSize == 0) {
        fontSize = [UIFont systemFontSize];
    }
    
    if ([fontName isEqualToString:@""]) {
        return [UIFont systemFontOfSize:fontSize];
    }
    
    if ([fontName isEqualToString:@"bold"] || [fontName isEqualToString:@"b"]) {
        return [UIFont boldSystemFontOfSize:fontSize];
    }
    
    return [UIFont fontWithName:fontName size:fontSize];
}

@end

@implementation UIColor (TKThemed)

+ (UIColor *)themedFor:(NSString *)themePath {
    
    NSString *hexString = themedValue(themePath);
    
    if (!hexString) {
        NSLog(@"[TKThemeManager] No Color for %@", themePath);
        return nil;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hex;
    BOOL success = [scanner scanHexInt:&hex];
    
    if (!success) return nil;
    
    UIColor *color = UIColorFromRGB(hex);
    return color;
}

@end
