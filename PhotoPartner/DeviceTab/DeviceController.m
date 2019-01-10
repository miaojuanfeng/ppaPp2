//
//  DeviceController.m
//  PhotoPartner
//
//  Created by USER on 8/3/2018.
//  Copyright © 2018 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "DeviceController.h"
#import "AddDeviceController.h"
#import <AFNetworking/AFNetworking.h>

@interface DeviceController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property UITableView *tableView;
@property AppDelegate *appDelegate;
@property UILabel *emptyLabel;
@property UIAlertController *alertController;
@property UIRefreshControl *refreshControl;
@end

@implementation DeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.navigationItem.title = NSLocalizedString(@"deviceListNavigationItemTitle", nil);
    
    INIT_RightBarButtonItem(ICON_ADD, clickDeviceAddButton);
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, MARGIN_TOP, VIEW_WIDTH, VIEW_HEIGHT)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self setupRefresh];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self isEmptyDeviceList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 下拉刷新
- (void)setupRefresh {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshClick:) forControlEvents:UIControlEventValueChanged];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"refresh", nil)];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, attrString.length)];
    self.refreshControl.attributedTitle = attrString;
    //刷新图形时的颜色，即刷新的时候那个菊花的颜色
    self.refreshControl.tintColor = [UIColor lightGrayColor];
    [self.tableView addSubview:self.refreshControl];
//    [self.refreshControl beginRefreshing];
//    [self refreshClick:self.refreshControl];
}

// 下拉刷新触发，在此获取数据
- (void)refreshClick:(UIRefreshControl *)refreshControl {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"refreshing", nil)];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, attrString.length)];
    self.refreshControl.attributedTitle = attrString;
    [self.refreshControl beginRefreshing];
    //    。。。// 此处添加刷新tableView数据的代码
    //    查询数据库
//    self.dbCtrl=[[FMVC1 alloc]init];
//    self.datasource=[self.dbCtrl select_data];
//    [refreshControl endRefreshing];
//    [self.tableView reloadData];// 刷新tableView即可
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{
                               @"user_id":[self.appDelegate.userInfo objectForKey:@"user_id"]
                               };
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
            
            [self endRefreshing];
            [self.tableView reloadData];
            
            if( self.appDelegate.deviceList.count == 0 ){
                AddDeviceController *addDeviceController = [[AddDeviceController alloc] init];
                [self.navigationController pushViewController:addDeviceController animated:YES];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败.%@",error);
        NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        [self endRefreshing];
    }];
}

