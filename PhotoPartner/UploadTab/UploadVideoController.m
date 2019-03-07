//
//  UploadPhotoController.m
//  PhotoPartner
//
//  Created by USER on 8/3/2018.
//  Copyright © 2018 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "UploadVideoController.h"
#import <AFNetworking/AFNetworking.h>
#import <TZImagePickerController.h>
#import <TZImageManager.h>
#import "UITextView+ZWPlaceHolder.h"
#import <QiniuSDK.h>
#import <ZipArchive.h>
#import "AddDeviceController.h"
#import "LoginController.h"

//#define FileHashDefaultChunkSizeForReadingData 1024*8
#include <CommonCrypto/CommonDigest.h>

@interface UploadVideoController () <UITableViewDataSource, UITableViewDelegate, TZImagePickerControllerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate>
@property UITableView *tableView;
@property TZImagePickerController *imagePickerVc;

@property UITextView *textView;
@property UILabel *textCountLabel;
@property UIView *mediaView;
@property UIButton *addImageButton;

@property AppDelegate *appDelegate;

@property UILabel *tLabel;
@property Boolean isDeleteSignals;

@property AFHTTPSessionManager *manager;

@property NSMutableArray *successBlock;
@property NSMutableArray *failedBlock;

@property Boolean isCancelSignals;

@end

@implementation UploadVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    
    self.navigationItem.title = NSLocalizedString(@"uploadVideoNavigationItemTitle", nil);
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    INIT_RightBarButtonItem(ICON_FORWARD, clickSubmitButton);
    INIT_RightBarButtonItem(ICON_FORWARD, test);
    
    self.mediaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(self.view), IMAGE_VIEW_SIZE+PHOTO_NUM_HEIGHT+GAP_HEIGHT+2*GAP_HEIGHT)];
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(self.view), 100)];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, MARGIN_TOP, VIEW_WIDTH, VIEW_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
//    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
//    }
    [self.view addSubview:self.tableView];
    
    
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    
    //监听当键将要退出时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.textCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(GAP_WIDTH, 0, GET_LAYOUT_WIDTH(self.view)-2*GAP_WIDTH, PHOTO_NUM_HEIGHT)];
    self.textCountLabel.textColor = [UIColor lightGrayColor];
    self.textCountLabel.font = [UIFont systemFontOfSize:14.0f];
    self.textCountLabel.textAlignment = NSTextAlignmentRight;
    self.textCountLabel.text = [NSString stringWithFormat:@"%d", MAX_LIMIT_NUMS];
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(GAP_WIDTH, GET_LAYOUT_OFFSET_Y(self.textCountLabel)+GET_LAYOUT_HEIGHT(self.textCountLabel), GET_LAYOUT_WIDTH(self.view)-2*GAP_WIDTH, 100)];
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.font = [UIFont systemFontOfSize:16.0f];
    self.textView.placeholder = NSLocalizedString(@"uploadTextViewVideoPlaceHolderText", nil);
    self.textView.delegate = self;
    
    [self updateDeviceList];
    
    if( self.appDelegate.photos.count == 0 ){
        [self showImagePickerVc:MAX_VIDEO_COUNT];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if( section == 0 ){
        return @" ";
    }else{
        return NSLocalizedString(@"uploadPushDeviceTitle", nil);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( section == 0 ){
        return 2;
    }else{
        return self.appDelegate.deviceList.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0){
        return CGFLOAT_MIN;
    }else{
        return 12;
    }
}

-(void)updateDeviceList{
    //HUD_WAITING_SHOW(NSLocalizedString(@"Loading", nil));
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    NSDictionary *parameters=@{
                               @"user_id":[self.appDelegate.userInfo objectForKey:@"user_id"]
                               };
    //加入header参数
    [manager.requestSerializer setValue:[self.appDelegate.userInfo objectForKey:@"user_system_token"] forHTTPHeaderField:@"user_token"];
    [manager POST:BASE_URL(@"user/user_device") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功.%@",responseObject);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        
        int status = [[dic objectForKey:@"status"] intValue];
        
        //HUD_WAITING_HIDE;
        if( status == 200 ){
            self.appDelegate.deviceList = [[dic objectForKey:@"data"] mutableCopy];
            [self.appDelegate saveDeviceList];
            
            [self.tableView reloadData];
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
        
        //HUD_WAITING_HIDE;
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UploadMediaCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.frame = CGRectMake(0, 0, GET_LAYOUT_WIDTH(self.tableView), tableView.rowHeight);
    if( indexPath.section == 0 ){
        if( indexPath.row == 0 ){
            self.tableView.rowHeight = GET_LAYOUT_HEIGHT(self.textView)+GET_LAYOUT_HEIGHT(self.textCountLabel);
            
            [cell.contentView addSubview:self.textCountLabel];
            
            self.textView.font = [UIFont systemFontOfSize:16.0f];
            [cell.contentView addSubview:self.textView];
            
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, GET_BOUNDS_WIDTH(cell));
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else if( indexPath.row == 1 ){
            self.tableView.rowHeight = GET_LAYOUT_HEIGHT(self.mediaView);
            [self getMediaView:cell];
        }
    }else{
        self.tableView.rowHeight = 44;
        
        NSMutableDictionary *deviceItem = [self.appDelegate.deviceList[indexPath.row] mutableCopy];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [[deviceItem objectForKey:@"device_name"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *deviceId = [deviceItem objectForKey:@"device_id"];
        if( ![self.appDelegate.deviceSent containsObject:deviceId] ){
            cell.accessoryType = UITableViewCellAccessoryNone;
            [deviceItem setObject:@0 forKey:@"isSelected"];
        }else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [deviceItem setObject:@1 forKey:@"isSelected"];
        }
        [self.appDelegate.deviceList replaceObjectAtIndex:indexPath.row withObject:deviceItem];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        if( ![[deviceItem objectForKey:@"isAccepted"] isEqualToString:@"1"] ){
            cell.hidden = YES;
        }
    }
    return cell;
}

- (void)getMediaView:(UITableViewCell *)cell {

    DO_CLEAR_MEDIA_VIEW;
    
    long imageTotal = self.appDelegate.photos.count;
    float imageViewSize = IMAGE_VIEW_SIZE;
    float x = GAP_WIDTH;
    float y = GAP_HEIGHT;
    for(int i=0;i<imageTotal;i++){
        if( i%IMAGE_PER_ROW == 0 ){
            x = GAP_WIDTH;
        }else{
            x += imageViewSize + GAP_HEIGHT;
        }
        if( i > 0 && i%IMAGE_PER_ROW == 0 ){
            y += imageViewSize + GAP_HEIGHT;
            self.mediaView.frame = CGRectMake(GET_LAYOUT_OFFSET_X(self.mediaView), 0, GET_LAYOUT_WIDTH(self.mediaView), y+imageViewSize+GAP_HEIGHT);
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, imageViewSize, imageViewSize)];
        //        imageView.backgroundColor = [UIColor orangeColor];
        imageView.image = self.appDelegate.photos[i];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)];
        singleTap.delegate = self;
        [imageView setTag:i];
        [imageView addGestureRecognizer:singleTap];
        [self.mediaView addSubview:imageView];
        
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(imageView)-20, GET_LAYOUT_WIDTH(imageView), 20)];
        descLabel.backgroundColor = RGBA_COLOR(0, 0, 0, 0.8);
        descLabel.textColor = [UIColor whiteColor];
        if( [self.appDelegate.fileDesc[i] isEqualToString:@""] ){
            descLabel.text = NSLocalizedString(@"uploadDescLabelPlaceHolderText", nil);
        }else{
            descLabel.text = self.appDelegate.fileDesc[i];
        }
        descLabel.font = [UIFont systemFontOfSize:12.0f];
        [imageView addSubview:descLabel];
        
        UIButton *rmButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(imageView)-26, 0, 26, 26)];
        [rmButton setImage:[UIImage imageNamed:@"cancel_button"] forState:UIControlStateNormal];
        rmButton.tag = i;
        [rmButton addTarget:self action:@selector(clickRmButton:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:rmButton];
    }
    
    if( imageTotal%IMAGE_PER_ROW == 0 ){
        x = GAP_WIDTH;
    }else{
        x += imageViewSize + GAP_HEIGHT;
    }
    if( imageTotal > 0 && imageTotal%IMAGE_PER_ROW == 0 && self.appDelegate.photos.count < MAX_VIDEO_COUNT ){
        y += imageViewSize + GAP_HEIGHT;
        self.mediaView.frame = CGRectMake(GET_LAYOUT_OFFSET_X(self.mediaView), 0, GET_LAYOUT_WIDTH(self.mediaView), y+imageViewSize+GAP_HEIGHT);
    }
    /*
     *  移除旧的CGRect可点击区域
     */
    [self.addImageButton removeFromSuperview];
    if( self.appDelegate.photos.count < MAX_VIDEO_COUNT ){
        self.addImageButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, imageViewSize, imageViewSize)];
        [self.addImageButton setImage:[UIImage imageNamed:@"iv_upload"] forState:UIControlStateNormal];
        [self.addImageButton addTarget:self action:@selector(clickAddMediaButton) forControlEvents:UIControlEventTouchUpInside];
        self.addImageButton.layer.borderColor = BORDER_COLOR;
        self.addImageButton.layer.borderWidth = BORDER_WIDTH;
        [self.mediaView addSubview:self.addImageButton];
    }
    
    UILabel *photoNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(self.mediaView), GET_LAYOUT_OFFSET_Y(self.mediaView)+GET_LAYOUT_HEIGHT(self.mediaView), GET_LAYOUT_WIDTH(self.mediaView), PHOTO_NUM_HEIGHT)];
    photoNumLabel.text = [NSString stringWithFormat:@"%ld/%d", self.appDelegate.photos.count, MAX_VIDEO_COUNT];
    photoNumLabel.textColor = [UIColor lightGrayColor];
    photoNumLabel.font = [UIFont systemFontOfSize:14.0f];
    photoNumLabel.textAlignment = NSTextAlignmentCenter;
    [self.mediaView addSubview:photoNumLabel];
    //    photoNumLabel.backgroundColor = [UIColor blueColor];
    self.mediaView.frame = CGRectMake(GET_LAYOUT_OFFSET_X(self.mediaView), 0, GET_LAYOUT_WIDTH(self.mediaView), GET_LAYOUT_HEIGHT(self.mediaView)+PHOTO_NUM_HEIGHT+GAP_HEIGHT);
    
    [cell.contentView addSubview:self.mediaView];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, GET_BOUNDS_WIDTH(cell));
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.section > 0 ){
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    if( indexPath.section == 1 ){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSMutableDictionary *device = [[self.appDelegate.deviceList objectAtIndex:indexPath.row] mutableCopy];
        NSString *deviceId = [device objectForKey:@"device_id"];
        if( [self.appDelegate.deviceSent containsObject:deviceId] ){
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.appDelegate.deviceSent removeObject:deviceId];
            [device setObject:@0 forKey:@"isSelected"];
        }else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.appDelegate.deviceSent addObject:deviceId];
            [device setObject:@1 forKey:@"isSelected"];
        }
        [self.appDelegate.deviceList replaceObjectAtIndex:indexPath.row withObject:device];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
