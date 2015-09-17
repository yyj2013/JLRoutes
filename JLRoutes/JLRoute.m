//
//  JLRoute.m
//  JLRoutes
//
//  Created by Joel Levin on 9/17/15.
//  Copyright © 2015 Afterwork Studios. All rights reserved.
//

#import "JLRoute.h"


@interface JLRoute ()

@property (nonatomic, strong, nonnull) NSString *path;
@property (nonatomic, strong, nonnull) NSArray <NSString *> *pathComponents;
@property (nonatomic, strong, nonnull) BOOL (^handler)(NSDictionary *__nonnull parameters);
@property (nonatomic) NSUInteger priority;

@end


@implementation JLRoute

- (nonnull instancetype)initWithPath:(nonnull NSString *)path priority:(NSUInteger)priority handler:(nonnull void (^)(NSDictionary *__nonnull parameters))handlerBlock;
{
    if ((self = [super init]))
    {
        self.path = path;
        self.pathComponents = [[self.path pathComponents] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF like '/'"]];
    }
    return self;
}

- (NSDictionary *)parametersForURL:(NSURL *)URL components:(NSArray *)URLComponents
{
    NSDictionary *routeParameters = nil;
    
    // do a quick component count check to quickly eliminate incorrect patterns
    BOOL componentCountEqual = self.pathComponents.count == URLComponents.count;
    BOOL routeContainsWildcard = !NSEqualRanges([self.path rangeOfString:@"*"], NSMakeRange(NSNotFound, 0));
    if (componentCountEqual || routeContainsWildcard)
    {
        // now that we've identified a possible match, move component by component to check if it's a match
        NSUInteger componentIndex = 0;
        NSMutableDictionary *variables = [NSMutableDictionary dictionary];
        BOOL isMatch = YES;
        
        for (NSString *patternComponent in self.pathComponents)
        {
            NSString *URLComponent = nil;
            if (componentIndex < [URLComponents count])
            {
                URLComponent = URLComponents[componentIndex];
            }
            else if ([patternComponent isEqualToString:@"*"])
            {
                // match /foo by /foo/*
                URLComponent = [URLComponents lastObject];
            }
            
            if ([patternComponent hasPrefix:@":"])
            {
                // this component is a variable
                NSString *variableName = [patternComponent substringFromIndex:1];
                NSString *variableValue = URLComponent;
                NSString *urlDecodedVariableValue = [variableValue JLRoutes_URLDecodedString];
                if ([variableName length] > 0 && [urlDecodedVariableValue length] > 0)
                {
                    variables[variableName] = urlDecodedVariableValue;
                }
            }
            else if ([patternComponent isEqualToString:@"*"])
            {
                // match wildcards
                variables[JLRouteWildcardComponentsKey] = [URLComponents subarrayWithRange:NSMakeRange(componentIndex, URLComponents.count-componentIndex)];
                isMatch = YES;
                break;
            }
            else if (![patternComponent isEqualToString:URLComponent])
            {
                // a non-variable component did not match, so this route doesn't match up - on to the next one
                isMatch = NO;
                break;
            }
            componentIndex++;
        }
        
        if (isMatch) {
            routeParameters = variables;
        }
    }
    
    return routeParameters;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@ (%@)", [super description], self.path, @(self.priority)];
}

@end
