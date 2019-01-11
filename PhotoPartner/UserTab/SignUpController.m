//
//  LoginController.m
//  PhotoPartner
//
//  Created by Dreamover on 2019/1/11.
//  Copyright © 2019年 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "SignUpController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD.h>

@interface SignUpController ()
@property UIScrollView *scrollView;

@property AppDelegate *appDelegate;
@end

@implementation SignUpController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.navigationItem.title = NSLocalizedString(@"messageNavigationItemTitle", nil);
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, MARGIN_TOP, GET_LAYOUT_WIDTH(self.view)-GAP_WIDTH*4, GET_LAYOUT_HEIGHT(self.view)-MARGIN_TOP)];
    
        UITextField *usernameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, GET_LAYOUT_WIDTH(boxView), 44)];
        usernameField.backgroundColor = [UIColor whiteColor];
        usernameField.delegate = self;
        usernameField.placeholder = @"请输入密码";
        UIImageView *usernameImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 32, 24)];
        usernameImageViewPwd.image=[UIImage imageNamed:@"bg_main"];
        usernameField.leftView=usernameImageViewPwd;
        usernameField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
        UIView *usernameLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(usernameField)-1, GET_LAYOUT_WIDTH(usernameField), 1)];
            usernameLineView.backgroundColor = [UIColor grayColor];
            [usernameField addSubview:usernameLineView];
    
        [boxView addSubview:usernameField];
    
        UITextField *newPwdField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(usernameField)+GET_LAYOUT_HEIGHT(usernameField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView), 44)];
        newPwdField.backgroundColor = [UIColor whiteColor];
        newPwdField.delegate = self;
        newPwdField.placeholder = @"请输入密码";
        UIImageView *newPwdImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 32, 24)];
        newPwdImageViewPwd.image=[UIImage imageNamed:@"bg_main"];
        newPwdField.leftView=newPwdImageViewPwd;
        newPwdField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        newPwdField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
        UIView *newPwdLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(newPwdField)-1, GET_LAYOUT_WIDTH(newPwdField), 1)];
            newPwdLineView.backgroundColor = [UIColor grayColor];
            [newPwdField addSubview:newPwdLineView];
    
        [boxView addSubview:newPwdField];
    
        UITextField *VPField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(newPwdField)+GET_LAYOUT_HEIGHT(newPwdField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView), 44)];
        VPField.backgroundColor = [UIColor whiteColor];
        VPField.delegate = self;
        VPField.placeholder = @"请输入密码";
        UIImageView *VPImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 32, 24)];
        VPImageViewPwd.image=[UIImage imageNamed:@"bg_main"];
        VPField.leftView=VPImageViewPwd;
        VPField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        VPField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
        UIView *VPLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(VPField)-1, GET_LAYOUT_WIDTH(VPField), 1)];
        VPLineView.backgroundColor = [UIColor grayColor];
        [VPField addSubview:VPLineView];
    
        [boxView addSubview:VPField];
    
    
    
        UITextField *emailField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(VPField)+GET_LAYOUT_HEIGHT(VPField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView), 44)];
        emailField.backgroundColor = [UIColor whiteColor];
        emailField.delegate = self;
        emailField.placeholder = @"请输入密码";
        UIImageView *emailImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 32, 24)];
        emailImageViewPwd.image=[UIImage imageNamed:@"bg_main"];
        emailField.leftView=emailImageViewPwd;
        emailField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
        UIView *emailLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(emailField)-1, GET_LAYOUT_WIDTH(emailField), 1)];
        emailLineView.backgroundColor = [UIColor grayColor];
        [emailField addSubview:emailLineView];
    
        [boxView addSubview:emailField];
    
    
        UITextField *VCField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(emailField)+GET_LAYOUT_HEIGHT(emailField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView), 44)];
        VCField.backgroundColor = [UIColor whiteColor];
        VCField.delegate = self;
        VCField.placeholder = @"请输入密码";
        UIImageView *VCImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 32, 24)];
        VCImageViewPwd.image=[UIImage imageNamed:@"bg_main"];
        VCField.leftView=VCImageViewPwd;
        VCField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        VCField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
        UIView *VCLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(VCField)-1, GET_LAYOUT_WIDTH(VCField), 1)];
        VCLineView.backgroundColor = [UIColor grayColor];
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

-(void)clickLoginButton{
    NSLog(@"点击3");
    
}

-(void)forgetPasswordTap:(UITapGestureRecognizer*)gesture {
    NSLog(@"点击");
}

-(void)signUpTap:(UITapGestureRecognizer*)gesture {
    NSLog(@"点击2");
}

#pragma mark - UITextFieldDelegate
// 获取第一响应者时调用
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //textField.layer.cornerRadius = 8.0f;
    // textField.layer.masksToBounds=YES;
    //textField.layer.borderColor = BORDER_FOCUS_COLOR;
    //textField.layer.borderWidth = BORDER_WIDTH*2;
    
    textField.subviews[0].backgroundColor = [UIColor blueColor];
    return YES;
}

// 失去第一响应者时调用
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //textField.layer.borderColor = BORDER_WHITE_COLOR;
    
    textField.subviews[0].backgroundColor = [UIColor grayColor];
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
