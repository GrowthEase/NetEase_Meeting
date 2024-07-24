#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run 'pod lib lint meeting_plugin.podspec' to validate before publishing.
#

Pod::Spec.new do |s|
  s.name = "netease_meeting_kit"
  s.version = "0.0.1"
  s.summary = "A new flutter plugin project."
  s.description = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage = "https://meeting.163.com"
  s.license = { :file => "../LICENSE" }
  s.author = { "NetEase, Inc." => "hzsunyj@corp.netease.com" }
  s.source = { :path => "." }
  s.source_files = "Classes/**/*"

  s.resource = ["Assets/**/*.png"]
  s.public_header_files = "Classes/**/*.h"

  s.dependency "Flutter"
  s.platform = :ios, "12.0"
  s.swift_version = "5.0"
  s.dependency "YXAlog"
  s.dependency "SDWebImage"
  if Pod.const_defined?(:MEETING_TEST) && MEETING_TEST
    # 测试阶段
    if Pod.const_defined?(:LOCAL_DEPENDENCY) && LOCAL_DEPENDENCY
      # 使用本地依赖，路径指定交给主工程pod
      s.dependency "NERoomKit"
    else
      # 使用内部pod
      if Pod.const_defined?(:TEST_ROOM_VERSION)
        s.dependency "NERoomKit-Private", TEST_ROOM_VERSION
      else
        s.dependency "NERoomKit-Private"
      end
    end
  else
    # 非测试阶段，版本不使用环境变量，只需要在迭代开始时修改一次就行了
    # 支持NERoomKit的Special_All，不指定NIMSDK版本
    if Pod.const_defined?(:SPECIAL_VERSION) && SPECIAL_VERSION
        s.dependency "NERoomKit/Special_All", "1.30.0"
    else
        s.dependency "NERoomKit", "1.30.0"
    end
  end

  s.dependency "NEDyldYuv"
  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES", "VALID_ARCHS[sdk=iphonesimulator*]" => "x86_64" }
end
