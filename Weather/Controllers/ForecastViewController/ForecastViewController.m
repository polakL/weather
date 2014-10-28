//
//  ForecastViewController.m
//  Weather
//
//  Created by Ludvik Polak on 26.10.14.
//  Copyright (c) 2014 com.ludvikpolak. All rights reserved.
//

#import "ForecastViewController.h"
#import "WeatherDataObject.h"
#import "ForecastTableCellController.h"
#import "LocationsViewController.h"

@interface ForecastViewController ()

@end

@implementation ForecastViewController

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
    
    self.navigationItem.title = NSLocalizedString(@"Forecast", @"Forecast");
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
    
//    NSLog(@"GetWeatherData:\n%@",[[WeatherDataObject Shared] GetWeatherData]);
    NSArray * data = [[WeatherDataObject Shared] GetPlace];
    
    if([data count]){
        NSString * place = [[[data objectAtIndex:0] componentsSeparatedByString:@","] objectAtIndex:0];
        self.navigationItem.title = place;
        [self.tableView reloadData];
    }
    
}

-(NSDate *)dateFromString:(NSString *)Date{
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:Date];
    
    return date;
}

-(NSString*)weekDayFromDate:(NSDate*)Date{
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale=[NSLocale currentLocale];
    
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:Date];
    
//    NSInteger year = [dateComponents year];
//    NSInteger month = [dateComponents month];
//    NSInteger day = [dateComponents day];
//    NSInteger hour = [dateComponents hour];
//    NSInteger minute = [dateComponents minute];
//    NSInteger second = [dateComponents second];
    NSInteger weekday = [dateComponents weekday];
    
    NSString * dayString = @"";
    switch (weekday) {
        case 1:
            dayString = NSLocalizedString(@"Sunday", @"Sunday");
            break;
        case 2:
            dayString = NSLocalizedString(@"Monday", @"Monday");
            break;
        case 3:
            dayString = NSLocalizedString(@"Thuesday", @"Thuesday");
            break;
        case 4:
            dayString = NSLocalizedString(@"Wednesday", @"Wednesday");
            break;
        case 5:
            dayString = NSLocalizedString(@"Thursday", @"Thursday");
            break;
        case 6:
            dayString = NSLocalizedString(@"Friday", @"Friday");
            break;
        case 7:
            dayString = NSLocalizedString(@"Saturday", @"Saturday");
            break;
        
            
        default:
            dayString = @"- - -";
            break;
    }
    
    return dayString;
}


#pragma mark - Table -
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [[[WeatherDataObject Shared] GetWeatherData] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ForecastTableCellController * cell = (ForecastTableCellController*)[tableView dequeueReusableCellWithIdentifier:@"forecastCell"];
    if(cell == nil){
        [tableView registerNib:[UINib nibWithNibName:@"ForecastTableCellController" bundle:nil] forCellReuseIdentifier:@"forecastCell"];
        cell = (ForecastTableCellController*)[tableView dequeueReusableCellWithIdentifier:@"forecastCell"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[ForecastTableCellController class]]){
        NSDictionary * item = [[[WeatherDataObject Shared] GetWeatherData] objectAtIndex:indexPath.row];
        
        if(item){
            
            NSString * day = [self weekDayFromDate:[self dateFromString:[item objectForKey:@"date"]]];
            
            // index 4 could be time 1pm
            NSDictionary * data = [[item objectForKey:@"hourly"] objectAtIndex:4];
            
            NSString * weatherText = @"- - -";
            if([[data objectForKey:@"weatherDesc"] count] > 0)
                weatherText = [NSString stringWithFormat:@"%@",[[[data objectForKey:@"weatherDesc"] objectAtIndex:0] objectForKey:@"value"]];
            
            UIImage * weatherSymbol = nil;
            NSInteger code = [[data objectForKey:@"weatherCode"] integerValue];
            
            if(code < 116){
                weatherSymbol = [UIImage imageNamed:@"Sun_Big"];
            }
            else if(code < 299){
                weatherSymbol = [UIImage imageNamed:@"Cloudy_Big"];
            }
            else{
                weatherSymbol = [UIImage imageNamed:@"Lightning_Big"];
            }
            
            ((ForecastTableCellController*)cell).labelTempC.text = [NSString stringWithFormat:@"%@°",[data objectForKey:@"tempC"]];
            ((ForecastTableCellController*)cell).labelDayName.text = day;
            ((ForecastTableCellController*)cell).labelWeatherDescription.text = weatherText;
            ((ForecastTableCellController*)cell).imageIcon.image = weatherSymbol;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
