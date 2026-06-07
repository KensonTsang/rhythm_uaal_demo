using System;

public interface IMessageDispatcher
{
    event Action<string, string> onMessageDispatched;
}
