//
//  AllViewController_iPad.m
//  Oznoz
//
//  Created by Tony Stark on 2/5/13.
//  Copyright (c) 2013 Oznoz Entertainment, LLC. All rights reserved.
//

#import "AllViewController_iPad.h"
#import "AppDelegate.h"
#import "WPReachability.h"
#import "Brand.h"
#import "Constants.h"
#import "ToolBar.h"
#import "GMGridViewLayoutStrategies.h"
#import "AboutViewController.h"
#import "ResultsViewController_iPad.h"
#import "AgeFilterViewController.h"
#import "LanguagesViewController.h"
#import "EpisodeViewController_iPad.h"
#import "ModalLoginViewController_iPad.h"
#import "GridViewCell_iPad.h"
#import "MyStuffViewController_iPad.h"
#import "EpisodeViewController_iPad.h"
#import "AllViewController_iPad.h"
#import "FeaturedViewController_iPad.h"

#import "UIDevice-Hardware.h"

@interface AllViewController_iPad ()

@end

@implementation AllViewController_iPad
@synthesize HUD,filterbar,gridView,PageSize,apiPaginator,footerLabel,activityIndicator,popoverController,datasource,onoffSub;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        PageSize=12;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIView setAnimationsEnabled:NO];

    [[NSUserDefaults standardUserDefaults] setValue:@"All" forKey:@"filter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    onoffSub = [[NSUserDefaults standardUserDefaults] valueForKey:@"oznoztv_only_subscription"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_toolbar_ios7.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    UIInterfaceOrientation toInterfaceOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    switch(toInterfaceOrientation){
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            PageSize=12;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            PageSize=10;
            break;
        default:
            if ([[UIScreen mainScreen] bounds].size.height == 1004 ) {
                PageSize=10;
            }
            if ([[UIScreen mainScreen] bounds].size.height == 911 ) {
                PageSize=10;
            }
            if ([[UIScreen mainScreen] bounds].size.height == 655 ) {
                PageSize=12;
            }
            if ([[UIScreen mainScreen] bounds].size.height == 1024 ) {
                PageSize=10;
            }
            if (self.view.bounds.size.width == 768 && self.view.bounds.size.height== 1004 ) {
                PageSize=12;
            }
            break;
    }
    if([[UIDevice currentDevice] platformType]!=UIDevice1GiPad){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    [self reloadDatabase];
    self.title=@"All";
    CGSize lblTitleSize = [@"All" sizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:CGSizeMake(300,28) lineBreakMode:nil];
    
    lbNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,0,lblTitleSize.width,40)];
    //lbNavTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lbNavTitle.textAlignment = UITextAlignmentCenter;
    lbNavTitle.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue: 102/255.0 alpha:1];
    lbNavTitle.backgroundColor = [UIColor clearColor];
    lbNavTitle.font = [UIFont systemFontOfSize:20];
    lbNavTitle.text = @"All";
    self.navigationItem.titleView = lbNavTitle;
    
    filterbar = [[FilterBar_iPad alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,40) delegateWith:self];
    filterbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    filterbar.backgroundColor=[UIColor whiteColor];
    filterbar.layer.zPosition=1000;
    [self.view addSubview:filterbar];
    
    gridView = [[GMGridView alloc] initWithFrame:CGRectMake(5,50, self.view.bounds.size.width,self.view.bounds.size.height-50-self.navigationController.navigationBar.frame.size.height)];
    
    gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gridView.backgroundColor = [UIColor whiteColor];
    gridView.layer.zPosition=0;
    
    [self.view addSubview:gridView];
    
    gridView.style = GMGridViewStyleSwap;
    gridView.itemSpacing = 2;
    gridView.minEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    gridView.centerGrid = NO;
    gridView.actionDelegate = self;
    gridView.dataSource = self;
    gridView.delegate = self;
    gridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)orientationChanged:(NSNotification *)dict
{
    if([[UIDevice currentDevice] getMemoryUse]>1.55){
        NSLog(@"Exit app here, Virtual mem: %f GB",[[UIDevice currentDevice] getMemoryUse]);
        exit(0);
    }
    UIInterfaceOrientation toInterfaceOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    switch(toInterfaceOrientation){
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            PageSize=12;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            PageSize=10;
            break;
        default:
            if ([[UIScreen mainScreen] bounds].size.height == 1004 ) {
                PageSize=10;
            }
            if ([[UIScreen mainScreen] bounds].size.height == 911 ) {
                PageSize=10;
            }
            if ([[UIScreen mainScreen] bounds].size.height == 655 ) {
                PageSize=12;
            }
            if ([[UIScreen mainScreen] bounds].size.height == 1024 ) {
                PageSize=10;
            }
            if (self.view.bounds.size.width == 768 && self.view.bounds.size.height== 1004 ) {
                PageSize=12;
            }
            break;
    }
    filterbar.frame= CGRectMake(0, 0, self.view.frame.size.width,40);
    [gridView reloadData];
    [self.filterbar refeshView:filter];

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    // [self setupTableViewFooter];
    switch(toInterfaceOrientation){
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            PageSize=12;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            PageSize=10;
            break;
        default:
            if ([[UIScreen mainScreen] bounds].size.height == 1004 ) {
                PageSize=10;
            }
            if ([[UIScreen mainScreen] bounds].size.height == 911 ) {
                PageSize=10;
            }
            if ([[UIScreen mainScreen] bounds].size.height == 655 ) {
                PageSize=12;
            }
            if ([[UIScreen mainScreen] bounds].size.height == 1024 ) {
                PageSize=10;
            }
            if (self.view.bounds.size.width == 768 && self.view.bounds.size.height== 1004 ) {
                PageSize=12;
            }
            break;
    }
    filterbar.frame= CGRectMake(0, 0, self.view.frame.size.width,40);
    [filterbar refeshView:filter];
    [gridView reloadData];
    return YES;
}


