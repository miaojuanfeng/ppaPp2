//
//  ViewController.m
//  PhotoPartner
//
//  Created by USER on 6/3/2018.
//  Copyright © 2018 MJF. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import <TZImagePickerController.h>
#import "MacroDefine.h"
#import "AppDelegate.h"
#import "HomeController.h"
#import "UploadPhotoController.h"
#import "UploadVideoController.h"
#import "DeviceController.h"
#import "AddDeviceController.h"
#import "MessageController.h"
#import "SettingController.h"
#import "LoginController.h"
#import "DetailController.h"
#import "DevicesController.h"
//#import <MobileCoreServices/MobileCoreServices.h>
#import "GSKeyChainDataManager.h"
#import <AFNetworking/AFNetworking.h>
#import <TZImageManager.h>
#import <Photos/Photos.h>
#import <QiniuSDK.h>

@interface HomeController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property UIAlertController *actionSheet;
@property AppDelegate *appDelegate;

@property Boolean isHideBar;

@property TZImagePickerController *imagePickerVc;

@property UILabel *usernameLabel;
@property UIImageView *headImage;
@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
//    self.navigationItem.title = NSLocalizedString(@"homeNavigationItemTitle", nil);
    self.navigationController.delegate = self;
    self.isHideBar = true;
    
    VIEW_WIDTH = VIEW_WIDTH - GAP_WIDTH * 4;
    VIEW_HEIGHT = VIEW_HEIGHT - GAP_HEIGHT * 3 -20;
    int leftGap = GAP_WIDTH * 2;
