//
//  AppsTableViewController.m
//  TwilioAuthenticatorSample
//
//  Created by Adriana Pineda on 11/17/17.
//  Copyright © 2017 Authy. All rights reserved.
//

#import "AppsTableViewController.h"
#import "ApprovalRequestsViewController.h"
#import "TOTPViewController.h"

#import "DeviceResetManager.h"

@interface AppsTableViewController ()

@property (nonatomic, strong) TwilioAuthenticator *twilioAuthenticator;
@property (nonatomic) BOOL appsTableExists;
@end

@implementation AppsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.twilioAuthenticator = [TwilioAuthenticator sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadApps:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {

    self.navigationController.navigationBar.topItem.rightBarButtonItem = nil;
    
    // Left bar button item - Device ID
    UIBarButtonItem *deviceIdBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ID" style:UIBarButtonItemStylePlain target:self action:@selector(getIDs:)];
    [deviceIdBarButtonItem setTintColor:[UIColor colorWithHexString:defaultColor]];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = deviceIdBarButtonItem;

    self.tableView.tableFooterView = [[UIView alloc] init];

    if(!self.appsTableExists) {
        self.appsTableExists = YES;
    } else {
        // Reload apps table when coming back
        [self reloadApps:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)getApps {

    return [self.twilioAuthenticator getApps];
}

- (void) reloadApps:(NSNotification *) ignored {
    [self.tableView reloadData];
}

#pragma mark - Get IDs
- (IBAction)getIDs:(id)sender {

    TwilioAuthenticator *sharedTwilioAuth = [TwilioAuthenticator sharedInstance];
    NSString *deviceId = [sharedTwilioAuth getDeviceId];
    NSString *authyId = [sharedTwilioAuth getAuthyId];

    NSString *message = [NSString stringWithFormat:@"Device Id: %@\rAuthy Id: %@",deviceId, authyId];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IDs" message:message preferredStyle:UIAlertControllerStyleAlert];

    // OK Action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [okAction setValue:[UIColor colorWithHexString:defaultColor] forKey:@"titleTextColor"];
    [alert addAction:okAction];

    // Logout Action
    __weak AppsTableViewController *weakSelf = self;
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {

        [sharedTwilioAuth clearLocalData];
        [DeviceResetManager resetDeviceAndGetRegistrationViewForCurrentView:weakSelf withCustomTitle:@"Local Data Deleted"];

    }];
    [alert addAction:logoutAction];

    // Present Alert
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getApps].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sdk_apps_cell_id" forIndexPath:indexPath];

    AUTApp *currentApp = [[self getApps] objectAtIndex:indexPath.row];
    cell.textLabel.text = currentApp.name;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO

    NSInteger currentAppIndex = indexPath.row;
    AUTApp *currentApp = [[self getApps] objectAtIndex:currentAppIndex];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UITabBarController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"tabBarController"];
    ApprovalRequestsViewController *approvalRequestsViewController = [viewController.childViewControllers objectAtIndex:0];
    approvalRequestsViewController.currentApp = currentApp;

    TOTPViewController *totpViewController = [viewController.childViewControllers objectAtIndex:1];
    totpViewController.currentAppId = currentApp.serialId;

    [self.navigationController pushViewController:viewController animated:YES];
    
}
/*
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSInteger currentAppIndex = indexPath.row;
    App *currentApp = [[self getApps] objectAtIndex:currentAppIndex];

    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

    UITabBarController *viewController = segue.destinationViewController;
    ApprovalRequestsViewController *approvalRequestsViewController = [viewController.childViewControllers objectAtIndex:0];
    approvalRequestsViewController.currentApp = currentApp;

    TOTPViewController *totpViewController = [viewController.childViewControllers objectAtIndex:1];
    totpViewController.currentAppId = currentApp.serialId;
}*/

@end
