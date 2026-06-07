using System;
using System.Collections.Generic;

public static class ServiceLocator
{
    static readonly Dictionary<Type, object> _services = new Dictionary<Type, object>();

    public static void Register<T>(T service)
    {
        _services[typeof(T)] = service;
    }

    public static T Get<T>()
    {
        if (_services.TryGetValue(typeof(T), out var service))
            return (T)service;
        throw new InvalidOperationException(
            $"[ServiceLocator] Service not registered: {typeof(T).Name}. " +
            "Ensure ServiceBootstrapper runs before any consumer's Start().");
    }

    public static void Clear() => _services.Clear();
}
