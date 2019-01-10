//
//  MessageController.m
//  PhotoPartner
//
//  Created by USER on 7/3/2018.
//  Copyright © 2018 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "MessageController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD.h>

@interface MessageController ()
@property UIScrollView *scrollView;

@property AppDelegate *appDelegate;
@end

@implementation MessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.navigationItem.title = NSLocalizedString(@"messageNavigationItemTitle", nil);
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, MARGIN_TOP, GET_LAYOUT_WIDTH(self.view), GET_LAYOUT_HEIGHT(self.view)-MARGIN_TOP)];
    
    [self.view addSubview:self.scrollView];
    
    [self updateLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLayout{
    long offsetTop = 0;
    long messageWidth = GET_LAYOUT_WIDTH(self.scrollView)-20;
    for(NSMutableDictionary *messageItem in self.appDelegate.messageList){
        long messageHeight = 0;
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, messageWidth, 25)];
        timeLabel.text = [self.appDelegate getMessageTime:[messageItem objectForKey:@"time"]];
//        timeLabel.backgroundColor = [UIColor blueColor];
        messageHeight = GET_LAYOUT_OFFSET_Y(timeLabel)+GET_LAYOUT_HEIGHT(timeLabel);
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(timeLabel)+GET_LAYOUT_HEIGHT(timeLabel), messageWidth, 25)];
//        titleLabel.backgroundColor = [UIColor grayColor];
        if( [[messageItem objectForKey:@"type"] isEqualToString:@"bind"] ){
            titleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"messageBindDeviceTo", nil), [[messageItem objectForKey:@"title"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }else if( [[messageItem objectForKey:@"type"] isEqualToString:@"unbind"] ){
            titleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"messageUnbindDeviceTo", nil), [[messageItem objectForKey:@"title"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }else if( [[messageItem objectForKey:@"type"] isEqualToString:@"image"] ){
            titleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"messageSendPhotoTo", nil), [[messageItem objectForKey:@"title"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }else if( [[messageItem objectForKey:@"type"] isEqualToString:@"video"] ){
            titleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"messageSendVideoTo", nil), [[messageItem objectForKey:@"title"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        titleLabel.numberOfLines = 0;
        [titleLabel sizeToFit];
        messageHeight = GET_LAYOUT_OFFSET_Y(titleLabel)+GET_LAYOUT_HEIGHT(titleLabel);
        
        UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(10, offsetTop, messageWidth, GET_LAYOUT_OFFSET_Y(titleLabel)+GET_LAYOUT_HEIGHT(titleLabel)+5)];
//        messageView.backgroundColor = [UIColor grayColor];
        CALayer *messageViewBorder = [CALayer layer];
        messageViewBorder.frame = CGRectMake(0.0f, GET_LAYOUT_HEIGHT(messageView)-1, GET_LAYOUT_WIDTH(messageView), BORDER_WIDTH);
        messageViewBorder.backgroundColor = BORDER_COLOR;
        [messageView.layer addSublayer:messageViewBorder];
        [messageView addSubview:timeLabel];
        [messageView addSubview:titleLabel];
        
        if( [[messageItem objectForKey:@"type"] isEqualToString:@"image"] ||
            [[messageItem objectForKey:@"type"] isEqualToString:@"video"] ){
            
            UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(titleLabel)+GET_LAYOUT_HEIGHT(titleLabel), messageWidth, 25)];
            descLabel.text = [messageItem objectForKey:@"desc"];
            descLabel.numberOfLines = 0;
            [descLabel sizeToFit];
//            descLabel.backgroundColor = [UIColor orangeColor];
            messageHeight = GET_LAYOUT_OFFSET_Y(descLabel)+GET_LAYOUT_HEIGHT(descLabel);
            
            
            UIView *mediaView = [[UIView alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(descLabel)+GET_LAYOUT_HEIGHT(descLabel), 100, 150+15)];
//            mediaView.backgroundColor = [UIColor yellowColor];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 100, 150)];
            imageView.image = [UIImage imageWithData:[[NSData alloc] initWithBase64Encoding:[messageItem objectForKey:@"data"]]];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
//            imageView.backgroundColor = [UIColor redColor];
            [mediaView addSubview:imageView];
            
            if( [[messageItem objectForKey:@"type"] isEqualToString:@"video"] ){
                UIImageView *videoView = [[UIImageView alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(mediaView)-80)/2, (GET_LAYOUT_HEIGHT(mediaView)-80)/2, 80, 80)];
                videoView.image = [UIImage imageNamed:@"message_video"];
    //            videoView.contentMode = UIViewContentModeScaleAspectFill;
    //            videoView.clipsToBounds = YES;
                [mediaView addSubview:videoView];
            }
            messageHeight = GET_LAYOUT_OFFSET_Y(mediaView)+GET_LAYOUT_HEIGHT(mediaView);
            
            messageView = [[UIView alloc] initWithFrame:CGRectMake(10, offsetTop, messageWidth, GET_LAYOUT_OFFSET_Y(mediaView)+GET_LAYOUT_HEIGHT(mediaView))];
//            messageView.backgroundColor = [UIColor grayColor];
            CALayer *messageViewBorder = [CALayer layer];
            messageViewBorder.frame = CGRectMake(0.0f, GET_LAYOUT_HEIGHT(messageView)-1, GET_LAYOUT_WIDTH(messageView), BORDER_WIDTH);
            messageViewBorder.backgroundColor = BORDER_COLOR;
            [messageView.layer addSublayer:messageViewBorder];
            [messageView addSubview:timeLabel];
            [messageView addSubview:titleLabel];
            [messageView addSubview:descLabel];
            [messageView addSubview:mediaView];
            
    //        NSLog(@"%f", GET_LAYOUT_HEIGHT(timeLabel)+GET_LAYOUT_HEIGHT(titleLabel)+GET_LAYOUT_HEIGHT(descLabel)+GET_LAYOUT_HEIGHT(imageView));
        }
        offsetTop+=messageHeight;
        self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
        [self.scrollView addSubview:messageView];
    }
}

@end
