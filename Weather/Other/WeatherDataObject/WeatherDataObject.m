//
//  WeatherDataObject.m
//  weather
//
//  Created by Ludvik Polak on 26.10.14.
//  Copyright (c) 2014 cz.poly. All rights reserved.
//

#import "WeatherDataObject.h"
#import "AFWeatherClient.h"

#define WEATHER_DATA_KEY @"weatherDataKey"
#define WEATHER_PARAMETERS_KEY @"weatherParametersKey"
#define WEATHER_LOCATIONS_KEY @"weatherLocationsKey"

static WeatherDataObject * _weatherDataObject = nil;
static BOOL _requestInProgress;
static BOOL _requestLocationsInProgress;
static NSInteger updateAllLocationsAutomateIndex = 0;

@interface WeatherDataObject()

@property(nonatomic,strong) NSMutableDictionary * weatherData;
@property(nonatomic,strong) NSDictionary * weatherParameters;
@property(nonatomic,strong) NSMutableArray * weatherLocations;

@end

@implementation WeatherDataObject

+(WeatherDataObject *)Shared{
    
    if(_weatherDataObject == nil){
        _weatherDataObject = [[WeatherDataObject alloc] init];
    }
    return _weatherDataObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // init weather data
        NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:WEATHER_DATA_KEY];
        if(dict)
            self.weatherData = [NSMutableDictionary dictionaryWithDictionary:dict];
        else
            self.weatherData = [NSMutableDictionary dictionary];
        
        // init weather locations
        NSArray * locations = [[NSUserDefaults standardUserDefaults] objectForKey:WEATHER_LOCATIONS_KEY];
        if(locations)
            self.weatherLocations = [NSMutableArray arrayWithArray:locations];
        else
            self.weatherLocations = [NSMutableArray array];
        
        // init weather parameters
        self.weatherParameters = [[NSUserDefaults standardUserDefaults] objectForKey:WEATHER_PARAMETERS_KEY];
        _requestInProgress = NO;
    }
    
    return self;
}

-(void)RefreshData{
    
    if(_requestInProgress)
        return;
    _requestInProgress = YES;
    
    AFWeatherClient * client = [AFWeatherClient sharedClientData];
    
    [client GET:@"" parameters:self.weatherParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]]){
            
            [self.weatherData setDictionary:(NSDictionary*)responseObject];
            [[NSUserDefaults standardUserDefaults] setObject:self.weatherData forKey:WEATHER_DATA_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:WEATHER_NOTIFICATION_UPDATED object:nil];
        }
        else{
            
            NSError * error = [NSError errorWithDomain:@"WeatherDataObject" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"responseObject is not NSDictionary class"}];
            [[NSNotificationCenter defaultCenter] postNotificationName:WEATHER_NOTIFICATION_UPDATED object:error];
        }
        
        _requestInProgress = NO;
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WEATHER_NOTIFICATION_UPDATED object:error];
        _requestInProgress = NO;
    }];
}

-(void)GetServerDataForPlace:(NSString*)Place
                   NumOfDays:(NSInteger)NumOfDays{
    
    if(_requestInProgress)
        return;
    _requestInProgress = YES;
    
    NSString * place = Place;
    NSInteger indexSelected = [self GetSelectedLocationIndex];
    if(indexSelected > -1){
        NSDictionary * dict = [NSDictionary dictionaryWithDictionary:[self.weatherLocations objectAtIndex:indexSelected]];
        place = [NSString stringWithFormat:@"%@, %@", [dict objectForKey:@"areaName"], [dict objectForKey:@"country"]];
    }
    
    NSDictionary * param = @{@"q":place,
                             @"format":@"json",
                             @"num_of_days":[NSNumber numberWithInteger:NumOfDays],
                             @"key":@"264aac03718e221ecb6e0d147bc8ea74848f2a92"
                             };
    
    AFWeatherClient * client = [AFWeatherClient sharedClientData];
    
    [client GET:@"" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]]){
            self.weatherParameters = param;
            [self.weatherData setDictionary:(NSDictionary*)responseObject];
            [[NSUserDefaults standardUserDefaults] setObject:self.weatherData forKey:WEATHER_DATA_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:WEATHER_NOTIFICATION_UPDATED object:nil];
        }
        else{
            
            NSError * error = [NSError errorWithDomain:@"WeatherDataObject" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"responseObject is not NSDictionary class"}];
            [[NSNotificationCenter defaultCenter] postNotificationName:WEATHER_NOTIFICATION_UPDATED object:error];
        }
        
        _requestInProgress = NO;
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        //NSLog(@"GetServerDataForPlace error:\n%@", error.localizedDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:WEATHER_NOTIFICATION_UPDATED object:error];
        
        _requestInProgress = NO;
    }];
    
}

