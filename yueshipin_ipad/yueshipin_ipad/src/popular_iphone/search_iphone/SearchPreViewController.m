//
//  SearchPreViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-27.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SearchPreViewController.h"
#import "IphoneSearchViewController.h"
#import "UIImage+Scale.h"
@interface SearchPreViewController ()

@end

@implementation SearchPreViewController
@synthesize searchBar = searchBar_;
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
    self.title = @"搜索";
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:bg];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"top_return_common.png"] forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
	// Do any additional setup after loading the view.
    searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar_.tintColor = [UIColor whiteColor];
    searchBar_.placeholder = @"电影/电视剧/综艺";
    UITextField *searchField;
    NSUInteger numViews = [searchBar_.subviews count];
    for(int i = 0; i < numViews; i++) {
        if([[searchBar_.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            searchField = [searchBar_.subviews objectAtIndex:i];
        }
    }
    if(!(searchField == nil)) {
        [searchField.leftView setHidden:YES];
        [searchField setBackground: [UIImage imageNamed:@"my_search_sou_suo_kuang.png"] ];
        [searchField setBorderStyle:UITextBorderStyleNone];
    }
    searchBar_.delegate = self;
    [self.view addSubview:searchBar_];
}

-(void)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    IphoneSearchViewController *searchViewController = [[IphoneSearchViewController alloc] init];
    searchViewController.keyWords = searchBar_.text;
    [self.navigationController pushViewController:searchViewController animated:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
