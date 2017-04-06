//
//  ATLTestUser.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/2/14.
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

#import "ATLMTestUser.h"

@implementation ATLMTestUser

+ (instancetype)testUserWithNumber:(NSUInteger)number
{
    ATLMTestUser *user = [ATLMTestUser new];
    [user setFirstName:@"Layer"];
    [user setLastName:[NSString stringWithFormat:@"Tester%lu", (unsigned long)number]];
    [user setEmail:[NSString stringWithFormat:@"tester%lu@layer.com", (unsigned long)number]];
    [user setPassword:[NSString stringWithFormat:@"password%lu", (unsigned long)number]];
    [user setPasswordConfirmation:[NSString stringWithFormat:@"password%lu", (unsigned long)number]];
    return user;
}

@end
