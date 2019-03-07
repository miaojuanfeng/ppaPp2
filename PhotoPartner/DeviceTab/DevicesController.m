//
//  LoginController.m
//  PhotoPartner
//
//  Created by Dreamover on 2019/1/11.
//  Copyright © 2019年 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "DevicesController.h"
#import "AddDeviceController.h"
#import "AvaDeviceController.h"
#import "DetailController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD.h>
#import "LoginController.h"
#import "DeviceNameController.h"

@interface DevicesController ()
@property UIScrollView *scrollView;

@property AppDelegate *appDelegate;

@property NSInteger marginTop;
@end

@implementation DevicesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    
    self.navigationItem.title = NSLocalizedString(@"deviceListNavigationItemTitle", nil);
    
    INIT_RightBarButtonItem(ICON_REFRESH, clickRefreshButton);
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.marginTop = MARGIN_TOP;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, MARGIN_TOP, GET_LAYOUT_WIDTH(self.view), GET_LAYOUT_HEIGHT(self.view)-MARGIN_TOP)];
    
    [self.view addSubview:self.scrollView];
    
    [self updateLayout];
    
    NSLog(@"%@", self.appDelegate.deviceList);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [self updateLayout];
}

- (void)clickRefreshButton {
    HUD_WAITING_SHOW(NSLocalizedString(@"Loading", nil));
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{
                               @"user_id":[self.appDelegate.userInfo objectForKey:@"user_id"]
                               };
    
    //加入header参数
    [manager.requestSerializer setValue:[self.appDelegate.userInfo objectForKey:@"user_system_token"] forHTTPHeaderField:@"user_token"];
    [manager POST:BASE_URL(@"user/user_device") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        HUD_WAITING_HIDE;
        if( status == 200 ){
            self.appDelegate.deviceList = [[dic objectForKey:@"data"] mutableCopy];
            [self.appDelegate saveDeviceList];
            
            NSLog(@"%@", dic);
            //[self.tableView reloadData];
            [self updateLayout];
            
        } else if ( status == 418 ) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UserSystemTokenError", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.appDelegate deleteUserInfo];
                self.appDelegate.isLogout = true;
                LoginController *loginController = [[LoginController alloc] init];
                [self.navigationController pushViewController:loginController animated:YES];
            }];
            
            [alertController addAction:okAction];           // A
            
            [self presentViewController:alertController animated:YES completion:nil];
        } else if ( status == 405 ) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UserSystemTokenError", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.appDelegate deleteUserInfo];
                self.appDelegate.isLogout = true;
                LoginController *loginController = [[LoginController alloc] init];
                [self.navigationController pushViewController:loginController animated:YES];
            }];
            
            [alertController addAction:okAction];           // A
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败.%@",error);
        NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        
        HUD_WAITING_HIDE;
    }];
}

-(void)clearView{
    NSArray *views = [self.scrollView subviews];
    for(UIView *view in views){
        [view removeFromSuperview];
    }
    self.scrollView.frame = CGRectMake(0, self.marginTop, GET_LAYOUT_WIDTH(self.view), GET_LAYOUT_HEIGHT(self.view)-self.marginTop);
}

