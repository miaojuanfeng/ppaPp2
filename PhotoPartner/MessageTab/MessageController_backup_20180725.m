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

@interface MessageController () <UITableViewDataSource, UITableViewDelegate>
@property UITableView *tableView;

@property AppDelegate *appDelegate;
@end

@implementation MessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.navigationItem.title = NSLocalizedString(@"messageNavigationItemTitle", nil);
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, MARGIN_TOP, VIEW_WIDTH, VIEW_HEIGHT)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.appDelegate.messageList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self getCellHeight:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSMutableDictionary *messageItem = self.appDelegate.messageList[indexPath.row];
    
//    messageView.backgroundColor = [UIColor redColor];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(self.tableView), 25)];
    timeLabel.text = [self.appDelegate getMessageTime:[messageItem objectForKey:@"time"]];
//    timeLabel.backgroundColor = [UIColor blueColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(timeLabel)+GET_LAYOUT_HEIGHT(timeLabel), GET_LAYOUT_WIDTH(self.tableView), 25)];
//    titleLabel.backgroundColor = [UIColor grayColor];
    if( [[[self.appDelegate.messageList objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"bind"] ){
        titleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"messageBindDeviceTo", nil), [messageItem objectForKey:@"title"]];
    }else if( [[[self.appDelegate.messageList objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"unbind"] ){
        titleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"messageUnbindDeviceTo", nil), [messageItem objectForKey:@"title"]];
    }else if( [[[self.appDelegate.messageList objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"image"] ){
        titleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"messageSendPhotoTo", nil), [messageItem objectForKey:@"title"]];
    }else if( [[[self.appDelegate.messageList objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"video"] ){
        titleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"messageSendVideoTo", nil), [messageItem objectForKey:@"title"]];
    }
    
    UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, GET_LAYOUT_WIDTH(self.tableView)-20, 120)];
    [messageView addSubview:timeLabel];
    [messageView addSubview:titleLabel];
    
    if( [[[self.appDelegate.messageList objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"image"] ||
        [[[self.appDelegate.messageList objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"video"] ){
        
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(titleLabel)+GET_LAYOUT_HEIGHT(titleLabel), GET_LAYOUT_WIDTH(self.tableView), 25)];
        descLabel.text = [messageItem objectForKey:@"desc"];
        descLabel.numberOfLines = 0;
        [descLabel sizeToFit];
//        descLabel.backgroundColor = [UIColor orangeColor];
        
        
        UIView *mediaView = [[UIView alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_OFFSET_Y(descLabel)+GET_LAYOUT_HEIGHT(descLabel), 100, 150)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, GET_LAYOUT_WIDTH(mediaView), GET_LAYOUT_HEIGHT(mediaView))];
        imageView.image = [UIImage imageWithData:[[NSData alloc] initWithBase64Encoding:[[self.appDelegate.messageList objectAtIndex:indexPath.row] objectForKey:@"data"]]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [mediaView addSubview:imageView];
        
        if( [[[self.appDelegate.messageList objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"video"] ){
            UIImageView *videoView = [[UIImageView alloc] initWithFrame:CGRectMake((GET_LAYOUT_WIDTH(mediaView)-80)/2, (GET_LAYOUT_HEIGHT(mediaView)-80)/2, 80, 80)];
            videoView.image = [UIImage imageNamed:@"message_video"];
//            videoView.contentMode = UIViewContentModeScaleAspectFill;
//            videoView.clipsToBounds = YES;
            [mediaView addSubview:videoView];
        }
        
        messageView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, GET_LAYOUT_WIDTH(self.tableView)-20, 120)];
        [messageView addSubview:timeLabel];
        [messageView addSubview:titleLabel];
        [messageView addSubview:descLabel];
        [messageView addSubview:mediaView];
        
//        NSLog(@"%f", GET_LAYOUT_HEIGHT(timeLabel)+GET_LAYOUT_HEIGHT(titleLabel)+GET_LAYOUT_HEIGHT(descLabel)+GET_LAYOUT_HEIGHT(imageView));
    }
    
//    NSLog(@"%f", GET_LAYOUT_HEIGHT(timeLabel)+GET_LAYOUT_HEIGHT(titleLabel)+GET_LAYOUT_HEIGHT(descLabel));
    
    [cell.contentView addSubview:messageView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //    VideoDetailController *videoDetailController = [[VideoDetailController alloc] init];
    //    [self.navigationController pushViewController:videoDetailController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)getCellHeight:(long)index {
    if( [[[self.appDelegate.messageList objectAtIndex:index] objectForKey:@"type"] isEqualToString:@"image"] ){
        return IMAGE_CELL_HEIGHT;
    }else if( [[[self.appDelegate.messageList objectAtIndex:index] objectForKey:@"type"] isEqualToString:@"video"] ){
        return VIDEO_CELL_HEIGHT;
    }else{
        return TEXT_CELL_HEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
