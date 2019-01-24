//
//  LoginController.m
//  PhotoPartner
//
//  Created by Dreamover on 2019/1/11.
//  Copyright © 2019年 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "ResetPasswordController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD.h>

@interface ResetPasswordController ()
@property UIScrollView *scrollView;

@property AppDelegate *appDelegate;

@property UITextField *passwordField;
@property UITextField *VPField;
@property UITextField *emailField;
@property UITextField *VCField;
@end

@implementation ResetPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.navigationItem.title = NSLocalizedString(@"ResetNavigationItemTitle", nil);
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIColor *lineColor = RGBA_COLOR(200, 200, 200, 1);
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, MARGIN_TOP, GET_LAYOUT_WIDTH(self.view)-GAP_WIDTH*4, GET_LAYOUT_HEIGHT(self.view)-MARGIN_TOP)];
    
        self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, GET_LAYOUT_WIDTH(boxView), 44)];
        self.passwordField.backgroundColor = [UIColor whiteColor];
        self.passwordField.delegate = self;
        self.passwordField.placeholder = NSLocalizedString(@"newPassword", nil);
        UIImageView *newPwdImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        newPwdImageViewPwd.image=[UIImage imageNamed:@"ic_lock_black"];
        self.passwordField.leftView=newPwdImageViewPwd;
        self.passwordField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        self.passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.passwordField setSecureTextEntry:YES];
    
        UIView *newPwdLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.passwordField)-1, GET_LAYOUT_WIDTH(self.passwordField), 1)];
        newPwdLineView.backgroundColor = lineColor;
        [self.passwordField addSubview:newPwdLineView];
    
        [boxView addSubview:self.passwordField];
    
        self.VPField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.passwordField)+GET_LAYOUT_HEIGHT(self.passwordField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView), 44)];
        self.VPField.backgroundColor = [UIColor whiteColor];
        self.VPField.delegate = self;
        self.VPField.placeholder = NSLocalizedString(@"verifyPassword", nil);
        UIImageView *VPImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        VPImageViewPwd.image=[UIImage imageNamed:@"ic_lock_black"];
        self.VPField.leftView=VPImageViewPwd;
        self.VPField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        self.VPField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.VPField setSecureTextEntry:YES];
    
        UIView *VPLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.VPField)-1, GET_LAYOUT_WIDTH(self.VPField), 1)];
        VPLineView.backgroundColor = lineColor;
        [self.VPField addSubview:VPLineView];
    
        [boxView addSubview:self.VPField];
    
    
        self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.VPField)+GET_LAYOUT_HEIGHT(self.VPField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView), 44)];
        self.emailField.backgroundColor = [UIColor whiteColor];
        self.emailField.delegate = self;
        self.emailField.placeholder = NSLocalizedString(@"email", nil);
        UIImageView *emailImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        emailImageViewPwd.image=[UIImage imageNamed:@"ic_email_black"];
        self.emailField.leftView=emailImageViewPwd;
        self.emailField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        self.emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
        UIView *emailLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.emailField)-1, GET_LAYOUT_WIDTH(self.emailField), 1)];
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
    
        UIView *VCLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.VCField)-1, GET_LAYOUT_WIDTH(self.VCField), 1)];
        VCLineView.backgroundColor = lineColor;
        [self.VCField addSubview:VCLineView];
    
        [boxView addSubview:self.VCField];
    
    
        UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.VCField)+GET_LAYOUT_HEIGHT(self.VCField)+GAP_HEIGHT*3, GET_LAYOUT_WIDTH(boxView), 44)];
        loginButton.backgroundColor = RGBA_COLOR(27, 163, 232, 1);
        loginButton.layer.cornerRadius = 5;
        loginButton.layer.masksToBounds = YES;
        [loginButton setTitle:NSLocalizedString(@"ResetButton", nil) forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(clickResetButton) forControlEvents:UIControlEventTouchUpInside];
        [boxView addSubview:loginButton];
    
    
    [self.view addSubview:boxView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickResetButton{
    NSLog(@"点击3");
    
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
