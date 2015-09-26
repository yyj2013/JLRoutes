/*
 Copyright (c) 2015, Joel Levin
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of JLRoutes nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSString+JLRouteAdditions.h"


@implementation NSString (JLRouteAdditions)

- (nonnull NSString *)JLRoutes_URLDecodedStringDecodingPlusSymbols:(BOOL)decodePlusSymbols
{
    NSString *input = self;
    if (decodePlusSymbols)
    {
        input = [self stringByReplacingOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, self.length)];
    }
    return [input stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (nonnull NSDictionary *)JLRoutes_URLParameterDictionaryDecodingPlusSymbols:(BOOL)decodePlusSymbols
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (self.length && [self rangeOfString:@"="].location != NSNotFound)
    {
        NSArray *keyValuePairs = [self componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in keyValuePairs)
        {
            NSArray *pair = [keyValuePair componentsSeparatedByString:@"="];
            
            // don't assume we actually got a real key=value pair. start by assuming we only got @[key] before checking count
            NSString *paramKey = pair.firstObject;
            NSString *paramValue = pair.count == 2 ? pair[1] : @"";
            paramValue = [paramValue JLRoutes_URLDecodedStringDecodingPlusSymbols:decodePlusSymbols];
            
            if (parameters[paramKey] != nil)
            {
                // this is an array in the form of key=value1&key=value2
                id value = parameters[paramKey];
                if ([value isKindOfClass:[NSArray class]])
                {
                    // already an array, just append it
                    NSMutableArray *values = (NSMutableArray *)value;
                    [values addObject:paramValue];
                }
                else
                {
                    // not an array, convert it
                    NSMutableArray *values = [NSMutableArray arrayWithObject:value];
                    [values addObject:paramValue];
                    parameters[paramKey] = values;
                }
            }
            else
            {
                // this is a new key/value pair, simply insert it
                parameters[paramKey] = paramValue;
            }
        }
    }
    
    return parameters;
}

@end