//    MARGIN_TOP -= GET_LAYOUT_HEIGHT(self.navigationController.navigationBar);
//    VIEW_HEIGHT += GET_LAYOUT_HEIGHT(self.navigationController.navigationBar);
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(self.view), GET_LAYOUT_HEIGHT(self.view)+GAP_HEIGHT*2)];
    //bgView.image = [UIImage imageNamed:@"bg_main"];
    //[self.view addSubview:bgView];
    
    UIView *accountBoxView = [[UIView alloc] initWithFrame:CGRectMake(leftGap, MARGIN_TOP+20, VIEW_WIDTH, VIEW_HEIGHT/4-GAP_HEIGHT*8)];
    
        UIButton *headButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (GET_LAYOUT_HEIGHT(accountBoxView)-60)/2, 60, 60)];
        headButton.layer.masksToBounds = YES;
        headButton.layer.cornerRadius = 30;
        [headButton addTarget:self action:@selector(clickHeadButton) forControlEvents:UIControlEventTouchUpInside];
        self.headImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(headButton), GET_LAYOUT_HEIGHT(headButton))];
        self.headImage.contentMode = UIViewContentModeScaleAspectFill;
        if( self.appDelegate.userInfo != nil && ![[self.appDelegate.userInfo objectForKey:@"profileImageUrl"] isEqualToString:@""] ){
            self.headImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.appDelegate.userInfo objectForKey:@"profileImageUrl"]]]];
        }else{
            self.headImage.image = [UIImage imageNamed:@"ic_profile_black"];
        }
        [headButton addSubview:self.headImage];
        [accountBoxView addSubview:headButton];
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(self.headImage)+GET_LAYOUT_WIDTH(self.headImage)+GAP_WIDTH*2, 0, GET_LAYOUT_WIDTH(accountBoxView)/2-GAP_WIDTH*2, GET_LAYOUT_HEIGHT(accountBoxView))];
        self.usernameLabel.font = [UIFont systemFontOfSize:18];
        self.usernameLabel.text = [[self.appDelegate.userInfo objectForKey:@"user_nickname"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //usernameLabel.backgroundColor = [UIColor yellowColor];
        [accountBoxView addSubview:self.usernameLabel];
    
        UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(accountBoxView)-35-GAP_WIDTH*2, (GET_LAYOUT_HEIGHT(accountBoxView)-40)/2, 35, 35)];
        UIImageView *settingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0-15, 0-15, GET_LAYOUT_WIDTH(settingButton)+30, GET_LAYOUT_HEIGHT(settingButton)+30)];
        settingImageView.image = [UIImage imageNamed:@"ic_settings_black"];
        [settingButton addSubview:settingImageView];
        [settingButton addTarget:self action:@selector(clickSettingButton) forControlEvents:UIControlEventTouchUpInside];
        [accountBoxView addSubview:settingButton];
    
    
    [self.view addSubview:accountBoxView];
    
    
    UIView *topBoxView = [[UIView alloc] initWithFrame:CGRectMake(leftGap, GET_LAYOUT_OFFSET_Y(accountBoxView)+GET_LAYOUT_HEIGHT(accountBoxView)+GAP_HEIGHT, VIEW_WIDTH, VIEW_HEIGHT/4+GAP_HEIGHT*2)];
        UIView *topLeftBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (GET_LAYOUT_WIDTH(topBoxView)-GAP_WIDTH*2)/2, GET_LAYOUT_HEIGHT(topBoxView))];
            UIButton *takePhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(topLeftBoxView), GET_LAYOUT_HEIGHT(topLeftBoxView))];
            [takePhotoButton addTarget:self action:@selector(clickTakePhotoButton) forControlEvents:UIControlEventTouchUpInside];
            //[takePhotoButton setImage:[UIImage imageNamed:@"pictures_bg"] forState:UIControlStateNormal];
            takePhotoButton.backgroundColor = RGBA_COLOR(255, 69, 0, 1);
            takePhotoButton.clipsToBounds = YES;
            takePhotoButton.layer.cornerRadius = 10;
            takePhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
                UIView *takePhotoIcon = [[UIView alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(topLeftBoxView)-60)/2, (GET_LAYOUT_HEIGHT(topLeftBoxView)-60)/2-15, 60, 60)];
                takePhotoIcon.userInteractionEnabled = NO;
                    UIImageView *takePhotoIconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(takePhotoIcon), GET_LAYOUT_HEIGHT(takePhotoIcon))];
                    takePhotoIconImage.image = [UIImage imageNamed:@"ic_camera_white"];
                    [takePhotoIcon addSubview:takePhotoIconImage];
                    UILabel *takePhotoIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(takePhotoIcon)+10, GET_LAYOUT_WIDTH(takePhotoIcon), 20)];
                    takePhotoIconLabel.textAlignment = NSTextAlignmentCenter;
                    takePhotoIconLabel.textColor = [UIColor whiteColor];
                    takePhotoIconLabel.text = NSLocalizedString(@"homeTakePhotoTitle", nil);
                    [takePhotoIcon addSubview:takePhotoIconLabel];
                [takePhotoButton addSubview:takePhotoIcon];
        [topLeftBoxView addSubview:takePhotoButton];
        [topBoxView addSubview:topLeftBoxView];
    
        UIView *topRightBoxView = [[UIView alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(topLeftBoxView)+GAP_WIDTH*2, 0, (GET_LAYOUT_WIDTH(topBoxView)-GAP_WIDTH*2)/2, topBoxView.frame.size.height)];
            UIButton *takeVideoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(topRightBoxView), GET_LAYOUT_HEIGHT(topRightBoxView))];
            [takeVideoButton addTarget:self action:@selector(clickTakeVideoButton) forControlEvents:UIControlEventTouchUpInside];
            //[takeVideoButton setImage:[UIImage imageNamed:@"video_recording_bg"] forState:UIControlStateNormal];
            takeVideoButton.backgroundColor = RGBA_COLOR(29, 161, 242, 1);
            takeVideoButton.clipsToBounds = YES;
            takeVideoButton.layer.cornerRadius = 10;
            takeVideoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            UIView *takeVideoIcon = [[UIView alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(takeVideoButton)-60)/2, (GET_LAYOUT_HEIGHT(takeVideoButton)-60)/2-15, 60, 60)];
            takeVideoIcon.userInteractionEnabled = NO;
            UIImageView *takeVideoIconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(takePhotoIcon), GET_LAYOUT_HEIGHT(takePhotoIcon))];
            takeVideoIconImage.image = [UIImage imageNamed:@"ic_video_white"];
            [takeVideoIcon addSubview:takeVideoIconImage];
            [takeVideoButton addSubview:takeVideoIcon];
    
            UILabel *takeVideoIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(takeVideoIcon)+GET_LAYOUT_HEIGHT(takeVideoIcon)+10, GET_LAYOUT_WIDTH(takeVideoButton), 20)];
            takeVideoIconLabel.textAlignment = NSTextAlignmentCenter;
            takeVideoIconLabel.textColor = [UIColor whiteColor];
            takeVideoIconLabel.text = NSLocalizedString(@"homeTakeVodioTitle", nil);
            [takeVideoButton addSubview:takeVideoIconLabel];
        [topRightBoxView addSubview:takeVideoButton];
        [topBoxView addSubview:topRightBoxView];
    [self.view addSubview:topBoxView];
    
    UIView *centerBoxView = [[UIView alloc] initWithFrame:CGRectMake(leftGap, GET_LAYOUT_OFFSET_Y(topBoxView)+GET_LAYOUT_HEIGHT(topBoxView)+GAP_HEIGHT*2, VIEW_WIDTH, VIEW_HEIGHT/4)];
        //UIView *centerLeftBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (GET_LAYOUT_WIDTH(centerBoxView)-GAP_WIDTH)/2, GET_LAYOUT_HEIGHT(centerBoxView))];
          /*  UIButton *takeVideoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(centerLeftBoxView), GET_LAYOUT_HEIGHT(centerLeftBoxView))];
            [takeVideoButton addTarget:self action:@selector(clickTakeVideoButton) forControlEvents:UIControlEventTouchUpInside];
            [takeVideoButton setImage:[UIImage imageNamed:@"video_recording_bg"] forState:UIControlStateNormal];
            takeVideoButton.clipsToBounds = YES;
            takeVideoButton.layer.cornerRadius = 10;
            takeVideoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
                UIView *takeVideoIcon = [[UIView alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(takeVideoButton)-80)/2, (GET_LAYOUT_HEIGHT(takeVideoButton)-80)/2, 80, 80)];
                takeVideoIcon.userInteractionEnabled = NO;
                    UIImageView *takeVideoIconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(takePhotoIcon), GET_LAYOUT_HEIGHT(takePhotoIcon))];
                    takeVideoIconImage.image = [UIImage imageNamed:@"video_recording"];
                    [takeVideoIcon addSubview:takeVideoIconImage];
                    [takeVideoButton addSubview:takeVideoIcon];
    
                UILabel *takeVideoIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(takeVideoIcon)+GET_LAYOUT_HEIGHT(takeVideoIcon)+10, GET_LAYOUT_WIDTH(takeVideoButton), 20)];
                takeVideoIconLabel.textAlignment = NSTextAlignmentCenter;
                takeVideoIconLabel.textColor = [UIColor whiteColor];
                takeVideoIconLabel.text = NSLocalizedString(@"homeTakeVodioTitle", nil);
                [takeVideoButton addSubview:takeVideoIconLabel];
            [centerLeftBoxView addSubview:takeVideoButton];
        [centerBoxView addSubview:centerLeftBoxView];*/
    
        //UIView *centerRightBoxView = [[UIView alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(centerLeftBoxView)+GAP_WIDTH, 0, (GET_LAYOUT_WIDTH(centerBoxView)-GAP_WIDTH)/2, centerBoxView.frame.size.height)];
            UIButton *photoLibButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(centerBoxView), GET_LAYOUT_HEIGHT(centerBoxView))];
            photoLibButton.backgroundColor = RGBA_COLOR(239, 179, 54, 1);
            photoLibButton.clipsToBounds = YES;
            photoLibButton.layer.cornerRadius = 10;