- (BOOL)shouldAutorotate {
    //  NSLog(@"2");
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    // NSLog(@"3");
    return UIInterfaceOrientationMaskAll;
}
-(void) viewWillAppear:(BOOL)animated
{
    self.title=@"All";
    if([[UIDevice currentDevice] getMemoryUse]>1.55){
        NSLog(@"Exit app here, Virtual mem: %f GB",[[UIDevice currentDevice] getMemoryUse]);
        exit(0);
    }

    if([self.datasource count]==0 || ![[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"] isEqualToString:@"All"]|| ![[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_age"] isEqualToString:@"All"]||
       [onoffSub isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"oznoztv_only_subscription"]]==NO){
        onoffSub = [[NSUserDefaults standardUserDefaults] valueForKey:@"oznoztv_only_subscription"];
       [self reloadLoadingView];
    }
    self.tabBarController.tabBar.hidden = FALSE;
}
- (void)reloadLoadingView{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view addSubview:HUD];
	HUD.delegate = self;
    [HUD showWhileExecuting:@selector(reloadDatabase) onTarget:self withObject:nil animated:YES];
}
- (void)reloadDatabaseUpdated{
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"filter"] isEqualToString:@"All"]) {
        [[dbCore sharedInstance] getBrandsByFilter:[[NSUserDefaults standardUserDefaults] objectForKey:@"filter"]];
        self.datasource=[dbCore sharedInstance].brands;
        [filterbar refeshView:[[NSUserDefaults standardUserDefaults] objectForKey:@"filter"]];
    }else{
        [[dbCore sharedInstance] getBrandList];
        self.datasource=[dbCore sharedInstance].brands;
        [filterbar refeshView:@"All"];
    }
    [gridView reloadData];
    [[dbCore sharedInstance].brands  release];
}
- (void)reloadDatabaseReset{
   /* if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"filter"] isEqualToString:@"All"]) {
        [[dbCore sharedInstance] getBrandsByFilter:[[NSUserDefaults standardUserDefaults] objectForKey:@"filter"]];
        self.datasource=[dbCore sharedInstance].brands;
        [filterbar refeshView:[[NSUserDefaults standardUserDefaults] objectForKey:@"filter"]];
    }else{*/
        [[dbCore sharedInstance] getBrandList];
        self.datasource=[dbCore sharedInstance].brands;
        [filterbar refeshView:@"All"];
  //  }
    [gridView reloadData];
}
- (void)reloadDatabase{
    if (![[[UIDevice currentDevice] platformString] isEqualToString:@"iPad 1G"])
    {
        [self addToolBar];
    }else{
        [self addToolBar];
    }
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"filter"] isEqualToString:@"All"]) {
        [[dbCore sharedInstance] getBrandsByFilter:[[NSUserDefaults standardUserDefaults] objectForKey:@"filter"]];
        self.datasource=[dbCore sharedInstance].brands;
        [filterbar refeshView:[[NSUserDefaults standardUserDefaults] objectForKey:@"filter"]];
    }else{
        [[dbCore sharedInstance] getBrandList];
        self.datasource=[dbCore sharedInstance].brands;
        [filterbar refeshView:@"All"];
    }
    [gridView reloadData];
    [[dbCore sharedInstance].brands  release];
}/*
  #pragma mark - Pager
  - (void)fetchNextPage
  {
  [self.apiPaginator goNextPage:0 withVolume:0];
  [self.activityIndicator startAnimating];
  }
  - (void)setupTableViewFooter
  {
  int _width=[[UIScreen mainScreen] applicationFrame].size.width;
  UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
  switch(interfaceOrientation){
  case UIInterfaceOrientationPortrait:
  case UIInterfaceOrientationPortraitUpsideDown:
  break;
  case UIInterfaceOrientationLandscapeLeft:
  case UIInterfaceOrientationLandscapeRight:
  _width=[[UIScreen mainScreen] applicationFrame].size.height;
  break;
  default:
  if (self.view.bounds.size.width==768) {
  _width=self.view.bounds.size.width;
  }
  if (self.view.bounds.size.width==1024) {
  _width=self.view.bounds.size.width;
  }
  if (self.view.bounds.size.width==768 && self.view.bounds.size.height==1004) {
  _width=self.view.bounds.size.width;
  }
  break;
  }
  // set up label
  UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _width, 44)];
  footerView.backgroundColor = [UIColor clearColor];
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _width, 44)];
  label.font = [UIFont boldSystemFontOfSize:16];
  label.textColor = [UIColor lightGrayColor];
  label.textAlignment = UITextAlignmentCenter;
  
  self.footerLabel = label;
  self.footerLabel.frame=CGRectMake(0, 0, _width, 44);
  [footerView addSubview:label];
  
  // set up activity indicator
  UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  activityIndicatorView.center = CGPointMake(_width/2-11, 22);
  activityIndicatorView.hidesWhenStopped = YES;
  
  self.activityIndicator = activityIndicatorView;
  [footerView addSubview:activityIndicatorView];
  
  
  }
  
  - (void)updateTableViewFooter
  {
  if (self.apiPaginator.total > PageSize && ![self.apiPaginator reachedLastPage])
  {
  self.footerLabel.text = [NSString stringWithFormat:@""];
  } else
  {
  self.footerLabel.text = @"";
  [self.activityIndicator stopAnimating];
  }
  
  [self.footerLabel setNeedsDisplay];
  }
  #pragma mark - Paginator delegate methods
  
  - (void)paginator:(id)paginator didReceiveResults:(NSMutableArray *)results
  {
  
  [self.activityIndicator stopAnimating];
  @try {
  
  NSInteger j = [self.apiPaginator.results count] - [results count];
  if([results count]>0){
  for(NSArray *result in results)
  {
  [gridView insertObjectAtIndex:j++ withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
  }
  }
  }
  @catch (NSException * e) {
  NSLog(@"Exception: %@", e);
  }
  @finally {
  // NSLog(@"finally");
  }
  //[self.gridView reloadData];
  [self updateTableViewFooter];
  
  }
  
  - (void)paginatorDidReset:(id)paginator
  {
  [self.gridView reloadData];
  [self updateTableViewFooter];
  }
  
  - (void)paginatorDidFailToRespond:(id)paginator
  {
  // Todo
  }
  #pragma mark - UIScrollViewDelegate Methods
  
  - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
  
  if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height)
  {
  if(![self.apiPaginator reachedLastPage])
  {
  // [self fetchNextPage];
  // [gridView reloadData];
  }
  }
  
  
  }*/

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self.datasource count];
    
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    switch(orientation){
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown://NSLog(@"dung");
            return CGSizeMake(187,265);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight://NSLog(@"ngang");
            return CGSizeMake(202,265);
            break;
    }
    //return CGSizeMake(185,300);
    
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gmGridView cellForItemAtIndex:(NSInteger)index
{
    //static NSString * PlainCellIdentifier = @"PlainCellIdentifier";
        
    if (index<[self.datasource count]&&[self.datasource count]>0) {
        GMGridViewCell *cell = [gmGridView dequeueReusableCell];
        if ( !cell ) {
            CGSize size = [self GMGridView:gmGridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
            cell = [[GMGridViewCell alloc] init];
            cell.contentView = [[Cell_iPad alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) withInfo:[self.datasource objectAtIndex:index]];
        }
        [(Cell_iPad *)cell.contentView setData:[self.datasource objectAtIndex:index]];
        return cell;
    }
    return nil;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    
    if(position<[self.datasource count]){
        Brand *info = (Brand *)[self.datasource objectAtIndex:position];
        NSArray *_viewControllers = [[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers];
        for(UIViewController *view in _viewControllers) {
            if([view isKindOfClass:[EpisodeViewController_iPad class]])
            {
                [view removeFromParentViewController];
            }
        }
        EpisodeViewController_iPad *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EPISODE_VIEW"];
        vc.type=@"all";
        if(info.property_id>0){
            vc.brand_id=info.property_id;
            vc.volume_id = info.brandsId;
        }else{
            vc.volume_id = 0;
            vc.brand_id = info.brandsId;
        }
        vc.brand = info;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

#pragma mark - filterbar
-(IBAction)changePageClick:(id)sender
{
    UIButton *btnAlpha = (UIButton *) sender;

    [[NSUserDefaults standardUserDefaults] setValue:btnAlpha.titleLabel.text forKey:@"filter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadDatabase];
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"filteralpha"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void) addToolBar
{
    ToolBar *tools = [[ToolBar alloc] initWithFrame:CGRectMake(0,0, 300, 45)];
    
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSString *LanguagesTitle=@"All Languages";
    UIImage *bg_filter = [UIImage imageNamed:@"border_gray_ios7.png"];
    UIColor *color=[UIColor colorWithRed:102/255.0 green:102/255.0 blue: 102/255.0 alpha:1];
    
    //UIColor *color=[UIColor whiteColor];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"] length] > 0 ) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"] isEqualToString:@"All"]) {
            LanguagesTitle=@"All Languages";
            
        }else
        {
            color=[UIColor whiteColor];
            //color=[UIColor colorWithRed:237/255.0 green:0/255.0 blue:140/255.0 alpha:1];
            LanguagesTitle=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"]];
            bg_filter = [UIImage imageNamed:@"border_red_ios7.png"];
        }
    }
    CGSize lblTitleSize = [LanguagesTitle sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(300,28) lineBreakMode:nil];
    
    UIButton *btnLanguages = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLanguages.userInteractionEnabled = YES;
    [btnLanguages setFrame:CGRectMake(5,0.0, (lblTitleSize.width<70)?100:(lblTitleSize.width+20), 28.0)];
    [btnLanguages setBackgroundImage:bg_filter forState:UIControlStateNormal];
    [btnLanguages setTitle:LanguagesTitle forState: UIControlStateNormal];
    btnLanguages.titleLabel.font = [UIFont systemFontOfSize:12];
    [btnLanguages setTitleColor:color forState:UIControlStateNormal];
    UITapGestureRecognizer *tappedLanguages = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(languagesClick:)];
    tappedLanguages.numberOfTapsRequired = 1;
    [btnLanguages addGestureRecognizer:tappedLanguages];
    [btnLanguages setNeedsDisplay];
    UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithCustomView:btnLanguages];
    [buttons addObject:bi];
    
    bg_filter = [UIImage imageNamed:@"border_gray_ios7.png"];
    //color=[UIColor colorWithRed:177/255.0 green:181/255.0 blue: 193/255.0 alpha:1];
    color=[UIColor colorWithRed:102/255.0 green:102/255.0 blue: 102/255.0 alpha:1];
    NSString *ageTitle=@"Select Age";
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_age"] length] > 0 ) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_age"] isEqualToString:@"All"]) {
            ageTitle=@"Select Age";
        }else
        {
            color=[UIColor whiteColor];
            //color=[UIColor colorWithRed:237/255.0 green:0/255.0 blue:140/255.0 alpha:1];
            ageTitle=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_age"]];
            bg_filter = [UIImage imageNamed:@"border_red_ios7.png"];
        }
    }
    lblTitleSize = [ageTitle sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(200,28) lineBreakMode:nil];
    UIButton *btnAgeFilter = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAgeFilter.userInteractionEnabled = YES;
    [btnAgeFilter setFrame:CGRectMake(0.0,0.0, (lblTitleSize.width<70)?100:(lblTitleSize.width), 28.0)];
    [btnAgeFilter setBackgroundImage:bg_filter forState:UIControlStateNormal];
    [btnAgeFilter setTitle:ageTitle forState: UIControlStateNormal ];
    btnAgeFilter.titleLabel.font = [UIFont systemFontOfSize:12];
    [btnAgeFilter setTitleColor:color forState:UIControlStateNormal];
    UITapGestureRecognizer *tappedAgeFilter = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ageFilterClick:)];
    tappedAgeFilter.numberOfTapsRequired = 1;
    [btnAgeFilter addGestureRecognizer:tappedAgeFilter];
    [btnAgeFilter setNeedsDisplay];
    bi = [[UIBarButtonItem alloc] initWithCustomView:btnAgeFilter];
    bi.tintColor=color;
    [buttons addObject:bi];
    
    UIImageView *imgSearch = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_search_ios7.png"]];
    [imgSearch setFrame:CGRectMake(0, 0, 20, 20)];
    UITapGestureRecognizer *tappedSearch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchClick:)];
    tappedSearch.numberOfTapsRequired = 1;
    [imgSearch addGestureRecognizer:tappedSearch];
    
    bi = [[UIBarButtonItem alloc] initWithCustomView:imgSearch];
    //bi.width=20;
    [buttons addObject:bi];
    
    UIImageView *imgMore = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_setting_ios7.png"]];
    [imgMore setFrame:CGRectMake(0, 0, 20, 20)];
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(settingList:)];
    tapped.numberOfTapsRequired = 1;
    [imgMore addGestureRecognizer:tapped];
    
    bi = [[UIBarButtonItem alloc] initWithCustomView:imgMore];
    //bi.width=20;
    [buttons addObject:bi];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [buttons addObject:spacer];
    
    // stick the buttons in the toolbar
    [tools setItems:buttons animated:NO];
    UIBarButtonItem *negativeSeparator=[[UIBarButtonItem alloc] initWithCustomView:tools];
    //negativeSeparator.width=20;
    //[self.navigationItem setRightBarButtonItems:@[negativeSeparator, tools]];
    self.navigationItem.rightBarButtonItem = negativeSeparator;


}
#pragma mark - toolbar action
-(IBAction)languagesClick:(id)sender
{
    [self.popoverController dismissPopoverAnimated:FALSE];
        LanguagesViewController *languages = [self.storyboard instantiateViewControllerWithIdentifier:@"LANGUAGES"];
        languages.listOfLanguages=[[dbCore sharedInstance] languageList];
        languages.type=@"allbrand";
        UIPopoverController *popover =  [[UIPopoverController alloc] initWithContentViewController:languages];
        popover.popoverContentSize =  CGSizeMake(300, 335);
        popover.delegate = self;
        self.popoverController = popover;
    [self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
- (IBAction)ageFilterClick:(id)sender
{
        [self.popoverController dismissPopoverAnimated:FALSE];
        AgeFilterViewController *ages = [self.storyboard instantiateViewControllerWithIdentifier:@"AGES"];
        ages.ageList=[[dbCore sharedInstance] ageList];
        ages.type=@"allbrandAge";
        UIPopoverController *popover =  [[UIPopoverController alloc] initWithContentViewController:ages];
        popover.popoverContentSize =  CGSizeMake(300, 280);
        popover.delegate = self;
        self.popoverController = popover;
    
    [self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
-(IBAction)searchClick:(id)sender
{
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please insert Keyword" message:@""
                                                   delegate:self cancelButtonTitle:@"Cancel"  otherButtonTitles:@"Submit", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
	[alert release];
	
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if ( [[alert title] isEqualToString:@"Please insert Keyword"]){
		if (buttonIndex != [alert cancelButtonIndex])
		{
            // Clicked the Submit button
            NSString *inputText = [[alert textFieldAtIndex:0] text];
            NSUInteger lenght=[inputText length];
            NSString *keyword=inputText;
            
            if(lenght > 0 ){
                ResultsViewController_iPad *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SEARCH_VIEW"];
                vc.keyword=keyword;
                [self.navigationController pushViewController:vc animated:NO];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"Message Alert"
                                      message: @"Please try again!"
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
            
		}
	}
	if ( [[alert title] isEqualToString:@"Are you sure you want to logout?"]){
        if (buttonIndex != [alert cancelButtonIndex])
        {
            //if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_authenticated_flag"] isEqualToString:@"1"]) {
            [[dbCore sharedInstance] logoutAuth];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate clearLoginData];
            //[self addToolBar];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
            ModalLoginViewController_iPad *vc = [storyboard instantiateViewControllerWithIdentifier:@"LOGIN_VIEW"];
            vc.modalPresentationStyle = UIModalPresentationCurrentContext;
            [self.tabBarController presentModalViewController:vc animated:NO];
            //}
        }
    }
    //Restore In App Purchased
    if ( [[alert title] isEqualToString:@"Sync Purchases"]){
        if (buttonIndex != [alert cancelButtonIndex])
        {
            [[dbCore sharedInstance] syncPurchasedBrands];
            [[dbCore sharedInstance] syncUpdateChanged];
            [self reloadDatabase];
        }
    }
}
#pragma mark MenuSettingsDelegate
- (void)menuSelected:(NSInteger )menu {
    [popoverController dismissPopoverAnimated:FALSE];
    UIViewController *viewController = nil;
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    //AboutViewController *aboutController = [storyboard instantiateViewControllerWithIdentifier:@"ABOUT_VIEW"];
    //aboutController.title=@"About";
    UIAlertView *alert =nil;
    switch (menu) {
        case 0:
            if (([[WPReachability sharedReachability] internetConnectionStatus] != NotReachable)) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to logout?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes", nil];
                [alert show];
                [alert release];
                
                
            }
            break;
        case 1:
            self.title =nil;
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ABOUT_VIEW"];
            viewController.title = @"About";
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        case 3:
            self.title =nil;
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MYSUBSCRIPTION_VIEW"];
            viewController.title = @"My Subscription";
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        case 2:
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_authenticated_flag"] isEqualToString:@"0"]) {
                alert = [[UIAlertView alloc] initWithTitle:@"Please login before restore!" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles: @"Ok", nil];
                [alert show];
                [alert release];
                
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"oznoztv_bought"];
                [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
                [[SKPaymentQueue defaultQueue]restoreCompletedTransactions];
            }
            break;
            
    }
}
- (IBAction)settingList:(id)sender {//MENUSETTINGS_VIEW
    
    [popoverController dismissPopoverAnimated:NO];
        MenuSettingsViewController *mnSettings = [self.storyboard instantiateViewControllerWithIdentifier:@"MENUSETTINGS_VIEW"];
        mnSettings.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mnSettings];
        mnSettings=nil;
        popoverController = [[UIPopoverController alloc] initWithContentViewController:nav];
        nav = nil;
    [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"%@",queue );
    NSLog(@"Restored Transactions are once again in Queue for purchasing %@",[queue transactions]);
    
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    NSLog(@"received restored transactions: %i", queue.transactions.count);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
        NSLog (@"product id is %@" , productID);
        NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString *sku=[productID stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@.",appID] withString:@""];
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        [[dbCore sharedInstance] productBySKU:[sku intValue]];
        [array addObject:sku];
        
    }
    
    NSString *string = [array componentsJoinedByString:@","];
    [[dbCore sharedInstance] syncPurchasedFromInAppPurchased:[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_username_preference"]  with:string];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"oznoztv_mystuff_first_load"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"oznoztv_bought"];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"oznoztv_bought"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync Purchases" message:@"All purchases have been synced!" delegate:self cancelButtonTitle:nil otherButtonTitles: @"Done", nil];
    [alert show];
    [alert release];
}
@end
