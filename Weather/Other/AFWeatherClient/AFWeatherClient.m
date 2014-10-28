//
//  AFWeatherClient.m
//  weather
//
//  Created by Ludvik Polak on 26.10.14.
//  Copyright (c) 2014 cz.poly. All rights reserved.
//

#import "AFWeatherClient.h"

@implementation AFWeatherClient

+ (instancetype)sharedClientData {
    
    static AFWeatherClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFWeatherClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.worldweatheronline.com/free/v2/weather.ashx"]];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
    });
    
    return _sharedClient;
}

+ (instancetype)sharedClientSearch{
    
    static AFWeatherClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFWeatherClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.worldweatheronline.com/free/v2/search.ashx"]];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
    });
    
    return _sharedClient;
}

@end
