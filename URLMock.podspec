Pod::Spec.new do |s|
  s.name         = "URLMock"
  s.version      = "1.3.6"

  s.summary      = "A Cocoa framework for mocking and stubbing URL requests and responses."
  s.description  = <<-DESC
                   URLMock is an Objective-C framework for mocking and stubbing URL requests and
                   responses. It works with APIs built on the Foundation NSURL loading system—
                   NSURLConnection, NSURLSession, and AFNetworking, for example—without any changes
                   to your code.
                   DESC

  s.author       = { "Prachi Gauriar" => "prachi_github@quantumlenscap.com" }
  s.homepage     = "https://github.com/prachigauriar/URLMock"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'
  s.requires_arc = true

  s.source       = { :git => "https://github.com/prachigauriar/URLMock.git", :tag => s.version.to_s }

  s.subspec 'Core' do |ss|
    s.source_files  = [
      'Sources/URLMock/Headers/Public/URLMock/URLMock.h',
      'Sources/URLMock/Headers/Public/URLMock/NSURLRequest+UMKHTTPConvenienceMethods.h',
      'Sources/URLMock/Categories/NSURLRequest+UMKHTTPConvenienceMethods.m',
      'Sources/URLMock/Headers/Public/URLMock/UMKMockHTTPMessage.h',
      'Sources/URLMock/Mock Messages/UMKMockHTTPMessage.m',
      'Sources/URLMock/Headers/Public/URLMock/UMKMockHTTPRequest.h',
      'Sources/URLMock/Mock Messages/UMKMockHTTPRequest.m',
      'Sources/URLMock/Headers/Public/URLMock/UMKMockHTTPResponder.h',
      'Sources/URLMock/Mock Messages/UMKMockHTTPResponder.m',
      'Sources/URLMock/Headers/Public/URLMock/UMKMockURLProtocol+UMKHTTPConvenienceMethods.h',
      'Sources/URLMock/Mock URL Protocol/UMKMockURLProtocol+UMKHTTPConvenienceMethods.m',
      'Sources/URLMock/Headers/Public/URLMock/UMKMockURLProtocol.h',
      'Sources/URLMock/Mock URL Protocol/UMKMockURLProtocol.m',
      'Sources/URLMock/Pattern-Matching Mock Requests/SOCKit.h',
      'Sources/URLMock/Pattern-Matching Mock Requests/SOCKit.m',
      'Sources/URLMock/Headers/Public/URLMock/UMKPatternMatchingMockRequest.h',
      'Sources/URLMock/Pattern-Matching Mock Requests/UMKPatternMatchingMockRequest.m'
    ]
  end

  s.subspec 'TestHelpers' do |ss|
    ss.source_files = [
      'Sources/URLMock/Headers/Public/URLMock/NSURL+UMKQueryParameters.h',
      'Sources/URLMock/Categories/NSURL+UMKQueryParameters.m',
      'Sources/URLMock/Headers/Public/URLMock/NSDictionary+UMKURLEncoding.h',
      'Sources/URLMock/Categories/NSDictionary+UMKURLEncoding.m',
      'Sources/URLMock/Headers/Public/URLMock/UMKErrorUtilities.h',
      'Sources/URLMock/Utilities/UMKErrorUtilities.m',
      'Sources/URLMock/Headers/Public/URLMock/UMKMessageCountingProxy.h',
      'Sources/URLMock/Utilities/UMKMessageCountingProxy.m',
      'Sources/URLMock/Headers/Private/UMKParameterPair.h',
      'Sources/URLMock/Utilities/UMKParameterPair.m',
      'Sources/URLMock/Headers/Public/URLMock/UMKTestUtilities.h',
      'Sources/URLMock/Utilities/UMKTestUtilities.m',
      'Sources/URLMock/Headers/Private/UMKURLEncodedParameterStringParser.h',
      'Sources/URLMock/Utilities/UMKURLEncodedParameterStringParser.m'
    ]
  end

  s.subspec 'SubclassResponsibility' do |ss|
    ss.dependency 'URLMock/TestHelpers'
    ss.source_files = [
      'Sources/URLMock/Headers/Public/URLMock/NSException+UMKSubclassResponsibility.h',
      'Sources/URLMock/Categories/NSException+UMKSubclassResponsibility.m'
    ]
  end
end
