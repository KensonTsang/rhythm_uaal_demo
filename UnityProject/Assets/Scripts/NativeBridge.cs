using System.Runtime.InteropServices;
using UnityEngine;

public class NativeBridge : MonoBehaviour
{
    public static NativeBridge instance;
    
    [DllImport("__Internal")]
    private static extern void HideUnityView();


    [DllImport("__Internal")]
    private static extern void KillUnityView();


    private void Awake()
    {
        if (instance == null)
        {
            instance = this.GetComponent<NativeBridge>();
        }
        Debug.Log("NativeBridge Awake");
        DontDestroyOnLoad(this.gameObject);
    }


    public void HideUnity()
    {
        Debug.Log("NativeBridge CloseUnity");
#if UNITY_IOS && !UNITY_EDITOR
        HideUnityView();
#endif
    }
    
    public void KillUnity()
    {
        Debug.Log("NativeBridge KillUnity");
#if UNITY_IOS && !UNITY_EDITOR
        KillUnityView();
#endif
    }
    
    
}