//    self.focusImageIndex = self.fileDesc.count;
//    for (int i=0; i<photos.count; i++) {
//        [self.photos addObject:photos[i]];
//        [self.fileDesc addObject:@""];
//    }
//    NSLog(@"self.photos: %@", self.photos);
//    self.textView.text = [self.fileDesc objectAtIndex:self.focusImageIndex];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    [self getMediaView:cell];
//    [self.tableView reloadData];
//}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    NSLog(@"%@", coverImage);
    self.appDelegate.focusImageIndex = self.appDelegate.fileDesc.count;
    [self.appDelegate.photos addObject:coverImage];
    [self.appDelegate.fileDesc addObject:@""];
    self.appDelegate.videoAsset = asset;
    NSLog(@"self.photos: %@", self.appDelegate.photos);
    self.textView.text = [self.appDelegate.fileDesc objectAtIndex:self.appDelegate.focusImageIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self getMediaView:cell];
    [self.tableView reloadData];
}

- (CGFloat) getFileSize:(NSString *)path
{
    NSLog(@"%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;
    }else{
        NSLog(@"找不到文件");
    }
    return filesize;
}//此方法可以获取文件的大小，返回的是单位是KB。
- (CGFloat) getVideoLength:(NSURL *)URL
{
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}//此方法可以获取视频文件的时长。
- (void) convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                               outputURL:(NSURL*)outputURL
                         completeHandler:(void (^)(AVAssetExportSession*))handler
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    //  NSLog(resultPath);
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:
                 NSLog(@"AVAssetExportSessionStatusCompleted");
                 NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:outputURL]]);
                 NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[outputURL path]]]);
                 
                 //UISaveVideoAtPathToSavedPhotosAlbum([outputURL path], self, nil, NULL);//这个是保存到手机相册
                 
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 break;
         }
         
     }];
    
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    NSLog(@"Cancel");
}


/*
 *  要让AFHTTPSessionManager支持上传表单数组，需要修改AFNetworking/Serialization/AFURLRequestSerialization.m
 *  将
 *  [mutableQueryStringComponents addObjectsFromArray:AFQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
 *  修改为
 *  [mutableQueryStringComponents addObjectsFromArray:AFQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@", key], nestedValue)];
 */

