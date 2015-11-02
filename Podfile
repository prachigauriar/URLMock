Target = Struct.new(:target, :platform, :platform_version)

targets = [ Target.new('URLMock', :osx, '10.9'),
            Target.new('URLMock-iOS', :ios, '8.0'),
            Target.new('libURLMock', :ios, '7.0') ]

targets.each do |t|
  target t.target.to_sym, exclusive: true do
    platform t.platform, t.platform_version

    # Pods for the framework/library targets
    pod 'SOCKit', '~> 1.1'
  end

  target "#{t.target}Tests".to_sym, exclusive: true do
    platform t.platform, t.platform_version

    # Pods for the test targets
    pod 'OCMock', '~> 2.0'

    # The logic tests for libURLMock also need to link with SOCKit since it's not included in the static lib.
    if t.target == "libURLMock"
        pod 'SOCKit', '~> 1.1'
    end
  end
end
