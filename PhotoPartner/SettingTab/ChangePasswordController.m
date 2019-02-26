//
//  LoginController.m
//  PhotoPartner
//
//  Created by Dreamover on 2019/1/11.
//  Copyright © 2019年 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "ChangePasswordController.h"
#import "ResetPasswordController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD.h>

@interface ChangePasswordController ()
@property UIScrollView *scrollView;

@property AppDelegate *appDelegate;

@property UITextField *currentPasswordField;
@property UITextField *passwordField;
@property UITextField *VPField;

@property Boolean isCurrentPwdSecureText;
@property Boolean isPwdSecureText;
@property Boolean isCfmPwdSecureText;
@end

@implementation ChangePasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.navigationItem.title = NSLocalizedString(@"ChangePassword", nil);
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.isPwdSecureText = YES;
    self.isCfmPwdSecureText = YES;
    
    UIColor *lineColor = RGBA_COLOR(200, 200, 200, 1);
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, MARGIN_TOP, GET_LAYOUT_WIDTH(self.view)-GAP_WIDTH*4, GET_LAYOUT_HEIGHT(self.view)-MARGIN_TOP)];
    
        self.currentPasswordField = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, GET_LAYOUT_WIDTH(boxView)-20, 44)];
        self.currentPasswordField.backgroundColor = [UIColor whiteColor];
        self.currentPasswordField.delegate = self;
        self.currentPasswordField.placeholder = NSLocalizedString(@"currentPassword", nil);
        UIImageView *currentPwdImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        currentPwdImageViewPwd.image=[UIImage imageNamed:@"ic_lock_black"];
        self.currentPasswordField.leftView=currentPwdImageViewPwd;
        self.currentPasswordField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        self.currentPasswordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.currentPasswordField setSecureTextEntry:YES];
        self.currentPasswordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
        UIButton *currentPwdSecButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(self.currentPasswordField)+GET_LAYOUT_WIDTH(self.currentPasswordField), GET_LAYOUT_OFFSET_Y(self.currentPasswordField)+12, 20, 20)];
        currentPwdSecButton.titleLabel.font = [UIFont fontWithName:@"iconfont" size:20.0f];
        [currentPwdSecButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [currentPwdSecButton setTitle:ICON_EYE_OFF forState:UIControlStateNormal];
        [currentPwdSecButton addTarget:self action:@selector(clickCurrentPwdSecButton:) forControlEvents:UIControlEventTouchUpInside];
        [boxView addSubview:currentPwdSecButton];
    
        UIView *currentPwdLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.currentPasswordField)-1, GET_LAYOUT_WIDTH(self.currentPasswordField)+20, 1)];
        currentPwdLineView.backgroundColor = lineColor;
        [self.currentPasswordField addSubview:currentPwdLineView];
    
        [boxView addSubview:self.currentPasswordField];
    
        self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.currentPasswordField)+GET_LAYOUT_HEIGHT(self.currentPasswordField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView)-20, 44)];
        self.passwordField.backgroundColor = [UIColor whiteColor];
        self.passwordField.delegate = self;
        self.passwordField.placeholder = NSLocalizedString(@"newPassword", nil);
        UIImageView *newPwdImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        newPwdImageViewPwd.image=[UIImage imageNamed:@"ic_lock_black"];
        self.passwordField.leftView=newPwdImageViewPwd;
        self.passwordField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        self.passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.passwordField setSecureTextEntry:YES];
        self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
        UIButton *pwdSecButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(self.passwordField)+GET_LAYOUT_WIDTH(self.passwordField), GET_LAYOUT_OFFSET_Y(self.passwordField)+12, 20, 20)];
        pwdSecButton.titleLabel.font = [UIFont fontWithName:@"iconfont" size:20.0f];
        [pwdSecButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [pwdSecButton setTitle:ICON_EYE_OFF forState:UIControlStateNormal];
        [pwdSecButton addTarget:self action:@selector(clickPwdSecButton:) forControlEvents:UIControlEventTouchUpInside];
        [boxView addSubview:pwdSecButton];
    
        UIView *newPwdLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.passwordField)-1, GET_LAYOUT_WIDTH(self.passwordField)+20, 1)];
        newPwdLineView.backgroundColor = lineColor;
        [self.passwordField addSubview:newPwdLineView];
    
        [boxView addSubview:self.passwordField];
    
        self.VPField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.passwordField)+GET_LAYOUT_HEIGHT(self.passwordField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView)-20, 44)];
        self.VPField.backgroundColor = [UIColor whiteColor];
        self.VPField.delegate = self;
        self.VPField.placeholder = NSLocalizedString(@"verifyPassword", nil);
        UIImageView *VPImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        VPImageViewPwd.image=[UIImage imageNamed:@"ic_lock_black"];
        self.VPField.leftView=VPImageViewPwd;
        self.VPField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        self.VPField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.VPField setSecureTextEntry:YES];
        self.VPField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
        UIButton *pwdCfmSecButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(self.VPField)+GET_LAYOUT_WIDTH(self.VPField), GET_LAYOUT_OFFSET_Y(self.VPField)+12, 20, 20)];
        pwdCfmSecButton.titleLabel.font = [UIFont fontWithName:@"iconfont" size:20.0f];
        [pwdCfmSecButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [pwdCfmSecButton setTitle:ICON_EYE_OFF forState:UIControlStateNormal];
        [pwdCfmSecButton addTarget:self action:@selector(clickCfmPwdSecButton:) forControlEvents:UIControlEventTouchUpInside];
        [boxView addSubview:pwdCfmSecButton];
    
        UIView *VPLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.VPField)-1, GET_LAYOUT_WIDTH(self.VPField)+20, 1)];
        VPLineView.backgroundColor = lineColor;
        [self.VPField addSubview:VPLineView];
    
        [boxView addSubview:self.VPField];
    
        UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.VPField)+GET_LAYOUT_HEIGHT(self.VPField)+GAP_HEIGHT*3, GET_LAYOUT_WIDTH(boxView), 44)];
        loginButton.backgroundColor = RGBA_COLOR(27, 163, 232, 1);
        loginButton.layer.cornerRadius = 5;
        loginButton.layer.masksToBounds = YES;
        [loginButton setTitle:NSLocalizedString(@"ResetButton", nil) forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(clickResetButton) forControlEvents:UIControlEventTouchUpInside];
        [boxView addSubview:loginButton];
    
        UILabel *forgetLabel = [[UILabel alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(boxView)-140)/2, GET_LAYOUT_OFFSET_Y(loginButton)+GET_LAYOUT_HEIGHT(loginButton)+GAP_HEIGHT*2, 140, 44)];
        forgetLabel.text = NSLocalizedString(@"ResetLabel", nil);
        forgetLabel.textAlignment = NSTextAlignmentLeft;
        forgetLabel.textColor = RGBA_COLOR(27, 163, 232, 1);
        forgetLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer* forgetGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forgetPasswordTap:)];
        forgetGesture.numberOfTouchesRequired = 1;
        [forgetLabel addGestureRecognizer:forgetGesture];
        [boxView addSubview:forgetLabel];
    
    [self.view addSubview:boxView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)forgetPasswordTap:(UITapGestureRecognizer*)gesture {
    ResetPasswordController *resetPasswordController = [[ResetPasswordController alloc] init];
    [self.navigationController pushViewController:resetPasswordController animated:YES];
}