- (void)clickSubmitButton {
    if( !self.appDelegate.isSending ){
        [self.view endEditing:YES];
        
        [self.appDelegate.deviceId removeAllObjects];
        for (NSMutableDictionary *device in self.appDelegate.deviceList) {
            if( [[device objectForKey:@"isSelected"] boolValue] ){
                [self.appDelegate.deviceId addObject:[device objectForKey:@"device_id"]];
            }
        }
        
        if( self.appDelegate.photos.count == 0 ){
            HUD_TOAST_SHOW(NSLocalizedString(@"uploadVideoEmptyError", nil));
            return;
        }
        if( self.appDelegate.deviceId.count == 0 ){
            HUD_TOAST_SHOW(NSLocalizedString(@"uploadDeviceEmptyError", nil));
            return;
        }
        
        DISABLE_RightBarButtonItem;
        NAV_UPLOAD_START;
        HUD_WAITING_SHOW(NSLocalizedString(@"loadingProcessing", nil));
        //    HUD_TOAST_SHOW(NSLocalizedString(@"uploadProcessingRightBarButtonItemTitle", nil));
        
        //    NSLog(@"视频fileMD5计算完成,md5值为:%@", [self.appDelegate fileMD5:UIImagePNGRepresentation(coverImage)]);
        self.appDelegate.md5 = [self.appDelegate fileMD5:UIImagePNGRepresentation([self.appDelegate.photos objectAtIndex:0])];
        NSLog(@"视频md5计算完成,md5值为:%@", self.appDelegate.md5);
        
        //    [[TZImageManager manager] getVideoWithAsset:asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        //        NSString *PHImageFileSandboxExtensionTokenKey = [info objectForKey:@"PHImageFileSandboxExtensionTokenKey"];
        //        self.appDelegate.md5 =  [self.appDelegate md5:PHImageFileSandboxExtensionTokenKey];
        
        //        self.appDelegate.md5 = [self.appDelegate md5:@"s" ];
        //        NSLog(@"视频md5计算完成,md5值为:%@", self.appDelegate.md5);
        if( self.appDelegate.videoAsset != nil && self.appDelegate.videoData == nil ){
            [[TZImageManager manager] getVideoOutputPathWithAsset:self.appDelegate.videoAsset success:^(NSString *outputPath){
                //            NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
                NSURL *videoUrl = [NSURL fileURLWithPath:outputPath];
                //            NSLog(@"videoUrl: %@", videoUrl);
                NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
                //            NSLog(@"***%@",videoData);
                //            NSLog(@"***%ld",videoData.length);
                
                DO_DATA_TO_BLOCK_IF_FAILED(videoData);
            
                if( self.appDelegate.isSending ){
                    [self doUploadVideo];
                }
                
                ENABLE_RightBarButtonItem;
                //            UPDATE_RightBarButtonItem(ICON_FORWARD);
                
                //        NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:videoUrl]]);
                //        NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[videoUrl path]]]);
                //
                //        NSURL *newVideoUrl ; //一般.mp4
                //        NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
                //        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
                //        //    这个是保存在app自己的沙盒路径里，后面可以选择是否在上传后删除掉。我建议删除掉，免得占空间。
                //        newVideoUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]]];
                //        [self convertVideoQuailtyWithInputURL:videoUrl outputURL:newVideoUrl completeHandler:nil];
            } failure:^(NSString *errorMessage, NSError *error) {
                
            }];
        }else{
            DO_DATA_TO_BLOCK_IF_FAILED(self.appDelegate.videoData);
            
            if( self.appDelegate.isSending ){
                [self doUploadVideo];
            }
            
            ENABLE_RightBarButtonItem;
        }
        //    }];
    }else{
        NSLog(@"Cancel sending");
        [self.manager.session invalidateAndCancel];
        NAV_UPLOAD_END;
        HUD_LOADING_HIDE;
    }
}

- (void)doUploadVideo {
    //创建会话管理者
    self.manager = [AFHTTPSessionManager manager];
    /*
     *  返回json格式数据时，如果没有下面代码，会提示上传失败，实际上已经成功。
     *  加上下面这句才会提示成功
     */
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //    manager.requestSerializer.timeoutInterval = 30.0f;
    //发送post请求上传路径
    /*
     第一个参数:请求路径
     第二个参数:字典(非文件参数)
     第三个参数:constructingBodyWithBlock 处理要上传的文件数据
     第四个参数:进度回调
     第五个参数:成功回调 responseObject响应体信息
     第六个参数:失败回调
     */
    NSLog(@"videos.count: %ld", self.appDelegate.videos.count);
    HUD_WAITING_HIDE;
    HUD_LOADING_SHOW(NSLocalizedString(@"uploadSendingRightBarButtonItemTitle", nil));
    NSString *totalBlock = [NSString stringWithFormat:@"%ld", self.appDelegate.videos.count];
    //        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    //        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //        [dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
    //        NSString *fileName = [NSString stringWithFormat:@"VID_%@_%d.mp4", [dateFormatter stringFromDate:date], arc4random() % 50001 + 100000];
    NSString *fileName = [NSString stringWithFormat:@"VID_%@_%@.mp4", [self.appDelegate.userInfo objectForKey:@"user_id"], [self.appDelegate.md5 uppercaseString]];
    self.successBlock = [[NSMutableArray alloc] init];
    self.failedBlock = [[NSMutableArray alloc] init];
    if( self.appDelegate.fileDesc.count == 1 && [[self.appDelegate.fileDesc objectAtIndex:0] isEqualToString:@""] ){
        [self.appDelegate.fileDesc replaceObjectAtIndex:0 withObject:@" "];
    }
    // 查找是否存在上次上次失败的块
    NSMutableArray *failedVideoList = [self.appDelegate.failedBlock objectForKey:self.appDelegate.md5];
    for (int i=0; i< self.appDelegate.videos.count; i++) {
        NSString *fileBlock = [NSString stringWithFormat:@"%d", i+1];
        
        // 如果存在失败的块
        if( failedVideoList != nil && ![failedVideoList containsObject:fileBlock] ){
            [self.successBlock addObject:fileBlock];
            [self.appDelegate.completedUnitPercent replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:1.0f/self.appDelegate.videos.count]];
            continue;
        }
        
        NSDictionary *parameters=@{
                                   @"user_id"       :   [self.appDelegate.userInfo objectForKey:@"user_id"],
                                   @"file_block"    :   fileBlock,
                                   @"total_block"   :   totalBlock,
                                   @"device_id"     :   [self.appDelegate.deviceId copy],
                                   @"file_MD5"      :   self.appDelegate.md5,
                                   @"file_desc"     :   [self.appDelegate.fileDesc copy]
                                   };
        [self.manager POST:BASE_URL(@"upload/video") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
            /*
             *   使用formData拼接数据
             *   方法一:
             *   第一个参数:二进制数据 要上传的文件参数
             *   第二个参数:服务器规定的
             *   第三个参数:文件上传到服务器以什么名称保存
             */
            [formData appendPartWithFileData:self.appDelegate.videos[i] name:@"file" fileName:fileName mimeType:@"video/mp4"];
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float progress = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount / self.appDelegate.videos.count;
                NSNumber *number = [NSNumber numberWithFloat:progress];
                float total = 0.0f;
                if( self.appDelegate.completedUnitPercent.count > 0 ){
                    [self.appDelegate.completedUnitPercent replaceObjectAtIndex:i withObject:number];
                    for (NSNumber *num in self.appDelegate.completedUnitPercent) {
                        total += [num floatValue];
                    }
                    NSLog(@"self.completedUnitPercent: %f", total);
                }
                HUD_LOADING_PROGRESS(total);
            });
            NSLog(@"%f",1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"上传成功.%@",responseObject);
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
            NSLog(@"results: %@", dic);
            
            NSDictionary *data = [dic objectForKey:@"data"];
            if( [[data objectForKey:@"complete"] intValue] ){
                
                [self.manager.session invalidateAndCancel];
                
                [self.appDelegate.failedBlock removeObjectForKey:self.appDelegate.md5];
                [self.appDelegate saveFailedBlock];
                
                NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *time = [dateFormatter stringFromDate:date];
                for(int i=0;i<self.appDelegate.photos.count;i++){
                    NSString *deviceName = @"";
                    for(int j=0;j<self.appDelegate.deviceId.count;j++){
                        NSString  *device_id = [self.appDelegate.deviceId objectAtIndex:j];
                        for(int k=0;k<self.appDelegate.deviceList.count;k++){
                            //                    NSLog(@"%@", [[self.appDelegate.deviceList objectAtIndex:k] objectForKey:@"device_id"] );
                            //                    NSLog(@"%@", device_id);
                            if( [[self.appDelegate.deviceList objectAtIndex:k] objectForKey:@"device_id"] == device_id ){
                                NSString *device_name = [[self.appDelegate.deviceList objectAtIndex:k] objectForKey:@"device_name"];
                                if( [deviceName isEqualToString:@""] ){
                                    deviceName = device_name;
                                }else{
                                    deviceName = [NSString stringWithFormat:@"%@, %@", deviceName, device_name];
                                }
                                break;
                            }
                        }
                    }
                    NSString *desc = [self.appDelegate.fileDesc objectAtIndex:i];
                    int imageWidth = 0;
                    int imageHeight = 0;
                    if( self.appDelegate.photos[i].size.width >= self.appDelegate.photos[i].size.height ){
                        imageWidth = 150;
                        imageHeight = 150 / self.appDelegate.photos[i].size.width * self.appDelegate.photos[i].size.height;
                    }else{
                        imageWidth = 150 / self.appDelegate.photos[i].size.height * self.appDelegate.photos[i].size.width;
                        imageHeight = 150;
                    }
                    CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
                    NSData *data = [self.appDelegate compressQualityWithMaxLength:PHOTO_MAX_SIZE withSourceImage:[self.appDelegate imageByScalingAndCroppingForSize:imageSize withSourceImage:self.appDelegate.photos[i]]];
                    [self.appDelegate addMessageList:@"video" withTime:time withTitle:deviceName withDesc:desc withData:data];
                }
                
                DO_FINISH_UPLOAD;
                NAV_UPLOAD_END;
                HUD_LOADING_HIDE;
                HUD_TOAST_SHOW(NSLocalizedString(@"uploadSendSuccess", nil));
            }else{
                [self.successBlock addObject:fileBlock];
                if( (self.successBlock.count + self.failedBlock.count) == self.appDelegate.videos.count ){
                    [self.appDelegate addFailedBlock:self.failedBlock withMD5:self.appDelegate.md5];
                    [self.appDelegate loadFailedBlock];
                    NSLog(@"self.appDelegate.failedBlock: %@", self.appDelegate.failedBlock);
                    NAV_UPLOAD_END;
                    HUD_LOADING_HIDE;
                    HUD_TOAST_SHOW(NSLocalizedString(@"uploadSendFailed", nil));
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"上传失败.%@",error);
            NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
            // 这里要记录下没有上传成功的块
            [self.failedBlock addObject:fileBlock];
            if( (self.successBlock.count + self.failedBlock.count) == self.appDelegate.videos.count ){
                [self.appDelegate addFailedBlock:self.failedBlock withMD5:self.appDelegate.md5];
                [self.appDelegate loadFailedBlock];
                NSLog(@"self.appDelegate.failedBlock: %@", self.appDelegate.failedBlock);
                if( self.appDelegate.isSending ){
                    HUD_TOAST_SHOW(NSLocalizedString(@"uploadSendFailed", nil));
                }else{
                    HUD_TOAST_SHOW(NSLocalizedString(@"uploadSendCanceled", nil));
                }
                NAV_UPLOAD_END;
                HUD_LOADING_HIDE;
            }
        }];
    }
}

