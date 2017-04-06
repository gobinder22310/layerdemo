//
//  ATLMLayerControllerTest.m
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

#import <KIF/KIF.h>
#import <KIFViewControllerActions/KIFViewControllerActions.h>
#import <XCTest/XCTest.h>

#import "ATLMLayerController.h"
#import "ATLMTestInterface.h"
#import "ATLMTestUser.h"

@interface ATLMLayerControllerTest : KIFTestCase

@property (nonatomic) ATLMTestInterface *testInterface;
@property (nonatomic) ATLMTestUser *testUser;

@end

@implementation ATLMLayerControllerTest

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

- (void)testToVerifyApplicationGlobalResourcesOnInitialization
{
    expect(self.testInterface.applicationController.layerClient).toNot.beNil;
    expect(self.testInterface.applicationController.layerClient).to.beKindOf([LYRClient class]);
    
    expect(self.testInterface.applicationController.APIManager).toNot.beNil;
    expect(self.testInterface.applicationController.APIManager).to.beKindOf([ATLMAPIManager class]);
    
    expect(self.testInterface.applicationController.persistenceManager).toNot.beNil;
    expect(self.testInterface.applicationController.persistenceManager).to.beKindOf([ATLMPersistenceManager class]);
}

@end
