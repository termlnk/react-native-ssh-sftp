#
# Binary CocoaPod that vends `CSSH.xcframework` (libssh2 + OpenSSL with both
# iOS device and iOS Simulator slices), published by DimaRU/Libssh2Prebuild.
#
# Why this exists: NMSSH originally vendored static .a libraries built only
# for iOS device (`iphoneos`). Linking those into a Simulator build fails on
# Apple Silicon because the simulator is a separate Xcode platform that
# requires its own arm64 slice. XCFrameworks bundle the right slice per
# platform, so the simulator now links cleanly.
#
# Consumer recipe: add this podspec via expo-build-properties (or directly in
# a Podfile) alongside termlnk/NMSSH (which depends on `CSSH-Binary`). The
# xcframework zip is downloaded at `pod install` time from the upstream
# Libssh2Prebuild release.
#
Pod::Spec.new do |s|
  s.name     = 'CSSH-Binary'
  s.version  = '1.11.0'
  s.summary  = 'libssh2 + OpenSSL packaged as an XCFramework (Libssh2Prebuild).'
  s.license  = { :type => 'MIT' }
  s.homepage = 'https://github.com/termlnk/react-native-ssh-sftp'
  s.authors  = { 'termlnk' => 'noreply@termlnk.dev' }
  s.platform = :ios, '12.0'
  s.source   = {
    :http => 'https://github.com/DimaRU/Libssh2Prebuild/releases/download/1.11.0-OpenSSL-1-1-1w/CSSH-1.11.0-OpenSSL-1-1-1w.xcframework.zip'
  }
  s.vendored_frameworks = 'CSSH.xcframework'
end