//- (AFHTTPSessionManager *)sharedManager {
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    //最大请求并发任务数
//    manager.operationQueue.maxConcurrentOperationCount = 5;
//
//    // 请求格式
//    // AFHTTPRequestSerializer            二进制格式
//    // AFJSONRequestSerializer            JSON
//    // AFPropertyListRequestSerializer    PList(是一种特殊的XML,解析起来相对容易)
//
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 上传普通格式
//
//    // 超时时间
//    manager.requestSerializer.timeoutInterval = 30.0f;
//    // 设置请求头
//    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
//    // 设置接收的Content-Type
//    manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
//
//    // 返回格式
//    // AFHTTPResponseSerializer           二进制格式
//    // AFJSONResponseSerializer           JSON
//    // AFXMLParserResponseSerializer      XML,只能返回XMLParser,还需要自己通过代理方法解析
//    // AFXMLDocumentResponseSerializer (Mac OS X)
//    // AFPropertyListResponseSerializer   PList
//    // AFImageResponseSerializer          Image
//    // AFCompoundResponseSerializer       组合
//
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];//返回格式 JSON
////    //设置返回C的ontent-type
////    manager.responseSerializer.acceptableContentTypes=[[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
//
//    return manager;
//}

//CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,
//                                      size_t chunkSizeForReadingData) {
//
//    // Declare needed variables
//    CFStringRef result = NULL;
//    CFReadStreamRef readStream = NULL;
//
//    // Get the file URL
//    CFURLRef fileURL =
//    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
//                                  (CFStringRef)filePath,
//                                  kCFURLPOSIXPathStyle,
//                                  (Boolean)false);
//    if (!fileURL) goto done;
//
//    // Create and open the read stream
//    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
//                                            (CFURLRef)fileURL);
//    if (!readStream) goto done;
//    bool didSucceed = (bool)CFReadStreamOpen(readStream);
//    if (!didSucceed) goto done;
//
//    // Initialize the hash object
//    CC_MD5_CTX hashObject;
//    CC_MD5_Init(&hashObject);
//
//    // Make sure chunkSizeForReadingData is valid
//    if (!chunkSizeForReadingData) {
//        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
//    }
//
//    // Feed the data to the hash object
//    bool hasMoreData = true;
//    while (hasMoreData) {
//        uint8_t buffer[chunkSizeForReadingData];
//        CFIndex readBytesCount = CFReadStreamRead(readStream,
//                                                  (UInt8 *)buffer,
//                                                  (CFIndex)sizeof(buffer));
//        if (readBytesCount == -1) break;
//        if (readBytesCount == 0) {
//            hasMoreData = false;
//            continue;
//        }
//        CC_MD5_Update(&hashObject,
//                      (const void *)buffer,
//                      (CC_LONG)readBytesCount);
//    }
//
//    // Check if the read operation succeeded
//    didSucceed = !hasMoreData;
//
//    // Compute the hash digest
//    unsigned char digest[CC_MD5_DIGEST_LENGTH];
//    CC_MD5_Final(digest, &hashObject);
//
//    // Abort if the read operation failed
//    if (!didSucceed) goto done;
//
//    // Compute the string result
//    char hash[2 * sizeof(digest) + 1];
//    for (size_t i = 0; i < sizeof(digest); ++i) {
//        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
//    }
//    result = CFStringCreateWithCString(kCFAllocatorDefault,
//                                       (const char *)hash,
//                                       kCFStringEncodingUTF8);
//
//done:
//
//    if (readStream) {
//        CFReadStreamClose(readStream);
//        CFRelease(readStream);
//    }
//    if (fileURL) {
//        CFRelease(fileURL);
//    }
//    return result;
//}

