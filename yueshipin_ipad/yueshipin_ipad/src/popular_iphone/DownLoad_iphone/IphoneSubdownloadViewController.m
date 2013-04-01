//
//  IphoneSubdownloadViewController.m
//  yueshipin
//
//  Created by 08 on 13-1-22.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "IphoneSubdownloadViewController.h"
#import "UIImageView+WebCache.h"
#import "DownLoadManager.h"
#import "SubdownloadItem.h"
#import "AppDelegate.h"
#import "IphoneAVPlayerViewController.h"
#import "Reachability.h"
#import "CMConstants.h"
@interface IphoneSubdownloadViewController ()

@end

@implementation IphoneSubdownloadViewController
@synthesize editButtonItem = editButtonItem_;
@synthesize doneButtonItem = doneButtonItem_;
@synthesize prodId = prodId_;
@synthesize itemArr = itemArr_;
@synthesize imageUrl = imageUrl_;
@synthesize progressArr = progressArr_;
@synthesize progressLabelArr = progressLabelArr_;
@synthesize statusImgArr = statusImgArr_;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:backGround];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"top_return_common.png"] forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton addTarget:self action:@selector(editPressed:) forControlEvents:UIControlEventTouchUpInside];
    editButton.frame = CGRectMake(0, 0, 37, 30);
    [editButton setImage:[UIImage imageNamed:@"download_edit.png"] forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"download_edit_s.png"] forState:UIControlStateHighlighted];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    editButtonItem_ = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem = editButtonItem_;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
    doneButton.frame = CGRectMake(0, 0, 37, 30);
    [doneButton setImage:[UIImage imageNamed:@"download_done.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"download_done_s.png"] forState:UIControlStateHighlighted];
    [doneButton setTitle:@"done" forState:UIControlStateNormal];
    doneButtonItem_ = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    
    //初始化数据
    [self initData];
    
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 0, 320, kCurrentWindowHeight)];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gmGridView];
    gMGridView_ = gmGridView;
    
    NSInteger spacing = 5;
    gMGridView_.style = GMGridViewStyleSwap;
    gMGridView_.itemSpacing = spacing;
    gMGridView_.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    gMGridView_.centerGrid = NO;
    gMGridView_.actionDelegate = self;
    gMGridView_.dataSource = self;
    gMGridView_.mainSuperView = self.view;
    
    downLoadManager_ = [AppDelegate instance].downLoadManager;
    downLoadManager_.downLoadMGdelegate = self;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
}

-(void)initData{
    progressArr_ = [NSMutableArray arrayWithCapacity:5];
    progressLabelArr_ = [NSMutableArray arrayWithCapacity:5];
    statusImgArr_ = [NSMutableArray arrayWithCapacity:5];
    itemArr_ = [NSMutableArray arrayWithCapacity:5];
    NSArray *items = [SubdownloadItem allObjects];
    for (SubdownloadItem *item in items) {
        if ([item.subitemId hasPrefix:prodId_]) {
            [itemArr_ addObject:item];
        }
    }
}
-(void)reloadDataSource{
    [self initData];
    [gMGridView_ reloadData];
}

-(void)downloadBeginwithId:(NSString *)itemId inClass:(NSString *)className{
   
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]){
        
        [self reloadDataSource];
        return;
        NSString *query = [NSString stringWithFormat:@"WHERE subitem_id ='%@'",itemId];
        NSArray *itemArr = [SubdownloadItem findByCriteria:query];
        
        int percet = 0;
        if ([itemArr count] >0) {
            percet = ((SubdownloadItem *)[itemArr objectAtIndex:0]).percentage;
        }
       
        NSArray *arr = [itemId componentsSeparatedByString:@"_"];
        int num = [[arr objectAtIndex:0] intValue]*10+[[arr objectAtIndex:1] intValue];
        for (UILabel *label in progressLabelArr_) {
            if (label.tag == num) {
                label.text = [NSString stringWithFormat:@"已下载:%i%%",percet];
                break;
                
            }
            
        }
        for (UIImageView *imgV in statusImgArr_) {
            if (imgV.tag == num) {
                imgV.image = [UIImage imageNamed:@"download_loading.png"];
                break;
            }
        }
        
        for (UIProgressView *proV in progressArr_) {
            if (proV.tag == num) {
               proV.progress = percet/100.0;
                break;
            }
        }
        
      
    }
    
}


