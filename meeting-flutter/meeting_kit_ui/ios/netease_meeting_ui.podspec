#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run 'pod lib lint meeting_plugin.podspec' to validate before publishing.
#

class RoomKitConfig
    @is_test = false
    @is_special = false

    def self.name
        return @is_test ? (@is_special ? 'NERoomKit-Private/Special_All' : 'NERoomKit-Private') : (@is_special ? 'NERoomKit/Special_All' : 'NERoomKit')
    end

    def self.version
        return @is_test ? '1.21.1.0' : '1.21.1'
    end
end


Pod::Spec.new do |s|
  s.name             = 'netease_meeting_ui'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://meeting.163.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'NetEase, Inc.' => 'hzsunyj@corp.netease.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'

  s.resource = ['Assets/**/*.png']
  s.public_header_files = 'Classes/**/*.h'
  
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'
  s.swift_version = '5.0'
  s.dependency 'YXAlog'
  s.dependency RoomKitConfig.name, RoomKitConfig.version
  s.dependency 'NEDyldYuv'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
