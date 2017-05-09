#
# Be sure to run `pod lib lint Nudgespot.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

s.name             = 'Nudgespot'
s.version          = '3.1.2'
s.summary          = 'nudgespot-ios is Objective-C framework.'

s.description      = <<-DESC
Nudgespot provides framework for iOS which allows users to track events.
DESC

s.homepage         = 'https://github.com/nudgespot/nudgespot-ios'

#s.license          = { :type => 'MIT', :file => 'LICENSE' }

s.author           = { 'Nudgespot' => 'dev@nudgespot.com' }

s.source           = { :git => 'https://github.com/nudgespot/nudgespot-ios.git',
:tag => s.version.to_s }

s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-ObjC', "FRAMEWORK_SEARCH_PATHS" => '"$(SRCROOT)/../../Nudgespot/Assets/Analytics" "$(SRCROOT)/../../Nudgespot/Assets/Messaging"', 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/Nudgespot/Nudgespot'}

s.module_name = "Nudgespot"

s.ios.deployment_target = '7.0'

s.requires_arc = true

s.source_files = 'Nudgespot/Classes/**/*.{h,m}', 'Nudgespot/Assets/*.h'

s.ios.public_header_files  = 'Nudgespot/Classes/**/*.h'

s.ios.vendored_frameworks = "Nudgespot/Assets/**/*.{framework}"

s.prefix_header_file = 'Example/Pods/Target Support Files/Nudgespot/Nudgespot-prefix.pch'

s.frameworks = 'SystemConfiguration', 'Foundation', 'CoreGraphics', 'MobileCoreServices', 'Security', 'AdSupport', 'CFNetwork', 'AddressBook'

s.ios.libraries = 'stdc++', 'z', 'sqlite3'

s.resource_bundles = {
'Nudgespot' => ['Nudgespot/Assets/*.{plist}']
}

s.dependency 'Reachability'
s.dependency 'AFNetworking'

# ////*** PCH Content begin here.. ***/////
s.prefix_header_contents = '#ifdef __OBJC__

#import "NudgespotActivity.h"
#import "SubscriberContact.h"
#import "Nudgespot.h"
#import "NudgespotSubscriber.h"
#import "SubscriberClient.h"
#import "NudgespotActivity.h"
#import "BasicUtils.h"
#import "Reachability.h"
#import "AFNetworking.h"
#import "SubscriberClient.h"
#import "NudgespotConstants.h"
#import "NudgespotVisitor.h"

#import <AdSupport/AdSupport.h>

#endif

#ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)'

# ////*** PCH Content End here.. ***/////

end
