Pod::Spec.new do |s|
  s.name     = 'TKThemeManager'
  s.version  = '0.0.1'
  s.platform = :ios
  s.license = 'MIT'
  s.summary  = 'iOS Lib to style components from plist'
  s.homepage = 'https://github.com/xslim/TKThemeManager'
  s.authors   = {
    'Taras Kalapun' => 'http://kalapun.com'
  }
  s.source   = { :git => 'git://github.com/xslim/TKThemeManager.git' }
  s.source_files = '*.{h,m}'
  s.clean_paths  = 'theme.plist'
end
