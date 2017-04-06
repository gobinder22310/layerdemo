//
//  ATLMPersistenceManagerTest.m
//  Atlas Messenger
//
//  Created by Blake Watters on 6/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
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
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "ATLMPersistenceManager.h"

@interface ATLMPersistenceManagerTest : XCTestCase

@end

@implementation ATLMPersistenceManagerTest

- (void)testRaisesOnAttempToInit
{
    expect(^{ [ATLMPersistenceManager new]; }).to.raise(NSInternalInconsistencyException);
}

@end

@interface ATLMInMemoryPersistenceManagerTest : XCTestCase

@end

@implementation ATLMInMemoryPersistenceManagerTest

@end

@interface ATLMOnDiskPersistenceManagerTest : XCTestCase

@end

@implementation ATLMOnDiskPersistenceManagerTest

- (void)testInitializingWithEmptyDirectory
{
    ATLMPersistenceManager *manager = [ATLMPersistenceManager defaultManager];
    expect([manager persistedSessionWithError:nil]).to.beNil();
    expect([manager persistedUsersWithError:nil]).to.beNil();
}

- (void)testSessionPersistence
{
    ATLMPersistenceManager *manager = [ATLMPersistenceManager defaultManager];
    ATLMUser *user = [ATLMUser new];
    user.userID = [[NSUUID UUID] UUIDString];
    ATLMSession *session = [ATLMSession sessionWithAuthenticationToken:@"12345" user:user];
    
    NSError *error = nil;
    BOOL success = [manager persistSession:session error:&error];
    expect(success).to.beTruthy();
    expect(error).to.beNil();
    
    ATLMSession *loadedSession = [manager persistedSessionWithError:&error];
    expect(loadedSession).notTo.beNil();
    expect(error).to.beNil();
    expect(loadedSession.user.userID).to.equal(user.userID);
    expect(loadedSession.authenticationToken).to.equal(@"12345");
}

- (void)testLoadingNonExistantSessionFileFailsWithoutError
{
    ATLMPersistenceManager *manager = [ATLMPersistenceManager defaultManager];
    NSError *error = nil;
    ATLMSession *session = [manager persistedSessionWithError:&error];
    expect(session).to.beNil();
    expect(error).to.beNil();
}

- (void)testUsersPersistence
{
    ATLMPersistenceManager *manager = [ATLMPersistenceManager defaultManager];
    ATLMUser *user1 = [ATLMUser new];
    user1.userID = @"12345";
    ATLMUser *user2 = [ATLMUser new];
    user2.userID = @"5678";
    NSError *error = nil;
    NSSet *users = [NSSet setWithObjects:user1, user2, nil];
    BOOL success = [manager persistUsers:users error:&error];
    expect(success).to.beTruthy();
    expect(error).to.beNil();
    
    NSSet *loadedUsers = [manager persistedUsersWithError:&error];
    expect(loadedUsers).to.equal(users);
    expect(error).to.beNil();
}

- (void)testLoadingNonExistantUsersFileFailsWithoutError
{
    ATLMPersistenceManager *manager = [ATLMPersistenceManager defaultManager];
    NSError *error = nil;
    NSSet *users = [manager persistedUsersWithError:&error];
    expect(users).to.beNil();
    expect(error).to.beNil();
}

- (void)testRemovingAllObjects
{
    ATLMPersistenceManager *manager = [ATLMPersistenceManager defaultManager];
    ATLMUser *user = [ATLMUser new];
    user.userID = [[NSUUID UUID] UUIDString];
    ATLMSession *session = [ATLMSession sessionWithAuthenticationToken:@"12345" user:user];
    
    NSError *error = nil;
    BOOL success = [manager persistSession:session error:&error];
    expect(success).to.beTruthy();
    expect(error).to.beNil();
    
    ATLMUser *user1 = [ATLMUser new];
    user1.userID = @"12345";
    ATLMUser *user2 = [ATLMUser new];
    user2.userID = @"5678";
    NSSet *users = [NSSet setWithObjects:user1, user2, nil];
    success = [manager persistUsers:users error:&error];
    expect(success).to.beTruthy();
    expect(error).to.beNil();
    
    success = [manager deleteAllObjects:&error];
    expect(success).to.beTruthy();
    expect(error).to.beNil();
    
    // Verify the objects are gone
    session = [manager persistedSessionWithError:&error];
    expect(session).to.beNil();
    expect(error).to.beNil();
    
    users = [manager persistedUsersWithError:&error];
    expect(users).to.beNil();
    expect(error).to.beNil();
}

@end
