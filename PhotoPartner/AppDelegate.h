//
//  AppDelegate.h
//  PhotoPartner
//
//  Created by USER on 6/3/2018.
//  Copyright © 2018 MJF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//
@property NSMutableDictionary *userInfo;
@property NSMutableArray *deviceList;
@property NSMutableArray *messageList;
@property int appVersion;
@property NSString *deviceUUID;
//
@property NSMutableArray *deviceId;
@property NSMutableArray *fileDesc;
@property NSMutableArray<UIImage *> *photos;
//@property NSMutableArray *isTakePhoto;
@property long focusImageIndex;
@property Boolean isSending;
/*
 *  For Video
 */
@property id videoAsset;
@property NSData *videoData;
@property NSMutableArray<NSData *> *videos;
@property NSMutableDictionary *failedBlock;
@property NSMutableArray *completedUnitPercent;
@property NSString *md5;
/*
 *  For Common UI
 */
@property MBProgressHUD *hudLoading;
@property MBProgressHUD *hudToast;
@property MBProgressHUD *hudWaiting;
/*
 *  For Function
 */
- (void)clearProperty;
//- (void)clearPickerProperty;
- (void)clearIndexProperty:(long)index;
- (void)addFailedBlock:(NSMutableArray *) failedBlock withMD5:(NSString *)md5;
- (void)saveFailedBlock;
- (void)loadFailedBlock;
- (void)addDeviceList:(NSMutableDictionary *) device;
- (void)saveDeviceList;
- (void)loadDeviceList;
- (Boolean)isNilDeviceList;
- (void)addMessageList:(NSString *)type withTime:(NSString *) time withTitle:(NSString *) title withDesc:(NSString *) desc withData:(NSData *) data;
- (void)saveMessageList;
- (void)loadMessageList;
- (void)clearMessageList;
- (bool)doDataToBlock:(NSData *) videoData;
//- (NSString *)md5:(NSString *) string;
- (NSString*)fileMD5:(NSData*)data;
- (NSString*)getMessageTime:(NSString*) time;

- (NSString*)convertToJSONData:(id)infoDict;
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withSourceImage:(UIImage *)sourceImage;
- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength withSourceImage:(UIImage *)sourceImage;

- (void)saveUserInfo;
- (void)loadUserInfo;

@end

