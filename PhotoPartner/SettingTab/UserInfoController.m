//
//  UserInfoController.m
//  PhotoPartner
//
//  Created by USER on 23/3/2018.
//  Copyright © 2018 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "UserInfoController.h"
#import "ResetPasswordController.h"
#import <AFNetworking/AFNetworking.h>

@interface UserInfoController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>
@property UITableView *tableView;

@property UITextField *userNameField;
@property UITextField *userAccountField;
@property NSString *userNickname;

@property AppDelegate *appDelegate;
@end

@implementation UserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.navigationItem.title = NSLocalizedString(@"userInfoNavigationItemTitle", nil);
    
    UIBarButtonItem *userSaveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"saveButton", nil) style:UIBarButtonItemStylePlain target:self action:@selector(clickUserSaveButton)];
    self.navigationItem.rightBarButtonItem = userSaveButton;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, MARGIN_TOP, VIEW_WIDTH, VIEW_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.userNickname = [[self.appDelegate.userInfo objectForKey:@"user_nickname"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //self.view.userInteractionEnabled = YES;
    //UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    //singleTap.delegate = self;
    //[self.view addGestureRecognizer:singleTap];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if( indexPath.row == 0 ){
        self.userNameField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, GET_LAYOUT_WIDTH(self.tableView)-30, 44)];
        self.userNameField.text = self.userNickname;
        self.userNameField.backgroundColor = [UIColor whiteColor];
        [self setTextFieldLeftPadding:self.userNameField forWidth:110 forText:NSLocalizedString(@"userInfoUserName", nil)];
        self.userNameField.placeholder = NSLocalizedString(@"userInfoUserNameTextFiledTitle", nil);
        self.userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.userNameField.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.userNameField];
    }else if( indexPath.row == 1 ){
        self.userAccountField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, GET_LAYOUT_WIDTH(self.tableView)-30, 44)];
        self.userAccountField.backgroundColor = [UIColor whiteColor];
        [self setTextFieldLeftPadding:self.userAccountField forWidth:110 forText:NSLocalizedString(@"userInfoUserAccount", nil)];
        self.userAccountField.text = [[self.appDelegate.userInfo objectForKey:@"user_account"] stringValue];
        self.userAccountField.enabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.userAccountField];
    }else if( indexPath.row == 2 ){
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"ChangePassword", nil);
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @" ";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //    VideoDetailController *videoDetailController = [[VideoDetailController alloc] init];
    //    [self.navigationController pushViewController:videoDetailController animated:YES];
    ResetPasswordController *resetPasswordController;
    if( indexPath.section == 0 ){
        switch (indexPath.row) {
            case 2:
                resetPasswordController = [[ResetPasswordController alloc] init];
                [self.navigationController pushViewController:resetPasswordController animated:YES];
                break;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)setTextFieldLeftPadding:(UITextField *)textField forWidth:(CGFloat)leftWidth forText:(NSString *)text {
    CGRect frame = textField.frame;
    frame.size.width = leftWidth;
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:frame];
    leftLabel.text = text;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = leftLabel;
}

- (void)clickUserSaveButton {
    [self.view endEditing:YES];
    
    if( [self.userNickname isEqualToString:self.userNameField.text] ){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if( self.userNameField.text.length > INPUT_MAX_TEXT ){
        HUD_TOAST_SHOW(NSLocalizedString(@"inputMaxText", nil));
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{
                               @"userId":[self.appDelegate.userInfo objectForKey:@"user_id"],
                               @"userNewName": [self.userNameField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                               };
    HUD_WAITING_SHOW(NSLocalizedString(@"loadingSaving", nil));
    [manager POST:BASE_URL(@"user/userModUserName") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        NSLog(@"results: %@", dic);
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        HUD_WAITING_HIDE;
        if( status == 200 ){
            self.userNickname = self.userNameField.text;
            [self.appDelegate.userInfo setObject:self.userNameField.text forKey:@"user_nickname"];
            [self.appDelegate saveUserInfo];
            HUD_TOAST_SHOW(NSLocalizedString(@"saveSuccess", nil));
        }else{
            NSString *eCode = [NSString stringWithFormat:@"e%d", status];
            HUD_TOAST_SHOW(NSLocalizedString(eCode, nil));
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败.%@",error);
        NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        
        HUD_WAITING_HIDE;
        HUD_TOAST_SHOW(NSLocalizedString(@"saveFailed", nil));
    }];
}

-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if( (self.userNameField.text.length + string.length) > INPUT_MAX_TEXT ){
        HUD_TOAST_SHOW(NSLocalizedString(@"inputMaxText", nil));
        return NO;
    }
    return YES;
}

@end
