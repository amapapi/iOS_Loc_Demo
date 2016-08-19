//
//  SingleLocaitonAloneViewController.m
//  officialDemoLoc
//
//  Created by 朱浩 on 16/2/24.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "SingleLocaitonAloneViewController.h"

#define DefaultLocationTimeout 10
#define DefaultReGeocodeTimeout 5

@interface SingleLocaitonAloneViewController () <AMapLocationManagerDelegate>

@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;

@property (nonatomic, strong) UILabel *displayLabel;

@end

@implementation SingleLocaitonAloneViewController

#pragma mark - Action Handle

- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    [self.locationManager setLocationTimeout:DefaultLocationTimeout];
    
    [self.locationManager setReGeocodeTimeout:DefaultReGeocodeTimeout];
}

- (void)cleanUpAction
{
    [self.locationManager stopUpdatingLocation];
    
    [self.locationManager setDelegate:nil];
    
    [self.displayLabel setText:nil];
}

- (void)reGeocodeAction
{
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
}

- (void)locAction
{
    [self.locationManager requestLocationWithReGeocode:NO completionBlock:self.completionBlock];
}

#pragma mark - Initialization

- (void)initCompleteBlock
{
    __weak SingleLocaitonAloneViewController *weakSelf = self;
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        if (location)
        {
            if (regeocode)
            {
                [weakSelf.displayLabel setText:[NSString stringWithFormat:@"%@ \n %@-%@-%.2fm", regeocode.formattedAddress,regeocode.citycode, regeocode.adcode, location.horizontalAccuracy]];
            }
            else
            {
                [weakSelf.displayLabel setText:[NSString stringWithFormat:@"lat:%f;lon:%f \n accuracy:%.2fm", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy]];
            }
        }
    };
}

- (void)initToolBar
{
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    
    UIBarButtonItem *reGeocodeItem = [[UIBarButtonItem alloc] initWithTitle:@"带逆地理定位"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(reGeocodeAction)];
    
    UIBarButtonItem *locItem = [[UIBarButtonItem alloc] initWithTitle:@"不带逆地理定位"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(locAction)];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexble, reGeocodeItem, flexble, locItem, flexble, nil];
}

- (void)initNavigationBar
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clean"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(cleanUpAction)];
}

- (void)initDisplayLabel
{
    self.displayLabel = [[UILabel alloc] init];
    self.displayLabel.frame = [UIScreen mainScreen].bounds;
    self.displayLabel.backgroundColor  = [UIColor clearColor];
    self.displayLabel.textColor        = [UIColor blackColor];
    self.displayLabel.textAlignment = NSTextAlignmentCenter;
    self.displayLabel.numberOfLines = 0;
    
    [self.view addSubview:_displayLabel];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    [self initToolBar];
    
    [self initNavigationBar];
    
    [self initCompleteBlock];
    
    [self configLocationManager];
    
    [self initDisplayLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.translucent   = YES;
    self.navigationController.toolbarHidden         = NO;
}

- (void)dealloc
{
    [self cleanUpAction];
    
    self.completionBlock = nil;
}

@end
