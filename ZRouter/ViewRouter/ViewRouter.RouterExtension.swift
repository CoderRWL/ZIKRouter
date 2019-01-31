//
//  RouterExtension.swift
//  ZRouter
//
//  Created by zuik on 2018/1/20.
//  Copyright © 2017 zuik. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import ZIKRouter

public extension ViewRouteConfig {
    public func configurePath(_ path: ViewRoutePath) {
        if let source = path.source {
            self.source = source
        }
        self.routeType = path.routeType
    }
}

// MARK: View Router Extension

/// Add Swift methods for ZIKViewRouter. Unavailable for any other classes.
public protocol ViewRouterExtension: class {
    static func register<Protocol>(_ routableView: RoutableView<Protocol>)
    static func register<Protocol>(_ routableViewModule: RoutableViewModule<Protocol>)
    static func register<Protocol>(_ routableView: RoutableView<Protocol>, forMakingView viewClass: AnyClass)
    static func register<Protocol>(_ routableView: RoutableView<Protocol>, forMakingView viewClass: AnyClass, making: @escaping (ViewRouteConfig, ZIKAnyViewRouter) -> Protocol?)
}

public extension ViewRouterExtension {
    /// Register a view protocol that all views registered with the router conforming to.
    ///
    /// - Parameter routableView: A routabe entry carrying a protocol conformed by the destination of the router.
    static func register<Protocol>(_ routableView: RoutableView<Protocol>) {
        Registry.register(routableView, forRouter: self)
    }
    
    /// Register a module config protocol conformed by the router's default route configuration.
    ///
    /// - Parameter routableViewModule: A routabe entry carrying a module config protocol conformed by the custom configuration of the router.
    static func register<Protocol>(_ routableViewModule: RoutableViewModule<Protocol>) {
        Registry.register(routableViewModule, forRouter: self)
    }
    
    /// Register view class with protocol without using any router subclass. The view will be created with `[[viewClass alloc] init]` when used. Use this if your view is very easy and don't need a router subclass.
    ///
    /// - Parameters:
    ///   - routableView: A routabe entry carrying a protocol conformed by the destination.
    ///   - viewClass: The view class.
    static func register<Protocol>(_ routableView: RoutableView<Protocol>, forMakingView viewClass: AnyClass) {
        Registry.register(routableView, forMaking: viewClass)
    }
    
    /// Register view class with protocol without using any router subclass. The view will be created with the `making` block when used. Use this if your view is very easy and don't need a router subclass.
    ///
    /// - Parameters:
    ///   - routableView: A routabe entry carrying a protocol conformed by the destination.
    ///   - viewClass: The view class.
    ///   - making: Block creating the view.
    static func register<Protocol>(_ routableView: RoutableView<Protocol>, forMakingView viewClass: AnyClass, making: @escaping (ViewRouteConfig, ZIKAnyViewRouter) -> Protocol?) {
        assert(_swift_typeIsTargetType(viewClass, Protocol.self), "When registering, destination (\(viewClass)) should conforms to protocol (\(Protocol.self))")
        _ = ZIKAnyViewRoute.make(withDestination: viewClass) { (config, router) -> AnyObject? in
            if let router = router as? ZIKAnyViewRouter, let destination = making(config, router) {
                return destination as AnyObject
            }
            return nil
        }.register(routableView)
    }
}

extension ZIKViewRouter: ViewRouterExtension {
    
}

// MARK: Adapter Extension

public extension ZIKViewRouteAdapter {
    
    /// Register adapter and adaptee protocols conformed by the destination. Then if you try to find router with the adapter, there will return the adaptee's router.
    ///
    /// - Parameter adapter: The required protocol used in the user. The protocol should not be directly registered with any router yet.
    /// - Parameter adaptee: The provided protocol.
    public static func register<Adapter, Adaptee>(adapter: RoutableView<Adapter>, forAdaptee adaptee: RoutableView<Adaptee>) {
        Registry.register(adapter: adapter, forAdaptee: adaptee)
    }
    
    /// Register adapter and adaptee protocols conformed by the default configuration of the adaptee's router. Then if you try to find router with the adapter, there will return the adaptee's router.
    ///
    /// - Parameter adapter: The required protocol used in the user. The protocol should not be directly registered with any router yet.
    /// - Parameter adaptee: The provided protocol.
    public static func register<Adapter, Adaptee>(adapter: RoutableViewModule<Adapter>, forAdaptee adaptee: RoutableViewModule<Adaptee>) {
        Registry.register(adapter: adapter, forAdaptee: adaptee)
    }
}

// MARK: View Route Extension

/// Add Swift methods for ZIKViewRoute. Unavailable for any other classes.
public protocol ViewRouteExtension: class {
    #if swift(>=4.1)
    func register<Protocol>(_ routableView: RoutableView<Protocol>) -> Self
    func register<Protocol>(_ routableViewModule: RoutableViewModule<Protocol>) -> Self
    #else
    func register<Protocol>(_ routableView: RoutableView<Protocol>)
    func register<Protocol>(_ routableViewModule: RoutableViewModule<Protocol>)
    #endif
}

public extension ViewRouteExtension {
    
    #if swift(>=4.1)
    
    /// Register pure Swift protocol or objc protocol for your view with this ZIKViewRoute.
    ///
    /// - Parameter routableView: A routabe entry carrying a protocol conformed by the destination of the router.
    /// - Returns: Self
    func register<Protocol>(_ routableView: RoutableView<Protocol>) -> Self {
        Registry.register(routableView, forRoute: self)
        return self
    }
    
    /// Register pure Swift protocol or objc protocol for your custom configuration with a ZIKViewRoute. You must add `makeDefaultConfiguration` for this route, and router will check whether the registered config protocol is conformed by the defaultRouteConfiguration.
    ///
    /// - Parameter routableViewModule: A routabe entry carrying a module config protocol conformed by the custom configuration of the router.
    /// - Returns: Self
    func register<Protocol>(_ routableViewModule: RoutableViewModule<Protocol>) -> Self {
        Registry.register(routableViewModule, forRoute: self)
        return self
    }
    
    #else
    
    func register<Protocol>(_ routableView: RoutableView<Protocol>) {
        Registry.register(routableView, forRoute: self)
    }
    
    /// Register pure Swift protocol or objc protocol for your custom configuration with a ZIKViewRoute. You must add `makeDefaultConfiguration` for this route, and router will check whether the registered config protocol is conformed by the defaultRouteConfiguration.
    ///
    /// - Parameter routableViewModule: A routabe entry carrying a module config protocol conformed by the custom configuration of the router.
    /// - Returns: Self
    func register<Protocol>(_ routableViewModule: RoutableViewModule<Protocol>) {
        Registry.register(routableViewModule, forRoute: self)
    }
    
    #endif
}

extension ZIKViewRoute: ViewRouteExtension {
    
}