- (void)updateLayout{
    long offsetTop = GAP_HEIGHT;
    long messageWidth = GET_LAYOUT_WIDTH(self.scrollView)-GAP_WIDTH*4;
    float fontSize = 14;
    UIColor *lineColor = RGBA_COLOR(200, 200, 200, 1);
    int count = 0;
    
    [self clearView];
 
    UIView *myDeviceView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 36)];
        UILabel *myDeviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(myDeviceView), GET_LAYOUT_HEIGHT(myDeviceView))];
        myDeviceLabel.font = [UIFont systemFontOfSize:fontSize];
        myDeviceLabel.text = NSLocalizedString(@"MyDeviceLabel", nil);
        myDeviceLabel.textColor = [UIColor blueColor];
        [myDeviceView addSubview:myDeviceLabel];
        UIButton *myDeviceButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(myDeviceView)-20, 8, 20, 20)];
        UIImageView *myDeviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0-5, 0-5, GET_LAYOUT_WIDTH(myDeviceButton)+10, GET_LAYOUT_HEIGHT(myDeviceButton)+10)];
        myDeviceImageView.image = [UIImage imageNamed:@"ic_add_blue"];
        [myDeviceButton addSubview:myDeviceImageView];
        [myDeviceButton addTarget:self action:@selector(clickAddMyDeviceButton) forControlEvents:UIControlEventTouchUpInside];
        [myDeviceView addSubview:myDeviceButton];
    
    offsetTop+=GET_LAYOUT_HEIGHT(myDeviceView);
    self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
    [self.scrollView addSubview:myDeviceView];
    for(int i=0;i<self.appDelegate.deviceList.count;i++){
        NSMutableDictionary *device = [self.appDelegate.deviceList objectAtIndex:i];
        if( [[device objectForKey:@"isAdmin"] isEqualToString:@"mydevice"] ){
            long messageHeight = 0;
            UIButton *devicesView = [[UIButton alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 60)];
            
            if ([[device objectForKey:@"isAccepted"] intValue] == 1) {
                devicesView.tag = i;
                [devicesView addTarget:self action:@selector(clickDeviceDetailButton:) forControlEvents:UIControlEventTouchUpInside];
                
                UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(devicesView)-1, GET_LAYOUT_WIDTH(devicesView), 1)];
                lineView.backgroundColor = lineColor;
                [devicesView addSubview:lineView];
                UILabel *deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(devicesView), GET_LAYOUT_HEIGHT(devicesView)/2)];
                NSString *device_token = [NSString stringWithFormat:@"(%@)", [device objectForKey:@"device_token"]];
                NSString *deviceLabel_txt = [NSString stringWithFormat:@"%@%@",[device objectForKey:@"device_name"], device_token];
                NSRange device_token_range = [deviceLabel_txt rangeOfString:device_token];
                UIColor *device_token_color = RGBA_COLOR(128, 128, 128, 1);
                NSMutableAttributedString *deviceLabel_txt_attributedStr = [[NSMutableAttributedString alloc] initWithString:deviceLabel_txt];
                [deviceLabel_txt_attributedStr addAttributes:@{NSForegroundColorAttributeName:device_token_color} range:device_token_range];
                deviceLabel.attributedText = deviceLabel_txt_attributedStr;
                deviceLabel.font = [UIFont systemFontOfSize:15];
                [devicesView addSubview:deviceLabel];
                
                UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(devicesView)/2-5, GET_LAYOUT_WIDTH(devicesView)-60, GET_LAYOUT_HEIGHT(devicesView)/2)];
                emailLabel.text = [device objectForKey:@"device_email"];
                
                emailLabel.textColor = RGBA_COLOR(128, 128, 128, 1);
                emailLabel.font = [UIFont systemFontOfSize:fontSize];
                [devicesView addSubview:emailLabel];
                
    //            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(devicesView)/2-5, GET_LAYOUT_WIDTH(devicesView)/2, GET_LAYOUT_HEIGHT(devicesView)/2)];
    //            nameLabel.text = [device objectForKey:@"device_token"];
    //
    //            nameLabel.textColor = RGBA_COLOR(128, 128, 128, 1);
    //            nameLabel.font = [UIFont systemFontOfSize:fontSize];
    //            [devicesView addSubview:nameLabel];
                
    //            UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(devicesView)/2-30, GET_LAYOUT_HEIGHT(devicesView)/2-5, GET_LAYOUT_WIDTH(devicesView)/2-70, GET_LAYOUT_HEIGHT(devicesView)/2)];
    //            emailLabel.text = [self.appDelegate.userInfo objectForKey:@"userEmail"];
    //            emailLabel.textAlignment = NSTextAlignmentRight;
    //            emailLabel.textColor = RGBA_COLOR(128, 128, 128, 1);
    //            emailLabel.font = [UIFont systemFontOfSize:fontSize];
    //            [devicesView addSubview:emailLabel];
                
                UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(devicesView)-80, 15, 30, 30)];
                settingButton.tag = i;
                [settingButton addTarget:self action:@selector(clickSettingButton:) forControlEvents:UIControlEventTouchUpInside];
                UIImageView *settingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-5, 0, GET_LAYOUT_WIDTH(settingButton)+10, GET_LAYOUT_HEIGHT(settingButton)+10)];
                settingImageView.image = [UIImage imageNamed:@"ic_edit_black"];
                [settingButton addSubview:settingImageView];
                [devicesView addSubview:settingButton];
                
                UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(devicesView)-40, 15, 30, 30)];
                //deleteButton.backgroundColor = [UIColor blueColor];
                deleteButton.tag = i;
                [deleteButton addTarget:self action:@selector(clickDeleteDeviceButton:) forControlEvents:UIControlEventTouchUpInside];
                UIImageView *deleteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-5, 0, GET_LAYOUT_WIDTH(deleteButton)+10, GET_LAYOUT_HEIGHT(deleteButton)+10)];
                deleteImageView.image = [UIImage imageNamed:@"ic_delete_black"];
                [deleteButton addSubview:deleteImageView];
                [devicesView addSubview:deleteButton];
            } else {
                UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(devicesView)-1, GET_LAYOUT_WIDTH(devicesView), 1)];
                lineView.backgroundColor = lineColor;
                [devicesView addSubview:lineView];
                UILabel *deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, GET_LAYOUT_WIDTH(devicesView), GET_LAYOUT_HEIGHT(devicesView)/2)];
                NSString *device_token = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"waitingForConfirmation", nil)];
                NSString *deviceLabel_txt = [NSString stringWithFormat:@"%@%@",[device objectForKey:@"device_name"], device_token];
                NSRange device_token_range = [deviceLabel_txt rangeOfString:device_token];
                UIColor *device_token_color = RGBA_COLOR(128, 128, 128, 1);
                NSMutableAttributedString *deviceLabel_txt_attributedStr = [[NSMutableAttributedString alloc] initWithString:deviceLabel_txt];
                [deviceLabel_txt_attributedStr addAttributes:@{NSForegroundColorAttributeName:device_token_color} range:device_token_range];
                deviceLabel.attributedText = deviceLabel_txt_attributedStr;
                deviceLabel.font = [UIFont systemFontOfSize:15];
                [devicesView addSubview:deviceLabel];
            }
            
            messageHeight = GET_LAYOUT_HEIGHT(devicesView);
       
            offsetTop+=messageHeight;
            self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
            [self.scrollView addSubview:devicesView];
            
            count++;
        }
    }
    if(count<4){
        for(int i=0;i<(4-count);i++){
            long messageHeight = 0;
            UIView *devicesView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 60)];
            
            messageHeight = GET_LAYOUT_HEIGHT(devicesView);
            
            offsetTop+=messageHeight;
            self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
            [self.scrollView addSubview:devicesView];
        }
    }
    offsetTop+=GAP_HEIGHT*4;
    UIView *boundDeviceView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 36)];
        UILabel *boundDeviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(myDeviceView), GET_LAYOUT_HEIGHT(myDeviceView))];
        boundDeviceLabel.font = [UIFont systemFontOfSize:fontSize];
        boundDeviceLabel.text = NSLocalizedString(@"AvaDeviceLabel", nil);
        boundDeviceLabel.textColor = [UIColor blueColor];
        [boundDeviceView addSubview:boundDeviceLabel];
        UIButton *boundDeviceButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(myDeviceView)-20, 8, 20, 20)];
        UIImageView *boundDeviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0-5, 0-5, GET_LAYOUT_WIDTH(myDeviceButton)+10, GET_LAYOUT_HEIGHT(myDeviceButton)+10)];
        boundDeviceImageView.image = [UIImage imageNamed:@"ic_add_blue"];
        [boundDeviceButton addSubview:boundDeviceImageView];
        [boundDeviceButton addTarget:self action:@selector(clickAddBoundDeviceButton) forControlEvents:UIControlEventTouchUpInside];
        [boundDeviceView addSubview:boundDeviceButton];
    
    offsetTop+=GET_LAYOUT_HEIGHT(boundDeviceView);
    self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
    [self.scrollView addSubview:boundDeviceView];
    for(int i=0;i<self.appDelegate.deviceList.count;i++){
        NSMutableDictionary *device = [self.appDelegate.deviceList objectAtIndex:i];
        if( [[device objectForKey:@"isAdmin"] isEqualToString:@"bounddevice"] ){
            long messageHeight = 0;
            UIView *devicesView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 50)];
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(devicesView)-1, GET_LAYOUT_WIDTH(devicesView), 1)];
            lineView.backgroundColor = lineColor;
            [devicesView addSubview:lineView];
            UILabel *deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(devicesView), GET_LAYOUT_HEIGHT(devicesView))];