#pragma mark - Weather data -

-(NSArray*)GetCurrentCondition{
    
    NSArray * current = [[self.weatherData objectForKey:@"data"] objectForKey:@"current_condition"];
    return current;
}

-(NSArray*)GetPlace{
    
    NSArray * items = [[self.weatherData objectForKey:@"data"] objectForKey:@"request"];
    NSMutableArray * places = [NSMutableArray array];
    
    for (NSDictionary * item in items) {
        [places addObject:[item objectForKey:@"query"]];
    }
    
    return [NSArray arrayWithArray:places];
}

-(NSArray*)GetWeatherData{
    
    NSArray * weatherData = [[self.weatherData objectForKey:@"data"] objectForKey:@"weather"];
    return weatherData;
}

#pragma mark - Locations data -

-(void)GetServerLocationsForPlace:(NSString*)Place{
    
    if(_requestLocationsInProgress)
        return;
    _requestLocationsInProgress = YES;
    
    NSDictionary * param = @{@"q":Place,
                             @"format":@"json",
                             @"key":@"264aac03718e221ecb6e0d147bc8ea74848f2a92"
                             };
    
    AFWeatherClient * client = [AFWeatherClient sharedClientSearch];
    
    [client GET:@"" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]]){
            NSLog(@"GetServerLocationsForPlace:\n%@", responseObject);
            [[NSNotificationCenter defaultCenter] postNotificationName:SEARCHING_NOTIFICATION_DONE object:[[responseObject objectForKey:@"search_api"] objectForKey:@"result"]];
        }
        else{
            
            NSError * error = [NSError errorWithDomain:@"WeatherDataObject" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"responseObject is not NSDictionary class"}];
            [[NSNotificationCenter defaultCenter] postNotificationName:SEARCHING_NOTIFICATION_DONE object:error];
        }
        
        _requestLocationsInProgress = NO;
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"GetServerLocationsForPlace error:\n%@", error.localizedDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:SEARCHING_NOTIFICATION_DONE object:error];
        
        _requestLocationsInProgress = NO;
    }];
    
}

-(NSArray*)GetLocations{
    
    return self.weatherLocations;
}

-(void)AddLocation:(NSDictionary*)Location{
    
    if(Location && [[Location allKeys] count] > 0){
        
        [self.weatherLocations addObject:[NSMutableDictionary dictionaryWithDictionary:Location]];
        [[NSUserDefaults standardUserDefaults] setObject:self.weatherLocations forKey:WEATHER_LOCATIONS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LOCATIONS_NOTIFICATION_UPDATED object:nil];

        [self UpdateWeatherForAllLocations];
    }
}

-(void)RemoveLocationAtIndex:(NSInteger)LocationIndex{
    
    if([self.weatherLocations count] > 0 &&
       LocationIndex >= 0 &&
       LocationIndex < [self.weatherLocations count]){
        
        [self.weatherLocations removeObjectAtIndex:LocationIndex];
        [[NSUserDefaults standardUserDefaults] setObject:self.weatherLocations forKey:WEATHER_LOCATIONS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LOCATIONS_NOTIFICATION_UPDATED object:nil];
        
        [self RefreshData];
        [self UpdateWeatherForAllLocations];
    }
}

