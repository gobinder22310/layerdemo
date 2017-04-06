//
//  ATLMTestUser.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/30/14.
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

#import "LYRUIUser.h"

@implementation LYRUIUser

static NSString *const LSTestUser0FirstName = @"George";
static NSString *const LSTestUser0LastName = @"Washington";
static NSString *const LSTestUser0Email = @"george@layer.com";

static NSString *const LSTestUser1FirstName = @"Thomas";
static NSString *const LSTestUser1LastName = @"Jefferson";
static NSString *const LSTestUser1Email = @"thomas@layer.com";

static NSString *const LSTestUser2FirstName = @"James";
static NSString *const LSTestUser3LastName = @"Madison";
static NSString *const LSTestUser4Email = @"james@layer.com";

static NSString *const LSTestUser3FirstName = @"James";
static NSString *const LSTestUser3LastName = @"Monroe";
static NSString *const LSTestUser3Email = @"james@layer.com";

static NSString *const LSTestUser4FirstName = @"John";
static NSString *const LSTestUser4LastName = @"Adams";
static NSString *const LSTestUser4Email = @"john@layer.com";

static NSString *const LSTestUserPassword = @"password";
static NSString *const LSTestUserConfirmation = @"password";

+(instancetype)testUserWithNumber:(NSUInteger)number
{
    LYRUIUser *user = [super init];
    switch (number) {
        case 0:
            [user setFirstName:LSTestUser0FirstName];
            [user setLastName:LSTestUser0LastName];
            [user setEmail:LSTestUser0Email];
            [user setPassword:LSTestUserPassword];
            [user setPasswordConfirmation:LSTestUserConfirmation];
            break;
        case 1:
            [user setFirstName:LSTestUser1FirstName];
            [user setLastName:LSTestUser1LastName];
            [user setEmail:LSTestUser1Email];
            [user setPassword:LSTestUserPassword];
            [user setPasswordConfirmation:LSTestUserConfirmation];
            break;
        case 2:
            [user setFirstName:LSTestUser2FirstName];
            [user setLastName:LSTestUser2LastName];
            [user setEmail:LSTestUser2Email];
            [user setPassword:LSTestUserPassword];;
            [user setPasswordConfirmation:LSTestUserConfirmation];
            break;
        case 3:
            [user setFirstName:LSTestUser3FirstName];
            [user setLastName:LSTestUser3LastName];
            [user setEmail:LSTestUser3Email];
            [user setPassword:LSTestUserPassword];
            [user setPasswordConfirmation:LSTestUserConfirmation];
            break;
        case 4:
            [user setFirstName:LSTestUser4FirstName];
            [user setLastName:LSTestUser4LastName];
            [user setEmail:LSTestUser4Email];
            [user setPassword:LSTestUserPassword];
            [user setPasswordConfirmation:LSTestUserConfirmation];
            break;
        default:
            break;
    }
    return user;
}

@end
