//
//  ATLMErrors.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/26/14.
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

#import <Foundation/Foundation.h>

extern NSString *const ATLMErrorDomain;

typedef NS_ENUM(NSUInteger, ATLMAuthenticationError) {
    ATLMErrorUnknownError                            = 7000,
    
    /* Messaging Errors */
    ATLMInvalidFirstName                              = 7001,
    ATLMInvalidLastName                               = 7002,
    ATLMInvalidEmailAddress                           = 7003,
    ATLMInvalidPassword                               = 7004,
    ATLMInvalidAuthenticationNonce                    = 7005,
    ATLMNoAuthenticatedSession                        = 7006,
    ATLMRequestInProgress                             = 7007,
    ATLMInvalidAppIDString                            = 7008,
    ATLMInvalidAppID                                  = 7009,
    ATLMInvalidIdentityToken                          = 7010,
    ATLMDeviceTypeNotSupported                        = 7011,
    ATLMAuthenticationErrorNoDataTransmitted          = 7012
};