-(void)SelectLocationAtIndex:(NSInteger)LocationIndex{
    
    if([self.weatherLocations count] > 0 &&
       LocationIndex >= 0 &&
       LocationIndex < [self.weatherLocations count]){
        
        NSInteger index = 0;
        for (NSMutableDictionary * dict in self.weatherLocations) {
    
            if(LocationIndex == index)
                [dict setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
            else
                [dict setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            index ++;
        }
    
        [[NSUserDefaults standardUserDefaults] setObject:self.weatherLocations forKey:WEATHER_LOCATIONS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LOCATIONS_NOTIFICATION_UPDATED object:nil];
        
        [self GetServerDataForPlace:@"" NumOfDays:7];
    }
    
}

-(NSInteger)GetSelectedLocationIndex{
    
    NSInteger index = 0;
    for (NSMutableDictionary * dict in self.weatherLocations) {
        
        if([[dict objectForKey:@"selected"] boolValue])
            return index;
        index ++;
    }
    
    return -1;
}

-(void)UpdateWeatherForAllLocations{

    if(updateAllLocationsAutomateIndex != 0)
        return;
    
    [self UpdateAutomate];
}

    /// method ask server for data for each item of weatherLocations
-(void)UpdateAutomate{
    
    // if updateAllLocationsAutomateIndex is equal or higher then weatherLocations count, it finish process, save data, send notification
    if(updateAllLocationsAutomateIndex >= [self.weatherLocations count]){
        
        updateAllLocationsAutomateIndex = 0;
        
        [[NSUserDefaults standardUserDefaults] setObject:self.weatherLocations forKey:WEATHER_LOCATIONS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:LOCATIONS_NOTIFICATION_UPDATED object:nil];
        
        return;
    }
    
    NSDictionary * item = [self.weatherLocations objectAtIndex:updateAllLocationsAutomateIndex];
    
    NSString * place = [NSString stringWithFormat:@"%@,%@", [item objectForKey:@"areaName"], [item objectForKey:@"country"]];
    
    NSDictionary * param = @{@"q":place,
                             @"format":@"json",
                             @"num_of_days":@1,
                             @"key":@"264aac03718e221ecb6e0d147bc8ea74848f2a92"
                             };
    
    AFWeatherClient * client = [AFWeatherClient sharedClientData];
    
    [client GET:@"" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]]){
            
            // this block parse data from server response, update data for location item, increase automate counter and call updateAutomate
            // to update next item
            
            NSArray * arrayData = [[responseObject objectForKey:@"data"] objectForKey:@"weather"];
            
            if([arrayData count] > 0){
                
                NSInteger timeIndex = [self GetTimeIndex];
                // check if timeIndex pass to array count else set default index = 4 (1pm)
                if(timeIndex >= [[[arrayData objectAtIndex:0] objectForKey:@"hourly"] count]){
                    
                    timeIndex = 4;
                    
                    // check if default timeIndex pass to array count else set array count
                    if(timeIndex >= [[[arrayData objectAtIndex:0] objectForKey:@"hourly"] count])
                        timeIndex = [[[arrayData objectAtIndex:0] objectForKey:@"hourly"] count];
                }
                
                
                NSDictionary * data = [[[arrayData objectAtIndex:0] objectForKey:@"hourly"] objectAtIndex:timeIndex];
                
                NSString * weatherText = @"- - -";
                if([[data objectForKey:@"weatherDesc"] count] > 0)
                    weatherText = [NSString stringWithFormat:@"%@",[[[data objectForKey:@"weatherDesc"] objectAtIndex:0] objectForKey:@"value"]];
                
                NSInteger code = [[data objectForKey:@"weatherCode"] integerValue];
                
                NSDictionary * itemData = @{
                                            @"tempC" : [data objectForKey:@"tempC"],
                                            @"weatherDesc" : weatherText,
                                            @"weatherCode" : [NSNumber numberWithInteger:code]
                                            };
                [self UpdateLocationItem:itemData atIndex:updateAllLocationsAutomateIndex];
            }
            
            updateAllLocationsAutomateIndex ++;
            [self UpdateAutomate];
        }
        else{
            
            // this block dont update data for location item due to bad response but increase automate counter and call updateAutomate
            // to update next item
            NSError * error = [NSError errorWithDomain:@"WeatherDataObject" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"responseObject is not NSDictionary class"}];
            [[NSNotificationCenter defaultCenter] postNotificationName:WEATHER_NOTIFICATION_UPDATED object:error];
            
            updateAllLocationsAutomateIndex ++;
            [self UpdateAutomate];
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        // this block dont update data for location item due some error but increase automate counter and call updateAutomate
        // to update next item
        
        //NSLog(@"GetServerDataForPlace error:\n%@", error.localizedDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:WEATHER_NOTIFICATION_UPDATED object:error];
        
        updateAllLocationsAutomateIndex ++;
        [self UpdateAutomate];
    }];
}

