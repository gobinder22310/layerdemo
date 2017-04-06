//
//  ATLMConversationViewControllerTest.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 1/15/15.
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

#import <KIF/KIF.h>
#import <KIFViewControllerActions/KIFViewControllerActions.h>
#import <XCTest/XCTest.h>

#import "ATLMLayerController.h"
#import "ATLMTestInterface.h"
#import "ATLMTestUser.h"

extern NSString *const ATLMComposeButtonAccessibilityLabel;
extern NSString *const ATLMConversationViewControllerAccessibilityLabel;
extern NSString *const ATLMDetailsButtonAccessibilityLabel;
extern NSString *const ATLMConversationDetailViewControllerTitle;
extern NSString *const ATLMMessageDetailViewControllerAccessibilityLabel;

extern NSString *const ATLConversationListViewControllerTitle;
extern NSString *const ATLConversationCollectionViewAccessibilityIdentifier;
extern NSString *const ATLAddressBarAccessibilityLabel;
extern NSString *const ATLMessageInputToolbarAccessibilityLabel;

@interface ATLMConversationViewControllerTest : KIFTestCase

@property (nonatomic) ATLMTestInterface *testInterface;
@property (nonatomic) NSSet *participants;

@end

@implementation ATLMConversationViewControllerTest

- (void)setUp
{
    [super setUp];
    ATLMLayerController *applicationController =  [(ATLMAppDelegate *)[[UIApplication sharedApplication] delegate] layerController];
    self.testInterface = [ATLMTestInterface testInterfaceWithApplicationController:applicationController];
    [self.testInterface connectLayerClient];
    [self.testInterface deauthenticateIfNeeded];
    [self.testInterface registerTestUserWithIdentifier:@"test"];
    
    self.participants = [NSSet setWithObject:@"0"];
    [self.testInterface.contentFactory newConversationsWithParticipants:self.participants];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
}

- (void)tearDown
{
    [self.testInterface clearLayerContent];
    [tester waitForTimeInterval:1];
    [self.testInterface deauthenticateIfNeeded];
    [super tearDown];
}

- (void)testToVerifyNewConversationViewControllerUI
{
    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
    [tester tapViewWithAccessibilityLabel:ATLMComposeButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMConversationViewControllerAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:ATLMDetailsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
}

- (void)testToVerifyExistingConversationViewControllerUI
{
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMConversationViewControllerAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMDetailsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
}

- (void)testToVerifyBackButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
    [tester tapViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
}

- (void)testToVerifyDetailsButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
    [tester tapViewWithAccessibilityLabel:ATLMDetailsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMConversationDetailViewControllerTitle];
}


@end
