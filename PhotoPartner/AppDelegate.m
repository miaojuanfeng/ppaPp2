//
//  AppDelegate.m
//  PhotoPartner
//
//  Created by USER on 6/3/2018.
//  Copyright © 2018 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "HomeController.h"
#import <CommonCrypto/CommonDigest.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    [UINavigationBar appearance].barTintColor = RGBA_COLOR(27, 163, 232, 1);
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // Init Global Varables
    self.deviceId = [[NSMutableArray alloc] init];
    self.fileDesc = [[NSMutableArray alloc] init];
    self.photos = [[NSMutableArray alloc] init];
//    self.isTakePhoto = [[NSMutableArray alloc] init];
    self.focusImageIndex = -1;
    
    self.videoAsset = nil;
    self.videoData = nil;
    self.videos = [[NSMutableArray alloc] init];
    self.completedUnitPercent = [[NSMutableArray alloc] init];
    self.md5 = @"";
    
    [self loadDeviceList];
    if( self.deviceList == nil ){
        self.deviceList = [[NSMutableArray alloc] init];
    }
    [self loadUserInfo];
    self.appVersion = 11;
    self.isSending = false;
    
    [self loadMessageList];
    if( self.messageList == nil ){
        self.messageList = [[NSMutableArray alloc] init];
    }
    
    [self loadFailedBlock];
    if( self.failedBlock == nil ){
        self.failedBlock = [[NSMutableDictionary alloc] init];
    }
