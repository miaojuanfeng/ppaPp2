//
//  LoginController.m
//  PhotoPartner
//
//  Created by Dreamover on 2019/1/11.
//  Copyright © 2019年 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "ResetEmailController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD.h>

@interface ResetEmailController ()
@property UIScrollView *scrollView;

@property AppDelegate *appDelegate;

@property UITextField *emailField;
@property UITextField *VCField;
@end

@implementation ResetEmailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.navigationItem.title = NSLocalizedString(@"EditUserEmailNavigationItemTitle", nil);
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIColor *lineColor = RGBA_COLOR(200, 200, 200, 1);
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, MARGIN_TOP, GET_LAYOUT_WIDTH(self.view)-GAP_WIDTH*4, GET_LAYOUT_HEIGHT(self.view)-MARGIN_TOP)];
    
        self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, GET_LAYOUT_WIDTH(boxView)-20, 44)];
        self.emailField.backgroundColor = [UIColor whiteColor];
        self.emailField.delegate = self;
        self.emailField.text = [self.appDelegate.userInfo objectForKey:@"userEmail"];
        self.emailField.placeholder = NSLocalizedString(@"email", nil);
        UIImageView *emailImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        emailImageViewPwd.image=[UIImage imageNamed:@"ic_email_black"];
        self.emailField.leftView=emailImageViewPwd;
        self.emailField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        self.emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
        UIButton *emailSendButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(self.emailField)+GET_LAYOUT_WIDTH(self.emailField), GET_LAYOUT_OFFSET_Y(self.emailField)+12, 20, 20)];
        emailSendButton.titleLabel.font = [UIFont fontWithName:@"iconfont" size:14.0f];
        [emailSendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [emailSendButton setTitle:ICON_FORWARD forState:UIControlStateNormal];
        [emailSendButton addTarget:self action:@selector(clickSendEmailButton) forControlEvents:UIControlEventTouchUpInside];
        [boxView addSubview:emailSendButton];
    
        UIView *emailLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.emailField)-1, GET_LAYOUT_WIDTH(self.emailField)+20, 1)];
        emailLineView.backgroundColor = lineColor;
        [self.emailField addSubview:emailLineView];
    
        [boxView addSubview:self.emailField];
    
    
        self.VCField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.emailField)+GET_LAYOUT_HEIGHT(self.emailField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView), 44)];
        self.VCField.backgroundColor = [UIColor whiteColor];
        self.VCField.delegate = self;
        self.VCField.placeholder = NSLocalizedString(@"verifyCode", nil);
        UIImageView *VCImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        VCImageViewPwd.image=[UIImage imageNamed:@"ic_verification_black"];
        self.VCField.leftView=VCImageViewPwd;
        self.VCField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        self.VCField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.VCField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
        UIView *VCLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.VCField)-1, GET_LAYOUT_WIDTH(self.VCField), 1)];
        VCLineView.backgroundColor = lineColor;
        [self.VCField addSubview:VCLineView];
    
        [boxView addSubview:self.VCField];
    
    
        UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.VCField)+GET_LAYOUT_HEIGHT(self.VCField)+GAP_HEIGHT*3, GET_LAYOUT_WIDTH(boxView), 44)];
        loginButton.backgroundColor = RGBA_COLOR(27, 163, 232, 1);
        loginButton.layer.cornerRadius = 5;
        loginButton.layer.masksToBounds = YES;
        [loginButton setTitle:NSLocalizedString(@"RegisterButton", nil) forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(clickSubmitButton) forControlEvents:UIControlEventTouchUpInside];
        [boxView addSubview:loginButton];
    
    [self.view addSubview:boxView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickSendEmailButton{
    [self.view endEditing:YES];

    if( [self.emailField.text isEqualToString:@""] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"userEmailEmpty", nil));
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{
                               @"userEmail":self.emailField.text,
                               @"type":@"3",
                               @"companyName":COMPANY_NAME
                               };
    HUD_WAITING_SHOW(NSLocalizedString(@"SendingEmail", nil));
    [manager GET:BASE_URL(@"email/emailVerificationCode") parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        NSLog(@"results: %@", dic);
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        HUD_WAITING_HIDE;
        if( status == 200 ){
            HUD_TOAST_SHOW(NSLocalizedString(@"SendEmailSuccess", nil));
        }else{
            NSString *eCode = [NSString stringWithFormat:@"e%d", status];
            HUD_TOAST_SHOW(NSLocalizedString(eCode, nil));
        }
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败.%@",error);
        NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        
        HUD_WAITING_HIDE;
        HUD_TOAST_SHOW(NSLocalizedString(@"SendEmailFailue", nil));
    }];
}

-(void)clickSubmitButton{
    [self.view endEditing:YES];
    
    if( [self.emailField.text isEqualToString:@""] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"userEmailEmpty", nil));
        return;
    }
    if( [self.VCField.text isEqualToString:@""] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"userVerificationCodeEmpty", nil));
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{
                               @"userId":[self.appDelegate.userInfo objectForKey:@"user_id"],
                               @"userNewEmail":self.emailField.text,
                               @"userEmailCode":self.VCField.text
                               };
    HUD_WAITING_SHOW(NSLocalizedString(@"Registering", nil));
    [manager POST:BASE_URL(@"user/userModUserEmail") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        NSLog(@"results: %@", dic);
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        HUD_WAITING_HIDE;
        if( status == 200 ){
            [self.appDelegate.userInfo setObject:self.emailField.text forKey:@"userEmail"];
            [self.appDelegate saveUserInfo];
            
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