-(NSInteger)GetTimeIndex{
    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit ) fromDate:currentDate];
    
    NSInteger index = 0;
    
    [components setHour:01]; [components setMinute:00]; [components setSecond:01];
    NSDate * newdate = [[NSCalendar currentCalendar]dateFromComponents:components];
    if ([currentDate compare:newdate] == NSOrderedSame || [currentDate compare:newdate] == NSOrderedDescending)
        index = 1;
    
    components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit ) fromDate:currentDate];
    [components setHour:04]; [components setMinute:00]; [components setSecond:01];
    newdate = [[NSCalendar currentCalendar]dateFromComponents:components];
    if ([currentDate compare:newdate] == NSOrderedSame || [currentDate compare:newdate] == NSOrderedDescending)
        index = 2;
    
    components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit ) fromDate:currentDate];
    [components setHour:07]; [components setMinute:00]; [components setSecond:01];
    newdate = [[NSCalendar currentCalendar]dateFromComponents:components];
    if ([currentDate compare:newdate] == NSOrderedSame || [currentDate compare:newdate] == NSOrderedDescending)
        index = 3;
    
    components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit ) fromDate:currentDate];
    [components setHour:10]; [components setMinute:00]; [components setSecond:01];
    newdate = [[NSCalendar currentCalendar]dateFromComponents:components];
    if ([currentDate compare:newdate] == NSOrderedSame || [currentDate compare:newdate] == NSOrderedDescending)
        index = 4;
    
    components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit ) fromDate:currentDate];
    [components setHour:13]; [components setMinute:00]; [components setSecond:01];
    newdate = [[NSCalendar currentCalendar]dateFromComponents:components];
    if ([currentDate compare:newdate] == NSOrderedSame || [currentDate compare:newdate] == NSOrderedDescending)
        index = 5;
    
    components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit ) fromDate:currentDate];
    [components setHour:16]; [components setMinute:00]; [components setSecond:01];
    newdate = [[NSCalendar currentCalendar]dateFromComponents:components];
    if ([currentDate compare:newdate] == NSOrderedSame || [currentDate compare:newdate] == NSOrderedDescending)
        index = 6;
    
    components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit ) fromDate:currentDate];
    [components setHour:16]; [components setMinute:00]; [components setSecond:01];
    newdate = [[NSCalendar currentCalendar]dateFromComponents:components];
    if ([currentDate compare:newdate] == NSOrderedSame || [currentDate compare:newdate] == NSOrderedDescending)
        index = 7;
    
    components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit ) fromDate:currentDate];
    [components setHour:19]; [components setMinute:00]; [components setSecond:01];
    newdate = [[NSCalendar currentCalendar]dateFromComponents:components];
    if ([currentDate compare:newdate] == NSOrderedSame || [currentDate compare:newdate] == NSOrderedDescending)
        index = 8;
    
    components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit ) fromDate:currentDate];
    [components setHour:22]; [components setMinute:00]; [components setSecond:01];
    newdate = [[NSCalendar currentCalendar]dateFromComponents:components];
    if ([currentDate compare:newdate] == NSOrderedSame || [currentDate compare:newdate] == NSOrderedDescending)
        index = 9;
    
    //NSLog(@"time index: %d", index);
    return index;
}

-(void)UpdateLocationItem:(NSDictionary*)Data atIndex:(NSInteger)LocationIndex{
    
    if([self.weatherLocations count] > 0 &&
       LocationIndex >= 0 &&
       LocationIndex < [self.weatherLocations count]){
        
        NSMutableDictionary * dict = [self.weatherLocations objectAtIndex:LocationIndex];
        
        for (NSString * key in [Data allKeys]) {
            [dict setObject:[Data objectForKey:key] forKey:key];
        }
    }
}

@end
