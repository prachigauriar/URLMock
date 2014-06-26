platform :osx, '10.9'
  
pod 'SOCKit', '~> 1.1'
  
target 'URLMock Tests'.to_sym do
  pod 'OCMock', '~> 2.0'  
end

target :libURLMock, exclusive: false do
  platform :ios, '7.0'

  pod 'SOCKit', '~> 1.1'

  target 'libURLMock Tests'.to_sym do
    pod 'OCMock', '~> 2.0'
  end
end

