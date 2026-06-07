using System;

[Serializable]
public class MessageJson
{
    public string id;
    public int chunkIndex;
    public int totalChunks;
    public string data;
}
