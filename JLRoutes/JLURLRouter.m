/*
 Copyright (c) 2015, Joel Levin
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of JLRoutes nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "JLURLRouter.h"
#import "JLRoutes.h"
#import "NSString+JLRouteAdditions.h"
#import "NSURL+JLRouteAdditions.h"


@interface JLURLRouter ()

@property (nonatomic, strong, nullable) NSString *scheme;

@property (nonatomic, strong) NSMutableArray <__kindof JLRoute *> *routes;
@property (nonatomic, strong) NSMutableDictionary <NSString *, __kindof JLRoute *> *routesByPath;

@end


@implementation JLURLRouter

- (instancetype)init
{
    return [self initWithScheme:nil];
}

- (nonnull instancetype)initWithScheme:(nullable NSString *)scheme
{
    if ((self = [super init]))
    {
        self.scheme = scheme;
        self.routes = [NSMutableArray array];
        self.routesByPath = [NSMutableDictionary dictionary];
        self.defaultRouterClass = [JLRoute class];
    }
    return self;
}

#pragma mark - Route management

- (void)registerRoute:(nonnull __kindof JLRoute *)route
{
    NSParameterAssert(route != nil);
    NSParameterAssert(route.path != nil);
    
    NSAssert(self.routesByPath[route.path] == nil, @"A route with path '%@' already exists", route.path);
    
    if (self.routes.count == 0 || route.priority == JLRouteDefaultPriority)
    {
        [self.routes addObject:route];
    }
    else
    {
        // this route has some sort of priority, so insert it and then sort the whole deal
        [self.routes insertObject:route atIndex:0];
        [self.routes sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO]]];
    }
    
    self.routesByPath[route.path] = route;
    
    route.router = self;
}

- (nonnull __kindof JLRoute *)addRouteWithPath:(nonnull NSString *)routePath handler:(nonnull BOOL (^)(NSDictionary <NSString *, id> *__nonnull parameters))handlerBlock
{
    return [self addRouteWithPath:routePath priority:JLRouteDefaultPriority handler:handlerBlock];
}

- (nonnull __kindof JLRoute *)addRouteWithPath:(nonnull NSString *)routePath priority:(NSUInteger)priority handler:(nonnull BOOL (^)(NSDictionary <NSString *, id> *__nonnull parameters))handlerBlock
{
    NSParameterAssert(routePath != nil);
    
    JLRoute *route = [[JLRoute alloc] initWithPath:routePath priority:priority handler:handlerBlock];
    [self registerRoute:route];
    return route;
}

- (nonnull NSArray<__kindof JLRoute *> *)addRoutesWithPaths:(nonnull NSArray<NSString *> *)routePaths handler:(nonnull BOOL (^)(NSDictionary <NSString *, id> *__nonnull parameters))handlerBlock
{
    NSMutableArray *routes = [NSMutableArray array];
    for (NSString *path in routePaths)
    {
        [routes addObject:[self addRouteWithPath:path priority:JLRouteDefaultPriority handler:handlerBlock]];
    }
    return [routes copy];
}

- (nullable __kindof JLRoute *)routeWithPath:(nonnull NSString *)path
{
    return self.routesByPath[path];
}

- (void)removeRoute:(nonnull __kindof JLRoute *)route
{
    [self removeRouteWithPath:route.path];
}

- (void)removeRouteWithPath:(nonnull NSString *)routePath
{
    JLRoute *route = [self routeWithPath:routePath];
    if (route != nil)
    {
        route.router = nil;
        [self.routes removeObject:route];
        [self.routesByPath removeObjectForKey:routePath];
    }
}

- (void)removeAllRoutes
{
    for (JLRoute *route in self.routes)
    {
        route.router = nil;
    }
    [self.routes removeAllObjects];
    [self.routesByPath removeAllObjects];
}

#pragma mark - Routing

- (BOOL)canRouteURL:(nonnull NSURL *)URL
{
    return [self routeURL:URL userInfo:nil dryRun:YES];
}

- (BOOL)routeURL:(nonnull NSURL *)URL
{
    return [self routeURL:URL userInfo:nil dryRun:NO];
}

- (BOOL)routeURL:(nonnull NSURL *)URL userInfo:(nullable NSDictionary *)userInfo
{
    return [self routeURL:URL userInfo:userInfo dryRun:NO];
}

- (BOOL)routeURL:(nonnull NSURL *)URL userInfo:(nullable NSDictionary *)userInfo dryRun:(BOOL)dryRun
{
    NSParameterAssert(URL != nil);
    if (URL == nil)
    {
        return NO;
    }
    
    BOOL didRoute = NO;
    BOOL shouldDecodePlusSymbols = [JLRoutes shouldDecodePlusSymbols];
    
    NSDictionary *queryParameters = [URL.query JLRoutes_URLParameterDictionaryDecodingPlusSymbols:shouldDecodePlusSymbols];
    NSDictionary *fragmentParameters = [URL.fragment JLRoutes_URLParameterDictionaryDecodingPlusSymbols:shouldDecodePlusSymbols];
    
    // break the URL down into path components and filter out any leading/trailing slashes from it
    NSArray *pathComponents = [URL JLRoutes_nonSlashPathComponents];
    
    if ([URL.host rangeOfString:@"."].location == NSNotFound && ![URL.host isEqualToString:@"localhost"])
    {
        // handle scheme://path/to/resource as if 'path' was part of the path itself instead of the host
        pathComponents = [@[URL.host] arrayByAddingObjectsFromArray:pathComponents];
    }
    
    // try to find an exact path match
    NSString *composedPath = [@"/" stringByAppendingString:[pathComponents componentsJoinedByString:@"/"]];
    JLRoute *exactPathMatch = [self routeWithPath:composedPath];
    if (exactPathMatch != nil)
    {
        // found it, call the block
        if (!dryRun)
        {
            NSDictionary *matchParams = [exactPathMatch matchWithPathComponentsIfPossible:pathComponents];
            NSDictionary *params = [self routeParamsForRoute:exactPathMatch queryParams:queryParameters fragmentParams:fragmentParameters matchParams:matchParams URL:URL userInfo:userInfo];
            exactPathMatch.handler(params);
        }
        return YES;
    }
    
    // no exact match, so lets run through everything and try to find a match
    for (JLRoute *route in self.routes)
    {
        NSDictionary *matchParams = [route matchWithPathComponentsIfPossible:pathComponents];
        if (matchParams == nil)
        {
            // no match, keep going
            continue;
        }
        
        // if execution gets here, we've found a match!
        
        if (dryRun)
        {
            return YES;
        }
        
        // generate block params
        NSDictionary *params = [self routeParamsForRoute:route queryParams:queryParameters fragmentParams:fragmentParameters matchParams:matchParams URL:URL userInfo:userInfo];
        
        // call it
        didRoute = route.handler(params);
        
        // if it returned YES, we're done
        if (didRoute)
        {
            break;
        }
    }
    
    if (!didRoute && self.unmatchedURLHandler != nil)
    {
        didRoute = self.unmatchedURLHandler(self, URL, userInfo);
    }
    
    return didRoute;
}

- (nonnull NSDictionary <NSString *, id> *)routeParamsForRoute:(JLRoute *)route queryParams:(NSDictionary *)queryParams fragmentParams:(NSDictionary *)fragmentParams matchParams:(NSDictionary *)matchParams URL:(NSURL *)URL userInfo:(NSDictionary *)userInfo
{
    NSMutableDictionary <NSString *, id> *params = [NSMutableDictionary dictionary];
    
    // in increasing order of precedence: query, fragment, route
    [params addEntriesFromDictionary:queryParams];
    [params addEntriesFromDictionary:fragmentParams];
    [params addEntriesFromDictionary:matchParams];
    
    params[JLRouteParamRouteKey] = route;
    params[JLRouteParamURLKey] = URL;
    
    if (userInfo.count > 0)
    {
        params[JLRouteParamUserInfoKey] = userInfo;
    }
    
    return [params copy];
}

@end
