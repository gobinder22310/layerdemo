//
//  ATLMConfigurationTests.m
//  Atlas Messenger
//
//  Created by JP McGlone on 2/3/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ATLMConfiguration.h"
#import <Expecta/Expecta.h>

@interface ATLMConfigurationTests : XCTestCase

@end

/**
 @abstract Locates and returns the test configuration file used in this test case.
 @param suffix Appends a given string at the end of the filename with a dash ('-')
   in front of it.
 @return Returns a file `NSURL` instance pointing to the test configuration file.
 */
NSURL *ATLMConfigurationTestsDefaultConfigurationPath(NSString *__nullable suffix)
{
    NSBundle *bundle = [NSBundle bundleForClass:[ATLMConfigurationTests class]];
    NSURL *fileURL = [bundle URLForResource:suffix == nil ? @"TestLayerConfiguration": [@"TestLayerConfiguration-" stringByAppendingString:suffix] withExtension:@"json"];
    return fileURL;
}

@implementation ATLMConfigurationTests

- (void)testInitShouldFail
{
    // Call wrong initialization method
    expect(^{
        id allocatedConfig = [ATLMConfiguration alloc];
        __unused id noresult = [allocatedConfig init];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to call designated initializer. Call the designated initializer 'initWithFileURL:' on the `ATLMConfiguration` instead.");
}

- (void)testInitPassingNilShouldFail
{
    // Pass in `nil` as fileURL.
    expect(^{
        __unused id nullVal = nil;
        __unused id noresult = [[ATLMConfiguration alloc] initWithFileURL:nullVal];
    }).to.raiseWithReason(NSInvalidArgumentException, @"Failed to initialize `ATLMConfiguration` because the `fileURL` argument was `nil`.");
}

- (void)testInitPassingInvalidPathShouldFail
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[ATLMConfiguration alloc] initWithFileURL:[NSURL URLWithString:@"/dev/null"]];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `ATLMConfiguration` because the input file could not be read; error=Error Domain=NSCocoaErrorDomain Code=256 \"The file “null” couldn’t be opened.\" UserInfo={NSURL=/dev/null}");
}

- (void)testInitPassingInvalidJSONShouldFail
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[ATLMConfiguration alloc] initWithFileURL:ATLMConfigurationTestsDefaultConfigurationPath(@"invalid")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `ATLMConfiguration` because the input file could not be deserialized; error=Error Domain=NSCocoaErrorDomain Code=3840 \"Something looked like a 'null' but wasn't around character 0.\" UserInfo={NSDebugDescription=Something looked like a 'null' but wasn't around character 0.}");
}

- (void)testInitFailingDueToAppIDMissing
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[ATLMConfiguration alloc] initWithFileURL:ATLMConfigurationTestsDefaultConfigurationPath(@"appIDNotSet")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `ATLMConfiguration` because `app_id` key in the input file was not set.");
}

- (void)testInitFailingDueToNullAppID
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[ATLMConfiguration alloc] initWithFileURL:ATLMConfigurationTestsDefaultConfigurationPath(@"appIDNull")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `ATLMConfiguration` because `app_id` key value in the input file was `null`.");
}

- (void)testInitFailingDueToInvalidAppID
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[ATLMConfiguration alloc] initWithFileURL:ATLMConfigurationTestsDefaultConfigurationPath(@"appIDInvalid")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `ATLMConfiguration` because `app_id` key value in the input file was not a valid URL. appID=' '");
}

- (void)testInitFailingDueToIdentityProviderURLMissing
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[ATLMConfiguration alloc] initWithFileURL:ATLMConfigurationTestsDefaultConfigurationPath(@"identityProviderURLNotSet")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `ATLMConfiguration` because `identity_provider_url` key in the input file was not set.");
}

- (void)testInitFailingDueToNullIdentityProviderURL
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[ATLMConfiguration alloc] initWithFileURL:ATLMConfigurationTestsDefaultConfigurationPath(@"identityProviderURLNull")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `ATLMConfiguration` because `identity_provider_url` key value in the input file was `null`.");
}

- (void)testInitFailingDueToInvalidIdentityProviderURL
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[ATLMConfiguration alloc] initWithFileURL:ATLMConfigurationTestsDefaultConfigurationPath(@"identityProviderURLInvalid")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `ATLMConfiguration` because `identity_provider_url` key value in the input file was not a valid URL. identityProviderURL=' '");
}

- (void)testInitFailingDueToJSONNotAnArray
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[ATLMConfiguration alloc] initWithFileURL:ATLMConfigurationTestsDefaultConfigurationPath(@"notArray")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `ATLMConfiguration` because the input file JSON root was not an array");
}

- (void)testInitFailingDueToNameNotString
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[ATLMConfiguration alloc] initWithFileURL:ATLMConfigurationTestsDefaultConfigurationPath(@"nameNotString")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `ATLMConfiguration` because `name` key in the input file was not an NSString.");
}

- (void)testInitSuccessfullyDeserializesValidConfigurationFile
{
    ATLMConfiguration *configuration = [[ATLMConfiguration alloc] initWithFileURL:ATLMConfigurationTestsDefaultConfigurationPath(nil)];
    expect(configuration.appID.absoluteString).to.equal(@"layer:///apps/staging/test");
    expect(configuration.identityProviderURL.absoluteString).to.equal(@"https://test.herokuapp.com");
    expect(configuration.name).to.equal(@"TestApp");
}

@end