//            [photoLibButton setTitle:NSLocalizedString(@"homePhotoLibTitle", nil) forState:UIControlStateNormal];
            [photoLibButton addTarget:self action:@selector(clickPhotoLibButton) forControlEvents:UIControlEventTouchUpInside];
    
            UIView *photoLibIcon = [[UIView alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(photoLibButton)-60)/2, (GET_LAYOUT_HEIGHT(photoLibButton)-60)/2-15, 60, 60)];
            photoLibIcon.userInteractionEnabled = NO;
    
                UIImageView *photoLibImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(photoLibIcon), GET_LAYOUT_HEIGHT(photoLibIcon))];
                photoLibImage.image = [UIImage imageNamed:@"ic_folder_white"];
                [photoLibIcon addSubview:photoLibImage];
    
            [photoLibButton addSubview:photoLibIcon];
    
            UILabel *photoLibLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(photoLibIcon)+GET_LAYOUT_HEIGHT(photoLibIcon)+10, GET_LAYOUT_WIDTH(photoLibButton), 20)];
            photoLibLabel.textAlignment = NSTextAlignmentCenter;
            photoLibLabel.textColor = [UIColor whiteColor];
            photoLibLabel.text = NSLocalizedString(@"homePhotoLibTitle", nil);
            [photoLibButton addSubview:photoLibLabel];
    
            //[centerRightBoxView addSubview:photoLibButton];
    
    
    
        [centerBoxView addSubview:photoLibButton];
    
    [self.view addSubview:centerBoxView];
    
    UIView *bottomBoxView = [[UIView alloc] initWithFrame:CGRectMake(leftGap, GET_LAYOUT_OFFSET_Y(centerBoxView)+GET_LAYOUT_HEIGHT(centerBoxView)+GAP_HEIGHT*2, VIEW_WIDTH, VIEW_HEIGHT/4+GAP_HEIGHT*2)];
        UIView *bottomLeftBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (GET_LAYOUT_WIDTH(bottomBoxView)-GAP_WIDTH*2)/2, GET_LAYOUT_HEIGHT(bottomBoxView))];
    
            UIButton *bindDeviceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(bottomLeftBoxView), GET_LAYOUT_HEIGHT(bottomLeftBoxView))];
            bindDeviceButton.backgroundColor = RGBA_COLOR(52, 168, 83, 1);
            bindDeviceButton.clipsToBounds = YES;
            bindDeviceButton.layer.cornerRadius = 10;
    //        [bindDeviceButton setTitle:NSLocalizedString(@"deviceListNavigationItemTitle", nil) forState:UIControlStateNormal];
            [bindDeviceButton addTarget:self action:@selector(clickDeviceManageButton) forControlEvents:UIControlEventTouchUpInside];
            [bottomBoxView addSubview:bindDeviceButton];
    
            UIView *bindDevicIcon = [[UIView alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(bindDeviceButton)-60)/2, (GET_LAYOUT_HEIGHT(bindDeviceButton)-60)/2-15, 60, 60)];
            bindDevicIcon.userInteractionEnabled = NO;
    
            UIImageView *bindDevicIconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(bindDevicIcon), GET_LAYOUT_HEIGHT(bindDevicIcon))];
            bindDevicIconImage.image = [UIImage imageNamed:@"ic_devices_white"];
            [bindDevicIcon addSubview:bindDevicIconImage];
    
            [bindDeviceButton addSubview:bindDevicIcon];
    
            UILabel *bindDeviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(bindDevicIcon)+GET_LAYOUT_HEIGHT(bindDevicIcon)+5, GET_LAYOUT_WIDTH(bindDeviceButton), 20)];
            bindDeviceLabel.textAlignment = NSTextAlignmentCenter;
            bindDeviceLabel.textColor = [UIColor whiteColor];
            bindDeviceLabel.text = NSLocalizedString(@"deviceListNavigationItemTitle", nil);
            [bindDeviceButton addSubview:bindDeviceLabel];
        [bottomLeftBoxView addSubview:bindDeviceButton];
        [bottomBoxView addSubview:bottomLeftBoxView];
    
        UIView *bottomRightBoxView = [[UIView alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(bottomLeftBoxView)+GAP_WIDTH*2, 0, (GET_LAYOUT_WIDTH(bottomBoxView)-GAP_WIDTH*2)/2, GET_LAYOUT_HEIGHT(bottomBoxView))];
    
            UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(bottomRightBoxView), GET_LAYOUT_HEIGHT(bottomRightBoxView))];
            messageButton.backgroundColor = RGBA_COLOR(123, 142, 221, 1);
            messageButton.clipsToBounds = YES;
            messageButton.layer.cornerRadius = 10;
            [messageButton addTarget:self action:@selector(clickMessageButton) forControlEvents:UIControlEventTouchUpInside];
    
            UIView *messageIcon = [[UIView alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(messageButton)-60)/2, (GET_LAYOUT_HEIGHT(messageButton)-60)/2-15, 60, 60)];
            messageIcon.userInteractionEnabled = NO;
    
            UIImageView *messageIconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(messageIcon), GET_LAYOUT_HEIGHT(messageIcon))];
            messageIconImage.image = [UIImage imageNamed:@"ic_message_white"];
            [messageIcon addSubview:messageIconImage];
    
            [messageButton addSubview:messageIcon];
    
            UILabel *messageIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(messageIcon)+GET_LAYOUT_HEIGHT(messageIcon)+5, GET_LAYOUT_WIDTH(messageButton), 20)];
            messageIconLabel.textAlignment = NSTextAlignmentCenter;
            messageIconLabel.textColor = [UIColor whiteColor];
            messageIconLabel.text = NSLocalizedString(@"messageNavigationItemTitle", nil);
            [messageButton addSubview:messageIconLabel];
    
        [bottomRightBoxView addSubview:messageButton];
        [bottomBoxView addSubview:bottomRightBoxView];
    
    [self.view addSubview:bottomBoxView];
    
        /*UIView *topRightBoxView = [[UIView alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(topLeftBoxView)+GAP_WIDTH, 0, (GET_LAYOUT_WIDTH(topBoxView)-GAP_WIDTH)/2, topBoxView.frame.size.height)];
    
        UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(bindDeviceButton)+GAP_HEIGHT, GET_LAYOUT_WIDTH(bottomBoxView), (GET_LAYOUT_HEIGHT(bottomBoxView)-GAP_HEIGHT)/2)];
        settingButton.backgroundColor = RGBA_COLOR(235, 182, 67, 1);
            settingButton.clipsToBounds = YES;
            settingButton.layer.cornerRadius = 10;
    //        [settingButton setTitle:NSLocalizedString(@"settingNavigationItemTitle", nil) forState:UIControlStateNormal];
            [settingButton addTarget:self action:@selector(clickSettingButton) forControlEvents:UIControlEventTouchUpInside];
            [bottomBoxView addSubview:settingButton];
    
    
    
            UIView *settingIcon = [[UIView alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(settingButton)-70)/2, (GET_LAYOUT_HEIGHT(settingButton)-60)/2-10, 70, 60)];
            settingIcon.userInteractionEnabled = NO;
    
            UIImageView *settingIconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(settingIcon), GET_LAYOUT_HEIGHT(settingIcon))];
            settingIconImage.image = [UIImage imageNamed:@"settings"];
            [settingIcon addSubview:settingIconImage];
    
            [settingButton addSubview:settingIcon];
    
            UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(settingIcon)+GET_LAYOUT_HEIGHT(settingIcon)+5, GET_LAYOUT_WIDTH(settingButton), 20)];
            settingLabel.textAlignment = NSTextAlignmentCenter;
            settingLabel.textColor = [UIColor whiteColor];
            settingLabel.text = NSLocalizedString(@"settingNavigationItemTitle", nil);
            [settingButton addSubview:settingLabel];*/
    
    
    
    
    
    /**
     *  获取设备UUID
     */
    self.appDelegate.deviceUUID = [GSKeyChainDataManager readUUID];
    NSLog(@"deviceUUID: %@", self.appDelegate.deviceUUID);
    NSLog(@"userInfo: %@", self.appDelegate.userInfo);
    if( self.appDelegate.deviceUUID == nil ){
        self.appDelegate.deviceUUID = [[UIDevice currentDevice].identifierForVendor UUIDString];
        [GSKeyChainDataManager saveUUID:self.appDelegate.deviceUUID];
        NSLog(@"重新生成deviceUUID: %@", self.appDelegate.deviceUUID);
    }
    if( self.appDelegate.userInfo == nil ){
        /**
         *  向服务器提交登录信息
         */
        /*AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 30.0f;
        NSDictionary *parameters = @{@"user_imei":self.appDelegate.deviceUUID};
        HUD_WAITING_SHOW(NSLocalizedString(@"loadingSignin", nil));
        [manager POST:BASE_URL(@"user/signin") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float progress = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
                
                HUD_LOADING_PROGRESS(progress);
            });
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"成功.%@",responseObject);
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
            NSLog(@"results: %@", dic);
            
            int status = [[dic objectForKey:@"status"] intValue];
            
            HUD_WAITING_HIDE;
            if( status == 200 ){
                self.appDelegate.userInfo =  [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:@"data"]];
                [self.appDelegate saveUserInfo];
                
                // 获取设备列表，如果为空就链接服务器查询，如果任然为空，就跳转页面
                if( self.appDelegate.deviceList.count == 0 && [self.appDelegate isNilDeviceList] ){
                    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                    manager.requestSerializer.timeoutInterval = 30.0f;
                    NSDictionary *parameters=@{
                                               @"user_id":[self.appDelegate.userInfo objectForKey:@"user_id"]
                                               };
                    HUD_WAITING_SHOW(NSLocalizedString(@"loadingDeviceList", nil));
                    [manager POST:BASE_URL(@"user/user_device") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
                        
                    } progress:^(NSProgress * _Nonnull uploadProgress) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            float progress = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
                            
                            HUD_LOADING_PROGRESS(progress);
                        });
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        NSLog(@"成功.%@",responseObject);
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
                        
                        int status = [[dic objectForKey:@"status"] intValue];
                        
                        HUD_WAITING_HIDE;
                        if( status == 200 ){
                            self.appDelegate.deviceList = [[dic objectForKey:@"data"] mutableCopy];
                            [self.appDelegate saveDeviceList];
                            
                            if( self.appDelegate.deviceList.count == 0 ){
                                AddDeviceController *addDeviceController = [[AddDeviceController alloc] init];
                                //[self.navigationController pushViewController:addDeviceController animated:YES];
                            }
                        }
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        NSLog(@"失败.%@",error);
                        NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
                        
                        HUD_WAITING_HIDE;
                        [self closeAlart];
                    }];
                }
            }
            NSLog(@"userInfo: %@", self.appDelegate.userInfo);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"失败.%@",error);
            NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
            
            HUD_WAITING_HIDE;
            [self closeAlart];
        }];*/
        LoginController *loginController = [[LoginController alloc] init];
        [self.navigationController pushViewController:loginController animated:YES];
    //}else if( self.appDelegate.deviceList.count == 0 && [self.appDelegate isNilDeviceList] ){
       // AddDeviceController *addDeviceController = [[AddDeviceController alloc] init];
        //[self.navigationController pushViewController:addDeviceController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    NSLog(@"is title: %@", viewController );
//    BOOL isHidden = NO;
//    if( [viewController isKindOfClass:[self class]] ){
//        isHidden = YES;
//    }
////    [self.navigationController setNavigationBarHidden:isHidden animated:YES];
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if( self.appDelegate.isUpdateAvatar && ![[self.appDelegate.userInfo objectForKey:@"profileImageUrl"] isEqualToString:@""] ){
        self.headImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.appDelegate.userInfo objectForKey:@"profileImageUrl"]]]];
        self.appDelegate.isUpdateAvatar = false;
    }
    
    self.usernameLabel.text = [[self.appDelegate.userInfo objectForKey:@"user_name"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    if( self.appDelegate.isLogout ){
        self.appDelegate.isLogout = false;
        self.headImage.image = [UIImage imageNamed:@"ic_profile_black"];
        self.usernameLabel.text = NSLocalizedString(@"NotLoggedIn", nil);
        LoginController *loginController = [[LoginController alloc] init];
        [self.navigationController pushViewController:loginController animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if( self.isHideBar ){
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

#pragma mark - Button Action

- (void)showImagePickerVc:(long) count{
    self.imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:count delegate:self];
    self.imagePickerVc.allowPickingVideo = NO;
    self.imagePickerVc.allowPickingOriginalPhoto = NO;
    //    self.imagePickerVc.allowTakePicture = NO;
    [self presentViewController:self.imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    int imageWidth = 0;
    int imageHeight = 0;
    if( photos[0].size.width >= photos[0].size.height ){
        imageWidth = 100;
        imageHeight = 100 / photos[0].size.width * photos[0].size.height;
    }else{
        imageWidth = 100 / photos[0].size.height * photos[0].size.width;
        imageHeight = 100;
    }
    CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
    NSData *file = [self.appDelegate compressQualityWithMaxLength:PHOTO_MAX_SIZE withSourceImage:[self.appDelegate imageByScalingAndCroppingForSize:imageSize withSourceImage:photos[0]]];
    NSString *fileExt = [self.appDelegate typeForImageData:file];
    if( fileExt == nil ){
        fileExt = @"jpeg";
    }
    NSString *fileName = [NSString stringWithFormat:@"AVA_%@.%@", [self.appDelegate.userInfo objectForKey:@"user_id"], fileExt];
    NSString *filePath = [documentPath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
    [file writeToFile:filePath atomically:NO];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{
                               @"user_id":@"111",
                               @"userName":@"miaojuanfeng",
                               @"fileName":[NSString stringWithFormat:@"upload/ava/%@", fileName]
                               };
    
    NSLog(@"测试数据输出，%@", parameters);
    
    HUD_WAITING_SHOW(NSLocalizedString(@"UploadAvaLoading", nil));
    [manager POST:BASE_URL(@"upload/tokenUserImage") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        NSLog(@"results: %@", dic);
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        //HUD_WAITING_HIDE;
        if( status == 200 ){
            NSDictionary *data = [dic objectForKey:@"data"];
            
            [self ossUpload:[data objectForKey:@"upToken"] withFile:filePath withFileName:fileName];
        }else{
            HUD_WAITING_HIDE;
            NSString *eCode = [NSString stringWithFormat:@"e%d", status];
            HUD_TOAST_SHOW(NSLocalizedString(eCode, nil));
        }
        self.isHideBar = true;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败.%@",error);
        NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        
        HUD_WAITING_HIDE;
        HUD_TOAST_SHOW(NSLocalizedString(@"UploadAvaFailure", nil));
        self.isHideBar = true;
    }];

}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    self.isHideBar = true;
}

- (void)ossUpload:(NSString*) upToken withFile:(NSString*) filePath withFileName:(NSString*) fileName{
    
    
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zoneNa0];
    }];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        // percent 为上传进度
        NSLog(@"percent: %@ %f", key, percent);
        dispatch_async(dispatch_get_main_queue(), ^{
            HUD_LOADING_PROGRESS(percent);
        });
    }
    params:@{
        @"x:user_id":[[self.appDelegate.userInfo objectForKey:@"user_id"] stringValue],
        @"x:type":@"userImage"
    }
    checkCrc:NO
    cancellationSignal:^BOOL() {
        return false;
    }];
    
    NSString *ossPath = [NSString stringWithFormat:@"upload/ava/%@", fileName];
    [upManager putFile:filePath key:ossPath token:upToken complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        NSLog(@"oss: %@", info);
        NSLog(@"oss: %@", resp);
        
        NSInteger statusCode = [info statusCode];
        
        //HUD_WAITING_HIDE;
        if( [[resp objectForKey:@"status"] intValue] == 200 ){
            
            [self updateAvatarPath:ossPath];
        }else{
            HUD_TOAST_SHOW(NSLocalizedString(@"UploadAvaFailure", nil));
            HUD_LOADING_HIDE;
            
            HUD_WAITING_HIDE;
        }
        // 删除文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:nil];
    } option:uploadOption];
    
}

