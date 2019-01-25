//
//  LoginController.m
//  PhotoPartner
//
//  Created by Dreamover on 2019/1/11.
//  Copyright © 2019年 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "DevicesController.h"
#import "AddDeviceController.h"
#import "AvaDeviceController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD.h>

@interface DevicesController ()
@property UIScrollView *scrollView;

@property AppDelegate *appDelegate;
@end

@implementation DevicesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    
    self.navigationItem.title = NSLocalizedString(@"deviceListNavigationItemTitle", nil);
    
    INIT_RightBarButtonItem(ICON_REFRESH, clickRefreshButton);
    
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
    long offsetTop = GAP_HEIGHT;
    long messageWidth = GET_LAYOUT_WIDTH(self.scrollView)-GAP_WIDTH*4;
    float fontSize = 14;
    UIColor *lineColor = RGBA_COLOR(200, 200, 200, 1);
 
    UIView *myDeviceView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 36)];
        UILabel *myDeviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(myDeviceView), GET_LAYOUT_HEIGHT(myDeviceView))];
        myDeviceLabel.font = [UIFont systemFontOfSize:fontSize];
        myDeviceLabel.text = NSLocalizedString(@"MyDeviceLabel", nil);
        myDeviceLabel.textColor = [UIColor blueColor];
        [myDeviceView addSubview:myDeviceLabel];
        UIButton *myDeviceButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(myDeviceView)-20, 8, 20, 20)];
        UIImageView *myDeviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0-5, 0-5, GET_LAYOUT_WIDTH(myDeviceButton)+10, GET_LAYOUT_HEIGHT(myDeviceButton)+10)];
        myDeviceImageView.image = [UIImage imageNamed:@"ic_add_blue"];
        [myDeviceButton addSubview:myDeviceImageView];
        [myDeviceButton addTarget:self action:@selector(clickAddMyDeviceButton) forControlEvents:UIControlEventTouchUpInside];
        [myDeviceView addSubview:myDeviceButton];
    
    offsetTop+=GET_LAYOUT_HEIGHT(myDeviceView);
    self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
    [self.scrollView addSubview:myDeviceView];
    for(int i=0;i<20;i++){
        long messageHeight = 0;
        UIView *devicesView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 60)];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(devicesView)-1, GET_LAYOUT_WIDTH(devicesView), 1)];
        lineView.backgroundColor = lineColor;
        [devicesView addSubview:lineView];
        UILabel *deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(devicesView), GET_LAYOUT_HEIGHT(devicesView)/2)];
        deviceLabel.text = @"Device 1";
        deviceLabel.font = [UIFont systemFontOfSize:15];
        [devicesView addSubview:deviceLabel];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(devicesView)/2-5, GET_LAYOUT_WIDTH(devicesView)/2, GET_LAYOUT_HEIGHT(devicesView)/2)];
        nameLabel.text = @"ZS5FLV";
        nameLabel.textColor = RGBA_COLOR(128, 128, 128, 1);
        nameLabel.font = [UIFont systemFontOfSize:fontSize];
        [devicesView addSubview:nameLabel];
        
        UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(devicesView)/2, GET_LAYOUT_HEIGHT(devicesView)/2-5, GET_LAYOUT_WIDTH(devicesView)/2, GET_LAYOUT_HEIGHT(devicesView)/2)];
        emailLabel.text = @"Allen@bsimb.com";
        emailLabel.textAlignment = NSTextAlignmentRight;
        emailLabel.textColor = RGBA_COLOR(128, 128, 128, 1);
        emailLabel.font = [UIFont systemFontOfSize:fontSize];
        [devicesView addSubview:emailLabel];
        
        messageHeight = GET_LAYOUT_HEIGHT(devicesView);
   
        offsetTop+=messageHeight;
        self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
        [self.scrollView addSubview:devicesView];
    }
    if(false){
        for(int i=0;i<4;i++){
            long messageHeight = 0;
            UIView *devicesView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 60)];
            
            messageHeight = GET_LAYOUT_HEIGHT(devicesView);
            
            offsetTop+=messageHeight;
            self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
            [self.scrollView addSubview:devicesView];
        }
    }
    offsetTop+=GAP_HEIGHT*4;
    UIView *boundDeviceView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 36)];
        UILabel *boundDeviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(myDeviceView), GET_LAYOUT_HEIGHT(myDeviceView))];
        boundDeviceLabel.font = [UIFont systemFontOfSize:fontSize];
        boundDeviceLabel.text = NSLocalizedString(@"AvaDeviceLabel", nil);
        boundDeviceLabel.textColor = [UIColor blueColor];
        [boundDeviceView addSubview:boundDeviceLabel];
        UIButton *boundDeviceButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(myDeviceView)-20, 8, 20, 20)];
        UIImageView *boundDeviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0-5, 0-5, GET_LAYOUT_WIDTH(myDeviceButton)+10, GET_LAYOUT_HEIGHT(myDeviceButton)+10)];
        boundDeviceImageView.image = [UIImage imageNamed:@"ic_add_blue"];
        [boundDeviceButton addSubview:boundDeviceImageView];
        [boundDeviceButton addTarget:self action:@selector(clickAddBoundDeviceButton) forControlEvents:UIControlEventTouchUpInside];
        [boundDeviceView addSubview:boundDeviceButton];
    
    offsetTop+=GET_LAYOUT_HEIGHT(boundDeviceView);
    self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
    [self.scrollView addSubview:boundDeviceView];
    for(int i=0;i<20;i++){
        long messageHeight = 0;
        UIView *devicesView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 50)];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(devicesView)-1, GET_LAYOUT_WIDTH(devicesView), 1)];
        lineView.backgroundColor = lineColor;
        [devicesView addSubview:lineView];
        UILabel *deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(devicesView), GET_LAYOUT_HEIGHT(devicesView))];
        deviceLabel.text = @"Device 1";
        deviceLabel.font = [UIFont systemFontOfSize:15];
        [devicesView addSubview:deviceLabel];
        
        messageHeight = GET_LAYOUT_HEIGHT(devicesView);
        
        offsetTop+=messageHeight;
        self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
        [self.scrollView addSubview:devicesView];
    }
    
}

-(void)clickAddMyDeviceButton{
    AddDeviceController *addDeviceController = [[AddDeviceController alloc] init];
    [self.navigationController pushViewController:addDeviceController animated:YES];
}

-(void)clickAddBoundDeviceButton{
    AvaDeviceController *avaDeviceController = [[AvaDeviceController alloc] init];
    [self.navigationController pushViewController:avaDeviceController animated:YES];
}

-(void)clickRefreshButton{
    NSLog(@"refresh");
}
@end
