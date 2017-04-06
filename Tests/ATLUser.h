//
//  LYRUIUser.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYRUIUser : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *passwordConfirmation;
@property (nonatomic, readonly) NSString *participantIdentifier;

+ (instancetype)testUserWithNumber:(NSUInteger)number;

@end
