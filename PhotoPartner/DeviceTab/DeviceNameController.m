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
#import "DeviceNameController.h"
#import "ScanDeviceController.h"

@interface DeviceNameController () <UIGestureRecognizerDelegate, ScanDeviceControllerDelegate, UITextFieldDelegate>
@property AppDelegate *appDelegate;
@property UITextField *deviceUserNameField;
@end

@implementation DeviceNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    //self.view.backgroundColor = RGBA_COLOR(239, 239, 239, 1);
    self.navigationItem.title = NSLocalizedString(@"EditNameNavigationItemTitle", nil);
    
    //INIT_RightBarButtonItem(ICON_SCAN, clickDeviceScanButton);
    
    //    UIBarButtonItem *deviceAddButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"deviceAddRightBarButtonItemTitle", nil) style:UIBarButtonItemStylePlain target:self action:@selector(clickDeviceAddButtonButton)];
    //    self.navigationItem.rightBarButtonItem = deviceAddButton;
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIColor *lineColor = RGBA_COLOR(200, 200, 200, 1);
    
    UIView *deviceView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, MARGIN_TOP+GAP_HEIGHT*2+64, VIEW_WIDTH-4*GAP_WIDTH, VIEW_HEIGHT)];
    
    self.deviceUserNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(deviceView), 44)];
    self.deviceUserNameField.delegate = self;
    UIView *tokenLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.deviceUserNameField)-1, GET_LAYOUT_WIDTH(self.deviceUserNameField), 1)];
    tokenLineView.backgroundColor = lineColor;
    [self.deviceUserNameField addSubview:tokenLineView];
    self.deviceUserNameField.text = self.deviceName;
    self.deviceUserNameField.placeholder = NSLocalizedString(@"EditNameLabel", nil);
//    UIImageView *usernameImageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, 48, 48)];
//    usernameImageViewPwd.image=[UIImage imageNamed:@"ic_account_black"];
//    self.deviceUserNameField.leftView=usernameImageViewPwd;
//    self.deviceUserNameField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
    self.deviceUserNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.deviceUserNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [deviceView addSubview:self.deviceUserNameField];
    
    UIButton *deviceAddButton = [[UIButton alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.deviceUserNameField)+GET_LAYOUT_HEIGHT(self.deviceUserNameField)+40, GET_LAYOUT_WIDTH(deviceView), 44)];
    deviceAddButton.backgroundColor = RGBA_COLOR(27, 163, 232, 1);
    deviceAddButton.layer.cornerRadius = 5;
    deviceAddButton.layer.masksToBounds = YES;
    [deviceAddButton setTitle:NSLocalizedString(@"EditNameButton", nil) forState:UIControlStateNormal];
    [deviceAddButton addTarget:self action:@selector(clickDeviceUserNameSubmitButton) forControlEvents:UIControlEventTouchUpInside];
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

- (void)clickDeviceUserNameSubmitButton {
    [self.view endEditing:YES];
    
    if( [self.deviceUserNameField.text isEqualToString:@""] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"EditNameEmpty", nil));
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{
                               @"user_id":[self.appDelegate.userInfo objectForKey:@"user_id"],
                               @"device_id":[NSString stringWithFormat:@"%d", self.deviceId],
//                               @"status":@"rename",
                               @"rename_name":self.deviceUserNameField.text
                               };
    HUD_WAITING_SHOW(NSLocalizedString(@"Saving", nil));
    [manager POST:BASE_URL(@"user/modUserDeviceName") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        NSLog(@"results: %@", dic);
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        HUD_WAITING_HIDE;
        if( status == 200 ){
            /*NSDictionary *data = [dic objectForKey:@"data"];
             NSString *device_id = [data objectForKey:@"device_id"];
             
             NSMutableDictionary *device = [[NSMutableDictionary alloc] init];
             [device setObject:device_id forKey:@"device_id"];
             [device setObject:self.deviceUserNameField.text forKey:@"device_token"];
             //[device setObject:self.deviceNameField.text forKey:@"device_name"];
             [device setObject:@0 forKey:@"isSelected"];
             [self.appDelegate.deviceList addObject:device];
             
             NSLog(@"%@", self.appDelegate.deviceList);
             [self.appDelegate addDeviceList:device];
             
             
             NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
             NSString *time = [dateFormatter stringFromDate:date];
             //NSString *deviceName = self.deviceNameField.text;
             NSString *desc = @"";
             //[self.appDelegate addMessageList:@"bind" withTime:time withTitle:deviceName withDesc:desc withData:nil];*/
            
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

- (void)clickDeviceScanButton {
    ScanDeviceController *scanDeviceController = [[ScanDeviceController alloc] init];
    scanDeviceController.delegate = self;
    [self.navigationController pushViewController:scanDeviceController animated:YES];
}

- (void)license:(NSString *)license {
    self.deviceUserNameField.text = license;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //if( (self.deviceNameField.text.length + string.length) > INPUT_MAX_TEXT ){
    //    HUD_TOAST_SHOW(NSLocalizedString(@"inputMaxText", nil));
    //    return NO;
    //}
    return YES;
}

@end
