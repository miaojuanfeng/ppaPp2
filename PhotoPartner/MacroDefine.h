//
//  MacroDefinition.h
//  PhotoPartner
//
//  Created by USER on 7/3/2018.
//  Copyright © 2018 MJF. All rights reserved.
//

#ifndef MacroDefine_h
#define MacroDefine_h

#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define SET_VIEW_BACKGROUND_COLOR self.view.backgroundColor = [UIColor whiteColor]
#define GET_LAYOUT_MARGIN   float MARGIN_TOP = 0; \
                            float MARGIN_BOTTOM = 0; \
                            do{ \
                                CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame]; \
                                MARGIN_TOP = rectStatus.size.height + GET_LAYOUT_HEIGHT(self.navigationController.navigationBar); \
                                MARGIN_TOP = 0; \
                                if(IS_IPHONE_X){ \
                                    MARGIN_TOP = 20; \
                                    MARGIN_BOTTOM = 34; \
                                } \
                            }while(0)
#define GET_VIEW_WIDTH   float VIEW_WIDTH  = GET_LAYOUT_WIDTH(self.view)
#define GET_VIEW_HEIGHT  float VIEW_HEIGHT = GET_LAYOUT_HEIGHT(self.view) - MARGIN_TOP - MARGIN_BOTTOM
#define GET_VIEW_SIZE GET_VIEW_WIDTH;GET_VIEW_HEIGHT
#define GAP_WIDTH 8
#define GAP_HEIGHT GAP_WIDTH
#define GET_LAYOUT_WIDTH(v) v.frame.size.width
#define GET_LAYOUT_HEIGHT(v) v.frame.size.height
#define GET_BOUNDS_WIDTH(v) v.bounds.size.width
#define GET_BOUNDS_HEIGHT(v) v.bounds.size.height
#define GET_LAYOUT_OFFSET_X(v) v.frame.origin.x
#define GET_LAYOUT_OFFSET_Y(v) v.frame.origin.y
#define COMMON_MACRO    SET_VIEW_BACKGROUND_COLOR; \
                        GET_LAYOUT_MARGIN; \
                        GET_VIEW_SIZE

#define RGBA_COLOR(r,g,b,a) [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha: a]
#define BORDER_COLOR [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor
#define BORDER_WHITE_COLOR [UIColor whiteColor].CGColor
#define BORDER_FOCUS_COLOR RGBA_COLOR(27,163,232,1).CGColor
#define BORDER_WIDTH 1.0f

#define VIDEO_CHUNK_SIZE (1024*1024)
#define VIDEO_MAX_SIZE (50*1024*1024)
#define PHOTO_MAX_SIZE (300*1024)

#define IMAGE_PER_ROW 3
#define IMAGE_VIEW_SIZE (GET_LAYOUT_WIDTH(self.view)-GAP_WIDTH*(IMAGE_PER_ROW+1))/IMAGE_PER_ROW
#define PHOTO_NUM_HEIGHT 20
#define MAX_LIMIT_NUMS 50
#define MAX_PHOTO_COUNT 9
#define MAX_VIDEO_COUNT 1
#define INPUT_MAX_TEXT 18

#define FileHashDefaultChunkSizeForReadingData 256

#define HUD_LOADING_SHOW(t) do{ \
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES]; \
                                self.appDelegate.hudLoading.label.text = t; \
                                self.appDelegate.hudLoading.progress =  0; \
                                [self.appDelegate.hudLoading showAnimated:YES]; \
                            }while(0)
#define HUD_LOADING_PROGRESS(p) do{ \
                                self.appDelegate.hudLoading.progress = p; \
                             }while(0)
#define HUD_LOADING_HIDE do{ \
                                [self.appDelegate.hudLoading hideAnimated:YES]; \
                            }while(0)

#define HUD_WAITING_SHOW(t) do{ \
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES]; \
                                self.appDelegate.hudWaiting.label.text = t; \
                                [self.appDelegate.hudWaiting showAnimated:YES]; \
                            }while(0)
#define HUD_WAITING_HIDE    do{ \
                                [self.appDelegate.hudWaiting hideAnimated:YES]; \
                            }while(0)

#define HIDE_TOAST(t) do{   \
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES]; \
                            self.appDelegate.hudToast = [MBProgressHUD showHUDAddedTo:self.view animated:YES]; \
                            self.appDelegate.hudToast.mode = MBProgressHUDModeText; \
                            self.appDelegate.hudToast.removeFromSuperViewOnHide = YES; \
                            self.appDelegate.hudToast.detailsLabel.text = t; \
                            self.appDelegate.hudToast.bezelView.backgroundColor = [UIColor blackColor]; \
                            self.appDelegate.hudToast.contentColor = [UIColor whiteColor]; \
                      }while(0)

#define HUD_TOAST_SHOW(t) do{ \
                                HIDE_TOAST(t); \
                                [self.appDelegate.hudToast showAnimated:YES whileExecutingBlock:^{ \
                                    sleep(2); \
                                } \
                                completionBlock:^{ \
                                    [self.appDelegate.hudToast removeFromSuperview]; \
                                    self.appDelegate.hudToast = nil; \
                                }]; \
                            }while(0)

