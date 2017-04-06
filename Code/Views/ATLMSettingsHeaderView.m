//
//  ATLMSettingsHeaderView.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 10/23/14.
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

#import "ATLMSettingsHeaderView.h"
#import <Atlas/Atlas.h>

@interface ATLMSettingsHeaderView ()

@property (nonatomic) LYRIdentity *user;
@property (nonatomic) ATLAvatarImageView *imageView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *connectionStateLabel;
@property (nonatomic) UIView *bottomBorder;

@end

@implementation ATLMSettingsHeaderView

static CGFloat const ATLMAvatarDiameter = 72;

+ (instancetype)headerViewWithUser:(LYRIdentity *)user
{
    return [[self alloc] initHeaderViewWithUser:user];
}

- (id)initHeaderViewWithUser:(LYRIdentity *)user
{
    self = [super init];
    if (self) {
        _user = user;
        self.backgroundColor = [UIColor whiteColor];

        _imageView = [[ATLAvatarImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.initialsFont = ATLLightFont(22);
        _imageView.initialsColor = ATLGrayColor();
        _imageView.backgroundColor = ATLLightGrayColor();
        _imageView.layer.cornerRadius = ATLMAvatarDiameter / 2;
        _imageView.avatarItem = (id<ATLAvatarItem>)user;
        [self addSubview:_imageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.text = user.displayName;
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = ATLGrayColor();
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nameLabel];
        
        _connectionStateLabel = [[UILabel alloc] init];
        _connectionStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _connectionStateLabel.font = [UIFont systemFontOfSize:14];
        _connectionStateLabel.textColor = ATLBlueColor();
        _connectionStateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_connectionStateLabel];
    
        _bottomBorder = [[UIView alloc] init];
        _bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBorder.backgroundColor = ATLGrayColor();
        [self addSubview:_bottomBorder];

        [self configureAvatarImageViewConstraints];
        [self configureNameLabelConstraints];
        [self configureConnectionLabelConstraints];
        [self configureBottomBorderConstraints];
    }
    return self;
}

- (void)configureAvatarImageViewConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ATLMAvatarDiameter]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ATLMAvatarDiameter]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:20]];
}

- (void)configureNameLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:4]];
}

- (void)configureConnectionLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:20]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
}

- (void)configureBottomBorderConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder  attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
}

- (void)updateConnectedStateWithString:(NSString *)string
{
    self.connectionStateLabel.text = string;
}

@end