-(void)clickCurrentPwdSecButton:(UIButton*)btn{
    self.isCurrentPwdSecureText = !self.isCurrentPwdSecureText;
    [self.currentPasswordField setSecureTextEntry:self.isCurrentPwdSecureText];
    if( self.isCurrentPwdSecureText ){
        [btn setTitle:ICON_EYE_OFF forState:UIControlStateNormal];
    }else{
        [btn setTitle:ICON_EYE_ON forState:UIControlStateNormal];
    }
}

-(void)clickPwdSecButton:(UIButton*)btn{
    self.isPwdSecureText = !self.isPwdSecureText;
    [self.passwordField setSecureTextEntry:self.isPwdSecureText];
    if( self.isPwdSecureText ){
        [btn setTitle:ICON_EYE_OFF forState:UIControlStateNormal];
    }else{
        [btn setTitle:ICON_EYE_ON forState:UIControlStateNormal];
    }
}

-(void)clickCfmPwdSecButton:(UIButton*)btn{
    self.isCfmPwdSecureText = !self.isCfmPwdSecureText;
    [self.VPField setSecureTextEntry:self.isCfmPwdSecureText];
    if( self.isCfmPwdSecureText ){
        [btn setTitle:ICON_EYE_OFF forState:UIControlStateNormal];
    }else{
        [btn setTitle:ICON_EYE_ON forState:UIControlStateNormal];
    }
}

-(void)clickResetButton{
    [self.view endEditing:YES];

    if( [self.currentPasswordField.text isEqualToString:@""] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"userCurrentPasswordEmpty", nil));
        return;
    }
    if( [self.passwordField.text isEqualToString:@""] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"userPasswordEmpty", nil));
        return;
    }
    if( [self.VPField.text isEqualToString:@""] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"userVerifyPasswordEmpty", nil));
        return;
    }
    if( ![self.passwordField.text isEqualToString:self.VPField.text] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"userPasswordNotEqual", nil));
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{
                               @"userId":[self.appDelegate.userInfo objectForKey:@"user_id"],
                               @"userPassword":self.currentPasswordField.text,
                               @"userNewPassword":self.passwordField.text
                               };
    HUD_WAITING_SHOW(NSLocalizedString(@"Resetting", nil));
    [manager POST:BASE_URL(@"user/userModPassword") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        NSLog(@"results: %@", dic);
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        HUD_WAITING_HIDE;
        if( status == 200 ){
            //NSDictionary *data = [dic objectForKey:@"data"];
            //NSLog(data);
            /*NSString *device_id = [data objectForKey:@"device_id"];
             
             NSMutableDictionary *device = [[NSMutableDictionary alloc] init];
             [device setObject:device_id forKey:@"device_id"];
             [device setObject:self.deviceTokenField.text forKey:@"device_token"];
             [device setObject:self.deviceNameField.text forKey:@"device_name"];
             [device setObject:@0 forKey:@"isSelected"];
             [self.appDelegate.deviceList addObject:device];
             
             NSLog(@"%@", self.appDelegate.deviceList);
             [self.appDelegate addDeviceList:device];
             
             
             NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
             NSString *time = [dateFormatter stringFromDate:date];
             NSString *deviceName = self.deviceNameField.text;
             NSString *desc = @"";
             [self.appDelegate addMessageList:@"bind" withTime:time withTitle:deviceName withDesc:desc withData:nil];*/
            
            HUD_TOAST_POP_SHOW(NSLocalizedString(@"Success", nil));
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
    //textField.layer.borderWidth = BORDER_WIDTH*2;
    
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

@end
