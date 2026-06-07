using UnityEngine;
using Button = UnityEngine.UI.Button;

public class NativeCanvasController : MonoBehaviour
{
    public Button killButton;
    public Button hideButton;

    private INativeBridge _bridge;

    void Start()
    {
        _bridge = ServiceLocator.Get<INativeBridge>();

        hideButton.onClick.AddListener(() =>
        {
            Debug.Log("onClick hideBtn");
            _bridge.PostMessageToNative(new NativeMessage { type = "HideUnity" });
        });

        killButton.onClick.AddListener(() =>
        {
            Debug.Log("onClick killBtn");
            _bridge.PostMessageToNative(new NativeMessage { type = "KillUnity" });
        });
    }
}
