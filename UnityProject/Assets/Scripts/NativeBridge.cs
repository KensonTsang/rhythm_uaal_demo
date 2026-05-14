using System.Runtime.InteropServices;
using UnityEngine;

public class NativeBridge : MonoBehaviour
{
    public static NativeBridge instance;
    
    [DllImport("__Internal")]
    private static extern void HideUnityView();


    private void Awake()
    {
        if (instance == null)
        {
            instance = this.GetComponent<NativeBridge>();
        }
        Debug.Log("NativeBridge Awake");
    }


    public void HideUnity()
    {
        Debug.Log("NativeBridge CloseUnity");
#if UNITY_IOS && !UNITY_EDITOR
            HideUnityView();
#endif
    }
    
}