-(void)endRefreshing{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"refresh", nil)];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, attrString.length)];
    self.refreshControl.attributedTitle = attrString;
    [self.refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.appDelegate.deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int labelMarginTop = 5;
    if( indexPath.row == 0 ){
        tableView.rowHeight = 59;
        labelMarginTop = 10;
    }else if( indexPath.row == self.appDelegate.deviceList.count - 1 ){
        tableView.rowHeight = 59;
    }else{
        tableView.rowHeight = 54;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    NSMutableDictionary *deviceItem = self.appDelegate.deviceList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    int cellWidth = GET_LAYOUT_WIDTH(tableView) - 20;
    
//    UIView *deviceLabelView = [[UIView alloc] initWithFrame:CGRectMake(10, labelMarginTop, cellWidth*0.56, 44)];
//    deviceLabelView.backgroundColor = RGBA_COLOR(27, 162, 230, 1);
//    deviceLabelView.layer.cornerRadius = 10;
//    deviceLabelView.layer.masksToBounds = YES;
//
//    UILabel *deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, GET_LAYOUT_WIDTH(deviceLabelView)-20, GET_LAYOUT_HEIGHT(deviceLabelView))];
//    deviceLabel.text = [NSString stringWithFormat:@"%@(%@)", [[deviceItem objectForKey:@"device_name"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [deviceItem objectForKey:@"device_token"]];
//    deviceLabel.textColor = [UIColor whiteColor];
//    [deviceLabelView addSubview:deviceLabel];
//
//    [cell.contentView addSubview:deviceLabelView];
    
    UIButton *deviceButton = [[UIButton alloc] initWithFrame:CGRectMake(10, labelMarginTop, cellWidth*0.56, 44)];
    deviceButton.backgroundColor = RGBA_COLOR(27, 162, 230, 1);
    deviceButton.layer.cornerRadius = 10;
    deviceButton.layer.masksToBounds = YES;
    [deviceButton setTitle:[NSString stringWithFormat:@"%@(%@)", [[deviceItem objectForKey:@"device_name"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [deviceItem objectForKey:@"device_token"]] forState:UIControlStateNormal];
    deviceButton.tag = [[deviceItem objectForKey:@"device_id"] intValue];
    [deviceButton addTarget:self action:@selector(clickDeviceButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:deviceButton];
    
    
//    UIButton *renameButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(deviceLabelView)+GET_LAYOUT_WIDTH(deviceLabelView)+5, labelMarginTop, cellWidth*0.22-5, 44)];
    UIButton *renameButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(deviceButton)+GET_LAYOUT_WIDTH(deviceButton)+5, labelMarginTop, cellWidth*0.22-5, 44)];
    [renameButton setTitle:NSLocalizedString(@"deviceListRename", nil) forState:UIControlStateNormal];
    renameButton.backgroundColor = RGBA_COLOR(27, 162, 230, 1);
    renameButton.layer.cornerRadius = 10;
    renameButton.layer.masksToBounds = YES;
    renameButton.tag = [[deviceItem objectForKey:@"device_id"] intValue];
    [renameButton addTarget:self action:@selector(clickRenameButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:renameButton];
    
    UIButton *unbindButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(renameButton)+GET_LAYOUT_WIDTH(renameButton)+5, labelMarginTop, cellWidth*0.22-5, 44)];
    [unbindButton setTitle:NSLocalizedString(@"deviceListUnbind", nil) forState:UIControlStateNormal];
    unbindButton.backgroundColor = RGBA_COLOR(27, 162, 230, 1);
    unbindButton.layer.cornerRadius = 10;
    unbindButton.layer.masksToBounds = YES;
    unbindButton.tag = [[deviceItem objectForKey:@"device_id"] intValue];
    [unbindButton addTarget:self action:@selector(clickUnbindButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:unbindButton];
    
    return cell;
}

- (void)isEmptyDeviceList{
    NSLog(@"self.appDelegate.deviceList: %@", self.appDelegate.deviceList);
    if( self.appDelegate.deviceList.count == 0 ){
        self.emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 64, self.view.frame.size.width-40, 95)];
        self.emptyLabel.numberOfLines = 0;
        self.emptyLabel.font =  [UIFont fontWithName:@"AppleGothic" size:18.0];
        self.emptyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.emptyLabel.textColor = [UIColor colorWithCGColor:BORDER_COLOR];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 10;// 字体的行间距
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:16],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        self.emptyLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"deviceListEmpty", nil) attributes:attributes];
        
        [self.view addSubview:self.emptyLabel];
    }else{
        [self.emptyLabel removeFromSuperview];
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //    VideoDetailController *videoDetailController = [[VideoDetailController alloc] init];
    //    [self.navigationController pushViewController:videoDetailController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [self isEmptyDeviceList];
}

- (void)clickDeviceAddButton {
    AddDeviceController *addDeviceController = [[AddDeviceController alloc] init];
    [self.navigationController pushViewController:addDeviceController animated:YES];
}

- (void)clickDeviceButton:(UIButton *)btn {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{
                               @"user_id":[self.appDelegate.userInfo objectForKey:@"user_id"],
                               @"device_id":[NSString stringWithFormat:@"%ld", btn.tag],
                               };
    NSLog(@"提交的数据：%@", parameters);
    HUD_WAITING_SHOW(NSLocalizedString(@"hudLoading", nil));
    [manager POST:BASE_URL(@"device/flow") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        NSLog(@"results: %@", dic);
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        HUD_WAITING_HIDE;
        if( status == 200 ){
            [[dic objectForKey:@"data"] objectForKey:@"flow"];
            NSString *message = [NSString stringWithFormat:@"Remaining data: %@ M", [[dic objectForKey:@"data"] objectForKey:@"flow"]];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * cancelAc = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                //点击取消要执行的代码
            }];
            
            UIAlertAction *comfirmAc = [UIAlertAction actionWithTitle:@"Charge" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //点击确定要执行的代码
                NSString *redirect_url = [[dic objectForKey:@"data"] objectForKey:@"redirect"];
                NSURL *url = [[NSURL alloc] initWithString:redirect_url];
                [[UIApplication sharedApplication] openURL:url];
            }];
            
            [alertVC addAction:cancelAc];
            [alertVC addAction:comfirmAc];
            [self presentViewController:alertVC animated:YES completion:nil];
        } else {
            NAV_UPLOAD_END;
            ENABLE_RightBarButtonItem;
            NSString *eCode = [NSString stringWithFormat:@"e%d", status];
            HUD_TOAST_SHOW(NSLocalizedString(eCode, nil));
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败.%@",error);
        NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        
        HUD_WAITING_HIDE;
        HUD_TOAST_SHOW(NSLocalizedString(@"deviceInfoReadFailed", nil));
    }];
}