-(void)updateAvatarPath:(NSString *)ossPath{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{
                               @"userId":[self.appDelegate.userInfo objectForKey:@"user_id"],
                               @"profileImage":ossPath
                               };
    //加入header参数
    [manager.requestSerializer setValue:[self.appDelegate.userInfo objectForKey:@"user_system_token"] forHTTPHeaderField:@"user_token"];
    [manager POST:BASE_URL(@"user/userModUserImage") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        NSLog(@"results: %@", dic);
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        HUD_WAITING_HIDE;
        if( status == 200 ){
            NSDictionary *data = [dic objectForKey:@"data"];
            
            NSString *profileImageUrl = [data objectForKey:@"profileImageUrl"];
            [self.appDelegate.userInfo setObject:profileImageUrl forKey:@"profileImageUrl"];
            [self.appDelegate saveUserInfo];
            
            self.headImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profileImageUrl]]];
            
            HUD_LOADING_HIDE;
            HUD_TOAST_SHOW(NSLocalizedString(@"UploadAvaSuccess", nil));
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
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败.%@",error);
        NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        
        HUD_WAITING_HIDE;
    }];
    
}

- (void)clickTakePhotoButton {
//    UploadPhotoController *uploadPhotoController = [[UploadPhotoController alloc] init];
//    [self.navigationController pushViewController:uploadPhotoController animated:YES];
//    return;
    
    if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ){
//        [self.activityIndicator startAnimating];
        self.isHideBar = false;
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        //            pickerController.allowsEditing = YES;
        pickerController.delegate = self;
        [self presentViewController:pickerController animated:YES completion:^{
            self.isHideBar = true;
        }];
    }else{
        NSLog(@"不支持相机");
    }
}

