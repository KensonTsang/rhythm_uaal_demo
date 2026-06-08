#if UNITY_EDITOR
using System;
using System.Collections;
using System.Text;
using UnityEngine;

public class MockNativeBridge : INativeBridge
{
    public event Action<string> onMessageReceived;

    private const int ChunkBytes = 256;
    private readonly MonoBehaviour _coroutineRunner;

    public MockNativeBridge(MonoBehaviour coroutineRunner)
    {
        _coroutineRunner = coroutineRunner;
    }

    public void PostMessageToNative(NativeMessage message)
    {
        Debug.Log($"[MockNativeBridge] PostMessageToNative: type={message.type} payload={message.payload}");

        if (message.type == "RequestJson")
        {
            var chunkId = string.IsNullOrEmpty(message.messageId) ? message.type : message.messageId;
            _coroutineRunner.StartCoroutine(SimulateJsonResponse(message.payload, chunkId));
        }
    }

    private IEnumerator SimulateJsonResponse(string resourceKey, string chunkId)
    {
        var asset = Resources.Load<TextAsset>($"MockData/{resourceKey}");
        if (asset == null)
        {
            Debug.LogError($"[MockNativeBridge] Mock data not found: Resources/MockData/{resourceKey}");
            yield break;
        }

        byte[] rawBytes = Encoding.UTF8.GetBytes(asset.text);
        int totalChunks = Mathf.CeilToInt((float)rawBytes.Length / ChunkBytes);

        for (int i = 0; i < totalChunks; i++)
        {
            int offset = i * ChunkBytes;
            int length = Mathf.Min(ChunkBytes, rawBytes.Length - offset);
            byte[] slice = new byte[length];
            Array.Copy(rawBytes, offset, slice, 0, length);

            var chunk = new MessageJson
            {
                id = chunkId,
                chunkIndex = i,
                totalChunks = totalChunks,
                data = Convert.ToBase64String(slice)
            };

            onMessageReceived?.Invoke(JsonUtility.ToJson(chunk));
            yield return null;
        }
    }
}
#endif
