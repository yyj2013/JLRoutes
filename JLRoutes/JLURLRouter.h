/*
 Copyright (c) 2015, Joel Levin
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of JLRoutes nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import "JLRoute.h"


static NSString *__nonnull const JLRoutePathKey = @"JLRoutePath";
static NSString *__nonnull const JLRouteURLKey = @"JLRouteURL";
static NSString *__nonnull const JLRouteSchemeKey = @"JLRouteScheme";
static NSString *__nonnull const JLRouteWildcardComponentsKey = @"JLRouteWildcardComponents";


@interface JLURLRouter : NSObject

/// Create URL router instance for the given scheme. Scheme is optional.
- (nonnull instancetype)initWithScheme:(nullable NSString *)scheme NS_DESIGNATED_INITIALIZER;


/// The URL scheme associated with this router
@property (nonatomic, strong, nullable, readonly) NSString *scheme;

/// Controls whether or not this routes controller will try to match a URL with global routes if it can't be matched in the current namespace. Default is NO.
@property (nonatomic) BOOL shouldFallbackToGlobalRoutes;

/// Called any time routeURL returns NO. Respects shouldFallbackToGlobalRoutes.
@property (nonatomic, copy, nullable) void (^unmatchedURLHandler)(JLRoutes *__nonnull routes, NSURL *__nonnull URL, NSDictionary *__nonnull parameters);


// Setting up routes


/// Registers a route instance
- (void)registerRoute:(nonnull __kindof JLRoute *)route;

/// Creates and registers a route with default priority (0)
- (nonnull JLRoute *)addRoute:(nonnull NSString *)routePath handler:(nonnull BOOL (^)(NSDictionary *__nonnull parameters))handlerBlock;

/// Creates and registers a route with given priority
- (nonnull JLRoute *)addRoute:(nonnull NSString *)routePath priority:(NSUInteger)priority handler:(nonnull BOOL (^)(NSDictionary *__nonnull parameters))handlerBlock;

/// Creates and registers multiple routes with a single handler and with default priority (0)
- (nonnull NSArray<JLRoute *> *)addRoutes:(nonnull NSArray<NSString *> *)routePaths handler:(nonnull BOOL (^)(NSDictionary *__nonnull parameters))handlerBlock;

/// Removes the first route with the matching path
- (void)removeRouteWithPath:(nonnull NSString *)routePath;

/// Removes the route with the matching identifier
- (void)removeRouteWithIdentifier:(nonnull NSString *)routeIdentifier;

/// Removes all routes
- (void)removeAllRoutes;

/// Creates and registers a route with default priority (0) using dictionary-style subscripting.
- (void)setObject:(nonnull BOOL (^)(NSDictionary *__nonnull parameters))handlerBlock forKeyedSubscript:(nonnull NSString *)routePatten;


// Routing

/// Returns whether a route exists for a URL
- (BOOL)canRouteURL:(nonnull NSURL *)URL;

/// Routes a URL, calling handler blocks (for patterns that match URL) until one returns YES.
- (BOOL)routeURL:(nonnull NSURL *)URL;

/// Routes a URL, calling handler blocks (for patterns that match URL) until one returns YES, optionally specifying a userInfo dictionary.
- (BOOL)routeURL:(nonnull NSURL *)URL userInfo:(nullable NSDictionary *)userInfo;

/// Prints the entire routing table
- (nonnull NSString *)routesDescription;


@end
