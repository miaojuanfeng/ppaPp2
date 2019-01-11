//
//  LoginController.m
//  PhotoPartner
//
//  Created by Dreamover on 2019/1/11.
//  Copyright © 2019年 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "LoginController.h"
#import "ResetPasswordController.h"
#import "SignUpController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD.h>

@interface LoginController ()
@property UIScrollView *scrollView;

@property AppDelegate *appDelegate;
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.navigationItem.title = NSLocalizedString(@"messageNavigationItemTitle", nil);
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, MARGIN_TOP, GET_LAYOUT_WIDTH(self.view)-GAP_WIDTH*4, GET_LAYOUT_HEIGHT(self.view)-MARGIN_TOP)];
    
        UITextField *usernameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 100, GET_LAYOUT_WIDTH(boxView), 44)];
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
    
        UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(usernameField)+GET_LAYOUT_HEIGHT(usernameField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView), 44)];
        passwordField.backgroundColor = [UIColor whiteColor];
        passwordField.delegate = self;
        passwordField.placeholder = @"请输入密码";
        UIImageView *passwordImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 32, 24)];
        passwordImageViewPwd.image=[UIImage imageNamed:@"bg_main"];
        passwordField.leftView=passwordImageViewPwd;
        passwordField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(passwordField)-1, GET_LAYOUT_WIDTH(passwordField), 1)];
        lineView.backgroundColor = [UIColor grayColor];
        [passwordField addSubview:lineView];
    
        [boxView addSubview:passwordField];
    
        UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(passwordField)+GET_LAYOUT_HEIGHT(passwordField)+GAP_HEIGHT*3, GET_LAYOUT_WIDTH(boxView), 44)];
        loginButton.backgroundColor = RGBA_COLOR(27, 163, 232, 1);
        loginButton.layer.cornerRadius = 5;
        loginButton.layer.masksToBounds = YES;
        [loginButton setTitle:NSLocalizedString(@"deviceAddRightBarButtonItemTitle", nil) forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(clickLoginButton) forControlEvents:UIControlEventTouchUpInside];
        [boxView addSubview:loginButton];
    
        UILabel *forgetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(loginButton)+GET_LAYOUT_HEIGHT(loginButton), 150, 44)];
        forgetLabel.text = @"forget";
        forgetLabel.textAlignment = NSTextAlignmentLeft;
        forgetLabel.textColor = RGBA_COLOR(27, 163, 232, 1);
        forgetLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer* forgetGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forgetPasswordTap:)];
        forgetGesture.numberOfTouchesRequired = 1;
        [forgetLabel addGestureRecognizer:forgetGesture];
        [boxView addSubview:forgetLabel];
    
        UILabel *signUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(boxView)-80, GET_LAYOUT_OFFSET_Y(loginButton)+GET_LAYOUT_HEIGHT(loginButton), 80, 44)];
        signUpLabel.text = @"signup";
        signUpLabel.textAlignment = NSTextAlignmentRight;
        signUpLabel.textColor = RGBA_COLOR(27, 163, 232, 1);
        signUpLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer* signUpGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(signUpTap:)];
        signUpGesture.numberOfTouchesRequired = 1;
        [signUpLabel addGestureRecognizer:signUpGesture];
        [boxView addSubview:signUpLabel];
    
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
    ResetPasswordController *resetPasswordController = [[ResetPasswordController alloc] init];
    [self.navigationController pushViewController:resetPasswordController animated:YES];
}

-(void)signUpTap:(UITapGestureRecognizer*)gesture {
    SignUpController *signUpController = [[SignUpController alloc] init];
    [self.navigationController pushViewController:signUpController animated:YES];
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
