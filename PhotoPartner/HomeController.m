//
//  ViewController.m
//  PhotoPartner
//
//  Created by USER on 6/3/2018.
//  Copyright © 2018 MJF. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import "MacroDefine.h"
#import "AppDelegate.h"
#import "HomeController.h"
#import "UploadPhotoController.h"
#import "UploadVideoController.h"
#import "DeviceController.h"
#import "AddDeviceController.h"
#import "MessageController.h"
#import "SettingController.h"
//#import <MobileCoreServices/MobileCoreServices.h>
#import "GSKeyChainDataManager.h"
#import <AFNetworking/AFNetworking.h>
#import <TZImageManager.h>
#import <Photos/Photos.h>

@interface HomeController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property UIAlertController *actionSheet;
@property AppDelegate *appDelegate;

@property Boolean isHideBar;
@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
//    self.navigationItem.title = NSLocalizedString(@"homeNavigationItemTitle", nil);
    self.navigationController.delegate = self;
    self.isHideBar = true;
    
    VIEW_WIDTH = VIEW_WIDTH - GAP_WIDTH * 2;
    VIEW_HEIGHT = VIEW_HEIGHT - GAP_HEIGHT * 3 -20;
//    MARGIN_TOP -= GET_LAYOUT_HEIGHT(self.navigationController.navigationBar);
//    VIEW_HEIGHT += GET_LAYOUT_HEIGHT(self.navigationController.navigationBar);
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(self.view), GET_LAYOUT_HEIGHT(self.view)+GAP_HEIGHT*2)];
    bgView.image = [UIImage imageNamed:@"bg_main"];
    [self.view addSubview:bgView];
    
    UIView *topBoxView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH, MARGIN_TOP+20, VIEW_WIDTH, VIEW_HEIGHT/4)];
        UIButton *takePhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(topBoxView), GET_LAYOUT_HEIGHT(topBoxView))];
        [takePhotoButton addTarget:self action:@selector(clickTakePhotoButton) forControlEvents:UIControlEventTouchUpInside];
        [takePhotoButton setImage:[UIImage imageNamed:@"pictures_bg"] forState:UIControlStateNormal];
        takePhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            UIView *takePhotoIcon = [[UIView alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(topBoxView)-80)/2, (GET_LAYOUT_HEIGHT(topBoxView)-80)/2, 80, 80)];
            takePhotoIcon.userInteractionEnabled = NO;
                UIImageView *takePhotoIconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(takePhotoIcon), GET_LAYOUT_HEIGHT(takePhotoIcon))];
                takePhotoIconImage.image = [UIImage imageNamed:@"pictures"];
                [takePhotoIcon addSubview:takePhotoIconImage];
                UILabel *takePhotoIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, GET_LAYOUT_WIDTH(takePhotoIcon), 20)];
                takePhotoIconLabel.textAlignment = NSTextAlignmentCenter;
                takePhotoIconLabel.textColor = [UIColor whiteColor];
                takePhotoIconLabel.text = NSLocalizedString(@"homeTakePhotoTitle", nil);
                [takePhotoIcon addSubview:takePhotoIconLabel];
            [takePhotoButton addSubview:takePhotoIcon];
        [topBoxView addSubview:takePhotoButton];
    [self.view addSubview:topBoxView];
    
    UIView *centerBoxView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH, GET_LAYOUT_OFFSET_Y(topBoxView)+GET_LAYOUT_HEIGHT(topBoxView)+GAP_HEIGHT, VIEW_WIDTH, VIEW_HEIGHT / 8 * 3 )];
        UIView *centerLeftBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (GET_LAYOUT_WIDTH(centerBoxView)-GAP_WIDTH)/2, GET_LAYOUT_HEIGHT(centerBoxView))];
            UIButton *takeVideoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(centerLeftBoxView), GET_LAYOUT_HEIGHT(centerLeftBoxView))];
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
        [centerBoxView addSubview:centerLeftBoxView];
    
        UIView *centerRightBoxView = [[UIView alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(centerLeftBoxView)+GAP_WIDTH, 0, (GET_LAYOUT_WIDTH(centerBoxView)-GAP_WIDTH)/2, centerBoxView.frame.size.height)];
            UIButton *photoLibButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(centerRightBoxView), (GET_LAYOUT_HEIGHT(centerRightBoxView)-GAP_HEIGHT)/2)];
            photoLibButton.backgroundColor = RGBA_COLOR(31, 193, 203, 1);
            photoLibButton.clipsToBounds = YES;
            photoLibButton.layer.cornerRadius = 10;
