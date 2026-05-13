using UnityEngine;
using Button = UnityEngine.UI.Button;

public class CanvasController : MonoBehaviour
{
    public Button closeButton;

    void Start()
    {  
        closeButton.onClick.AddListener(() =>
        {
            Debug.Log("onClick closeBtn");
            NativeBridge.instance.CloseUnity();
        });
    }
}
