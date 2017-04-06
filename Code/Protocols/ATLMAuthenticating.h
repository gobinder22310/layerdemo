//
//  ATLMAuthenticating.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 5/24/16.
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

/**
 @abstract The `ATLMAuthenticating` protocol must be adopted by objects that model users in the Atlas Messenger application.
 */
@protocol ATLMAuthenticating <NSObject>

@required

/**
 @abstract Requests an identity token required for Layer authentication with the supplied credentials and nonce.
 @param credentials An `NSDictionary` containing the credentials needed to request the identity token.
 @param nonce A nonce required for the identity token.
 @param completion A block to be called upon completion of the operation.
 */
- (void)authenticateWithCredentials:(nonnull NSDictionary *)credentials nonce:(nonnull NSString *)nonce completion:(nonnull void (^)(NSString * _Nullable identityToken, NSError * _Nullable error))completion;

/**
 @abstract Requests a new identity token with the supplied nonce.
 @param nonce A nonce required for the identity token.
 @param completion A block to be called upon completion of the operation.
 */
- (void)refreshAuthenticationWithNonce:(nonnull NSString *)nonce completion:(nonnull void (^)(NSString * _Nullable identityToken, NSError * _Nullable error))completion;

@end
