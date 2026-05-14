using UnityEngine;
using Button = UnityEngine.UI.Button;

public class CanvasController : MonoBehaviour
{
    public Button killButton;
    public Button hideButton;

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
            NativeBridge.instance.HideUnity();
        });
        
    }
}
