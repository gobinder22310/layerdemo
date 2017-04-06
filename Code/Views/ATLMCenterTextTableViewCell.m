//
//  ATLMCenterTextTableViewCell.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 10/24/14.
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

#import "ATLMCenterTextTableViewCell.h"

@implementation ATLMCenterTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.centerTextLabel = [[UILabel alloc] init];
        self.centerTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.centerTextLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.centerTextLabel];
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
}

@end
