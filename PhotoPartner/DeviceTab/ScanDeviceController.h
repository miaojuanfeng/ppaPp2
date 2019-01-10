//
//  ScanDeviceController.h
//  PhotoPartner
//
//  Created by USER on 8/4/2018.
//  Copyright © 2018 MJF. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScanDeviceControllerDelegate <NSObject>

- (void)license:(NSString *)license;

@end

@interface ScanDeviceController : UIViewController

@property (nonatomic, weak) id<ScanDeviceControllerDelegate> delegate;

@end
