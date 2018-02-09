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
@property (nonatomic, strong) NSArray *apps;
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
    [self.twilioAuthenticator setMultiAppDelegate:self];
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
    return self.apps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sdk_apps_cell_id" forIndexPath:indexPath];

    NSInteger row = indexPath.row;
    AUTApp *currentApp = [self.apps objectAtIndex:row];
    cell.textLabel.text = currentApp.name;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger currentAppIndex = indexPath.row;
    AUTApp *currentApp;
    if (self.apps.count > currentAppIndex) {
        currentApp = [self.apps objectAtIndex:currentAppIndex];
    }

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UITabBarController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"tabBarController"];
    ApprovalRequestsViewController *approvalRequestsViewController = [viewController.childViewControllers objectAtIndex:0];
    approvalRequestsViewController.currentApp = currentApp;

    TOTPViewController *totpViewController = [viewController.childViewControllers objectAtIndex:1];
    totpViewController.currentAppId = currentApp.appId;

    [self.navigationController pushViewController:viewController animated:YES];
    
}

#pragma mark - Delegation
- (void)didUpdateApps:(NSArray<AUTApp*> *)apps {

    NSMutableArray *currentApps = [[NSMutableArray alloc] initWithArray:self.apps];
    int index = 0;
    for (AUTApp *app in self.apps) {

        NSPredicate *appIdPredicate = [NSPredicate predicateWithFormat:@"SELF.appId == %@", app.appId];
        NSArray *filteredApps = [apps filteredArrayUsingPredicate: appIdPredicate];

        if (filteredApps.count == 1) {
            [currentApps replaceObjectAtIndex:index withObject:app];
        }

        index ++;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        self.apps = currentApps;
        [self.tableView reloadData];
        [self.tableView endUpdates];
    });
}

- (void)didAddApps:(NSArray<AUTApp *> *)apps {
    NSMutableArray *currentApps = [[NSMutableArray alloc] initWithArray:self.apps];
    [currentApps addObjectsFromArray:apps];
    self.apps = currentApps;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didDeleteApps:(NSArray<NSNumber *> *)appsId {

    NSMutableArray *currentApps = [[NSMutableArray alloc] initWithArray:self.apps];
    for (NSNumber *appId in appsId) {

        NSPredicate *appIdPredicate = [NSPredicate predicateWithFormat:@"appId == %@", appId];
        NSArray *filteredApps = [currentApps filteredArrayUsingPredicate:appIdPredicate];
        if (filteredApps.count == 1) {
            [currentApps removeObjectsInArray:filteredApps];
        }
    }

    self.apps = currentApps;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didReceiveCodes:(NSArray<AUTApp *> *)apps {

    NSLog(@"******* RECEIVE CODES");

    self.apps = apps;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

 - (void)didFail:(NSError *)error {

     NSLog(@"******* FAILS");

     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];

     // OK Action
     UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
     [okAction setValue:[UIColor colorWithHexString:defaultColor] forKey:@"titleTextColor"];
     [alert addAction:okAction];

     // Present Alert
     dispatch_async(dispatch_get_main_queue(), ^{
         [self presentViewController:alert animated:YES completion:nil];
     });
}

@end
