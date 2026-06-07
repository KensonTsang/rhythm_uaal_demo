using System;
using System.Collections.Generic;
using UnityEngine;

public class NativeMessageDispatcher : MonoBehaviour, IMessageDispatcher
{
    public INativeBridge Bridge { get; set; }

    private readonly Dictionary<string, List<MessageJson>> _pendingMessages =
        new Dictionary<string, List<MessageJson>>();

    public event Action<string, string> onMessageDispatched;

    private void Start()
    {
        if (Bridge == null)
            throw new InvalidOperationException(
                "[NativeMessageDispatcher] Bridge not set. Was ServiceBootstrapper executed?");
        Bridge.onMessageReceived += DispatchMessage;
    }

    private void OnDestroy()
    {
        if (Bridge != null)
            Bridge.onMessageReceived -= DispatchMessage;
    }

    private void DispatchMessage(string message)
    {
        var chunk = JsonUtility.FromJson<MessageJson>(message);

        if (!_pendingMessages.ContainsKey(chunk.id))
            _pendingMessages.Add(chunk.id, new List<MessageJson>(chunk.totalChunks));

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

        return chunks.Count == chunks[0].totalChunks;
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
                Debug.LogError($"Missing chunk. Expected:{i} Actual:{chunks[i].chunkIndex}");
                return;
            }
        }

        var allBytes = new List<byte>();
        foreach (var chunk in chunks)
        {
            try
            {
                allBytes.AddRange(Convert.FromBase64String(chunk.data));
            }
            catch (Exception e)
            {
                Debug.LogError($"Failed to decode Base64 chunk {chunk.chunkIndex}: {e}");
                return;
            }
        }

        string fullMessage = System.Text.Encoding.UTF8.GetString(allBytes.ToArray());
        Debug.Log($"Message reconstructed. Id:{id}, Length:{fullMessage.Length}");

        onMessageDispatched?.Invoke(id, fullMessage);
    }
}