//            [photoLibButton setTitle:NSLocalizedString(@"homePhotoLibTitle", nil) forState:UIControlStateNormal];
            [photoLibButton addTarget:self action:@selector(clickPhotoLibButton) forControlEvents:UIControlEventTouchUpInside];
    
            UIView *photoLibIcon = [[UIView alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(photoLibButton)-70)/2, (GET_LAYOUT_HEIGHT(photoLibButton)-50)/2-10, 70, 50)];
            photoLibIcon.userInteractionEnabled = NO;
    
                UIImageView *photoLibImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(photoLibIcon), GET_LAYOUT_HEIGHT(photoLibIcon))];
                photoLibImage.image = [UIImage imageNamed:@"photos_videos"];
                [photoLibIcon addSubview:photoLibImage];
    
            [photoLibButton addSubview:photoLibIcon];
    
            UILabel *photoLibLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(photoLibIcon)+GET_LAYOUT_HEIGHT(photoLibIcon)+10, GET_LAYOUT_WIDTH(photoLibButton), 20)];
            photoLibLabel.textAlignment = NSTextAlignmentCenter;
            photoLibLabel.textColor = [UIColor whiteColor];
            photoLibLabel.text = NSLocalizedString(@"homePhotoLibTitle", nil);
            [photoLibButton addSubview:photoLibLabel];
    
            [centerRightBoxView addSubview:photoLibButton];
    
            UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(photoLibButton)+GAP_HEIGHT, GET_LAYOUT_WIDTH(centerRightBoxView), (GET_LAYOUT_HEIGHT(centerRightBoxView)-GAP_HEIGHT)/2)];
            messageButton.backgroundColor = RGBA_COLOR(122, 144, 218, 1);
            messageButton.clipsToBounds = YES;
            messageButton.layer.cornerRadius = 10;
            [messageButton addTarget:self action:@selector(clickMessageButton) forControlEvents:UIControlEventTouchUpInside];

                UIView *messageIcon = [[UIView alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(messageButton)-70)/2, (GET_LAYOUT_HEIGHT(messageButton)-60)/2-10, 70, 60)];
                messageIcon.userInteractionEnabled = NO;

                    UIImageView *messageIconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(messageIcon), GET_LAYOUT_HEIGHT(messageIcon))];
                    messageIconImage.image = [UIImage imageNamed:@"message"];
                    [messageIcon addSubview:messageIconImage];

                [messageButton addSubview:messageIcon];

                UILabel *messageIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(messageIcon)+GET_LAYOUT_HEIGHT(messageIcon)+5, GET_LAYOUT_WIDTH(messageButton), 20)];
                messageIconLabel.textAlignment = NSTextAlignmentCenter;
                messageIconLabel.textColor = [UIColor whiteColor];
                messageIconLabel.text = NSLocalizedString(@"messageNavigationItemTitle", nil);
                [messageButton addSubview:messageIconLabel];

            [centerRightBoxView addSubview:messageButton];
    
        [centerBoxView addSubview:centerRightBoxView];
    
    [self.view addSubview:centerBoxView];
    
    UIView *bottomBoxView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH, GET_LAYOUT_OFFSET_Y(centerBoxView)+GET_LAYOUT_HEIGHT(centerBoxView)+GAP_HEIGHT, VIEW_WIDTH, VIEW_HEIGHT / 8 * 3 )];
        UIButton *bindDeviceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(bottomBoxView), (GET_LAYOUT_HEIGHT(bottomBoxView)-GAP_HEIGHT)/2)];
        bindDeviceButton.backgroundColor = RGBA_COLOR(36, 218, 170, 1);
        bindDeviceButton.clipsToBounds = YES;
        bindDeviceButton.layer.cornerRadius = 10;
//        [bindDeviceButton setTitle:NSLocalizedString(@"deviceListNavigationItemTitle", nil) forState:UIControlStateNormal];
        [bindDeviceButton addTarget:self action:@selector(clickDeviceManageButton) forControlEvents:UIControlEventTouchUpInside];
        [bottomBoxView addSubview:bindDeviceButton];
    
        UIView *bindDevicIcon = [[UIView alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(bindDeviceButton)-90)/2, (GET_LAYOUT_HEIGHT(bindDeviceButton)-60)/2-10, 90, 60)];
        bindDevicIcon.userInteractionEnabled = NO;
    
        UIImageView *bindDevicIconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(bindDevicIcon), GET_LAYOUT_HEIGHT(bindDevicIcon))];
        bindDevicIconImage.image = [UIImage imageNamed:@"connecting_devices"];
        [bindDevicIcon addSubview:bindDevicIconImage];
    
        [bindDeviceButton addSubview:bindDevicIcon];
    
        UILabel *bindDeviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(bindDevicIcon)+GET_LAYOUT_HEIGHT(bindDevicIcon)+5, GET_LAYOUT_WIDTH(bindDeviceButton), 20)];
        bindDeviceLabel.textAlignment = NSTextAlignmentCenter;
        bindDeviceLabel.textColor = [UIColor whiteColor];
        bindDeviceLabel.text = NSLocalizedString(@"deviceListNavigationItemTitle", nil);
        [bindDeviceButton addSubview:bindDeviceLabel];

    
    UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(bindDeviceButton)+GAP_HEIGHT, GET_LAYOUT_WIDTH(bottomBoxView), (GET_LAYOUT_HEIGHT(bottomBoxView)-GAP_HEIGHT)/2)];
    settingButton.backgroundColor = RGBA_COLOR(235, 182, 67, 1);
        settingButton.clipsToBounds = YES;
        settingButton.layer.cornerRadius = 10;
//        [settingButton setTitle:NSLocalizedString(@"settingNavigationItemTitle", nil) forState:UIControlStateNormal];
        [settingButton addTarget:self action:@selector(clickSettingButton) forControlEvents:UIControlEventTouchUpInside];
        [bottomBoxView addSubview:settingButton];
        [self.view addSubview:bottomBoxView];
    
    
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
        [settingButton addSubview:settingLabel];
    
    
    
    
    
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
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
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
                                [self.navigationController pushViewController:addDeviceController animated:YES];
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
        }];
    }else if( self.appDelegate.deviceList.count == 0 && [self.appDelegate isNilDeviceList] ){
        AddDeviceController *addDeviceController = [[AddDeviceController alloc] init];
        [self.navigationController pushViewController:addDeviceController animated:YES];
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
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if( self.isHideBar ){
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

#pragma mark - Button Action

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
        pickerController.videoMaximumDuration = 300.0f;
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
}

- (void)clickSettingButton {
    SettingController *settingController = [[SettingController alloc] init];
    [self.navigationController pushViewController:settingController animated:YES];
}

- (void)clickDeviceManageButton {
    DeviceController *deviceController = [[DeviceController alloc] init];
    [self.navigationController pushViewController:deviceController animated:YES];
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
