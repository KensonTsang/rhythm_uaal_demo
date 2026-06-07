using System;

public interface INativeBridge
{
    event Action<string> onMessageReceived;
    void PostMessageToNative(NativeMessage message);
}
