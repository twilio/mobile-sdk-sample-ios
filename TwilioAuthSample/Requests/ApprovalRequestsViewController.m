//
//  ApprovalRequestsViewController.m
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 11/24/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import "ApprovalRequestsViewController.h"
#import <TwilioAuth/TwilioAuth.h>
#import "RequestDetailViewController.h"
#import "RequestTableViewCell.h"
#import "DeviceResetManager.h"

#import "AUTApprovalRequest+Extensions.h"
#import "UIColor+Extensions.h"
#import "Constants.h"

NSInteger const pendingTabIndex = 0;
NSInteger const archiveTabIndex = 1;

@interface ApprovalRequestsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *requestTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *noRequestsLabel;

@property (nonatomic, strong) NSArray *requests;

@end

@implementation ApprovalRequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureTableView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRequests) name:UIApplicationWillEnterForegroundNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self configureNavigationBarTopItems];

    [self loadRequests];
}

- (void)configureNavigationBarTopItems {

    [self.navigationController setNavigationBarHidden:NO];

    self.navigationController.navigationBar.topItem.title = @"Requests";

    // Left bar button item - Device ID
    UIBarButtonItem *deviceIdBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ID" style:UIBarButtonItemStylePlain target:self action:@selector(getDeviceId:)];
    [deviceIdBarButtonItem setTintColor:[UIColor colorWithHexString:defaultColor]];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = deviceIdBarButtonItem;

    // Right bar button item - Refresh
    UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    [refreshBarButtonItem setTintColor:[UIColor colorWithHexString:defaultColor]];
    self.navigationController.navigationBar.topItem.rightBarButtonItem = refreshBarButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)requestTypeChanged:(id)sender {

    [self loadRequests];
}

- (IBAction)refresh:(id)sender {
    [self loadRequests];
}

- (AUTApprovalRequestStatus)getStatusesForSelectedSegment {

    if ([self.requestTypeSegmentedControl selectedSegmentIndex] == pendingTabIndex) {
        return AUTApprovalRequestStatusPending;
    } else {
        return (AUTApprovalRequestStatusExpired | AUTApprovalRequestStatusApproved | AUTApprovalRequestStatusDenied);
    }
}

- (void)showAlertWhenError:(NSError *)error withTitle:(NSString *)title retry:(void (^)(void))retryBlock {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [cancelAction setValue:[UIColor colorWithHexString:defaultColor] forKey:@"titleTextColor"];
    [alertController addAction:cancelAction];

    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Refresh" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        retryBlock();
    }];
    [retryAction setValue:[UIColor colorWithHexString:defaultColor] forKey:@"titleTextColor"];

    [alertController addAction:retryAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)setMessageToNoRequestsLabel {

    if ([self.requestTypeSegmentedControl selectedSegmentIndex] == pendingTabIndex) {
        self.noRequestsLabel.text = @"You have no pending requests";
    } else {
        self.noRequestsLabel.text = @"You have no requests";
    }
}

- (void)loadRequests {

    TwilioAuth *sharedTwilioAuth = [TwilioAuth sharedInstance];

    AUTApprovalRequestStatus statuses = [self getStatusesForSelectedSegment];

    __weak ApprovalRequestsViewController *weakSelf = self;
    [sharedTwilioAuth getApprovalRequestsWithStatuses:statuses timeInterval:nil completion:^(AUTApprovalRequests *approvalRequests, NSError *error) {

        dispatch_async(dispatch_get_main_queue(), ^{

            if (error.code == AUTDeviceDeletedError) {
                [DeviceResetManager resetDeviceAndGetRegistrationViewForCurrentView:weakSelf withCustomTitle:nil];
                return;
            }

            // Show alert when error
            if (error) {
                weakSelf.requests = @[];

                [weakSelf showAlertWhenError:error withTitle:@"Request Error" retry:^{
                    [weakSelf loadRequests];
                }];

            } else {
                weakSelf.requests = [self getRequestsOrderedFromApprovalRequestsResponse:approvalRequests];
            }

            // Configure label when there are no requests
            if ([weakSelf.requests count] == 0) {
                weakSelf.noRequestsLabel.hidden = NO;
                [weakSelf setMessageToNoRequestsLabel];
            } else {
                weakSelf.noRequestsLabel.hidden = YES;
            }

            // Reload table
            [weakSelf.tableView reloadData];
        });

    }];
}

- (NSArray *)getRequestsOrderedFromApprovalRequestsResponse:(AUTApprovalRequests *)requestsResponse {

    NSMutableArray *requests = [[NSMutableArray alloc] init];

    if (requestsResponse.pending != nil && requestsResponse.pending.count > 0) {
        [requests addObjectsFromArray:requestsResponse.pending];
    }

    if (requestsResponse.approved != nil && requestsResponse.approved.count > 0) {
        [requests addObjectsFromArray:requestsResponse.approved];
    }

    if (requestsResponse.denied != nil && requestsResponse.denied.count > 0) {
        [requests addObjectsFromArray:requestsResponse.denied];
    }

    if (requestsResponse.expired != nil && requestsResponse.expired.count > 0) {
        [requests addObjectsFromArray:requestsResponse.expired];
    }

    NSArray *sortedRequests = [requests sortedArrayUsingComparator:^NSComparisonResult(AUTApprovalRequest *obj1, AUTApprovalRequest *obj2) {
        return obj1.creationTimestamp < obj2.creationTimestamp;
    }];

    return sortedRequests;

}

#pragma mark - Device ID
- (IBAction)getDeviceId:(id)sender {

    TwilioAuth *sharedTwilioAuth = [TwilioAuth sharedInstance];
    NSString *deviceId = [sharedTwilioAuth getDeviceId];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Device ID" message:deviceId preferredStyle:UIAlertControllerStyleAlert];

    // OK Action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [okAction setValue:[UIColor colorWithHexString:defaultColor] forKey:@"titleTextColor"];
    [alert addAction:okAction];

    // Logout Action
    __weak ApprovalRequestsViewController *weakSelf = self;
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {

        [sharedTwilioAuth clearLocalData];
        [DeviceResetManager resetDeviceAndGetRegistrationViewForCurrentView:weakSelf withCustomTitle:@"Local Data Deleted"];

    }];
    [alert addAction:logoutAction];

    // Present Alert
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table
- (void)configureTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"RequestTableViewCell" bundle:nil] forCellReuseIdentifier:@"request"];
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 90;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showRequest" sender:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.requests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    RequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"request" forIndexPath:indexPath];

    cell.preservesSuperviewLayoutMargins = NO;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;

    // Get current request
    NSMutableString *messageText = [NSMutableString stringWithString:@"No data available"];
    NSMutableString *expireTimeText = [NSMutableString stringWithString:@"No data available"];
    NSMutableString *timeAgoText = [NSMutableString stringWithString:@"x minutes ago"];

    if (indexPath.row < self.requests.count) {

        AUTApprovalRequest *request = [self.requests objectAtIndex:indexPath.row];
        [messageText setString:request.message];
        [expireTimeText setString:[request expiredDateAsString]];
        [timeAgoText setString:[request timeAgoAsString]];
    }

    [cell setMessageText:messageText];
    [cell setExpireTimeText:expireTimeText];
    [cell setTimeAgoText:timeAgoText];

    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if (![segue.identifier isEqualToString:@"showRequest"]) {
        return;
    }

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

    AUTApprovalRequest *request = [self.requests objectAtIndex:indexPath.row];

    RequestDetailViewController *requestDetailViewController = segue.destinationViewController;
    requestDetailViewController.approvalRequest = request;
}
@end
