//
//  ATLMSettingsViewControllerTest.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 1/20/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <XCTest/XCTest.h>
#import <KIF/KIF.h>
#import <KIFViewControllerActions/KIFSystemTestActor+ViewControllerActions.h>

#import "ATLMTestInterface.h"
#import "ATLMTestUser.h"
#import "ATLMSettingsHeaderView.h"
#import "ATLMSettingsViewController.h"

extern NSString *const ATLMConversationListTableViewAccessibilityLabel;
extern NSString *const ATLMSettingsTableViewAccessibilityIdentifier;
extern NSString *const ATLMSettingsHeaderAccessibilityLabel;
extern NSString *const ATLMPushNotificationSettingSwitch;
extern NSString *const ATLMLocalNotificationSettingSwitch;
extern NSString *const ATLMDebugModeSettingSwitch;


@interface ATLMSettingsViewControllerTest : KIFTestCase

@property (nonatomic) ATLMTestInterface *testInterface;

@end

@implementation ATLMSettingsViewControllerTest

- (void)setUp
{
    [super setUp];
    ATLMLayerController *applicationController =  [(ATLMAppDelegate *)[[UIApplication sharedApplication] delegate] layerController];
    self.testInterface = [ATLMTestInterface testInterfaceWithApplicationController:applicationController];
}

- (void)tearDown
{
    [self.testInterface deauthenticateIfNeeded];
    [super tearDown];
}

- (void)testToVerifyHeaderUI
{
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    ATLMUser *user = self.testInterface.applicationController.APIManager.authenticatedSession.user;
    [tester waitForViewWithAccessibilityLabel:ATLMSettingsHeaderAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:user.fullName];
    [tester waitForViewWithAccessibilityLabel:@"Connected"];
}

- (void)testToVerifyDoneButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester waitForViewWithAccessibilityLabel:ATLMConversationListTableViewAccessibilityLabel];
}

- (void)testToVerifySettingsDelegateFunctionalityOnDoneButtonTap
{
    ATLMSettingsViewController *controller = [[ATLMSettingsViewController alloc] init];
    controller.applicationController = self.testInterface.applicationController;
    id delegateMock = OCMProtocolMock(@protocol(ATLMSettingsViewControllerDelegate));
    controller.settingsDelegate = delegateMock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        
    }] settingsViewControllerDidFinish:[OCMArg any]];
    
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [delegateMock verify];
}

- (void)testToVerifySettingsDelegateFunctionalityOnLogoutButtonTap
{
    ATLMSettingsViewController *controller = [[ATLMSettingsViewController alloc] init];
    controller.applicationController = self.testInterface.applicationController;
    id delegateMock = OCMProtocolMock(@protocol(ATLMSettingsViewControllerDelegate));
    controller.settingsDelegate = delegateMock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];

    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        
    }] logoutTappedInSettingsViewController:[OCMArg any]];
    
    [tester swipeViewWithAccessibilityLabel:ATLMSettingsHeaderAccessibilityLabel inDirection:KIFSwipeDirectionUp];
    [tester waitForViewWithAccessibilityLabel:@"Log Out"];
    [tester tapViewWithAccessibilityLabel:@"Log Out"];
    [delegateMock verify];
}

- (void)testToVerifyLayerStatistics
{
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    NSError *error;
    NSUInteger conversationCount = [self.testInterface.applicationController.layerClient countForQuery:query error:&error];
    expect(error).to.beFalsy;
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Conversations:, %lu", (unsigned long)conversationCount]];
    
    query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    NSUInteger messageCount = [self.testInterface.applicationController.layerClient countForQuery:query error:&error];
    expect(error).to.beFalsy;
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Messages:, %lu", (unsigned long)messageCount]];
    
    query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"isUnread" predicateOperator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    NSUInteger unreadMessageCount = [self.testInterface.applicationController.layerClient countForQuery:query error:&error];
    expect(error).to.beFalsy;
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Unread Messages:, %lu", (unsigned long)unreadMessageCount]];
}

- (void)testToVerifyLogoutButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    [tester swipeViewWithAccessibilityLabel:ATLMSettingsHeaderAccessibilityLabel inDirection:KIFSwipeDirectionUp];
    [tester waitForViewWithAccessibilityLabel:@"Log Out"];
    [tester tapViewWithAccessibilityLabel:@"Log Out"];
}

@end
