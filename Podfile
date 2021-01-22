inhibit_all_warnings!

Target = Struct.new(:target, :platform, :platform_version)

targets = [
  Target.new('URLMockTests-macOS', :osx, '10.13'),
  Target.new('URLMockTests-iOS', :ios, '11.0'),
  Target.new('URLMockTests-tvOS', :tvos, '11.0')
]


targets.each do |t|
  target "#{t.target}".to_sym do
    platform t.platform, t.platform_version

    # Pods for the test targets
    pod 'OCMock', '~> 3.0'
  end
end