//            deviceLabel.text = [device objectForKey:@"device_token"];
            if ([[device objectForKey:@"isAccepted"] intValue] == 1) {
                deviceLabel.text = [device objectForKey:@"device_name"];
            } else {
                NSString *device_token = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"waitingForConfirmation", nil)];
                NSString *deviceLabel_txt = [NSString stringWithFormat:@"%@%@",[device objectForKey:@"device_name"], device_token];
                NSRange device_token_range = [deviceLabel_txt rangeOfString:device_token];
                UIColor *device_token_color = RGBA_COLOR(128, 128, 128, 1);
                NSMutableAttributedString *deviceLabel_txt_attributedStr = [[NSMutableAttributedString alloc] initWithString:deviceLabel_txt];
                [deviceLabel_txt_attributedStr addAttributes:@{NSForegroundColorAttributeName:device_token_color} range:device_token_range];
                deviceLabel.attributedText = deviceLabel_txt_attributedStr;
            }

            deviceLabel.font = [UIFont systemFontOfSize:15];
            [devicesView addSubview:deviceLabel];
            
            if ([[device objectForKey:@"isAccepted"] intValue] == 1) {
                UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(devicesView)-80, 15, 30, 30)];
                settingButton.tag = i;
                [settingButton addTarget:self action:@selector(clickSettingButton:) forControlEvents:UIControlEventTouchUpInside];
                UIImageView *settingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0-5, 0-5, GET_LAYOUT_WIDTH(settingButton)+10, GET_LAYOUT_HEIGHT(settingButton)+10)];
                settingImageView.image = [UIImage imageNamed:@"ic_edit_black"];
                [settingButton addSubview:settingImageView];
                [devicesView addSubview:settingButton];
                
                UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(devicesView)-40, 15, 30, 30)];
                //deleteButton.backgroundColor = [UIColor blueColor];
                deleteButton.tag = i;
                [deleteButton addTarget:self action:@selector(clickDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
                UIImageView *deleteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0-5, 0-5, GET_LAYOUT_WIDTH(deleteButton)+10, GET_LAYOUT_HEIGHT(deleteButton)+10)];
                deleteImageView.image = [UIImage imageNamed:@"ic_delete_black"];
                [deleteButton addSubview:deleteImageView];
                [devicesView addSubview:deleteButton];
            }
            
            messageHeight = GET_LAYOUT_HEIGHT(devicesView);
            
            offsetTop+=messageHeight;
            self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
            [self.scrollView addSubview:devicesView];
        }
    }
    
}

