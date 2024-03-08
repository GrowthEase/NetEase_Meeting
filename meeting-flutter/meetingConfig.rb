module MeetingConfig

  # 设置环境变量
  def self.setup()
    # 是否是测试阶段
    Pod.const_set(:MEETING_TEST, false)
    # 是否本地依赖NERoom进行调试
    Pod.const_set(:LOCAL_DEPENDENCY, false)
    # 依赖内部pod时NERoom的版本号
    Pod.const_set(:TEST_ROOM_VERSION, "1.26.0.9")

    # 用于本地依赖NERoom时使用，不是本地依赖不用关注这个字段
    ENV["USE_SOURCE_FILES"] = "true"
  end
end
