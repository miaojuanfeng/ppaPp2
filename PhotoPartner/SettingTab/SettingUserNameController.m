//
//  AddDeviceController.m
//  PhotoPartner
//
//  Created by USER on 8/3/2018.
//  Copyright © 2018 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import "SettingUserNameController.h"
#import "LoginController.h"

@interface SettingUserNameController () <UIGestureRecognizerDelegate, UITextFieldDelegate>
@property AppDelegate *appDelegate;
@property UITextField *userNewNameField;
@end

@implementation SettingUserNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.view.backgroundColor = RGBA_COLOR(239, 239, 239, 1);
    self.navigationItem.title = NSLocalizedString(@"EditUserNameNavigationItemTitle", nil);
    
    //INIT_RightBarButtonItem(ICON_SCAN, clickDeviceScanButton);
    
//    UIBarButtonItem *deviceAddButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"deviceAddRightBarButtonItemTitle", nil) style:UIBarButtonItemStylePlain target:self action:@selector(clickDeviceAddButtonButton)];
//    self.navigationItem.rightBarButtonItem = deviceAddButton;
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIColor *lineColor = RGBA_COLOR(200, 200, 200, 1);
    
    UIView *deviceView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, MARGIN_TOP+GAP_HEIGHT*2+64, VIEW_WIDTH-4*GAP_WIDTH, VIEW_HEIGHT)];
    
    self.userNewNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(deviceView), 44)];
    self.userNewNameField.delegate = self;
    UIView *tokenLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.userNewNameField)-1, GET_LAYOUT_WIDTH(self.userNewNameField), 1)];
    tokenLineView.backgroundColor = lineColor;
    [self.userNewNameField addSubview:tokenLineView];
    self.userNewNameField.text = [self.appDelegate.userInfo objectForKey:@"user_name"];
    self.userNewNameField.placeholder = NSLocalizedString(@"EditUserNameLabel", nil);
    UIImageView *usernameImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
    usernameImageViewPwd.image=[UIImage imageNamed:@"ic_account_black"];
    self.userNewNameField.leftView=usernameImageViewPwd;
    self.userNewNameField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
    self.userNewNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.userNewNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [deviceView addSubview:self.userNewNameField];
    
    UIButton *deviceAddButton = [[UIButton alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.userNewNameField)+GET_LAYOUT_HEIGHT(self.userNewNameField)+40, GET_LAYOUT_WIDTH(deviceView), 44)];
    deviceAddButton.backgroundColor = RGBA_COLOR(27, 163, 232, 1);
    deviceAddButton.layer.cornerRadius = 5;
    deviceAddButton.layer.masksToBounds = YES;
    [deviceAddButton setTitle:NSLocalizedString(@"EditUserNameButton", nil) forState:UIControlStateNormal];
    [deviceAddButton addTarget:self action:@selector(clickEditUserNameSubmitButton) forControlEvents:UIControlEventTouchUpInside];
    [deviceView addSubview:deviceAddButton];
    
    [self.view addSubview:deviceView];
    
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    
    //if( self.appDelegate.deviceList.count == 0 ){
    //    [self.navigationItem setHidesBackButton:YES];
    //}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTextFieldLeftPadding:(UITextField *)textField forWidth:(CGFloat)leftWidth {
    CGRect frame = textField.frame;
    frame.size.width = leftWidth;
    UIView *leftview = [[UIView alloc] initWithFrame:frame];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = leftview;
}

- (void)clickEditUserNameSubmitButton {
    [self.view endEditing:YES];
    
    if( [self.userNewNameField.text isEqualToString:@""] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"EditUserNameEmpty", nil));
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    //加入header参数
    [manager.requestSerializer setValue:[self.appDelegate.userInfo objectForKey:@"user_system_token"] forHTTPHeaderField:@"user_token"];
//    [manager.requestSerializer setValue:@"hello" forHTTPHeaderField:@"user_token"];
    NSDictionary *parameters=@{
                               @"userId":[self.appDelegate.userInfo objectForKey:@"user_id"],
                               @"userNewName":self.userNewNameField.text
                               };
    HUD_WAITING_SHOW(NSLocalizedString(@"Saving", nil));
    [manager POST:BASE_URL(@"user/userModUserName") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        NSLog(@"results: %@", dic);
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        HUD_WAITING_HIDE;
        if( status == 200 ){
            [self.appDelegate.userInfo setObject:self.userNewNameField.text forKey:@"user_name"];
            [self.appDelegate saveUserInfo];
            
            HUD_TOAST_POP_SHOW(NSLocalizedString(@"Success", nil));
        } else if ( status == 418 ) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Token Error,Please login again" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.appDelegate deleteUserInfo];
                self.appDelegate.isLogout = true;
                LoginController *loginController = [[LoginController alloc] init];
                [self.navigationController pushViewController:loginController animated:YES];
            }];
            
            [alertController addAction:okAction];           // A
            
            [self presentViewController:alertController animated:YES completion:nil];
        } else if ( status == 405 ) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Token Error,Please login again" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
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
        HUD_TOAST_SHOW(NSLocalizedString(@"Failed", nil));
    }];
}

#pragma mark - UITextFieldDelegate
// 获取第一响应者时调用
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //textField.layer.cornerRadius = 8.0f;
    // textField.layer.masksToBounds=YES;
    //textField.layer.borderColor = BORDER_FOCUS_COLOR;
    //textField.layer.borderWidth = BORDER_WIDTH;
    
    textField.subviews[0].backgroundColor = RGBA_COLOR(30, 160, 245, 1);
    return YES;
}

// 失去第一响应者时调用
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //textField.layer.borderColor = BORDER_WHITE_COLOR;
    textField.subviews[0].backgroundColor = RGBA_COLOR(200, 200, 200, 1);
    return YES;
}

// 按enter时调用
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
}

- (void)license:(NSString *)license {
    self.userNewNameField.text = license;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //if( (self.deviceNameField.text.length + string.length) > INPUT_MAX_TEXT ){
    //    HUD_TOAST_SHOW(NSLocalizedString(@"inputMaxText", nil));
    //    return NO;
    //}
    return YES;
}

@end
