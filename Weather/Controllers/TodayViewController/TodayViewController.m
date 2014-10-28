//
//  TodayViewController.m
//  Weather
//
//  Created by Ludvik Polak on 26.10.14.
//  Copyright (c) 2014 com.ludvikpolak. All rights reserved.
//

#import "TodayViewController.h"
#import "WeatherDataObject.h"
#import "LocationsViewController.h"

@interface TodayViewController ()

@end

@implementation TodayViewController

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataWithNotification:) name:WEATHER_NOTIFICATION_UPDATED object:nil];
    
    [self updateData];
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Today", @"Today");
    [self createNavigationButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createNavigationButton{
    
    UIColor * activeTextColor = nil;
    UIColor * normalTextColor = nil;
    
    activeTextColor = [UIColor colorWithRed:27.0/255.0 green:142.0/255.0 blue:211.0/255.0 alpha:1.0];
    normalTextColor = activeTextColor;
    
    UIButton * rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 14)];
    
    [rightButton setBackgroundImage:[[UIImage imageNamed:@"Location"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [rightButton setTitle:@"" forState:UIControlStateNormal];
    [rightButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [rightButton addTarget:self action:@selector(openLocation) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = barButton;
}

-(void)openLocation{
    
    LocationsViewController * screen = [[LocationsViewController alloc] initWithNibName:@"LocationsViewController" bundle:nil];
    screen.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:screen animated:YES];
    screen = nil;
}

-(void)updateDataWithNotification:(NSNotification*)Notification{
    
    // if error occured in server request, ignore update
    if([Notification.object isKindOfClass:[NSError class]] == NO)
        [self updateData];
}

-(void)updateData{
    
    // prepare place text
    NSString * place = @"- - -";
    if([[[WeatherDataObject Shared] GetPlace] count] > 0)
        place = [[[WeatherDataObject Shared] GetPlace] objectAtIndex:0];
    
    // prepare currentCondiction data
    NSDictionary * currentCondiction = @{
                                 @"weatherDesc" : @[],
                                 @"weatherCode" : @0,
                                 @"temp_C" : @0,
                                 @"precipMM" : @0.0,
                                 @"pressure" : @0,
                                 @"humidity" : @0,
                                 @"windspeedKmph" : @0,
                                 @"winddir16Point" : @"- - -",
                                 };
    if([[[WeatherDataObject Shared] GetCurrentCondition] count] > 0)
        currentCondiction = [[[WeatherDataObject Shared] GetCurrentCondition] objectAtIndex:0];
    
    // prepare weather text
    NSString * weatherText = @"- - -";
    if([[currentCondiction objectForKey:@"weatherDesc"] count] > 0)
        weatherText = [NSString stringWithFormat:@"%@°C | %@",[currentCondiction objectForKey:@"temp_C"],[[[currentCondiction objectForKey:@"weatherDesc"] objectAtIndex:0] objectForKey:@"value"]];
    
    self.labelLocation.text = place;
    self.labelWeatherText.text = weatherText;
    self.labelHumidity.text = [NSString stringWithFormat:@"%@%%",[currentCondiction objectForKey:@"humidity"]];
    self.labelPrecipMM.text = [NSString stringWithFormat:@"%@ mm",[currentCondiction objectForKey:@"precipMM"]];
    self.labelPresure.text = [NSString stringWithFormat:@"%@ hPa",[currentCondiction objectForKey:@"pressure"]];
    self.labelWindSpeedKmph.text = [NSString stringWithFormat:@"%@ km/h",[currentCondiction objectForKey:@"windspeedKmph"]];
    self.labelWindDir16Point.text = [currentCondiction objectForKey:@"winddir16Point"];
    
    // fill data to screen
    
    
    UIImage * weatherSymbol = nil;
    NSInteger code = [[currentCondiction objectForKey:@"weatherCode"] integerValue];
    
    if(code < 116){
        weatherSymbol = [UIImage imageNamed:@"Sun_Big"];
    }
    else if(code < 299){
        weatherSymbol = [UIImage imageNamed:@"Cloudy_Big"];
    }
    else{
        weatherSymbol = [UIImage imageNamed:@"Lightning_Big"];
    }
    self.imageBigSymbol.image = weatherSymbol;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
