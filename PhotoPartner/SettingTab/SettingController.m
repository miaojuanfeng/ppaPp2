//
//  SettingController.m
//  PhotoPartner
//
//  Created by USER on 7/3/2018.
//  Copyright © 2018 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "SettingController.h"
#import "UserInfoController.h"
#import "AboutUsController.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>

@interface SettingController () <UITableViewDataSource, UITableViewDelegate>
@property UITableView *tableView;

@property AppDelegate *appDelegate;
@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.navigationItem.title = NSLocalizedString(@"settingNavigationItemTitle", nil);
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, MARGIN_TOP, VIEW_WIDTH, VIEW_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @" ";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    //cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"formCell"];

    
    if( indexPath.section == 0 ){
        switch( indexPath.row ){
            case 0:
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = NSLocalizedString(@"settingCellUserInfoTitle", nil);
                //cell.detailTextLabel.text = [[self.appDelegate.userInfo objectForKey:@"user_nickname"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                break;
            case 1:
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = NSLocalizedString(@"settingCellClearMessageTitle", nil);
                break;
            case 2:
//                cell.textLabel.text = NSLocalizedString(@"settingCellVersionTitle", nil);;
                cell.detailTextLabel.text = @"1.0.7";
                cell.textLabel.text = NSLocalizedString(@"aboutUsVersion", nil);
                break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UserInfoController *userInfoController;
    AboutUsController *aboutUsController;
    if( indexPath.section == 0 ){
        switch (indexPath.row) {
            case 0:
                userInfoController = [[UserInfoController alloc] init];
                [self.navigationController pushViewController:userInfoController animated:YES];
                break;
            case 1:
                [self clickClearMessage];
                break;
            case 2:
//                [self versionUpdate];
            /*
                aboutUsController = [[AboutUsController alloc] init];
                [self.navigationController pushViewController:aboutUsController animated:YES];*/
                break;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)versionUpdate{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{@"apk_id":@"1"};
    HUD_WAITING_SHOW(NSLocalizedString(@"hudLoading", nil));
    [manager POST:BASE_URL(@"user/version") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        NSLog(@"results: %@", dic);
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        HUD_WAITING_HIDE;
        if( status == 200 ){
            NSDictionary *data = [dic objectForKey:@"data"];
            if( [[data objectForKey:@"last_version"] intValue] > self.appDelegate.appVersion ){
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"versionNewTitle", nil) message:NSLocalizedString(@"versionNewDesc", nil) preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmCancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertController addAction:okAction];           // A
                [alertController addAction:cancelAction];       // B
                
                [self presentViewController:alertController animated:YES completion:nil];
            }else{
                HUD_TOAST_SHOW(NSLocalizedString(@"versionAlreadyLastVersion", nil));
            }
        }else{
            NSString *eCode = [NSString stringWithFormat:@"e%d", status];
            HUD_TOAST_SHOW(NSLocalizedString(eCode, nil));
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败.%@",error);
        NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        
        HUD_WAITING_HIDE;
        HUD_TOAST_SHOW(NSLocalizedString(@"networkError", nil));
    }];
}

- (void)clickClearMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"clearMessageListTitle", nil) message:NSLocalizedString(@"clearMessageListSubtitle", nil) preferredStyle:UIAlertControllerStyleAlert];
                
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.appDelegate clearMessageList];
        HUD_TOAST_SHOW(NSLocalizedString(@"clearMessageListDone", nil));
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmCancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
    }];
                
    [alertController addAction:okAction];           // A
    [alertController addAction:cancelAction];       // B
                
    [self presentViewController:alertController animated:YES completion:nil];
}

@end