//- (NSString*)getFileMD5WithPath:(NSString*)path {
//    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
//}
//
//CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
//    // Declare needed variables
//    CFStringRef result = NULL;
//    CFReadStreamRef readStream = NULL;
//    // Get the file URL
//    CFURLRef fileURL =
//    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
//                                  (CFStringRef)filePath,
//                                  kCFURLPOSIXPathStyle,
//                                  (Boolean)false);
//    if (!fileURL) goto done;
//    // Create and open the read stream
//    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
//                                            (CFURLRef)fileURL);
//    if (!readStream) goto done;
//    bool didSucceed = (bool)CFReadStreamOpen(readStream);
//    if (!didSucceed) goto done;
//    // Initialize the hash object
//    CC_MD5_CTX hashObject;
//    CC_MD5_Init(&hashObject);
//    // Make sure chunkSizeForReadingData is valid
//    if (!chunkSizeForReadingData) {
//        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
//    }
//    // Feed the data to the hash object
//    bool hasMoreData = true;
//    while (hasMoreData) {
//        uint8_t buffer[chunkSizeForReadingData];
//        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
//        if (readBytesCount == -1) break;
//        if (readBytesCount == 0) {
//            hasMoreData = false;
//            continue;
//        }
//        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
//    }
//    // Check if the read operation succeeded
//    didSucceed = !hasMoreData;
//    // Compute the hash digest
//    unsigned char digest[CC_MD5_DIGEST_LENGTH];
//    CC_MD5_Final(digest, &hashObject);
//    // Abort if the read operation failed
//    if (!didSucceed) goto done;
//    // Compute the string result
//    char hash[2 * sizeof(digest) + 1];
//    for (size_t i = 0; i < sizeof(digest); ++i) {
//        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
//    }
//    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
//
//done:
//    if (readStream) {
//        CFReadStreamClose(readStream);
//        CFRelease(readStream);
//    }
//    if (fileURL) {
//        CFRelease(fileURL);
//    }
//    return result;
//}

- (void)clickAddMediaButton {
     [self showImagePickerVc:(MAX_VIDEO_COUNT-self.appDelegate.photos.count)];
}

- (void)showImagePickerVc:(long) count{
    self.imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:count delegate:self];
    self.imagePickerVc.allowPickingImage = NO;
    self.imagePickerVc.allowPickingOriginalPhoto = NO;
    [self presentViewController:self.imagePickerVc animated:YES completion:nil];
}

- (void)clickImageView:(UIGestureRecognizer *) sender{
    self.isDeleteSignals = false;
    [self setTextViewToFileDesc];
    self.appDelegate.focusImageIndex = sender.view.tag;
    self.textView.text = [self.appDelegate.fileDesc objectAtIndex:sender.view.tag];
    //
    [self addTLabel];
    //
    [self.textView becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UITextViewTextDidChangeNotification" object:nil];
    self.textCountLabel.text = [NSString stringWithFormat:@"%ld", MAX(0, MAX_LIMIT_NUMS - self.textView.text.length)];
}

-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self setTextViewToFileDesc];
    NSLog(@"%@", self.appDelegate.fileDesc);
}

- (void)setTextViewToFileDesc {
    if( self.appDelegate.focusImageIndex > -1 ){
        NSLog(@"sds");
        [self.appDelegate.fileDesc replaceObjectAtIndex:self.appDelegate.focusImageIndex withObject:self.textView.text];
    }
}

- (void)didMoveToParentViewController:(UIViewController*)parent {
    if( !parent ){
        if( self.appDelegate.isSending ){
            NSLog(@"Cancel sending");
//            [self.manager.session invalidateAndCancel];
            self.isCancelSignals = true;
            //
            for (int i=0; i<self.appDelegate.videos.count; i++) {
                NSString *fileBlock = [NSString stringWithFormat:@"%d", i+1];
                if( ![self.successBlock containsObject:fileBlock] && ![self.failedBlock containsObject:fileBlock] ){
                    [self.failedBlock addObject:fileBlock];
                }
            }
            if( (self.successBlock.count + self.failedBlock.count) == self.appDelegate.videos.count ){
                [self.appDelegate addFailedBlock:self.failedBlock withMD5:self.appDelegate.md5];
                [self.appDelegate loadFailedBlock];
                NSLog(@"self.appDelegate.failedBlock: %@", self.appDelegate.failedBlock);
            }
            //
            NAV_UPLOAD_END;
            HUD_LOADING_HIDE;
            HUD_WAITING_HIDE;
        }
        [self.appDelegate clearProperty];
    }
}

// 因为我在scrollView加了手势 点击tableView didSelectRowAtIndexPath不执行 导致手势冲突 可以用此方法解决
#pragma mark 解决手势冲突

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    } else {
        return YES;
    }
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
//    NSInteger caninputlen = MAX_LIMIT_NUMS - comcatstr.length;
//    
//    if (caninputlen >= 0){
//        return YES;
//    }else{
//        NSInteger len = text.length + caninputlen;
//        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
//        NSRange rg = {0,MAX(len,0)};
//        
//        if (rg.length > 0){
//            NSString *s = [text substringWithRange:rg];
//            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
//        }
//        return NO;
//    }
//}

//- (void)textViewDidChange:(UITextView *)textView{
//    NSString  *nsTextContent = textView.text;
//    NSInteger existTextNum = nsTextContent.length;
//
//    if (existTextNum > MAX_LIMIT_NUMS){
//        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_NUMS];
//        [textView setText:s];
//    }
//    if( self.appDelegate.photos.count > 0 ){
//        UIImageView *imageView = self.mediaView.subviews[self.appDelegate.focusImageIndex];
//        UILabel *descLabel = imageView.subviews[0];
//        if( textView.text.length == 0 ){
//            descLabel.text = NSLocalizedString(@"uploadDescLabelPlaceHolderText", nil);
//        }else{
//            descLabel.text = textView.text;
//        }
//    }
//    self.textCountLabel.text = [NSString stringWithFormat:@"%ld", MAX(0, MAX_LIMIT_NUMS - existTextNum)];
//}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if( ![text isEqualToString:@""] && (textView.text.length + text.length) > MAX_LIMIT_NUMS ){
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    if( self.appDelegate.photos.count > 0 ){
        UIImageView *imageView = self.mediaView.subviews[self.appDelegate.focusImageIndex];
        UILabel *descLabel = imageView.subviews[0];
        if( textView.text.length == 0 ){
            descLabel.text = NSLocalizedString(@"uploadDescLabelPlaceHolderText", nil);
        }else{
            descLabel.text = textView.text;
        }
    }
    self.textCountLabel.text = [NSString stringWithFormat:@"%d", (int)MAX(0, MAX_LIMIT_NUMS - existTextNum)];
}