- (void)reFreshProgress:(double)progress withId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]) {
        float value = (float)progress;
        NSArray *arr = [itemId componentsSeparatedByString:@"_"];
        int num = [[arr objectAtIndex:0] intValue]*10+[[arr objectAtIndex:1] intValue];
        for (UIProgressView *progress in progressArr_) {
            if (progress.tag == num) {
                [progress setProgress:value];
                break;
            }
        }
        int progressValue = (int)(100*value);
        for (UILabel *label in progressLabelArr_) {
            if (label.tag == num) {
                if (progressValue == 100) {
                   // label.text = [NSString stringWithFormat:@"下载完成"];
                }
                else{
                    label.text = [NSString stringWithFormat:@"已下载:%i%%",progressValue];
                }
                break;
            }
        }

    }
    
}
- (void)downloadFailedwithId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]){
         [self reloadDataSource];
    }
}

-(void)downloadUrlTnvalidWithId:(NSString *)itemId inClass:(NSString *)className{
    
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]){
        [self reloadDataSource];
    }
}

-(void)downloadFinishwithId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]){
        
        [self reloadDataSource];
    }
    
}
-(void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)editPressed:(id)sender{
    gMGridView_.editing = YES;
    self.navigationItem.rightBarButtonItem = doneButtonItem_;
}

-(void)donePressed:(id)sender{
    gMGridView_.editing = NO;
    self.navigationItem.rightBarButtonItem = editButtonItem_;
}


- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView{
    return [itemArr_ count];
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView{
    return CGSizeMake(100, 140);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index{
    SubdownloadItem *downloadItem = [itemArr_ objectAtIndex:index];
    CGSize size = [self sizeForItemsInGMGridView:gridView];
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-3, -3);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor clearColor];
        cell.contentView = view;
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_detailed_picture_bg"]];
    frame.frame = CGRectMake(15, 15, 71, 104);
    [cell.contentView addSubview:frame];
    
    UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(17, 17, 67, 99)];
    [contentImage setImageWithURL:imageUrl_];
    [cell.contentView addSubview:contentImage];
    
    NSString *numStr = [[downloadItem.subitemId componentsSeparatedByString:@"_"] lastObject];
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(11, 123, 78, 15)];
    nameLbl.font = [UIFont systemFontOfSize:13];
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.textAlignment = NSTextAlignmentCenter;
    nameLbl.lineBreakMode = UILineBreakModeTailTruncation;
    nameLbl.numberOfLines = 0;
    if (downloadItem.type == 2) {
     
        NSString *sub_name = [[downloadItem.subitemId componentsSeparatedByString:@"_"] objectAtIndex:1];
        int num = [sub_name intValue];
        nameLbl.text = [NSString stringWithFormat:@"第%d集",num];
    }
    else if (downloadItem.type == 3){
        nameLbl.text =  [[downloadItem.name componentsSeparatedByString:@"_"] lastObject];
    }
    if ([nameLbl.text length]>5) {
        nameLbl.frame = CGRectMake(11, 123, 78, 30);
    }
    
    nameLbl.textColor = [UIColor blackColor];
    [cell.contentView addSubview:nameLbl];
    
    UILabel *labelDown = [[UILabel alloc] initWithFrame:CGRectMake(17, 101, 67, 15)];
    labelDown.textColor = [UIColor whiteColor];
    labelDown.backgroundColor = [UIColor blackColor];
    labelDown.alpha = 0.6;
    labelDown.textAlignment = NSTextAlignmentCenter;
    labelDown.font = [UIFont systemFontOfSize:10];
    
    
    UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 16, 67, 15)];
    progressLabel.textColor = [UIColor whiteColor];
    progressLabel.tag = 10*[downloadItem.itemId intValue]+[numStr intValue];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    progressLabel.backgroundColor = [UIColor blackColor];
    progressLabel.alpha = 0.6;
    progressLabel.font = [UIFont systemFontOfSize:10];
    [progressLabelArr_ addObject:progressLabel];
    
    UIImageView *statusImg = [[UIImageView alloc] initWithFrame:CGRectMake(17, 15, 44, 44)];
    statusImg.tag = 10*[downloadItem.itemId intValue]+[numStr intValue];
    statusImg.center = CGPointMake(cell.contentView.center.x, cell.contentView.center.y-10);
    [statusImgArr_ addObject:statusImg];
    [cell.contentView addSubview:statusImg];
    
    UIProgressView *progressView = nil;
    if(![downloadItem.downloadStatus isEqualToString:@"finish"]){
        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.frame = CGRectMake(20, 107, 62, 10);
        progressView.tag = 10*[downloadItem.itemId intValue]+[numStr intValue];
        progressView.progress = downloadItem.percentage/100.0;
        progressView.progressTintColor = [UIColor colorWithRed:62/255.0 green:138/255.0 blue:238/255.0 alpha:1];
        [progressArr_ addObject:progressView];
    }
    
    if([downloadItem.downloadStatus isEqualToString:@"loading"]||[downloadItem.downloadStatus isEqualToString:@"fail"]){
        statusImg.image = [UIImage imageNamed:@"download_loading.png"];
        progressLabel.text = [NSString stringWithFormat:@"已下载:%i%%",downloadItem.percentage];
        [cell.contentView addSubview:progressView];
        [cell.contentView addSubview:progressLabel];
        
    } else if([downloadItem.downloadStatus isEqualToString:@"stop"]){
        statusImg.image = [UIImage imageNamed:@"download_stop.png"];
        progressLabel.text = [NSString stringWithFormat:@"下载至:%i%%", downloadItem.percentage];
        labelDown.text = @"暂停";
        [cell.contentView addSubview:labelDown];
        
        if (downloadItem.percentage > 0) {
            [cell.contentView addSubview:progressLabel];
        }
   
    } else if([downloadItem.downloadStatus isEqualToString:@"finish"]){
        progressLabel.text = @"";
        
    } else if([downloadItem.downloadStatus isEqualToString:@"waiting"]){
        statusImg.image = [UIImage imageNamed:@"download_wait.png"];
        progressLabel.text = [NSString stringWithFormat:@"已下载:%i%%", downloadItem.percentage];
        labelDown.text = @"等待下载...";
        [cell.contentView addSubview:labelDown];
        if (downloadItem.percentage > 0) {
            [cell.contentView addSubview:progressLabel];
        }
    
    }
    else if([downloadItem.downloadStatus isEqualToString:@"fail_1011"]){
        labelDown.text = @"下载片源失效";
        [cell.contentView addSubview:labelDown];
    }
    return cell;
}


- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index{
    if (index >= [itemArr_ count]) {
        return;
    }
    
    [itemArr_ removeObjectAtIndex:index];
    NSString *query = [NSString stringWithFormat:@"WHERE item_id ='%@'",prodId_];
    NSArray *arr = [SubdownloadItem findByCriteria:query];
    SubdownloadItem *item = [arr objectAtIndex:index];
    NSString *itemId = item.subitemId;
    [DownLoadManager stopAndClear:itemId];
    
    NSString *fileName = [itemId stringByAppendingString:@".mp4"];
    //对于错误信息
    NSError *error;
    // 创建文件管理器
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //指向文件目录
    NSString *documentsDirectory= [NSHomeDirectory()
                                   stringByAppendingPathComponent:@"Documents"];
    
    
    NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    if ([item.fileName hasSuffix:@"m3u8"]) {
        NSString *deleteFilePath = [documentsDirectory stringByAppendingPathComponent:item.itemId];
        [fileMgr removeItemAtPath:deleteFilePath error:&error];
    }
    else{
        for (NSString *nameStr in fileList) {
            if ([nameStr hasPrefix:fileName]) {
                NSString *deleteFilePath = [documentsDirectory stringByAppendingPathComponent:nameStr];
                [fileMgr removeItemAtPath:deleteFilePath error:&error];
                break;
            }
        }
    }

    [item deleteObject];
    
    NSArray *tempArr = [SubdownloadItem findByCriteria:query];
    
    if ([tempArr count] == 0){
        NSString *subquery = [NSString stringWithFormat:@"WHERE item_id ='%@'",prodId_];
        NSArray *itemArr = [DownloadItem findByCriteria:subquery];
        for (DownloadItem *downloadItem in itemArr) {
            [downloadItem deleteObject];
        }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DELETE_ALL_SUBITEMS_MSG" object:nil];
    }

}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position{
    
    if (position >= [itemArr_ count]) {
        return;
    }
    SubdownloadItem *downloadItem = [itemArr_ objectAtIndex:position];
    if ([downloadItem.downloadStatus isEqualToString:@"finish"]) {
        NSString *fileName = [downloadItem.subitemId stringByAppendingString:@".mp4"];
        NSError *error;
        // 创建文件管理器
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        //指向文件目录
        NSString *documentsDirectory= [NSHomeDirectory()
                                       stringByAppendingPathComponent:@"Documents"];
        NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
        
        NSString *playPath = nil;
        if (![downloadItem.downloadType isEqualToString:@"m3u8"]) {
            for (NSString *str in fileList) {
                if ([str isEqualToString:fileName]) {
                    playPath = [documentsDirectory stringByAppendingPathComponent:str];
                    break;
                }
            }
        }
        else{
            [[AppDelegate instance] startHttpServer];
            NSString *idStr = downloadItem.subitemId ;
            NSArray *tempArr =  [idStr componentsSeparatedByString:@"_"];
            playPath =[NSString stringWithFormat:@"%@/%@/%@/%@.m3u8",LOCAL_HTTP_SERVER_URL,downloadItem.itemId,idStr,[tempArr objectAtIndex:1]];
        }
        if (playPath) {
            IphoneAVPlayerViewController *iphoneAVPlayerViewController = [[IphoneAVPlayerViewController alloc] init];
            iphoneAVPlayerViewController.local_file_path = playPath;
            if ([downloadItem.downloadType isEqualToString:@"m3u8"]){
              iphoneAVPlayerViewController.isM3u8 = YES;
              iphoneAVPlayerViewController.playDuration = downloadItem.duration;
              iphoneAVPlayerViewController.lastPlayTime = CMTimeMake(1, NSEC_PER_SEC);
            }
            iphoneAVPlayerViewController.islocalFile = YES;
            if (downloadItem.type == 2) {
                NSString *name = [[downloadItem.name componentsSeparatedByString:@"_"] objectAtIndex:0];
                NSString *sub_name = [[downloadItem.name componentsSeparatedByString:@"_"] objectAtIndex:1];
                int num = [sub_name intValue];
                iphoneAVPlayerViewController.nameStr = [NSString stringWithFormat:@"%@ 第%d集",name,++num];
            }
            else if (downloadItem.type == 3){
                iphoneAVPlayerViewController.nameStr =  [[downloadItem.name componentsSeparatedByString:@"_"] lastObject];
            }
            [self presentViewController:iphoneAVPlayerViewController animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"未找到影片" delegate:self
                                                  cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
            [alert show];
        }

    }
   else if ([downloadItem.downloadStatus isEqualToString:@"waiting"] || [downloadItem.downloadStatus isEqualToString:@"loading"]) {
       Reachability *hostReach = [Reachability reachabilityForInternetConnection];
       if([hostReach currentReachabilityStatus] == NotReachable){
           
           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络中断，请检查您的网络。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
           [alert show];
           return;
       }
       
        downloadItem.downloadStatus = @"stop";
        [downloadItem save];
        [DownLoadManager stop:downloadItem.subitemId];
       
       NSArray *arr = [downloadItem.subitemId componentsSeparatedByString:@"_"];
       int num = [[arr objectAtIndex:0] intValue]*10+[[arr objectAtIndex:1] intValue];
       for (UILabel *label in progressLabelArr_) {
           if (label.tag == num) {
               label.text =  [NSString stringWithFormat:@"下载至:%i%%", downloadItem.percentage];
               break;
           }
       }
       
       for (UIImageView *imgV in statusImgArr_) {
           if (imgV.tag == num) {
                      imgV.image = [UIImage imageNamed:@"download_stop.png"];
                      break;
                  }
            }
       
       for (UIProgressView *progressView in progressArr_) {
           if (progressView.tag == num) {
               progressView.progress = downloadItem.percentage/100.0;
               break;
           }
           
       }

       [self reloadDataSource];
    }
    else if ([downloadItem.downloadStatus isEqualToString:@"stop"]||[downloadItem.downloadStatus isEqualToString:@"fail"]){
        Reachability *hostReach = [Reachability reachabilityForInternetConnection];
        if([hostReach currentReachabilityStatus] == NotReachable){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络中断，请检查您的网络。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        downloadItem.downloadStatus = @"waiting";
        [downloadItem save];
       
        
        NSArray *arr = [downloadItem.subitemId componentsSeparatedByString:@"_"];
        int num = [[arr objectAtIndex:0] intValue]*10+[[arr objectAtIndex:1] intValue];
        for (UILabel *label in progressLabelArr_) {
            if (label.tag == num) {
                label.text =  [NSString stringWithFormat:@"已下载:%i%%", downloadItem.percentage];
                break;
            }
        }
        for (UIImageView *imgV in statusImgArr_) {
            if (imgV.tag == num) {
                imgV.image = [UIImage imageNamed:@"download_wait.png"];
                break;
            }
        }
        for (UIProgressView *progressView in progressArr_) {
            if (progressView.tag == num) {
                progressView.progress = downloadItem.percentage/100.0;
                break;
            }
            
        }
     [DownLoadManager continueDownload:downloadItem.subitemId];
     [self reloadDataSource];
    }


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
