//
//  WeatherDataObject.h
//  weather
//
//  Created by Ludvik Polak on 26.10.14.
//  Copyright (c) 2014 cz.poly. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WEATHER_NOTIFICATION_UPDATED @"WeatherDataObjectUpdated"
#define LOCATIONS_NOTIFICATION_UPDATED @"WeatherLocationsObjectUpdated"
#define SEARCHING_NOTIFICATION_DONE @"WeatherSearchingDone"

@interface WeatherDataObject : NSObject

    /// return SingleTon object of WeatherDataObject
+(WeatherDataObject*)Shared;
    /// read data from wether server witl last parameters
    /// when data are updated WeatherDataObject sends notification 'WeatherDataObjectUpdated' with nil or NSError
    /// data for weather are stored when success
-(void)RefreshData;
    /// read data from wether server with new parameters
    /// when data are updated WeatherDataObject sends notification 'WeatherDataObjectUpdated' with nil or NSError
    /// data for weather and parameters are stored when success
-(void)GetServerDataForPlace:(NSString*)Place
                   NumOfDays:(NSInteger)NumOfDays;
    /// return data for current condictions
-(NSArray*)GetCurrentCondition;
    /// return description of places where data are for
-(NSArray*)GetPlace;
    /// return data of weather for days
-(NSArray*)GetWeatherData;



    /// read locations from server
    /// when data are received WeatherDataObject sends notification 'WeatherSearchingDone' with nil or NSError
-(void)GetServerLocationsForPlace:(NSString*)Place;
    /// return data of locations
-(NSArray*)GetLocations;
    /// Add Location and update data from server
-(void)AddLocation:(NSDictionary*)Location;
    /// remove Location at index  and update data from server
-(void)RemoveLocationAtIndex:(NSInteger)LocationIndex;
    /// select Location
-(void)SelectLocationAtIndex:(NSInteger)LocationIndex;
    /// method starts automate to update all records in weatherLocations
-(void)UpdateWeatherForAllLocations;
    /// method return index choosed by time. Weather API returns data for all day (array), this index response to near time
-(NSInteger)GetTimeIndex;


@end
