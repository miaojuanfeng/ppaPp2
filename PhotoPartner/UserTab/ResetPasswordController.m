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
@end

@implementation ResetPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.navigationItem.title = NSLocalizedString(@"messageNavigationItemTitle", nil);
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIColor *lineColor = RGBA_COLOR(200, 200, 200, 1);
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, MARGIN_TOP, GET_LAYOUT_WIDTH(self.view)-GAP_WIDTH*4, GET_LAYOUT_HEIGHT(self.view)-MARGIN_TOP)];
    
        UITextField *newPwdField = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, GET_LAYOUT_WIDTH(boxView), 44)];
        newPwdField.backgroundColor = [UIColor whiteColor];
        newPwdField.delegate = self;
        newPwdField.placeholder = @"New password";
        UIImageView *newPwdImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        newPwdImageViewPwd.image=[UIImage imageNamed:@"ic_lock_black"];
        newPwdField.leftView=newPwdImageViewPwd;
        newPwdField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        newPwdField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
        UIView *newPwdLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(newPwdField)-1, GET_LAYOUT_WIDTH(newPwdField), 1)];
        newPwdLineView.backgroundColor = lineColor;
        [newPwdField addSubview:newPwdLineView];
    
        [boxView addSubview:newPwdField];
    
        UITextField *VPField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(newPwdField)+GET_LAYOUT_HEIGHT(newPwdField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView), 44)];
        VPField.backgroundColor = [UIColor whiteColor];
        VPField.delegate = self;
        VPField.placeholder = @"Verify password";
        UIImageView *VPImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        VPImageViewPwd.image=[UIImage imageNamed:@"ic_lock_black"];
        VPField.leftView=VPImageViewPwd;
        VPField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        VPField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
        UIView *VPLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(VPField)-1, GET_LAYOUT_WIDTH(VPField), 1)];
        VPLineView.backgroundColor = lineColor;
        [VPField addSubview:VPLineView];
    
        [boxView addSubview:VPField];
    
    
        UITextField *emailField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(VPField)+GET_LAYOUT_HEIGHT(VPField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView), 44)];
        emailField.backgroundColor = [UIColor whiteColor];
        emailField.delegate = self;
        emailField.placeholder = @"Email";
        UIImageView *emailImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        emailImageViewPwd.image=[UIImage imageNamed:@"ic_email_black"];
        emailField.leftView=emailImageViewPwd;
        emailField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
        UIView *emailLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(emailField)-1, GET_LAYOUT_WIDTH(emailField), 1)];
        emailLineView.backgroundColor = lineColor;
        [emailField addSubview:emailLineView];
    
        [boxView addSubview:emailField];
    
    
        UITextField *VCField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(emailField)+GET_LAYOUT_HEIGHT(emailField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView), 44)];
        VCField.backgroundColor = [UIColor whiteColor];
        VCField.delegate = self;
        VCField.placeholder = @"Verification code";
        UIImageView *VCImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        VCImageViewPwd.image=[UIImage imageNamed:@"ic_verification_black"];
        VCField.leftView=VCImageViewPwd;
        VCField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        VCField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
        UIView *VCLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(VCField)-1, GET_LAYOUT_WIDTH(VCField), 1)];
        VCLineView.backgroundColor = lineColor;
        [VCField addSubview:VCLineView];
    
        [boxView addSubview:VCField];
    
    
        UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(VCField)+GET_LAYOUT_HEIGHT(VCField)+GAP_HEIGHT*3, GET_LAYOUT_WIDTH(boxView), 44)];
        loginButton.backgroundColor = RGBA_COLOR(27, 163, 232, 1);
        loginButton.layer.cornerRadius = 5;
        loginButton.layer.masksToBounds = YES;
        [loginButton setTitle:NSLocalizedString(@"deviceAddRightBarButtonItemTitle", nil) forState:UIControlStateNormal];
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