- (void)clickPhotoLibButton {
    self.actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"homeAlartPhotoLibTitle", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UploadPhotoController *uploadPhotoController = [[UploadPhotoController alloc] init];
        [self.navigationController pushViewController:uploadPhotoController animated:YES];
    }];
    UIAlertAction *videoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"homeAlartVideoLibTitle", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UploadVideoController *uploadVideoController = [[UploadVideoController alloc] init];
        [self.navigationController pushViewController:uploadVideoController animated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"homeAlartCancelTitle", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [cancelAction setValue:[UIColor redColor] forKey:@"_titleTextColor"];
    [self.actionSheet addAction:photoAction];
    [self.actionSheet addAction:videoAction];
    [self.actionSheet addAction:cancelAction];
    [self presentViewController:self.actionSheet animated:YES completion:^{

    }];
//    UploadPhotoController *uploadPhotoController = [[UploadPhotoController alloc] init];
//    [self.navigationController pushViewController:uploadPhotoController animated:YES];
}

- (void)clickVideoLibButton {
    UploadVideoController *uploadVideoController = [[UploadVideoController alloc] init];
    [self.navigationController pushViewController:uploadVideoController animated:YES];
}

- (void)clickHeadButton {
    self.isHideBar = false;
    [self showImagePickerVc:1];
}

