using System;
using System.Runtime.InteropServices;
using UnityEngine;

public class NativeBridge : MonoBehaviour, INativeBridge
{
    public event Action<string> onMessageReceived;

    [DllImport("__Internal")]
    private static extern void SendMessageToNative(string message);

    private void Awake()
    {
        Debug.Log("NativeBridge Awake");
    }

    public void PostMessageToNative(NativeMessage message)
    {
        string json = JsonUtility.ToJson(message);
        Debug.Log($"PostMessageToNative: {json}");
#if UNITY_IOS && !UNITY_EDITOR
        SendMessageToNative(json);
#endif
    }

    public void OnMessageReceived(string msg)
    {
        onMessageReceived?.Invoke(msg);
    }
}
