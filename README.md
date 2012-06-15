TKThemeManager
==============

iOS Lib to style components from plist
CComponent is dependent from [Injective](https://github.com/farcaller/Injective) lib

## Installation
* You need [cocoapods](http://cocoapods.org) lib manager
* Edit your `Podfile` and add
``` rb
dependency 'TKThemeManager', :podspec => 'https://raw.github.com/xslim/TKThemeManager/master/TKThemeManager.podspec'
```

## Usage
* Edit your `-Prefix.pch` file and add

``` obj-c
#ifdef __OBJC__
    // def imports...
    /// Theaming
    #import "IJContext.h"
    #import "TKThemeManager.h"
#endif
```

* In `AppDelegate.m`
``` obj-c
// Set-up Injective
[IJContext setDefaultContext:[[IJContext alloc] init]];

// Load the theme
[[TKThemeManager injectiveInstantiate] loadFromBundleWithFileName:@"theme"];
```

* Use in you classes
``` obj-c

CGPoint padPoint = themedPoint(@"epg.cell.title.point");

UIFont *activitiesFont = [UIFont themedFor:@"epg.cell.activity.font"];

label.backgroundColor = [UIColor themedFor:@"epg.timeline.time.bg_color"];

``` 

* Available defines: `themedValue`, `themedInt`, `themedFloat`, `themedRect`, `themedPoint`

