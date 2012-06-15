TKThemeManager
==============

iOS Lib to style components from plist
CComponent is dependent from [Injective](https://github.com/farcaller/Injective) lib

## Installation
* You need [cocoapods](http://cocoapods.org) lib manager
* Edit your `Podfile` and add

```ruby
dependency 'TKThemeManager', :podspec => 'https://raw.github.com/xslim/TKThemeManager/master/TKThemeManager.podspec'
```

## Usage
* Setup the theme info in `theme.plist`, look for sample here
* Edit your `-Prefix.pch` file and add

```obj-c
#ifdef __OBJC__
    // def imports...
    /// Theaming
    #import "IJContext.h"
    #import "TKThemeManager.h"
#endif
```

* In `AppDelegate.m`

```obj-c
// Set-up Injective
[IJContext setDefaultContext:[[IJContext alloc] init]];

// Load the theme
[[TKThemeManager injectiveInstantiate] loadFromBundleWithFileName:@"theme"];
```

* Use in you classes

```obj-c

CGPoint padPoint = themedPoint(@"epg.cell.title.point");

UIFont *activitiesFont = [UIFont themedFor:@"epg.cell.activity.font"];

label.backgroundColor = [UIColor themedFor:@"epg.timeline.time.bg_color"];

``` 

* Available defines: `themedValue`, `themedInt`, `themedFloat`, `themedRect`, `themedPoint`

## Theme plist 
* Colors: in HEX format, like `ffffff`
* Fonts: `:12` for standart font, `b:12` for bold, `CustomFontName:12` for custom font
* CGPoint: `{3,9}`
* CGRect: `{{3,9},{3,9}}`
* float: 34.15