-(void)clickAddMyDeviceButton{
    AddDeviceController *addDeviceController = [[AddDeviceController alloc] init];
    [self.navigationController pushViewController:addDeviceController animated:YES];
}

-(void)clickAddBoundDeviceButton{
    AvaDeviceController *avaDeviceController = [[AvaDeviceController alloc] init];
    [self.navigationController pushViewController:avaDeviceController animated:YES];
}

-(void)clickDeviceDetailButton:(UIButton *)btn{
    NSMutableDictionary *device = [self.appDelegate.deviceList objectAtIndex:btn.tag];
    DetailController *detailController = [[DetailController alloc] init];
    if( [[device objectForKey:@"isAcceptNewUsers"] isEqualToString:@"1"] ){
        detailController.isAcceptNewUsers = true;
    }else{
        detailController.isAcceptNewUsers = false;
    }
    detailController.deviceId = [[device objectForKey:@"device_id"] integerValue];
    [self.navigationController pushViewController:detailController animated:YES];
}

-(void)clickDeleteButton:(UIButton *)btn{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"deviceListUnbindConfirmTitle", nil)
                                                                             message:NSLocalizedString(@"deviceListUnbindConfirmSubtitle", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableDictionary *device = [self.appDelegate.deviceList objectAtIndex:btn.tag];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 30.0f;
        NSDictionary *parameters=@{
                                   @"user_id":[self.appDelegate.userInfo objectForKey:@"user_id"],
                                   @"device_id":[device objectForKey:@"device_id"],
                                   @"status":@"unbind"
                                   };
        HUD_WAITING_SHOW(NSLocalizedString(@"loadingUnbinding", nil));
        [manager POST:BASE_URL(@"device/status") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float progress = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
                
                HUD_LOADING_PROGRESS(progress);
            });
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"成功.%@",responseObject);
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
            NSLog(@"results: %@", dic);
            
            int status = [[dic objectForKey:@"status"] intValue];
            
            HUD_WAITING_HIDE;
            if( status == 200 ){
                [self.appDelegate.deviceList removeObjectAtIndex:btn.tag];
                [self.appDelegate saveDeviceList];
                [self updateLayout];
                HUD_TOAST_SHOW(NSLocalizedString(@"deviceListUnbindSuccess", nil));
            }else{
                NSString *eCode = [NSString stringWithFormat:@"e%d", status];
                HUD_TOAST_SHOW(NSLocalizedString(eCode, nil));
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"失败.%@",error);
            NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
            
            HUD_WAITING_HIDE;
            HUD_TOAST_SHOW(NSLocalizedString(@"deviceListUnbindFailed", nil));
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmCancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:okAction];           // A
    [alertController addAction:cancelAction];       // B
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)clickDeleteDeviceButton:(UIButton *)btn{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"deviceListUnbindConfirmTitle", nil)
                                                                             message:NSLocalizedString(@"deviceListUnbindConfirmSubtitle", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableDictionary *device = [self.appDelegate.deviceList objectAtIndex:btn.tag];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 30.0f;
        NSDictionary *parameters=@{
                                   @"userId":[self.appDelegate.userInfo objectForKey:@"user_id"],
                                   @"device_id":[device objectForKey:@"device_id"],
//                                   @"status":@"unbind"
                                   };
        //加入header参数
        [manager.requestSerializer setValue:[self.appDelegate.userInfo objectForKey:@"user_system_token"] forHTTPHeaderField:@"user_token"];
//        [manager.requestSerializer setValue:@"qweq" forHTTPHeaderField:@"user_token"];
        HUD_WAITING_SHOW(NSLocalizedString(@"loadingUnbinding", nil));
        [manager POST:BASE_URL(@"user/deleteMydevice") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float progress = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
                
                HUD_LOADING_PROGRESS(progress);
            });
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"成功.%@",responseObject);
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
            NSLog(@"results: %@", dic);
            
            int status = [[dic objectForKey:@"status"] intValue];
            
            HUD_WAITING_HIDE;
            if( status == 200 ){
                [self.appDelegate.deviceList removeObjectAtIndex:btn.tag];
                [self.appDelegate saveDeviceList];
                [self updateLayout];
                HUD_TOAST_SHOW(NSLocalizedString(@"deviceListUnbindSuccess", nil));
            } else if ( status == 418 ) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UserSystemTokenError", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.appDelegate deleteUserInfo];
                    self.appDelegate.isLogout = true;
                    LoginController *loginController = [[LoginController alloc] init];
                    [self.navigationController pushViewController:loginController animated:YES];
                }];
                
                [alertController addAction:okAction];           // A
                
                [self presentViewController:alertController animated:YES completion:nil];
            } else if ( status == 405 ) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UserSystemTokenError", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.appDelegate deleteUserInfo];
                    self.appDelegate.isLogout = true;
                    LoginController *loginController = [[LoginController alloc] init];
                    [self.navigationController pushViewController:loginController animated:YES];
                }];
                
                [alertController addAction:okAction];           // A
                
                [self presentViewController:alertController animated:YES completion:nil];
            }else{
                NSString *eCode = [NSString stringWithFormat:@"e%d", status];
                HUD_TOAST_SHOW(NSLocalizedString(eCode, nil));
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"失败.%@",error);
            NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
            
            HUD_WAITING_HIDE;
            HUD_TOAST_SHOW(NSLocalizedString(@"deviceListUnbindFailed", nil));
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmCancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:okAction];           // A
    [alertController addAction:cancelAction];       // B
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) clickSettingButton: (UIButton *)btn{
    NSMutableDictionary *device = [self.appDelegate.deviceList objectAtIndex:btn.tag];
    DeviceNameController *deviceNameController = [[DeviceNameController alloc] init];
//    NSLog(@"DeviceIdSetting:%@", [device objectForKey:@"device_id"]);
    deviceNameController.deviceId = [[device objectForKey:@"device_id"] intValue];
    [self.navigationController pushViewController:deviceNameController animated:YES];
}
@end
