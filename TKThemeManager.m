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

#define IPAD ((__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200) && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
#define IPHONE (!IPAD)


@interface NSDictionary (TKThemed)

- (id)TKObjectForKey:(id)aKey;
- (id)TKValueForKeyPath:(NSString *)keyPath;

@end

// TODO: static keys

@implementation TKThemeManager

injective_register_singleton(TKThemeManager)

@synthesize themeOptions = _themeOptions;

- (id)themedValueForPath:(NSString *)themePath
{
    return [self.themeOptions TKValueForKeyPath:themePath];
}

- (void)loadFromBundleWithFileName:(NSString *)fileName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    self.themeOptions = [NSDictionary dictionaryWithContentsOfFile:path];
}

- (UIViewController *)rootViewControllerFromLayout
{
    return [self viewControllerFromPropertyDictionary:[self themedValueForPath:@"layout"]];
}

- (UIViewController *)viewControllerFromPropertyDictionary:(NSDictionary *)propertyDict {
    if (!propertyDict) return nil;
    NSAssert([propertyDict isKindOfClass:[NSDictionary class]], @"Expected a dictionary where a %@ was found", NSStringFromClass([propertyDict class]));
    
    UIViewController *controller = nil;
    
    NSString *controllerName = [propertyDict TKObjectForKey:@"controller"];
    NSAssert([controllerName isKindOfClass:[NSString class]], @"The controller name should be a string");
    
    //Instantiate
    NSString *nibName = [propertyDict TKObjectForKey:@"nibName"];
    NSBundle *nibBundle = [NSBundle bundleWithPath:[propertyDict TKObjectForKey:@"nibBundle"]];
    if (nibName) {
        controller = [[NSClassFromString(controllerName) alloc] initWithNibName:nibName bundle:nibBundle];
    }
    else {
        controller = [[NSClassFromString(controllerName) alloc] init];
    }
    
    NSAssert(controller != nil, @"The controller named %@ can not be created", controllerName);
    NSAssert([controller isKindOfClass:[UIViewController class]], @"The controller %@ should be kind of UIViewController", controllerName);
    
    //Properties
    NSString *title = [propertyDict TKObjectForKey:@"title"];
    if (title) {
        controller.title = NSLocalizedString(title, nil);
    }
    
    //Subcontrollers
    NSArray *subControllers = [propertyDict TKObjectForKey:@"subControllers"];
    if (([controller respondsToSelector:@selector(setViewControllers:)]) && subControllers) {
        NSAssert([subControllers isKindOfClass:[NSArray class]], @"Subcontrollers should be an array");
        
        NSMutableArray *vcs = [NSMutableArray arrayWithCapacity:subControllers.count];
        for (NSDictionary *subController in subControllers) {
            UIViewController *vc = [self viewControllerFromPropertyDictionary:subController];
            if (vc) {
                [vcs addObject:vc];
            }
        }
        [controller performSelector:@selector(setViewControllers:) withObject:vcs];
    }
    
    //Navigation bar
    BOOL inNavigationController = [[propertyDict TKObjectForKey:@"inNavigationController"] boolValue];
    if (inNavigationController) {
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:controller];
        int barStyle = [[propertyDict TKObjectForKey:@"navBarStyle"] intValue];
        nc.navigationBar.barStyle = barStyle;
        controller = nc;
    }
    
    return controller;
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
    
    NSString *hexString = [themedValue(themePath) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!hexString) {
        NSLog(@"[TKThemeManager] No Color for %@", themePath);
        return nil;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hex;
    BOOL success = [scanner scanHexInt:&hex];
    
    if (!success) return nil;
    if ([hexString length] <= 6)
        return UIColorFromRGB(hex);
    else {
        unsigned color = (hex & 0xFFFFFF00) >> 8;
        CGFloat alpha = 1.0 * (hex & 0xFF) / 255.0;
        return UIColorFromRGBA(color, alpha);
    }
}

@end


@implementation NSDictionary (TKThemed)

- (id)TKObjectForKey:(id)aKey {
    //Check the value for the specific device
    NSString *keyPathDevice = [aKey stringByAppendingString:(IPAD? @"~iPad" : @"~iPhone")];
    id deviceValue = [self objectForKey:keyPathDevice];
    if (deviceValue) {
        return deviceValue;
    }
    return [self objectForKey:aKey];
}

- (id)TKValueForKeyPath:(NSString *)keyPath {
    //Check the value for the specific device
    NSString *keyPathDevice = [keyPath stringByAppendingString:(IPAD? @"~iPad" : @"~iPhone")];
    id deviceValue = [self valueForKeyPath:keyPathDevice];
    if (deviceValue) {
        return deviceValue;
    }
    return [self valueForKeyPath:keyPath];
}

@end
