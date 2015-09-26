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


@interface JLURLRouter ()

@property (nonatomic, strong, nullable) NSString *scheme;

@property (nonatomic, strong) NSMutableArray <__kindof JLRoute *> *routes;
@property (nonatomic, strong) NSMutableDictionary <NSString *, __kindof JLRoute *> *routesByPath;

@end


@implementation JLURLRouter

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

- (nonnull NSArray<__kindof JLRoute *> *)addRoutes:(nonnull NSArray<NSString *> *)routePaths handler:(nonnull BOOL (^)(NSDictionary <NSString *, id> *__nonnull parameters))handlerBlock
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
    
}

- (BOOL)routeURL:(nonnull NSURL *)URL
{
    
}

- (BOOL)routeURL:(nonnull NSURL *)URL userInfo:(nullable NSDictionary *)userInfo
{
    
}

/*+ (BOOL)routeURL:(NSURL *)URL withController:(JLRoutes *)routesController parameters:(NSDictionary *)parameters executeBlock:(BOOL)executeBlock {
    [self verboseLogWithFormat:@"Trying to route URL %@", URL];
    BOOL didRoute = NO;
    NSArray *routes = routesController.routes;
    NSDictionary *queryParameters = [URL.query JLRoutes_URLParameterDictionary];
    [self verboseLogWithFormat:@"Parsed query parameters: %@", queryParameters];
    
    NSDictionary *fragmentParameters = [URL.fragment JLRoutes_URLParameterDictionary];
    [self verboseLogWithFormat:@"Parsed fragment parameters: %@", fragmentParameters];
    
    // break the URL down into path components and filter out any leading/trailing slashes from it
    NSArray *pathComponents = [(URL.pathComponents ?: @[]) filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF like '/'"]];
    
    if ([URL.host rangeOfString:@"."].location == NSNotFound && ![URL.host isEqualToString:@"localhost"]) {
        // For backward compatibility, handle scheme://path/to/ressource as if path was part of the
        // path if it doesn't look like a domain name (no dot in it)
        pathComponents = [@[URL.host] arrayByAddingObjectsFromArray:pathComponents];
    }
    
    [self verboseLogWithFormat:@"URL path components: %@", pathComponents];
    
    for (_JLRoute *route in routes) {
        NSDictionary *matchParameters = [route parametersForURL:URL components:pathComponents];
        if (matchParameters) {
            [self verboseLogWithFormat:@"Successfully matched %@", route];
            if (!executeBlock) {
                return YES;
            }
            
            // add the URL parameters
            NSMutableDictionary *finalParameters = [NSMutableDictionary dictionary];
            
            // in increasing order of precedence: query, fragment, route, builtin
            [finalParameters addEntriesFromDictionary:queryParameters];
            [finalParameters addEntriesFromDictionary:fragmentParameters];
            [finalParameters addEntriesFromDictionary:matchParameters];
            [finalParameters addEntriesFromDictionary:parameters];
            finalParameters[kJLRoutePatternKey] = route.pattern;
            finalParameters[kJLRouteURLKey] = URL;
            __strong __typeof(route.parentRoutesController) strongParentRoutesController = route.parentRoutesController;
            finalParameters[kJLRouteNamespaceKey] = strongParentRoutesController.namespaceKey ?: [NSNull null];
            
            [self verboseLogWithFormat:@"Final parameters are %@", finalParameters];
            didRoute = route.block(finalParameters);
            if (didRoute) {
                break;
            }
        }
    }
    
    if (!didRoute) {
        [self verboseLogWithFormat:@"Could not find a matching route, returning NO"];
    }
    
    // if we couldn't find a match and this routes controller specifies to fallback and its also not the global routes controller, then...
    if (!didRoute && routesController.shouldFallbackToGlobalRoutes && ![routesController isGlobalRoutesController]) {
        [self verboseLogWithFormat:@"Falling back to global routes..."];
        didRoute = [self routeURL:URL withController:[self globalRoutes] parameters:parameters executeBlock:executeBlock];
    }
    
    // if, after everything, we did not route anything and we have an unmatched URL handler, then call it
    if (!didRoute && routesController.unmatchedURLHandler) {
        routesController.unmatchedURLHandler(routesController, URL, parameters);
    }
    
    return didRoute;
}*/

@end
