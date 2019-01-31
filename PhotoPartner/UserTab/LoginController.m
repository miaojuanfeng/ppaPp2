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

@property UITextField *usernameField;
@property UITextField *passwordField;
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.navigationItem.title = NSLocalizedString(@"LoginNavigationItemTitle", nil);
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.navigationItem setHidesBackButton:YES];
    self.navigationController.delegate = self;
    
    UIColor *lineColor = RGBA_COLOR(200, 200, 200, 1);
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, MARGIN_TOP, GET_LAYOUT_WIDTH(self.view)-GAP_WIDTH*4, GET_LAYOUT_HEIGHT(self.view)-MARGIN_TOP)];
    
        UIView *logoView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, GET_LAYOUT_WIDTH(boxView), 72)];
        UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 72, GET_LAYOUT_HEIGHT(logoView))];
        logoImage.image = [UIImage imageNamed:@"ic_cloud_blue"];
        [logoView addSubview:logoImage];
        UILabel *logoLable = [[UILabel alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(logoImage)+GET_LAYOUT_WIDTH(logoImage)+GAP_WIDTH, 0, GET_LAYOUT_WIDTH(logoView)-GET_LAYOUT_WIDTH(logoImage), GET_LAYOUT_HEIGHT(logoView))];
        logoLable.text = @"Cloud Photo";
        logoLable.textColor = RGBA_COLOR(95, 185, 245, 1);
        logoLable.font = [UIFont systemFontOfSize:18];
        [logoView addSubview:logoLable];
        [boxView addSubview:logoView];
    
        self.usernameField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(logoView)+GET_LAYOUT_HEIGHT(logoView)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView), 44)];
        self.usernameField.backgroundColor = [UIColor whiteColor];
        self.usernameField.delegate = self;
        self.usernameField.placeholder = NSLocalizedString(@"username", nil);
        UIImageView *usernameImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        usernameImageViewPwd.image=[UIImage imageNamed:@"ic_account_black"];
        self.usernameField.leftView=usernameImageViewPwd;
        self.usernameField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        self.usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    UIView *usernameLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.usernameField)-1, GET_LAYOUT_WIDTH(self.usernameField), 1)];
        usernameLineView.backgroundColor = lineColor;
        [self.usernameField addSubview:usernameLineView];
    
        [boxView addSubview:self.usernameField];
    
        self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.usernameField)+GET_LAYOUT_HEIGHT(self.usernameField)+GAP_HEIGHT*2, GET_LAYOUT_WIDTH(boxView), 44)];
        self.passwordField.backgroundColor = [UIColor whiteColor];
        self.passwordField.delegate = self;
        self.passwordField.placeholder = NSLocalizedString(@"password", nil);
        UIImageView *passwordImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
        passwordImageViewPwd.image=[UIImage imageNamed:@"ic_lock_black"];
        self.passwordField.leftView=passwordImageViewPwd;
        self.passwordField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
        self.passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.passwordField setSecureTextEntry:YES];
    
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.passwordField)-1, GET_LAYOUT_WIDTH(self.passwordField), 1)];
        lineView.backgroundColor = lineColor;
        [self.passwordField addSubview:lineView];
    
        [boxView addSubview:self.passwordField];
    
        UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.passwordField)+GET_LAYOUT_HEIGHT(self.passwordField)+GAP_HEIGHT*3, GET_LAYOUT_WIDTH(boxView), 44)];
        loginButton.backgroundColor = RGBA_COLOR(27, 163, 232, 1);
        loginButton.layer.cornerRadius = 5;
        loginButton.layer.masksToBounds = YES;
        [loginButton setTitle:NSLocalizedString(@"LoginButton", nil) forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(clickLoginButton) forControlEvents:UIControlEventTouchUpInside];
        [boxView addSubview:loginButton];
    
        UILabel *forgetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(loginButton)+GET_LAYOUT_HEIGHT(loginButton), 150, 44)];
        forgetLabel.text = NSLocalizedString(@"ResetLabel", nil);
        forgetLabel.textAlignment = NSTextAlignmentLeft;
        forgetLabel.textColor = RGBA_COLOR(27, 163, 232, 1);
        forgetLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer* forgetGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forgetPasswordTap:)];
        forgetGesture.numberOfTouchesRequired = 1;
        [forgetLabel addGestureRecognizer:forgetGesture];
        [boxView addSubview:forgetLabel];
    
        UILabel *signUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(boxView)-80, GET_LAYOUT_OFFSET_Y(loginButton)+GET_LAYOUT_HEIGHT(loginButton), 80, 44)];
        signUpLabel.text = NSLocalizedString(@"RegisterNavigationItemTitle", nil);
        signUpLabel.textAlignment = NSTextAlignmentRight;
        signUpLabel.textColor = RGBA_COLOR(27, 163, 232, 1);
        signUpLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer* signUpGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(signUpTap:)];
        signUpGesture.numberOfTouchesRequired = 1;
        [signUpLabel addGestureRecognizer:signUpGesture];
        [boxView addSubview:signUpLabel];
    
    [self.view addSubview:boxView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickLoginButton{
    [self.view endEditing:YES];
    
    if( [self.usernameField.text isEqualToString:@""] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"usernameEmpty", nil));
        return;
    }
    if( [self.passwordField.text isEqualToString:@""] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"userPasswordEmpty", nil));
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{
                               @"userName":self.usernameField.text,
                               @"userPassword":self.passwordField.text
                               };
    HUD_WAITING_SHOW(NSLocalizedString(@"Loging", nil));
    [manager POST:BASE_URL(@"user/signin") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        NSLog(@"results: %@", dic);
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        HUD_WAITING_HIDE;
        if( status == 200 ){
            self.appDelegate.userInfo =  [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:@"data"]];
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
