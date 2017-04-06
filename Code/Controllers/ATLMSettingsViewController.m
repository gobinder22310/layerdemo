//
//  ATLMSettingsViewController.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 10/20/14.
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

#import "ATLMSettingsViewController.h"
#import <Atlas/Atlas.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ATLMSettingsHeaderView.h"
#import "ATLMCenterTextTableViewCell.h"
#import "ATLMStyleValue1TableViewCell.h"
#import "ATLLogoView.h"

typedef NS_ENUM(NSInteger, ATLMSettingsTableSection) {
    ATLMSettingsTableSectionInfo,
    ATLMSettingsTableSectionLegal,
    ATLMSettingsTableSectionLogout,
    ATLMSettingsTableSectionCount,
};

typedef NS_ENUM(NSInteger, ATLMInfoTableRow) {
    ATLMInfoTableRowAtlasVersion,
    ATLMInfoTableRowLayerKitVersion,
    ATLMInfoTableRowAppIDRow,
    ATLMInfoTableRowCount,
};

typedef NS_ENUM(NSInteger, ATLMLegalTableRow) {
    ATLMLegalTableRowAttribution,
    ATLMLegalTableRowTerms,
    ATLMLegalTableRowCount,
};


@interface ATLMSettingsViewController () <UITextFieldDelegate>

@property (nonatomic) ATLMSettingsHeaderView *headerView;
@property (nonatomic) ATLLogoView *logoView;

@end

@implementation ATLMSettingsViewController

NSString *const ATLMSettingsViewControllerTitle = @"Settings";
NSString *const ATLMSettingsTableViewAccessibilityIdentifier = @"Settings Table View";
NSString *const ATLMSettingsHeaderAccessibilityLabel = @"Settings Header";

NSString *const ATLMDefaultCellIdentifier = @"defaultTableViewCell";
NSString *const ATLMCenterTextCellIdentifier = @"centerContentTableViewCell";

NSString *const ATLMConnected = @"Connected";
NSString *const ATLMDisconnected = @"Disconnected";
NSString *const ATLMLostConnection = @"Lost Connection";
NSString *const ATLMConnecting = @"Connecting";

- (id)initWithStyle:(UITableViewStyle)style layerClient:(nonnull LYRClient *)layerClient
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = ATLMSettingsViewControllerTitle;
        _layerClient = layerClient;
    }
    return self;
}

- (nullable instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil layerClient:(nonnull LYRClient *)layerClient
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = ATLMSettingsViewControllerTitle;
        _layerClient = layerClient;
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder layerClient:(nonnull LYRClient *)layerClient
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = ATLMSettingsViewControllerTitle;
        _layerClient = layerClient;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call the designated initializer. Use initWithStyle:layerClient:" userInfo:nil];
}

- (id)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call the designated initializer. Use initWithNibName:bundle:layerClient:" userInfo:nil];
}

