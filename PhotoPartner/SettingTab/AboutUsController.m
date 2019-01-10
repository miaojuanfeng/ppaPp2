//
//  AboutUsController.m
//  PhotoPartner
//
//  Created by USER on 8/4/2018.
//  Copyright © 2018 MJF. All rights reserved.
//

#import "MacroDefine.h"
#import "AppDelegate.h"
#import "AboutUsController.h"

@interface AboutUsController ()
@property AppDelegate *appDelegate;
@end

@implementation AboutUsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    COMMON_MACRO;
    self.navigationItem.title = NSLocalizedString(@"aboutUsTitle", nil);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;// 字体的行间距
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16.0f], NSParagraphStyleAttributeName:paragraphStyle};
    
    UITextView *aboutUsTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, MARGIN_TOP+GAP_HEIGHT+64, GET_LAYOUT_WIDTH(self.view)-20, 200)];
    aboutUsTextView.editable = NO;
    aboutUsTextView.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"aboutUsContent", nil) attributes:attributes];
    [self.view addSubview:aboutUsTextView];
    
//    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, GET_LAYOUT_OFFSET_Y(aboutUsTextView)+GET_LAYOUT_HEIGHT(aboutUsTextView), GET_LAYOUT_WIDTH(self.view)-20, 20)];
//    versionLabel.textColor = [UIColor lightGrayColor];
//    versionLabel.textAlignment = NSTextAlignmentCenter;
//    versionLabel.text = NSLocalizedString(@"aboutUsVersion", nil);
//    versionLabel.font = [UIFont systemFontOfSize:16.0f];
//    [self.view addSubview:versionLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
