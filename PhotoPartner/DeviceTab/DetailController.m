//
//  LoginController.m
//  PhotoPartner
//
//  Created by Dreamover on 2019/1/11.
//  Copyright © 2019年 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "DetailController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD.h>

@interface DetailController ()
@property UIScrollView *scrollView;

@property AppDelegate *appDelegate;
@end

@implementation DetailController

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
    long messageWidth = GET_LAYOUT_WIDTH(self.scrollView)-GAP_WIDTH*4;
    float fontSize = 14;
    UIColor *lineColor = [UIColor lightGrayColor];
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 60)];
        UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(infoView)/2, GET_LAYOUT_HEIGHT(infoView)/2)];
        dataLabel.text = @"Wireless Data";
        dataLabel.font = [UIFont systemFontOfSize:15];
        [infoView addSubview:dataLabel];
    
        UILabel *topUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(infoView)/2, 0, GET_LAYOUT_WIDTH(infoView)/2, GET_LAYOUT_HEIGHT(infoView)/2)];
        topUpLabel.text = @"Top Up";
        topUpLabel.textColor = [UIColor blueColor];
        topUpLabel.font = [UIFont systemFontOfSize:15];
        topUpLabel.textAlignment = NSTextAlignmentRight;
        [infoView addSubview:topUpLabel];
    
        UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(infoView)/2-5, GET_LAYOUT_WIDTH(infoView)/2, GET_LAYOUT_HEIGHT(infoView)/2)];
        totalLabel.font = [UIFont systemFontOfSize:fontSize];
        totalLabel.textColor = [UIColor grayColor];
        totalLabel.text = @"Total 10.00GB";
        [infoView addSubview:totalLabel];
    
        UILabel *avaLabel = [[UILabel alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(infoView)/2, GET_LAYOUT_HEIGHT(infoView)/2-5, GET_LAYOUT_WIDTH(infoView)/2, GET_LAYOUT_HEIGHT(infoView)/2)];
        avaLabel.font = [UIFont systemFontOfSize:fontSize];
        avaLabel.textColor = [UIColor grayColor];
        avaLabel.textAlignment = NSTextAlignmentRight;
        avaLabel.text = @"Available 9.66GB";
        [infoView addSubview:avaLabel];
    
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(infoView)-1, GET_LAYOUT_WIDTH(infoView), 1)];
        lineView.backgroundColor = lineColor;
        [infoView addSubview:lineView];
    offsetTop+=GET_LAYOUT_HEIGHT(infoView);
    self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
    [self.scrollView addSubview:infoView];
    UIView *usersView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 36)];
        UILabel *usersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(usersView), GET_LAYOUT_HEIGHT(usersView))];
        usersLabel.font = [UIFont systemFontOfSize:fontSize];
        usersLabel.text = @"Users";
        usersLabel.textColor = [UIColor blueColor];
        [usersView addSubview:usersLabel];
        UISwitch *acceptSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(usersView)-43, 5, 43, 10)];
        acceptSwitch.transform = CGAffineTransformMakeScale(0.7, 0.7);
        [acceptSwitch addTarget:self action:@selector(clickAcceptSwitch:) forControlEvents:UIControlEventValueChanged];
        [usersView addSubview:acceptSwitch];
        UILabel *acceptLabel = [[UILabel alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(acceptSwitch)-150-GAP_WIDTH, 10, 150, 20)];
        acceptLabel.textAlignment = NSTextAlignmentRight;
        acceptLabel.textColor = [UIColor blueColor];
        acceptLabel.text = @"Accept new users";
        acceptLabel.font = [UIFont systemFontOfSize:fontSize];
        [usersView addSubview:acceptLabel];
    offsetTop+=GET_LAYOUT_HEIGHT(usersView);
    self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
    [self.scrollView addSubview:usersView];
    for(int i=0;i<20;i++){
        long messageHeight = 0;
        UIView *usersView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 60)];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(usersView)-1, GET_LAYOUT_WIDTH(usersView), 1)];
        lineView.backgroundColor = lineColor;
        [usersView addSubview:lineView];
        UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 40, 40)];
        headImage.layer.masksToBounds = YES;
        headImage.layer.cornerRadius = 20;
        headImage.image = [UIImage imageNamed:@"bg_main"];
        [usersView addSubview:headImage];
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(headImage)+GET_LAYOUT_WIDTH(headImage)+GAP_WIDTH, 0, GET_LAYOUT_WIDTH(usersView)/2-GAP_WIDTH*2, GET_LAYOUT_HEIGHT(usersView))];
        usernameLabel.font = [UIFont systemFontOfSize:fontSize];
        usernameLabel.text = @"UserName";
        usernameLabel.backgroundColor = [UIColor yellowColor];
        [usersView addSubview:usernameLabel];
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(usersView)-40, 15, 30, 30)];
        //deleteButton.backgroundColor = [UIColor blueColor];
        [deleteButton addTarget:self action:@selector(clickDeleteButton) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *deleteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(deleteButton), GET_LAYOUT_HEIGHT(deleteButton))];
        deleteImageView.image = [UIImage imageNamed:@"bg_main"];
        [deleteButton addSubview:deleteImageView];
        [usersView addSubview:deleteButton];
        UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(deleteButton)-30-GAP_WIDTH*2, 15, 30, 30)];
        //deleteButton.backgroundColor = [UIColor blueColor];
        [settingButton addTarget:self action:@selector(clickSettingButton) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *settingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GET_LAYOUT_WIDTH(settingButton), GET_LAYOUT_HEIGHT(settingButton))];
        settingImageView.image = [UIImage imageNamed:@"bg_main"];
        [settingButton addSubview:settingImageView];
        [usersView addSubview:settingButton];
        messageHeight = GET_LAYOUT_HEIGHT(usersView);
   
        offsetTop+=messageHeight;
        self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
        [self.scrollView addSubview:usersView];
    }
    UILabel *newUsersLabel = [[UILabel alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 36)];
    newUsersLabel.font = [UIFont systemFontOfSize:fontSize];
    newUsersLabel.text = @"New Users";
    newUsersLabel.textColor = [UIColor blueColor];
    offsetTop+=GET_LAYOUT_HEIGHT(newUsersLabel);
    self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
    [self.scrollView addSubview:newUsersLabel];
    for(int i=0;i<20;i++){
        long messageHeight = 0;
        UIView *usersView = [[UIView alloc] initWithFrame:CGRectMake(GAP_WIDTH*2, offsetTop, messageWidth, 60)];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, GET_LAYOUT_HEIGHT(usersView)-1, GET_LAYOUT_WIDTH(usersView), 1)];
        lineView.backgroundColor = lineColor;
        [usersView addSubview:lineView];
        UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 40, 40)];
        headImage.layer.masksToBounds = YES;
        headImage.layer.cornerRadius = 20;
        headImage.image = [UIImage imageNamed:@"bg_main"];
        [usersView addSubview:headImage];
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(headImage)+GET_LAYOUT_WIDTH(headImage)+GAP_WIDTH, 0, GET_LAYOUT_WIDTH(usersView)/2-GAP_WIDTH*2, GET_LAYOUT_HEIGHT(usersView))];
        usernameLabel.font = [UIFont systemFontOfSize:fontSize];
        usernameLabel.text = @"UserName";
        usernameLabel.backgroundColor = [UIColor yellowColor];
        [usersView addSubview:usernameLabel];
        UIButton *acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_WIDTH(usersView)-60, 10, 60, 40)];
        [acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
        acceptButton.layer.masksToBounds = YES;
        acceptButton.layer.cornerRadius = 5;
        acceptButton.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        acceptButton.backgroundColor = [UIColor blueColor];
        [acceptButton addTarget:self action:@selector(clickAcceptButton) forControlEvents:UIControlEventTouchUpInside];

        [usersView addSubview:acceptButton];
        UIButton *refuseButton = [[UIButton alloc] initWithFrame:CGRectMake(GET_LAYOUT_OFFSET_X(acceptButton)-60-GAP_WIDTH, 10, 60, 40)];
        refuseButton.backgroundColor = [UIColor redColor];
        [refuseButton setTitle:@"Refuse" forState:UIControlStateNormal];
        refuseButton.layer.masksToBounds = YES;
        refuseButton.layer.cornerRadius = 5;
        refuseButton.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        [refuseButton addTarget:self action:@selector(clickRefuseButton) forControlEvents:UIControlEventTouchUpInside];

        [usersView addSubview:refuseButton];
        messageHeight = GET_LAYOUT_HEIGHT(usersView);
        
        offsetTop+=messageHeight;
        self.scrollView.contentSize = CGSizeMake(GET_LAYOUT_WIDTH(self.view), offsetTop);
        [self.scrollView addSubview:usersView];
    }
    
}

-(void)clickAcceptSwitch:(UISwitch *)swi{
    if(swi.isOn){
        NSLog(@"switch on");
    }else{
        NSLog(@"switch off");
    }
}

-(void)clickDeleteButton{
    NSLog(@"delete");
}

-(void)clickSettingButton{
    NSLog(@"setting");
}

-(void)clickRefuseButton{
    NSLog(@"refuse");
}

-(void)clickAcceptButton{
    NSLog(@"accept");
}
@end
