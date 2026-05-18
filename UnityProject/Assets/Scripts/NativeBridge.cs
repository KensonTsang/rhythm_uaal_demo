using System.Runtime.InteropServices;
using UnityEngine;

public class NativeBridge : MonoBehaviour
{
    public static NativeBridge instance;
    
    [DllImport("__Internal")]
    private static extern void SendMessageToNative(string message);


    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
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
    
    
    
}
