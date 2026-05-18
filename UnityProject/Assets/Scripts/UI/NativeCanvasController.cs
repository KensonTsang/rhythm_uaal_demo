using System;
using UnityEngine;
using UnityEngine.SceneManagement;
using Button = UnityEngine.UI.Button;

public class NativeCanvasController : MonoBehaviour
{
    public Button killButton;
    public Button hideButton;

    void Start()
    {  
        
        hideButton.onClick.AddListener(() =>
        {
            Debug.Log("onClick hideBtn");
            NativeBridge.instance.PostMessageToNative(new NativeMessage(){type = "HideUnity"});
        });
        
        killButton.onClick.AddListener(() =>
        {
            Debug.Log("onClick killBtn");
            NativeBridge.instance.PostMessageToNative(new NativeMessage(){type = "KillUnity"});
        });
        
    }
}
