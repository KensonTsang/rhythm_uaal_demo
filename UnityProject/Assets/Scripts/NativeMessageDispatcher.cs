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
        var chunk = JsonUtility.FromJson<NativeBridge.MessageJson>(message);

        if (!_pendingMessages.ContainsKey(chunk.id))
        {
            _pendingMessages.Add(chunk.id, new List<NativeBridge.MessageJson>(chunk.totalChunks));
        }
        
        _pendingMessages[chunk.id].Add(chunk);

        if (IsChunkCompleted(chunk.id))
        {
            FireMessageDispatched(chunk.id);
            _pendingMessages.Remove(chunk.id);                
        }
        
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

        Debug.Log($"FireMessageDispatched, total chunks: {chunks.Count}");
        
        for (int i = 0; i < chunks.Count; i++)
        {
            if (chunks[i].chunkIndex != i)
            {
                Debug.LogError(
                    $"Missing chunk. Expected:{i} Actual:{chunks[i].chunkIndex}");
                return;
            }
        }

        List<byte> allBytes = new();

        foreach (var chunk in chunks)
        {
            try
            {
                byte[] bytes = Convert.FromBase64String(chunk.data);
                allBytes.AddRange(bytes);
            }
            catch (Exception e)
            {
                Debug.LogError(
                    $"Failed to decode Base64 chunk {chunk.chunkIndex}: {e}");
                return;
            }
        }

        string fullMessage =
            System.Text.Encoding.UTF8.GetString(allBytes.ToArray());

        Debug.Log(
            $"Message reconstructed. Id:{id}, Length:{fullMessage.Length}");

        onMessageDispatched?.Invoke(id, fullMessage);
        
    }
    
}