- (void)clickRmButton:(UIButton *)btn{
    self.isDeleteSignals = true;
    [self.appDelegate clearIndexProperty:btn.tag];
    [self.appDelegate.videos removeAllObjects];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self getMediaView:cell];
    [self.tableView reloadData];
    
    if( self.appDelegate.photos.count > 0 ){
        self.textView.text = [self.appDelegate.fileDesc objectAtIndex:self.appDelegate.focusImageIndex];
        self.textCountLabel.text = [NSString stringWithFormat:@"%d", (int)MAX(0, MAX_LIMIT_NUMS - self.textView.text.length)];
    }else{
        self.textView.text = @"";
        self.textCountLabel.text = [NSString stringWithFormat:@"%d", MAX_LIMIT_NUMS];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    self.isDeleteSignals = false;
    if( self.appDelegate.photos.count > 0 ){
        [self addTLabel];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if( self.appDelegate.photos.count > 0 ){
        [self.tLabel removeFromSuperview];
    }
}

- (void)addTLabel{
    [self.tLabel removeFromSuperview];
    UIImageView *imageView = self.mediaView.subviews[self.appDelegate.focusImageIndex];
    self.tLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(imageView), GET_LAYOUT_HEIGHT(imageView)-20)];
    self.tLabel.backgroundColor = RGBA_COLOR(0, 0, 0, 0.4);
    self.tLabel.textColor = [UIColor whiteColor];
    self.tLabel.font = [UIFont systemFontOfSize:48.0f];
    self.tLabel.textAlignment = NSTextAlignmentCenter;
    self.tLabel.text = @"T";
    [imageView addSubview:self.tLabel];
}

- (void)viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
}



- (void)test{
    [self.view endEditing:YES];
    
    if( !self.appDelegate.isSending ){
        
        [self.appDelegate.deviceId removeAllObjects];
        for (NSMutableDictionary *device in self.appDelegate.deviceList) {
            if( [[device objectForKey:@"isSelected"] boolValue] ){
                [self.appDelegate.deviceId addObject:[device objectForKey:@"device_id"]];
            }
        }
        
        if( self.appDelegate.photos.count == 0 ){
            HUD_TOAST_SHOW(NSLocalizedString(@"uploadVideoEmptyError", nil));
            return;
        }
        if( self.appDelegate.deviceId.count == 0 ){
            HUD_TOAST_SHOW(NSLocalizedString(@"uploadDeviceEmptyError", nil));
            return;
        }
        
        DISABLE_RightBarButtonItem;
        NAV_UPLOAD_START;
        
        self.appDelegate.md5 = [self.appDelegate fileMD5:UIImagePNGRepresentation([self.appDelegate.photos objectAtIndex:0])];
        NSLog(@"视频md5计算完成,md5值为:%@", self.appDelegate.md5);
        
        //保存文件到本地然后获取目录
//        [[TZImageManager manager] getVideoOutputPathWithAsset:self.appDelegate.videoAsset success:^(NSString *outputPath){
//            NSLog(@"测试，视频导出到本地完成,沙盒路径为:%@", outputPath);
//
//            float video_size = [self getFileSize:outputPath]/1024.00;
//            NSLog(@"测试，视频导出到本地完成,大小为:%f M", video_size);
//
//            NSString *videoSize = [NSString stringWithFormat:@"%f", video_size];
//
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//            [fileManager removeItemAtPath:outputPath error:nil];
//        } failure:^(NSString *errorMessage, NSError *error) {}];

//        NSLog(@"测试:%@ ", self.appDelegate.videos);
        
//        NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
//        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:[NSArray arrayWithObject:referenceURL] options:nil];
//        PHAsset *videoAsset = (PHAsset*)fetchResult.firstObject;
//
//        float fileSize = 0.00;
//        if (self.appDelegate.videoAsset != nil && self.appDelegate.videoData == nil) {
//            PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:self.appDelegate.videoAsset] firstObject];
//            long long originFileSize = [[resource valueForKey:@"fileSize"] longLongValue];
//            fileSize = ((int)originFileSize/1024.00)/1024.00;
//            NSLog(@"视频大小:%f M", fileSize);
//        } else {
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
//            NSString *pathName = [NSString stringWithFormat:@"VID_%@.mp4", self.appDelegate.md5];
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *documentPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
//            NSString *filePath = [documentPath stringByAppendingString:[NSString stringWithFormat:@"/%@", pathName]];
//            [self.appDelegate.videoData writeToFile:filePath atomically:NO];
//            fileSize = [self getFileSize:filePath]/1024.00;
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//            [fileManager removeItemAtPath:filePath error:nil];
//            NSLog(@"视频大小:%f M", fileSize);
//        }
//        
        NSLog(@"测试数据输出：%@", self.appDelegate);
        
        NSMutableDictionary *video_data = [[NSMutableDictionary alloc] init];
        [video_data setObject:self.appDelegate.md5 forKey:@"file_md5"];
        [video_data setObject:[[self.appDelegate.fileDesc objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"file_desc"];
        [video_data setObject:self.appDelegate.deviceId forKey:@"device_id"];
        NSString *videoData = [self.appDelegate convertToJSONData:video_data];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 30.0f;
        //加入header参数
        [manager.requestSerializer setValue:[self.appDelegate.userInfo objectForKey:@"user_system_token"] forHTTPHeaderField:@"user_token"];
//        [manager.requestSerializer setValue:@"hello" forHTTPHeaderField:@"user_token"];
        NSDictionary *parameters=@{
                                   @"user_id":[self.appDelegate.userInfo objectForKey:@"user_id"],
                                   @"user_imei":[self.appDelegate.userInfo objectForKey:@"user_name"],
                                   @"video_data":videoData,
//                                   @"file_size":[NSString stringWithFormat:@"%f", fileSize]
//                                   @"file_size":@"1"
                                   };
        
        NSLog(@"提交的数据， %@", parameters);
        HUD_WAITING_SHOW(NSLocalizedString(@"hudLoading", nil));
        [manager POST:BASE_URL(@"upload/token/video") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"成功.%@",responseObject);
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
            NSLog(@"results: %@", dic);
            
            int status = [[dic objectForKey:@"status"] intValue];
            
            HUD_WAITING_HIDE;
            if( status == 200 ){
                NSDictionary *data = [dic objectForKey:@"data"];
                
                NSString *upToken = [data objectForKey:@"upToken"];
                if( upToken != nil ){
                    [self ossUpload:upToken];
                }else{
                    [self doMessage];
                    
                    NSLog(@"upToken: %@", upToken);
                    DO_FINISH_UPLOAD;
                    NAV_UPLOAD_END;
                    HUD_LOADING_HIDE;
                    ENABLE_RightBarButtonItem;
                    HUD_TOAST_SHOW(NSLocalizedString(@"uploadSendSuccess", nil));
                }
            }if( status == 122 ){
                NSDictionary *data = [dic objectForKey:@"data"];
                
                NSString *upToken = [data objectForKey:@"upToken"];
                if( upToken != nil ){
                    [self ossUpload:upToken];
                }else{
                    [self doMessage];
                    
                    NSLog(@"upToken: %@", upToken);
                    DO_FINISH_UPLOAD;
                    NAV_UPLOAD_END;
                    HUD_LOADING_HIDE;
                    ENABLE_RightBarButtonItem;
                    HUD_TOAST_SHOW(NSLocalizedString(@"uploadSendSuccess", nil));
                }
                
            }else if( status == 327 ){
                AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                manager.requestSerializer.timeoutInterval = 30.0f;
                NSDictionary *parameters=@{
                                           @"user_id":[self.appDelegate.userInfo objectForKey:@"user_id"]
                                           };
                //加入header参数
                [manager.requestSerializer setValue:[self.appDelegate.userInfo objectForKey:@"user_system_token"] forHTTPHeaderField:@"user_token"];
                
                HUD_WAITING_SHOW(NSLocalizedString(@"loadingDeviceList", nil));
                [manager POST:BASE_URL(@"user/user_device") parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
                    
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSLog(@"成功.%@",responseObject);
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
                    
                    int status = [[dic objectForKey:@"status"] intValue];
                    
                    HUD_WAITING_HIDE;
                    if( status == 200 ){
                        self.appDelegate.deviceList = [[dic objectForKey:@"data"] mutableCopy];
                        [self.appDelegate saveDeviceList];
                        
                        [self.tableView reloadData];
                        
                        NAV_UPLOAD_END;
                        ENABLE_RightBarButtonItem;
                        NSString *eCode = @"e327";
                        
                        if( self.appDelegate.deviceList.count == 0 ){
                            AddDeviceController *addDeviceController = [[AddDeviceController alloc] init];
                            HUD_TOAST_PUSH_SHOW(NSLocalizedString(eCode, nil), addDeviceController);
                        }else{
                            HUD_TOAST_SHOW(NSLocalizedString(eCode, nil));
                        }
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
                    
                    NAV_UPLOAD_END;
                    ENABLE_RightBarButtonItem;
                    NSString *eCode = @"e327";
                    HUD_TOAST_SHOW(NSLocalizedString(eCode, nil));
                }];
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
            } else{
                NAV_UPLOAD_END;
                ENABLE_RightBarButtonItem;
                NSString *eCode = [NSString stringWithFormat:@"e%d", status];
                HUD_TOAST_SHOW(NSLocalizedString(eCode, nil));
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"失败.%@",error);
            NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
            
            HUD_WAITING_HIDE;
            NAV_UPLOAD_END;
            ENABLE_RightBarButtonItem;
            HUD_TOAST_SHOW(NSLocalizedString(@"uploadSendFailed", nil));
        }];
    }else{
        NSLog(@"Cancel sending");
        self.isCancelSignals = true;
    }
}

