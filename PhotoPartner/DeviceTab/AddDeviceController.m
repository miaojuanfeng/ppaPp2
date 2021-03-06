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
#import "AddDeviceController.h"
#import "ScanDeviceController.h"
#import "LoginController.h"

#define NUM @"0123456789"
#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"

@interface AddDeviceController () <UIGestureRecognizerDelegate, ScanDeviceControllerDelegate, UITextFieldDelegate>
@property AppDelegate *appDelegate;
@property UITextField *deviceNameField;
@property UITextField *deviceUserNameField;
@property UITextField *deviceTokenField;
@end


@implementation AddDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    //self.view.backgroundColor = RGBA_COLOR(239, 239, 239, 1);
    self.navigationItem.title = NSLocalizedString(@"deviceAddNavigationItemTitle", nil);
    
    //INIT_RightBarButtonItem(ICON_SCAN, clickDeviceScanButton);
    
//    UIBarButtonItem *deviceAddButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"deviceAddRightBarButtonItemTitle", nil) style:UIBarButtonItemStylePlain target:self action:@selector(clickDeviceAddButtonButton)];
//    self.navigationItem.rightBarButtonItem = deviceAddButton;
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIColor *lineColor = RGBA_COLOR(200, 200, 200, 1);
    
    UIView *deviceView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, MARGIN_TOP+GAP_HEIGHT*2+64, VIEW_WIDTH-4*GAP_WIDTH, VIEW_HEIGHT)];
    
    self.deviceUserNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(deviceView), 44)];
    self.deviceUserNameField.delegate = self;
    UIView *nameLineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.deviceUserNameField)-1, GET_LAYOUT_WIDTH(self.deviceUserNameField), 1)];
    nameLineView2.backgroundColor = lineColor;
    [self.deviceUserNameField addSubview:nameLineView2];
    self.deviceUserNameField.placeholder = NSLocalizedString(@"deviceAddDeviceName", nil);
    self.deviceUserNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [deviceView addSubview:self.deviceUserNameField];
    
    self.deviceNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.deviceUserNameField)+30, GET_LAYOUT_WIDTH(deviceView)/2, 44)];
    self.deviceNameField.delegate = self;
    UIView *nameLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.deviceNameField)-1, GET_LAYOUT_WIDTH(deviceView), 1)];
    nameLineView.backgroundColor = lineColor;
    [self.deviceNameField addSubview:nameLineView];
    
    self.deviceNameField.keyboardType = UIKeyboardTypeASCIICapable;
    
    UILabel *mailSuffix = [[UILabel alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(self.deviceNameField), GET_LAYOUT_HEIGHT(self.deviceNameField)-44, GET_LAYOUT_WIDTH(self.deviceNameField)-5, 44)];
    mailSuffix.text = COMPANY_EMAIL(@"");
    mailSuffix.textAlignment = NSTextAlignmentRight;
//    mailSuffix.backgroundColor = [UIColor yellowColor];
    [self.deviceNameField addSubview:mailSuffix];
    
    self.deviceNameField.placeholder = NSLocalizedString(@"deviceAddEmailDeviceName", nil);
    self.deviceNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [deviceView addSubview:self.deviceNameField];
    
    
    
//    self.deviceTokenField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.deviceNameField)+GET_LAYOUT_HEIGHT(self.deviceNameField)+30, GET_LAYOUT_WIDTH(deviceView), 44)];
    self.deviceTokenField = [[UITextField alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.deviceNameField)+GET_LAYOUT_HEIGHT(self.deviceNameField)+30, GET_LAYOUT_WIDTH(deviceView), 44)];
    self.deviceTokenField.delegate = self;
    UIView *tokenLineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.deviceTokenField)-1, GET_LAYOUT_WIDTH(self.deviceTokenField), 1)];
    tokenLineView.backgroundColor = lineColor;
    [self.deviceTokenField addSubview:tokenLineView];
    self.deviceTokenField.placeholder = NSLocalizedString(@"deviceAddDeviceNumber", nil);
    self.deviceTokenField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [deviceView addSubview:self.deviceTokenField];
    
//    UIButton *deviceAddButton = [[UIButton alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(self.deviceTokenField)+GET_LAYOUT_HEIGHT(self.deviceTokenField)+40, GET_LAYOUT_WIDTH(deviceView), 44)];
    UIButton *deviceAddButton = [[UIButton alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(self.deviceUserNameField)+GET_LAYOUT_OFFSET_Y(self.deviceTokenField)+GET_LAYOUT_HEIGHT(self.deviceTokenField)+40, GET_LAYOUT_WIDTH(deviceView), 44)];
    deviceAddButton.backgroundColor = RGBA_COLOR(27, 163, 232, 1);
    deviceAddButton.layer.cornerRadius = 5;
    deviceAddButton.layer.masksToBounds = YES;
    [deviceAddButton setTitle:NSLocalizedString(@"deviceAddRightBarButtonItemTitle", nil) forState:UIControlStateNormal];
    [deviceAddButton addTarget:self action:@selector(clickDeviceAddButton) forControlEvents:UIControlEventTouchUpInside];
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

