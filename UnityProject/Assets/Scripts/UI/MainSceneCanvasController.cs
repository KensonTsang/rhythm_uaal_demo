using UnityEngine;
using UnityEngine.UI;

public class MainSceneCanvasController : MonoBehaviour
{
   public Button loadModelButton;

   [Space(10)] 
   public TMPro.TMP_Text inputText;
   public Button sendButton;

   void Start()
   {
      loadModelButton.onClick.AddListener(() =>
      {
         var rocket = Resources.Load<GameObject>("Prefabs/Rocket");
         Instantiate(rocket);
         
         loadModelButton.gameObject.SetActive(false);
      });
      
      sendButton.onClick.AddListener(() =>
      {
         var msg = new NativeMessage
         {
            type = "UpdateText",
            payload = inputText.text
         };
         NativeBridge.instance.PostMessageToNative(msg);
      });
      
   }
}
