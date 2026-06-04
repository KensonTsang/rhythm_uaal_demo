using System;
using UnityEngine;

public class JsonMessageDispatcher : MonoBehaviour
{
    void Start()
    {
        NativeBridge.instance.onMessageReceived += DispatchMessage;
    }

    private void OnDestroy()
    {
        NativeBridge.instance.onMessageReceived -= DispatchMessage;
    }

    private void DispatchMessage(string message)
    {
        Debug.Log("payload length: "+message.Length);
        var messageJson = JsonUtility.FromJson<NativeBridge.MessageJson>(message);
        
        
        Debug.Log("messageId: "+messageJson.id);
        Debug.Log("chunkIndex: "+messageJson.chunkIndex);
        Debug.Log("totalChunks: "+messageJson.totalChunks);
        Debug.Log("data size: "+messageJson.data.Length);
        
        
    } 
}