//    [self.failedBlock removeAllObjects];
//    [self saveFailedBlock];
    NSLog(@"self.failedBlock: %@", self.failedBlock);
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    HomeController *homeController = [[HomeController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:homeController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    self.hudLoading = [MBProgressHUD showHUDAddedTo:self.window.rootViewController.view animated:YES];
    self.hudLoading.mode = MBProgressHUDModeAnnularDeterminate;
    self.hudLoading.removeFromSuperViewOnHide = NO;
    self.hudLoading.bezelView.backgroundColor = [UIColor blackColor];
    self.hudLoading.contentColor = [UIColor whiteColor];
    self.hudLoading.progress = 0.0f;
    [self.hudLoading hideAnimated:NO];
    
    self.hudWaiting = [MBProgressHUD showHUDAddedTo:self.window.rootViewController.view animated:YES];
    self.hudWaiting.mode = MBProgressHUDModeIndeterminate;
    self.hudWaiting.removeFromSuperViewOnHide = NO;
    self.hudWaiting.bezelView.backgroundColor = [UIColor blackColor];
    self.hudWaiting.contentColor = [UIColor whiteColor];
    [self.hudWaiting hideAnimated:NO];
    
    
//    for (NSString * family in [UIFont familyNames]) {
//        NSLog(@"familyNames:%@", family);
//        for (NSString * name in [UIFont fontNamesForFamilyName:family]) {
//            NSLog(@"  name: %@",name);
//        }
//    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)clearProperty {
    [self.deviceId removeAllObjects];
    [self.fileDesc removeAllObjects];
    [self.photos removeAllObjects];
//    [self.isTakePhoto removeAllObjects];
    self.focusImageIndex = -1;
//    self.isSending = false;
    // Video
    self.videoAsset = nil;
    self.videoData = nil;
    [self.videos removeAllObjects];
    [self.completedUnitPercent removeAllObjects];
    self.md5 = @"";
}

//- (void)clearPickerProperty {
//    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
//    for (int i=0;i<self.photos.count;i++) {
//        if ( ![[self.isTakePhoto objectAtIndex:i] boolValue] ){
//            [indexSet addIndex:i];
//        }else{
//             self.focusImageIndex = i;
//        }
//    }
//    [self.photos removeObjectsAtIndexes:indexSet];
//    [self.isTakePhoto removeObjectsAtIndexes:indexSet];
//    [self.fileDesc removeObjectsAtIndexes:indexSet];
//}

- (void)clearIndexProperty:(long)index {
    [self.photos removeObjectAtIndex:index];
    [self.fileDesc removeObjectAtIndex:index];
    if( self.photos.count > 0 ){
        self.focusImageIndex = 0;
    }else{
        self.focusImageIndex = -1;
    }
}

- (void)addFailedBlock:(NSMutableArray *) failedBlock withMD5:(NSString *)md5 {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [path objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"failedBlock.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *newDic = nil;
    if ([fileManager fileExistsAtPath:plistPath] == NO) {
        newDic = [[NSMutableDictionary alloc] init];
    }else{
        newDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    }
    [newDic setValue:failedBlock forKey:md5];
    [newDic writeToFile:plistPath atomically:YES];
}

- (void)saveFailedBlock {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [path objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"failedBlock.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:plistPath error:nil];
    
    if( self.failedBlock.count ){
        [self.failedBlock writeToFile:plistPath atomically:YES];
    }
}

- (void)loadFailedBlock {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray objectAtIndex:0];
    NSString *plistPath = [path stringByAppendingPathComponent:@"failedBlock.plist"];
    self.failedBlock = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
}

- (void)addDeviceList:(NSMutableDictionary *) device {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [path objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"deviceList.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *newDic = nil;
    if ([fileManager fileExistsAtPath:plistPath] == NO) {
        newDic = [[NSMutableArray alloc] init];
    }else{
        newDic = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    }
    [newDic addObject:device];
    [newDic writeToFile:plistPath atomically:YES];
}

- (void)saveDeviceList {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [path objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"deviceList.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:plistPath error:nil];
    
    if( self.deviceList.count ){
        [self.deviceList writeToFile:plistPath atomically:YES];
    }
}

- (void)loadDeviceList {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray objectAtIndex:0];
    NSString *plistPath = [path stringByAppendingPathComponent:@"deviceList.plist"];
    self.deviceList = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
}

- (Boolean)isNilDeviceList {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray objectAtIndex:0];
    NSString *plistPath = [path stringByAppendingPathComponent:@"deviceList.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return ![fileManager fileExistsAtPath:plistPath];
}

- (void)addMessageList:(NSString *)type withTime:(NSString *) time withTitle:(NSString *) title withDesc:(NSString *) desc withData:(NSData *) data {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [path objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"messageList.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *newDic = nil;
    if ([fileManager fileExistsAtPath:plistPath] == NO) {
        newDic = [[NSMutableArray alloc] init];
    }else{
        newDic = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    }
    
    NSString *encodedImageStr = @"";
    if( data != nil ){
//        NSData *_data = UIImageJPEGRepresentation(data, 1.0f);
        NSData *_data = data;
        encodedImageStr = [_data base64Encoding];
    }
    
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    [message setObject:type forKey:@"type"];
    [message setObject:time forKey:@"time"];
    [message setObject:title forKey:@"title"];
    [message setObject:desc forKey:@"desc"];
    [message setObject:encodedImageStr forKey:@"data"];
    
    [self.messageList insertObject:message atIndex:0];
    
    [newDic insertObject:message atIndex:0];
    [newDic writeToFile:plistPath atomically:YES];
}

- (void)saveUserInfo {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [path objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"userInfo.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:plistPath error:nil];
    
    if( self.userInfo != nil ){
        [self.userInfo writeToFile:plistPath atomically:YES];
    }
}

- (void)loadUserInfo {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray objectAtIndex:0];
    NSString *plistPath = [path stringByAppendingPathComponent:@"userInfo.plist"];
    self.userInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
}

- (void)saveMessageList {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [path objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"messageList.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:plistPath error:nil];
    
    if( self.messageList.count ){
        [self.messageList writeToFile:plistPath atomically:YES];
    }
}

- (void)loadMessageList {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray objectAtIndex:0];
    NSString *plistPath = [path stringByAppendingPathComponent:@"messageList.plist"];
    self.messageList = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
}

- (void)clearMessageList{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [path objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"messageList.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:plistPath error:nil];
    
    self.messageList = [[NSMutableArray alloc] init];
}

- (bool)doDataToBlock:(NSData *) videoData{
    
    NSLog(@"video length: %ld", videoData.length);
    
    if( videoData.length > VIDEO_MAX_SIZE ){
        return false;
    }
    
    long videoChunkCount = 0;
    long lastChunkEnd = 0;
    if( videoData.length%VIDEO_CHUNK_SIZE == 0 ){
        videoChunkCount = videoData.length/VIDEO_CHUNK_SIZE;
    }else{
        videoChunkCount = videoData.length/VIDEO_CHUNK_SIZE + 1;
        lastChunkEnd = videoData.length%VIDEO_CHUNK_SIZE;
    }
    [self.videos removeAllObjects];
    for (int i=0; i<videoChunkCount; i++) {
        if( i == videoChunkCount-1 ){
            [self.videos addObject:[videoData subdataWithRange:NSMakeRange(i*VIDEO_CHUNK_SIZE, lastChunkEnd)]];
        }else{
            [self.videos addObject:[videoData subdataWithRange:NSMakeRange(i*VIDEO_CHUNK_SIZE, VIDEO_CHUNK_SIZE)]];
        }
    }
    NSLog(@"%ld",self.videos.count);
    for (int i=0; i<self.videos.count; i++) {
        [self.completedUnitPercent addObject:@0];
    }
    
    return true;
}

//- (NSString *)md5:(NSString *)string{
//    const char *cStr = [string UTF8String];
//    unsigned char digest[CC_MD5_DIGEST_LENGTH];
//    
//    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
//    
//    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
//    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
//        [result appendFormat:@"%02X", digest[i]];
//    }
//    
//    return result;
//}

-(NSString*)fileMD5:(NSData*)data
{
    if( data == nil ) return nil; // file didnt exist
    
    CC_MD5_CTX md5;
    
    CC_MD5_Init(&md5);
    
    CC_MD5_Update(&md5, [data bytes], (unsigned int)[data length]);

    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}

- (NSString*)getMessageTime:(NSString*) time{
    NSDate *nowDate = [NSDate date]; // 当前日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH-mm-ss";
    NSDate *creat = [formatter dateFromString:time];// 将传入的字符串转化成时间
    NSTimeInterval delta = [nowDate timeIntervalSinceDate:creat]; // 计算出相差多少秒
    if( delta < 60.0 ){
        return [NSString stringWithFormat:@"%d%@", (int)delta, NSLocalizedString(@"messageSecondAgo", nil)];
    }
    if( delta < ( 60.0 * 60.0 ) ){
        return [NSString stringWithFormat:@"%d%@", (int)delta/60, NSLocalizedString(@"messageMinuteAgo", nil)];
    }
    if( delta < ( 60.0 * 60.0 * 24) ){
        return [NSString stringWithFormat:@"%d%@", (int)delta/60/60, NSLocalizedString(@"messageHourAgo", nil)];
    }
    return time;
}

- (NSString*)convertToJSONData:(NSDictionary *)dict
{
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

/**
 *  图片压缩到指定大小
 *  @param targetSize  目标图片的大小
 *  @param sourceImage 源图片
 *  @return 目标图片
 */
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withSourceImage:(UIImage *)sourceImage
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength withSourceImage:(UIImage *)sourceImage
{
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(sourceImage, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(sourceImage, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    return data;
}

@end
