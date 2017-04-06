//
//  ATLMAuthenticationProvider.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 5/26/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
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
#import "ATLMAuthenticating.h"
#import "ATLMConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/*
 @abstract A key whose value should be the email address of an authenticating user.
 */
extern NSString * _Nonnull const ATLMEmailKey;

/*
 @abstract A key whose value should be the password of an authenticating user.
 */
extern NSString * _Nonnull const ATLMPasswordKey;

/**
 @abstract The `ATLMAuthenticationProvider` conforms to the `ATLMAuthenticating` protocol. It provides for making requests to the Layer Identity Provider in order to request identity tokens needed of LayerKit authentication.
 */
@interface ATLMAuthenticationProvider : NSObject <ATLMAuthenticating>

@property (nonatomic, copy, readonly) NSURL *layerAppID;

/**
 @abstract Initializes a `ATLMAuthenticationProvider` with a `ATLMConfiguration`
 */
- (instancetype)initWithConfiguration:(ATLMConfiguration *)configuration;
- (instancetype)initWithBaseURL:(nonnull NSURL *)baseURL layerAppID:(NSURL *)layerAppID NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/**
 @abstract The initializer for the `ATLMAuthenticationProvider`.
 @param baseURL The base url for the Layer Identity provider.
 */
+ (nonnull instancetype)providerWithBaseURL:(nonnull NSURL *)baseURL layerAppID:(nonnull NSURL *)layerAppID;

@end
NS_ASSUME_NONNULL_END
