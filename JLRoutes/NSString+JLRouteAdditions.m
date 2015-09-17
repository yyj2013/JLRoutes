//
//  NSString+JLRouteAdditions.m
//  JLRoutes
//
//  Created by Joel Levin on 9/17/15.
//  Copyright © 2015 Afterwork Studios. All rights reserved.
//

#import "NSString+JLRouteAdditions.h"


@implementation NSString (JLRouteAdditions)

- (NSString *)JLRoutes_URLDecodedString
{
    NSString *input = shouldDecodePlusSymbols ? [self stringByReplacingOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, self.length)] : self;
    return [input stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *)JLRoutes_URLParameterDictionary
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (self.length && [self rangeOfString:@"="].location != NSNotFound)
    {
        NSArray *keyValuePairs = [self componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in keyValuePairs)
        {
            NSArray *pair = [keyValuePair componentsSeparatedByString:@"="];
            // don't assume we actually got a real key=value pair. start by assuming we only got @[key] before checking count
            NSString *paramValue = pair.count == 2 ? pair[1] : @"";
            // CFURLCreateStringByReplacingPercentEscapesUsingEncoding may return NULL
            parameters[pair[0]] = [paramValue JLRoutes_URLDecodedString] ?: @"";
        }
    }
    
    return parameters;
}

@end
