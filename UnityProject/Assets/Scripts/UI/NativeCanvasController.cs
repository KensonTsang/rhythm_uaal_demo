using System;
using UnityEngine;
using UnityEngine.SceneManagement;
using Button = UnityEngine.UI.Button;

public class NativeCanvasController : MonoBehaviour
{
    public Button killButton;
    public Button hideButton;

    private void Awake()
    {
        DontDestroyOnLoad(gameObject);
    }


    void Start()
    {  
        
        hideButton.onClick.AddListener(() =>
        {
            Debug.Log("onClick hideBtn");
            NativeBridge.instance.HideUnity();
        });
        
        killButton.onClick.AddListener(() =>
        {
            Debug.Log("onClick killBtn");
            NativeBridge.instance.KillUnity();
        });
        
    }
}