- (void)ossUpload:(NSString*) upToken{
    
    DISABLE_RightBarButtonItem;
    NAV_UPLOAD_START;
    
//    ZipArchive* zip = [[ZipArchive alloc] init];
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYYMMdd_HHmmss"];
    
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *deviceIds = @"";
    for (NSString *deviceId in self.appDelegate.deviceId) {
        deviceIds = [NSString stringWithFormat:@"%@_%@", deviceIds, deviceId];
    }
    [dateFormatter setDateFormat:@"YYYYMMdd_HHmmss"];
    int y = (arc4random() % 8999) + 1000;
//    NSString *fileName = [NSString stringWithFormat:@"VID_%@.mp4", [dateFormatter stringFromDate:date]];
    //NSString *fileName = [NSString stringWithFormat:@"VID_%@.mp4", currentTimeString];
    NSString *fileName = [NSString stringWithFormat:@"VID_%@.mp4", currentTimeString];
    NSString *pathName = [NSString stringWithFormat:@"VID_%@%@%@.mp4", self.appDelegate.md5, deviceIds,[NSString stringWithFormat:@"%ld",y]];
    //NSString *zipFileName = [NSString stringWithFormat:@"IMG_%@%@.zip", [dateFormatter stringFromDate:date],[NSString stringWithFormat:@"%ld",y]];
    NSLog(@"测试数据输出:%@", pathName);
//    NSString *fileName = @"qiniu_test.mp4";
//    NSString *mp4FileName = [NSString stringWithFormat:@"VID_%@.mp4", [dateFormatter stringFromDate:date]];
//    NSString *mp4File = [documentPath stringByAppendingString:[NSString stringWithFormat:@"/%@", mp4FileName]];
    
//    [zip CreateZipFile2:zipFile];
    
    
    
    /*
     *  设备最大数量绑定有bug，检查一下
     */
    
    
    
    //
    
    if( self.appDelegate.videoAsset != nil && self.appDelegate.videoData == nil ){
        
        HUD_WAITING_SHOW(NSLocalizedString(@"loadingProcessing", nil));
        
        [[TZImageManager manager] getVideoOutputPathWithAsset:self.appDelegate.videoAsset success:^(NSString *outputPath){
            
            NSLog(@"视频导出到本地完成,沙盒路径为:%@", outputPath);
            
            ENABLE_RightBarButtonItem;
            HUD_WAITING_HIDE;
            HUD_LOADING_SHOW(NSLocalizedString(@"uploadSendingRightBarButtonItemTitle", nil));
            
//            DO_DATA_TO_BLOCK_IF_FAILED(videoData);
//
//            if( self.appDelegate.isSending ){
//                [self doUploadVideo];
//            }
            
//            ENABLE_RightBarButtonItem;
            //            UPDATE_RightBarButtonItem(ICON_FORWARD);
            
            //        NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:videoUrl]]);
            //        NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[videoUrl path]]]);
            //
            //        NSURL *newVideoUrl ; //一般.mp4
            //        NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
            //        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
            //        //    这个是保存在app自己的沙盒路径里，后面可以选择是否在上传后删除掉。我建议删除掉，免得占空间。
            //        newVideoUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]]];
            //        [self convertVideoQuailtyWithInputURL:videoUrl outputURL:newVideoUrl completeHandler:nil];
            
            
//            [zip addFileToZip:outputPath newname:fileName];
            
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//            [fileManager removeItemAtPath:outputPath error:nil];
            
            
            [self doUploadOssVideo:outputPath withFileName:fileName withPathName:pathName withToken:upToken];
            
            
//            [zip CloseZipFile2];
            
            
        } failure:^(NSString *errorMessage, NSError *error) {
            
        }];
    }else{
//        [zip addDataToZip:self.appDelegate.videoData fileAttributes:nil newname:fileName];
//
//        ENABLE_RightBarButtonItem;
//        HUD_WAITING_HIDE;
//
//        [self doUploadOssVideo:zipFile withFileName:zipFileName withToken:upToken];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        NSString *filePath = [documentPath stringByAppendingString:[NSString stringWithFormat:@"/%@", pathName]];
        
        [self.appDelegate.videoData writeToFile:filePath atomically:NO];
        
        NSString *tmpDir = NSTemporaryDirectory();
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:tmpDir error:nil];
        
        ENABLE_RightBarButtonItem;
        HUD_WAITING_HIDE;
        
        [self doUploadOssVideo:filePath withFileName:fileName withPathName:pathName withToken:upToken];
    }
}