- (id)initWithCoder:(nonnull NSCoder *)aDecoder
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call the designated initializer. Use initWithCoder:layerClient:" userInfo:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[ATLMStyleValue1TableViewCell class] forCellReuseIdentifier:ATLMDefaultCellIdentifier];
    [self.tableView registerClass:[ATLMCenterTextTableViewCell class] forCellReuseIdentifier:ATLMCenterTextCellIdentifier];
    
    // Left navigation item
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneTapped:)];
    doneButton.accessibilityLabel = @"Done";
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.headerView = [ATLMSettingsHeaderView headerViewWithUser:self.layerClient.authenticatedUser];
    self.headerView.frame = CGRectMake(0, 0, 320, 148);
    self.headerView.accessibilityLabel = ATLMSettingsHeaderAccessibilityLabel;
    if (self.layerClient.isConnected){
        [self.headerView updateConnectedStateWithString:ATLMConnected];
    } else {
        [self.headerView updateConnectedStateWithString:ATLMDisconnected];
    }
    
    self.logoView = [[ATLLogoView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
    self.tableView.tableFooterView = self.logoView;
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.sectionHeaderHeight = 48.0f;
    self.tableView.rowHeight = 44.0f;
    self.tableView.accessibilityIdentifier = ATLMSettingsTableViewAccessibilityIdentifier;
    
    [self registerNotificationObservers];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ATLMSettingsTableSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case ATLMSettingsTableSectionInfo:
            return ATLMInfoTableRowCount;
            
        case ATLMSettingsTableSectionLegal:
            return ATLMLegalTableRowCount;
            
        case ATLMSettingsTableSectionLogout:
            return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ATLMSettingsTableSectionInfo: {
            UITableViewCell *cell = [self defaultCellForIndexPath:indexPath];
            switch (indexPath.row) {
                case ATLMInfoTableRowAtlasVersion:
                    cell.textLabel.text = @"Atlas Version";
                    cell.detailTextLabel.text = ATLVersionString;
                    break;

                case ATLMInfoTableRowLayerKitVersion:
                    cell.textLabel.text = @"LayerKit Version";
                    cell.detailTextLabel.text = LYRSDKVersionString;
                    break;
                    
                case ATLMInfoTableRowAppIDRow:
                    cell.textLabel.text = @"App ID";
                    cell.detailTextLabel.text = [self.layerClient.appID absoluteString];
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
                    break;
                    
                case ATLMInfoTableRowCount:
                    break;
            }
            return cell;
        }
            
        case ATLMSettingsTableSectionLegal: {
            UITableViewCell *cell = [self defaultCellForIndexPath:indexPath];
            switch (indexPath.row) {
                case ATLMLegalTableRowAttribution:
                    cell.textLabel.text = @"Attribution";
                    break;
            
                case ATLMLegalTableRowTerms:
                    cell.textLabel.text = @"Terms Of Service";
                    break;
            
                case ATLMLegalTableRowCount:
                    break;
            }
            return cell;
        }
            
        case ATLMSettingsTableSectionLogout: {
            ATLMCenterTextTableViewCell *centerCell = [self.tableView dequeueReusableCellWithIdentifier:ATLMCenterTextCellIdentifier forIndexPath:indexPath];
            centerCell.centerTextLabel.text = @"Log Out";
            centerCell.centerTextLabel.textColor = ATLRedColor();
            return centerCell;
        }

        case ATLMSettingsTableSectionCount:
            break;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case ATLMSettingsTableSectionInfo:
            return @"Info";

        case ATLMSettingsTableSectionLegal:
            return @"Legal";

        case ATLMSettingsTableSectionLogout:
        case ATLMSettingsTableSectionCount:
            return nil;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == ATLMSettingsTableSectionCount) {
        //TODO - Add Atlas Footer
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - Cell Configuration

- (UITableViewCell *)defaultCellForIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ATLMDefaultCellIdentifier forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ATLMSettingsTableSectionLogout:
            [self logOut];
            break;
        case ATLMSettingsTableSectionLegal:
            [self legalRowTapped:indexPath.row];
            break;
        default:
            break;
    }
}

#pragma mark - Actions

- (void)doneTapped:(UIControl *)sender
{
    [self.settingsDelegate settingsViewControllerDidFinish:self];
}

- (void)logOut
{
    if (self.layerClient.isConnected) {
        [self.settingsDelegate logoutTappedInSettingsViewController:self];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Cannot Logout. Layer is not connected"];
    }
    
}

- (void)legalRowTapped:(ATLMLegalTableRow)tableRow
{
    switch (tableRow) {
        case ATLMLegalTableRowAttribution:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/layerhq/Atlas-iOS#license"]];
            break;
        case ATLMLegalTableRowTerms:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://layer.com/terms"]];
            break;
        default:
            break;
    }
}

# pragma mark - Layer Connection State Monitoring

- (void)registerNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidConnect:) name:LYRClientDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidDisconnect:) name:LYRClientDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerIsConnecting:) name:LYRClientWillAttemptToConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidLoseConnection:) name:LYRClientDidLoseConnectionNotification object:nil];
}

- (void)layerDidConnect:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:ATLMConnected];
}

- (void)layerDidDisconnect:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:ATLMDisconnected];
}

- (void)layerIsConnecting:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:ATLMConnecting];
}

- (void)layerDidLoseConnection:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:ATLMLostConnection];
}

@end