#define HUD_TOAST_POP_SHOW(t) do{ \
                                HIDE_TOAST(t); \
                                [self.appDelegate.hudToast showAnimated:YES whileExecutingBlock:^{ \
                                    sleep(2); \
                                } \
                                completionBlock:^{ \
                                    [self.appDelegate.hudToast removeFromSuperview]; \
                                    self.appDelegate.hudToast = nil; \
                                    [self.navigationController popViewControllerAnimated:YES]; \
                                }]; \
                            }while(0)

#define HUD_TOAST_PUSH_SHOW(t,c) do{ \
                                HIDE_TOAST(t); \
                                [self.appDelegate.hudToast showAnimated:YES whileExecutingBlock:^{ \
                                    sleep(2); \
                                } \
                                completionBlock:^{ \
                                    [self.appDelegate.hudToast removeFromSuperview]; \
                                    self.appDelegate.hudToast = nil; \
                                    [self.navigationController pushViewController:c animated:YES]; \
                                }]; \
                            }while(0)

#define NAV_UPLOAD_START do{ \
                            self.appDelegate.isSending = true; \
                            UPDATE_RightBarButtonItem(ICON_CANCEL); \
                         }while(0)

#define NAV_UPLOAD_END do{ \
                            self.appDelegate.isSending = false; \
                            UPDATE_RightBarButtonItem(ICON_FORWARD); \
                       }while(0)

#define DO_CLEAR_MEDIA_VIEW do{ \
                                NSArray *views = [self.mediaView subviews]; \
                                for(UIView *view in views){ \
                                    [view removeFromSuperview]; \
                                } \
                                self.mediaView.frame = CGRectMake(0, 0, GET_LAYOUT_WIDTH(self.view), IMAGE_VIEW_SIZE+2*GAP_HEIGHT); \
                            }while(0)

#define DO_FINISH_UPLOAD do{ \
                            [self.appDelegate clearProperty];   \
                            DO_CLEAR_MEDIA_VIEW; \
                            self.textView.text = @"";   \
                            self.textCountLabel.text = [NSString stringWithFormat:@"%d", MAX_LIMIT_NUMS]; \
                            [self.appDelegate saveDeviceList];  \
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];   \
                            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];   \
                            [self getMediaView:cell];   \
                            [self.tableView reloadData];    \
                         }while(0)

#define INIT_RightBarButtonItem(t,s) do{  \
                                    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];    \
                                    rightBarButton.frame = CGRectMake(0, 0, 25, 20); \
                                    if([t isEqualToString:ICON_FORWARD]){   \
                                        rightBarButton.titleLabel.font = [UIFont fontWithName:@"iconfont" size:22.0f]; \
                                    }else{  \
                                        rightBarButton.titleLabel.font = [UIFont fontWithName:@"iconfont" size:27.0f]; \
                                    }   \
                                    [rightBarButton setTitle:t forState:UIControlStateNormal];   \
                                    [rightBarButton addTarget:self action:@selector(s) forControlEvents:UIControlEventTouchUpInside]; \
                                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];  \
                                }while(0)

#define UPDATE_RightBarButtonItem(t) do{ \
                                        UIButton *rightBarButton = self.navigationItem.rightBarButtonItem.customView;   \
                                        if([t isEqualToString:ICON_FORWARD]){   \
                                            rightBarButton.titleLabel.font = [UIFont fontWithName:@"iconfont" size:22.0f]; \
                                        }else{  \
                                            rightBarButton.titleLabel.font = [UIFont fontWithName:@"iconfont" size:27.0f]; \
                                        }   \
                                        [rightBarButton setTitle:t forState:UIControlStateNormal];   \
                                    }while(0)

#define DISABLE_RightBarButtonItem do{  \
                                        UIButton *rightBarButton = self.navigationItem.rightBarButtonItem.customView;   \
                                        rightBarButton.enabled = NO; \
                                    }while(0)

#define ENABLE_RightBarButtonItem do{  \
                                        UIButton *rightBarButton = self.navigationItem.rightBarButtonItem.customView;   \
                                        rightBarButton.enabled = YES; \
                                    }while(0)

#define DO_DATA_TO_BLOCK_IF_FAILED(v) do{  \
                                        if( ![self.appDelegate doDataToBlock:v] ){ \
                                            [self.appDelegate clearProperty];   \
                                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];   \
                                            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];   \
                                            [self getMediaView:cell];   \
                                            self.textView.text = @"";   \
                                            [self.tableView reloadData];    \
                                            HUD_WAITING_HIDE;   \
                                            NAV_UPLOAD_END; \
                                            ENABLE_RightBarButtonItem; \
                                            HUD_TOAST_SHOW(NSLocalizedString(@"uploadVideoMaxSizeError", nil)); \
                                            return; \
                                        }   \
                                    }while(0)

#define BASE_URL(url) [NSString stringWithFormat:@"https://well.bsimb.cn/%@", url]

#define IMAGE_CELL_HEIGHT 250
#define VIDEO_CELL_HEIGHT IMAGE_CELL_HEIGHT
#define TEXT_CELL_HEIGHT 70

#define ICON_ADD @"\U0000e767"
#define ICON_SCAN @"\U0000e689"
#define ICON_FORWARD @"\U000f0026"
#define ICON_CANCEL @"\U0000e646"

#endif /* MacroDefine_h */