- (void)doUploadOssVideo:(NSString*)zipFile withFileName:(NSString*)fileName withPathName:(NSString*)pathName withToken:(NSString*)upToken{
    self.isCancelSignals = false;
    HUD_LOADING_SHOW(NSLocalizedString(@"uploadSendingRightBarButtonItemTitle", nil));
    
    NSMutableArray *fileDesc = [[NSMutableArray alloc] init];
    for (int i=0; i< self.appDelegate.photos.count; i++) {
        [fileDesc addObject:[[self.appDelegate.fileDesc objectAtIndex:i] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSLog(@"FILENAMESHIBUSHI SILE  =  %@",fileName);
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        // percent 为上传进度
        NSLog(@"percent: %@ %f", key, percent);
        dispatch_async(dispatch_get_main_queue(), ^{
            HUD_LOADING_PROGRESS(percent);
        });
    }
    params:@{
              @"x:type":@"video",
              @"x:platform":@"app",
              @"x:user_id":[[self.appDelegate.userInfo objectForKey:@"user_id"] stringValue],
              @"x:name":fileName,
              @"x:description":[self.appDelegate convertToJSONData:[fileDesc copy]],
              @"x:device_id":[self.appDelegate convertToJSONData:[self.appDelegate.deviceId copy]],
              @"x:md5":self.appDelegate.md5
              }
    checkCrc:NO
    cancellationSignal:^BOOL() {
        return self.isCancelSignals;
    }];
    
    NSLog(@"FILENAMESHIBUSHI SILE  =  %@",fileName);
//    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
//        builder.zone = [QNFixedZone zoneNa0];
//    }];
//    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    
    //文件管理  文件路径可以自定义
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //upprogress 文件夹用来存储上传进度 七牛云自动实现记录 无需别的操作
    NSString* fileurl = [document stringByAppendingPathComponent:[NSString stringWithFormat:@"qiniu_uid_%@", [self.appDelegate.userInfo objectForKey:@"user_id"]]];
    // 传入断点记录的代理
    NSError *error;
    QNFileRecorder *file = [QNFileRecorder fileRecorderWithFolder:fileurl error:&error];
    NSLog(@"qiniu error: %@", error);
    // 创建带有断点记录代理的上传管理者
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithRecorder:file];
    
    NAV_UPLOAD_START;
    [upManager putFile:zipFile key:[NSString stringWithFormat:@"upload/video/uid%@/%@", [self.appDelegate.userInfo objectForKey:@"user_id"], pathName] token:upToken complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//    [upManager putFile:zipFile key:[NSString stringWithFormat:@"%@",zipFileName] token:upToken complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        NSLog(@"oss: %@", info);
        NSLog(@"oss: %@", resp);
        
        NSInteger statusCode = [info statusCode];
        
        if( [[resp objectForKey:@"status"] intValue] == 200 ){
            [self doMessage];
            
            [self.appDelegate saveDeviceSent];
            
            DO_FINISH_UPLOAD;
            NAV_UPLOAD_END;
            HUD_LOADING_HIDE;
            HUD_TOAST_SHOW(NSLocalizedString(@"uploadSendSuccess", nil));
        }else if ([[resp objectForKey:@"status"] intValue] == 122) {
            NSString *message = [[resp objectForKey:@"data"] objectForKey:@"message"];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * cancelAc = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                //点击取消要执行的代码
            }];
            
            UIAlertAction *comfirmAc = [UIAlertAction actionWithTitle:@"Charge" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //点击确定要执行的代码
                NSString *redirect_url = [[resp objectForKey:@"data"] objectForKey:@"redirecturl"];
                NSURL *url = [[NSURL alloc] initWithString:redirect_url];
                [[UIApplication sharedApplication] openURL:url];
            }];
            
            [alertVC addAction:cancelAc];
            [alertVC addAction:comfirmAc];
            [self presentViewController:alertVC animated:YES completion:nil];
            DO_FINISH_UPLOAD;
            NAV_UPLOAD_END;
            HUD_LOADING_HIDE;
        } else if ([[resp objectForKey:@"status"] intValue] == 123) {
            NSString *message = [[resp objectForKey:@"data"] objectForKey:@"message"];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            
//            UIAlertAction * cancelAc = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                //点击取消要执行的代码
//            }];
            
            UIAlertAction *comfirmAc = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //点击确定要执行的代码
            }];
            
//            [alertVC addAction:cancelAc];
            [alertVC addAction:comfirmAc];
            [self presentViewController:alertVC animated:YES completion:nil];
//            DO_FINISH_UPLOAD;
            NAV_UPLOAD_END;
            HUD_LOADING_HIDE;
        }  else if ([[resp objectForKey:@"status"] intValue] == 124) {
            NSString *message = [[resp objectForKey:@"data"] objectForKey:@"message"];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            
            //            UIAlertAction * cancelAc = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //                //点击取消要执行的代码
            //            }];
            
            UIAlertAction *comfirmAc = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //点击确定要执行的代码
            }];
            
            //            [alertVC addAction:cancelAc];
            [alertVC addAction:comfirmAc];
            [self presentViewController:alertVC animated:YES completion:nil];
            //            DO_FINISH_UPLOAD;
            NAV_UPLOAD_END;
            HUD_LOADING_HIDE;
        } else if ( statusCode == 614 ) {
            HUD_TOAST_SHOW(@"The video already exists");
            NAV_UPLOAD_END;
            HUD_LOADING_HIDE;
        } else if( statusCode == -999 || statusCode == -2 ){
            HUD_TOAST_SHOW(NSLocalizedString(@"uploadSendCanceled", nil));
            NAV_UPLOAD_END;
            HUD_LOADING_HIDE;
        }else{
            HUD_TOAST_SHOW(NSLocalizedString(@"uploadSendFailed", nil));
            NAV_UPLOAD_END;
            HUD_LOADING_HIDE;
        }
        // 删除zip文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:zipFile error:nil];
    } option:uploadOption];
}

- (void)doMessage{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [dateFormatter stringFromDate:date];
    for(int i=0;i<self.appDelegate.photos.count;i++){
        NSString *deviceName = @"";
        for(int j=0;j<self.appDelegate.deviceId.count;j++){
            NSString  *device_id = [self.appDelegate.deviceId objectAtIndex:j];
            for(int k=0;k<self.appDelegate.deviceList.count;k++){
                //                    NSLog(@"%@", [[self.appDelegate.deviceList objectAtIndex:k] objectForKey:@"device_id"] );
                //                    NSLog(@"%@", device_id);
                if( [[self.appDelegate.deviceList objectAtIndex:k] objectForKey:@"device_id"] == device_id ){
                    NSString *device_name = [[self.appDelegate.deviceList objectAtIndex:k] objectForKey:@"device_name"];
                    if( [deviceName isEqualToString:@""] ){
                        deviceName = device_name;
                    }else{
                        deviceName = [NSString stringWithFormat:@"%@, %@", deviceName, device_name];
                    }
                    break;
                }
            }
        }
        NSString *desc = [self.appDelegate.fileDesc objectAtIndex:i];
        int imageWidth = 0;
        int imageHeight = 0;
        if( self.appDelegate.photos[i].size.width >= self.appDelegate.photos[i].size.height ){
            imageWidth = 150;
            imageHeight = 150 / self.appDelegate.photos[i].size.width * self.appDelegate.photos[i].size.height;
        }else{
            imageWidth = 150 / self.appDelegate.photos[i].size.height * self.appDelegate.photos[i].size.width;
            imageHeight = 150;
        }
        CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
        NSData *data = [self.appDelegate compressQualityWithMaxLength:PHOTO_MAX_SIZE withSourceImage:[self.appDelegate imageByScalingAndCroppingForSize:imageSize withSourceImage:self.appDelegate.photos[i]]];
        [self.appDelegate addMessageList:@"video" withTime:time withTitle:deviceName withDesc:desc withData:data];
    }
}

@end