- (void)clickTakeVideoButton{
    if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ){
        self.isHideBar = false;
        //        [self.activityIndicator startAnimating];
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
        pickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
        pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        //            pickerController.allowsEditing = YES;
        pickerController.videoMaximumDuration = 30.0f;
        pickerController.delegate = self;
        [self presentViewController:pickerController animated:YES completion:^{
            self.isHideBar = true;
        }];
    }else{
        NSLog(@"不支持相机");
    }
}

- (void)clickMessageButton {
    MessageController *messageController = [[MessageController alloc] init];
    [self.navigationController pushViewController:messageController animated:YES];
    //LoginController *loginController = [[LoginController alloc] init];
    //[self.navigationController pushViewController:loginController animated:YES];
}

- (void)clickSettingButton {
    SettingController *settingController = [[SettingController alloc] init];
    [self.navigationController pushViewController:settingController animated:YES];
}

- (void)clickDeviceManageButton {
    //DeviceController *deviceController = [[DeviceController alloc] init];
    //[self.navigationController pushViewController:deviceController animated:YES];
    //DetailController *detailController = [[DetailController alloc] init];
    //[self.navigationController pushViewController:detailController animated:YES];
    DevicesController *devicesController = [[DevicesController alloc] init];
    [self.navigationController pushViewController:devicesController animated:YES];
}

