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


static NSString *__nonnull const JLRouteParamRouteKey = @"JLRouteParamRouteKey";
static NSString *__nonnull const JLRouteParamURLKey = @"JLRouteParamURLKey";
static NSString *__nonnull const JLRouteParamWildcardParamsKey = @"JLRouteParamWildcardParamsKey";
static NSString *__nonnull const JLRouteParamUserInfoKey = @"JLRouteParamUserInfoKey";


@interface JLURLRouter : NSObject

/// Create URL router instance for the given scheme. Scheme is optional.
- (nonnull instancetype)initWithScheme:(nullable NSString *)scheme NS_DESIGNATED_INITIALIZER;

/// The URL scheme associated with this router
@property (nonatomic, strong, nullable, readonly) NSString *scheme;

/// Called any time routeURL returns NO. Respects shouldFallbackToGlobalRoutes.
@property (nonatomic, copy, nullable) BOOL (^unmatchedURLHandler)(__kindof JLURLRouter *__nonnull router, NSURL *__nonnull URL, NSDictionary *__nonnull userInfo);

/// Customize the default router class. Defaults to [JLRoute class].
@property (nonatomic, nonnull) Class defaultRouterClass;


// -- Route management -----------------

/// Registers a route instance
- (void)registerRoute:(nonnull __kindof JLRoute *)route;

/// Creates and registers a route with priority JLRouteDefaultPriority
- (nonnull __kindof JLRoute *)addRouteWithPath:(nonnull NSString *)routePath handler:(nonnull BOOL (^)(NSDictionary <NSString *, id> *__nonnull parameters))handlerBlock;

/// Creates and registers a route with a specified priority
- (nonnull __kindof JLRoute *)addRouteWithPath:(nonnull NSString *)routePath priority:(NSUInteger)priority handler:(nonnull BOOL (^)(NSDictionary <NSString *, id> *__nonnull parameters))handlerBlock;

/// Creates and registers multiple routes with a single handler and with priority JLRouteDefaultPriority
- (nonnull NSArray<__kindof JLRoute *> *)addRoutesWithPaths:(nonnull NSArray<NSString *> *)routePaths handler:(nonnull BOOL (^)(NSDictionary <NSString *, id> *__nonnull parameters))handlerBlock;

/// Returns the route with the given path, if it can be found in this router
- (nullable __kindof JLRoute *)routeWithPath:(nonnull NSString *)path;

/// Removes an arbtrary route instance
- (void)removeRoute:(nonnull __kindof JLRoute *)route;

/// Removes the first route with the matching path
- (void)removeRouteWithPath:(nonnull NSString *)routePath;

/// Removes all routes
- (void)removeAllRoutes;


// -- Routing -----------------

/// Returns whether a route exists for a URL
- (BOOL)canRouteURL:(nonnull NSURL *)URL;

/// Routes a URL, calling handler blocks (for patterns that match URL) until one returns YES.
- (BOOL)routeURL:(nonnull NSURL *)URL;

/// Routes a URL, calling handler blocks (for patterns that match URL) until one returns YES, optionally specifying a userInfo dictionary.
- (BOOL)routeURL:(nonnull NSURL *)URL userInfo:(nullable NSDictionary *)userInfo;


@end
