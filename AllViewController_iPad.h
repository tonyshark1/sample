//
//  AllViewController_iPad.h
//  Oznoz
//
//  Created by Tony Stark on 2/5/13.
//  Copyright (c) 2013 Oznoz Entertainment, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterBar_iPad.h"
#import "GMGridView.h"
#import "APIPaginator.h"
#import "MBProgressHUD.h"
#import "MenuSettingsViewController.h"
#import "Cell_iPad.h"

@interface AllViewController_iPad : UIViewController<MBProgressHUDDelegate,MenuSettinsDelegate,UIPopoverControllerDelegate,GMGridViewDataSource,GMGridViewActionDelegate,UIScrollViewDelegate,FilterBarDelegate>{
    MenuSettingsViewController *mSettings;
    UIPopoverController *settings_popoverController;
    NSString *filter;
    UILabel *lbNavTitle;
    
}
@property (nonatomic) NSInteger PageSize;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *onoffSub;
@property (nonatomic, strong) APIPaginator *apiPaginator;
@property (nonatomic, retain) GMGridView * gridView;
@property (nonatomic, retain) FilterBar_iPad *filterbar;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)reloadDatabase;
- (void)reloadDatabaseReset;
- (void)reloadDatabaseUpdated;


@end