- (void)clickDeviceAddButton {
    [self.view endEditing:YES];
    if( [self.deviceUserNameField.text isEqualToString:@""] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"deviceAddEmailDeviceName", nil));
        return;
    }
    
    if( [self.deviceNameField.text isEqualToString:@""] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"deviceAddDeviceName", nil));
        return;
    }
    if( [self.deviceTokenField.text isEqualToString:@""] ){
        HUD_TOAST_SHOW(NSLocalizedString(@"deviceAddDeviceNumber", nil));
        return;
    }
    
    if( self.deviceNameField.text.length > INPUT_MAX_TEXT ){
        HUD_TOAST_SHOW(NSLocalizedString(@"inputMaxText", nil));
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{
                               @"user_id":[self.appDelegate.userInfo objectForKey:@"user_id"],
                               @"device_token":self.deviceTokenField.text,
                               @"deviceUserName":[self.deviceUserNameField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                               @"device_name":[self.deviceNameField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                               @"type":@"mydevice",
                               @"companyName":COMPANY_NAME
                               };
    NSLog(@"AddDevicePush:%@",parameters);
    //加入header参数
    [manager.requestSerializer setValue:[self.appDelegate.userInfo objectForKey:@"user_system_token"] forHTTPHeaderField:@"user_token"];
    HUD_WAITING_SHOW(NSLocalizedString(@"loadingBinding", nil));
    [manager POST:BASE_URL(@"device/bind") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        NSLog(@"results: %@", dic);
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        HUD_WAITING_HIDE;
        if( status == 200 ){
            NSDictionary *data = [dic objectForKey:@"data"];
            
            NSMutableDictionary *device = [[NSMutableDictionary alloc] init];
            [device setObject:[data objectForKey:@"device_id"] forKey:@"device_id"];
            [device setObject:self.deviceTokenField.text forKey:@"device_token"];
            [device setObject:self.deviceNameField.text forKey:@"device_name"];
            [device setObject:[data objectForKey:@"device_fcm_token"] forKey:@"device_fcm_token"];
            [device setObject:[data objectForKey:@"create_date"] forKey:@"create_date"];
            [device setObject:[data objectForKey:@"modify_date"] forKey:@"modify_date"];
            [device setObject:@"mydevice" forKey:@"isAdmin"];
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
            [self.appDelegate addMessageList:@"bind" withTime:time withTitle:deviceName withDesc:desc withData:nil];
            
            HUD_TOAST_POP_SHOW(NSLocalizedString(@"deviceAddBindSuccess", nil));
        } else if ( status == 418 ) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UserSystemTokenError", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.appDelegate deleteUserInfo];
                self.appDelegate.isLogout = true;
                LoginController *loginController = [[LoginController alloc] init];
                [self.navigationController pushViewController:loginController animated:YES];
            }];
            
            [alertController addAction:okAction];           // A
            
            [self presentViewController:alertController animated:YES completion:nil];
        } else if ( status == 405 ) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UserSystemTokenError", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.appDelegate deleteUserInfo];
                self.appDelegate.isLogout = true;
                LoginController *loginController = [[LoginController alloc] init];
                [self.navigationController pushViewController:loginController animated:YES];
            }];
            
            [alertController addAction:okAction];           // A
            
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            NSString *eCode = [NSString stringWithFormat:@"e%d", status];
            HUD_TOAST_SHOW(NSLocalizedString(eCode, nil));
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败.%@",error);
        NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        
        HUD_WAITING_HIDE;
        HUD_TOAST_SHOW(NSLocalizedString(@"deviceAddBindFailed", nil));
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
    self.deviceTokenField.text = license;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    if( (self.deviceNameField.text.length + string.length) > INPUT_MAX_TEXT ){
//        HUD_TOAST_SHOW(NSLocalizedString(@"inputMaxText", nil));
//        return NO;
//    }
    if(textField == self.deviceNameField)
    {
        if( (self.deviceNameField.text.length + string.length) > INPUT_MAX_TEXT ){
            HUD_TOAST_SHOW(NSLocalizedString(@"inputMaxText", nil));
            return NO;
        }
        
    }
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
    
//    return YES;
}



@end
