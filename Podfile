Target = Struct.new(:target, :platform, :platform_version)

[ Target.new('URLMock', :osx, '10.8'), Target.new('libURLMock', :ios, '6.1') ].each do |t|
  target t.target.to_sym, exclusive: true do
    platform t.platform, t.platform_version
    pod 'SOCKit', '~> 1.1'
  end

  target "#{t.target} Tests".to_sym, exclusive: true do
    platform t.platform, t.platform_version
    pod 'OCMock', '~> 2.0'
  end
end
