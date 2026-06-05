using System;
using System.Collections.Generic;
using UnityEngine;

public class NativeMessageDispatcher : MonoBehaviour
{
    public static NativeMessageDispatcher instance;
    
    Dictionary<string, List<NativeBridge.MessageJson>>  _pendingMessages = new Dictionary<string, List<NativeBridge.MessageJson>>();

    public Action<string, string> onMessageDispatched;


    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
    }
    
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
        

        if (!_pendingMessages.ContainsKey(messageJson.id))
        {
            _pendingMessages.Add(messageJson.id, new List<NativeBridge.MessageJson>());
        }
        
        _pendingMessages[messageJson.id].Add(messageJson);

        if (IsChunkCompleted(messageJson.id))
        {
            FireMessageDispatched(messageJson.id);
            _pendingMessages.Remove(messageJson.id);                
        }
        
        
        Debug.Log("messageId: "+messageJson.id);
        Debug.Log("chunkIndex: "+messageJson.chunkIndex);
        Debug.Log("totalChunks: "+messageJson.totalChunks);
        Debug.Log("data size: "+messageJson.data.Length);
        
    }


    private bool IsChunkCompleted(string id)
    {
        if (!_pendingMessages.TryGetValue(id, out var chunks))
            return false;

        if (chunks.Count == 0)
            return false;

        int totalChunks = chunks[0].totalChunks;

        return chunks.Count == totalChunks;
    }


    private void FireMessageDispatched(string id)
    {
        if (!_pendingMessages.TryGetValue(id, out var chunks))
            return;

        chunks.Sort((a, b) => a.chunkIndex.CompareTo(b.chunkIndex));

        for (int i = 0; i < chunks.Count; i++)
        {
            if (chunks[i].chunkIndex != i)
            {
                Debug.LogError($"Missing chunk. Expected:{i} Actual:{chunks[i].chunkIndex}");
                return;
            }
        }

        var sb = new System.Text.StringBuilder();

        foreach (var chunk in chunks)
        {
            sb.Append(chunk.data);
        }

        string fullMessage = sb.ToString();

        Debug.Log($"Message reconstructed. Id:{id}, Length:{fullMessage.Length}");

        onMessageDispatched?.Invoke(id, fullMessage);
        
    }
    
}