- (void)clickRenameButton:(UIButton *)btn {
    self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"deviceListRenameTextFieldTitle", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self.alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        for (int i=0;i<self.appDelegate.deviceList.count;i++) {
            NSMutableDictionary *device = [self.appDelegate.deviceList objectAtIndex:i];
            if( [[device objectForKey:@"device_id"] intValue] == btn.tag ){
                textField.text = [[device objectForKey:@"device_name"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                break;
            }
        }
        textField.placeholder = NSLocalizedString(@"deviceListRenameTextFieldTitle", nil);
        textField.delegate = self;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *deviceName = self.alertController.textFields.firstObject.text;
        if( deviceName.length > INPUT_MAX_TEXT ){
            HUD_TOAST_SHOW(NSLocalizedString(@"inputMaxText", nil));
            return;
        }
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 30.0f;
        NSDictionary *parameters=@{
                                   @"user_id":[self.appDelegate.userInfo objectForKey:@"user_id"],
                                   @"device_id":[NSString stringWithFormat:@"%ld", btn.tag],
                                   @"device_name":[deviceName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                   };
        HUD_WAITING_SHOW(NSLocalizedString(@"hudLoading", nil));
        [manager POST:BASE_URL(@"device/rename") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
            
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
                for (int i=0;i<self.appDelegate.deviceList.count;i++) {
                    NSMutableDictionary *device = [self.appDelegate.deviceList objectAtIndex:i];
                    if( [[device objectForKey:@"device_id"] intValue] == btn.tag ){
                        device = [[self.appDelegate.deviceList objectAtIndex:i] mutableCopy];
                        [device setObject:deviceName forKey:@"device_name"];
                        [self.appDelegate.deviceList replaceObjectAtIndex:i withObject:device];
                        break;
                    }
                }
                [self.appDelegate saveDeviceList];
                [self.tableView reloadData];
                HUD_TOAST_SHOW(NSLocalizedString(@"deviceListRenameSuccess", nil));
            }else{
                NSString *eCode = [NSString stringWithFormat:@"e%d", status];
                HUD_TOAST_SHOW(NSLocalizedString(eCode, nil));
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"失败.%@",error);
            NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
            
            HUD_WAITING_HIDE;
            HUD_TOAST_SHOW(NSLocalizedString(@"deviceListRenameFailed", nil));
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmCancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [self.alertController addAction:okAction];
    [self.alertController addAction:cancelAction];
    
    [self presentViewController:self.alertController animated:YES completion:nil];
}

- (void)clickUnbindButton:(UIButton *)btn {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"deviceListUnbindConfirmTitle", nil)
                                                                             message:NSLocalizedString(@"deviceListUnbindConfirmSubtitle", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 30.0f;
        NSDictionary *parameters=@{
                                   @"user_id":[self.appDelegate.userInfo objectForKey:@"user_id"],
                                   @"device_id":[NSString stringWithFormat:@"%ld", btn.tag],
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
                NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *time = [dateFormatter stringFromDate:date];
                long device_id = btn.tag;
                NSString *deviceName = @"";
                for(int k=0;k<self.appDelegate.deviceList.count;k++){
                                        NSLog(@"%@", [[self.appDelegate.deviceList objectAtIndex:k] objectForKey:@"device_id"] );
                                        NSLog(@"%ld", device_id);
                                        NSLog(@"%d", [[[self.appDelegate.deviceList objectAtIndex:k] objectForKey:@"device_id"] longValue] == device_id);
                    if( [[[self.appDelegate.deviceList objectAtIndex:k] objectForKey:@"device_id"] longValue] == device_id ){
                        deviceName = [[self.appDelegate.deviceList objectAtIndex:k] objectForKey:@"device_name"];
                        break;
                    }
                }
                [self.appDelegate addMessageList:@"unbind" withTime:time withTitle:deviceName withDesc:@"" withData:nil];
                
                
                for (NSDictionary *device in self.appDelegate.deviceList) {
                    if( [[device objectForKey:@"device_id"] intValue] == btn.tag ){
                        [self.appDelegate.deviceList removeObject:device];
                        break;
                    }
                }
                [self.appDelegate saveDeviceList];
                [self isEmptyDeviceList];
                [self.tableView reloadData];
                
                if( self.appDelegate.deviceList.count == 0 ){
                    AddDeviceController *addDeviceController = [[AddDeviceController alloc] init];
                    HUD_TOAST_PUSH_SHOW(NSLocalizedString(@"deviceListUnbindSuccess", nil), addDeviceController);
                }else{
                    HUD_TOAST_SHOW(NSLocalizedString(@"deviceListUnbindSuccess", nil));
                }
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if( (self.alertController.textFields.firstObject.text.length + string.length) > INPUT_MAX_TEXT ){
        HUD_TOAST_SHOW(NSLocalizedString(@"inputMaxText", nil));
        return NO;
    }
    return YES;
}

@end
