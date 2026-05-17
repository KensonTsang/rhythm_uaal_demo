using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class StartSceneCanvasController : MonoBehaviour
{
    public Button mainSceneButton;

    void Start()
    {
        mainSceneButton.onClick.AddListener(() =>
        {
            SceneManager.LoadScene("MainScene");
        });
    }
}
