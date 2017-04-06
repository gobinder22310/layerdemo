//
//  ATLMConfiguration.h
//  Atlas Messenger
//
//  Created by JP McGlone 01/04/2017
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

NS_ASSUME_NONNULL_BEGIN

/**
 @abstract The purpose of this class is to deserialize JSON values from a
   configuration file into @c appID and @c identityProviderURL properties.
   The input configuration file (@c fileURL) should be a text encoded JSON
   structure containing two values keyed by "app_id" and "identity_provider_url".
   The JSON structure should have no root key elements.
 @discussion See the following JSON structure example
 @code
 {
   "app_id": "layer:///apps/staging/00000000-0000-0000-0000-000000000000",
   "identity_provider_url" : "https://foo.bar"
 }
 @endcode
 */
@interface ATLMConfiguration : NSObject

/**
 @abstract The optional deserialized value of the `name` found in the input
 JSON configuration file.
 @see -initWithFileURL:
 */
@property (nullable, nonatomic, readonly) NSString *name;

/**
 @abstract The deserialized value of the `appID` found in the input
   JSON configuration file.
 @see -initWithFileURL:
 */
@property (nonatomic, readonly) NSURL *appID;

/**
 @abstract The deserialized value of the `identityProviderURL` found in the
   input JSON configuration file.
 @see -initWithFileURL:
 */
@property (nonatomic, readonly) NSURL *identityProviderURL;

/**
 @abstract Initializes an `ATLMConfiguration` instance and loads the values
   from the input JSON file (`fileURL`) into the instance properties.
 @param fileURL A file path in a form of an `NSURL` instance pointing to 
   a configuration text file, containing a JSON structure.
 @return Returns an intialized instance of `ATLMConfiguration`.
 */
- (instancetype)initWithFileURL:(nonnull NSURL *)fileURL NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE; 

@end

NS_ASSUME_NONNULL_END
