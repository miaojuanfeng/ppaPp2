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
    
        UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(usernameField)+GET_LAYOUT_HEIGHT(usernameField)+GAP_HEIGHT, GET_LAYOUT_WIDTH(boxView), 44)];
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
    
    [self.view addSubview:boxView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