//- (void)clickBindDeviceButton {
//    AddDeviceController *addDeviceController = [[AddDeviceController alloc] init];
//    [self.navigationController pushViewController:addDeviceController animated:YES];
//}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    [self.activityIndicator startAnimating];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    NSLog(@"%@", info);
    if ([type isEqualToString:@"public.image"]) {
        
        //        NSURL *videoUrl=(NSURL*) [info objectForKey:UIImagePickerControllerReferenceURL];
        
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval timeStamp = [date timeIntervalSince1970];
        NSString *timeStampString = [NSString stringWithFormat:@"%d", (int)floor(timeStamp)];
        
        NSLog(@"%@", timeStampString);
        
//        //拿到图片
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        image = [self fixOrientation:image];
        [self.appDelegate.photos addObject:image];
//        [self.appDelegate.isTakePhoto addObject:[NSString stringWithFormat:@"%d", true]];
        [self.appDelegate.fileDesc addObject:@""];
        self.appDelegate.focusImageIndex = 0;
        //保存图片到相册
        if (image) {
            [[TZImageManager manager] savePhotoWithImage:image completion:^(NSError *error){
                if (!error) {
                    
                }
            }];
        }
        
        UploadPhotoController *uploadPhotoController = [[UploadPhotoController alloc] init];
        [self.navigationController pushViewController:uploadPhotoController animated:YES];
        
        //process image
        
    }else if([type isEqualToString:@"public.movie"]){
        NSURL *videoURL = [info valueForKey:UIImagePickerControllerMediaURL];
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoURL];
        player.shouldAutoplay = NO;
        UIImage  *thumbnail = [player thumbnailImageAtTime:0.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        player = nil;
//        NSLog(@"Total bytes %ld", [videoData length]);
        
//        self.appDelegate.md5 =  [self.appDelegate fileMD5:UIImagePNGRepresentation(thumbnail)];
//        NSLog(@"视频md5计算完成,md5值为:%@", self.appDelegate.md5);
//
//        if( ![self.appDelegate doDataToBlock:videoData] ){
//            [self.appDelegate clearProperty];
//            HUD_TOAST_SHOW(NSLocalizedString(@"uploadVideoMaxSizeError", nil));
//            return;
//        }
        
        self.appDelegate.videoAsset = nil;
        self.appDelegate.videoData = [NSData dataWithContentsOfURL:videoURL];
        [self.appDelegate.photos addObject:thumbnail];
        [self.appDelegate.fileDesc addObject:@""];
        self.appDelegate.focusImageIndex = 0;
        
        //保存视频到相册
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        [[TZImageManager manager] saveVideoWithUrl:url completion:^(NSError *error){
            if (!error) {
                
            }
        }];
        
        UploadVideoController *uploadVideoController = [[UploadVideoController alloc] init];
        [self.navigationController pushViewController:uploadVideoController animated:YES];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
//    [self.activityIndicator stopAnimating];
    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    [cell.contentView addSubview:self.photoButton];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [self.activityIndicator stopAnimating];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (void)closeAlart {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"networkError", nil) message:NSLocalizedString(@"willCloseApp", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirmOK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self clickQuitButton];
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)clickQuitButton {
//    AppDelegate *app = [UIApplication sharedApplication].delegate;
    UIWindow *window = self.appDelegate.window;
    [UIView animateWithDuration:1.0f animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
    //exit(0);
}

@end
