using UnityEngine;
using UnityEngine.UI;

public class MainSceneCanvasController : MonoBehaviour
{
   public Button loadModelButton;

   [Space(10)] 
   public TMPro.TMP_Text inputText;
   public Button sendButton;

   [Space(10)] 
   public Button toggleTextViewButton;
   public RectTransform textViewRect;
   public Button loadJson1Button;
   public Button loadJson2Button;
   public TMPro.TMP_Text jsonText;

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
      
      toggleTextViewButton.onClick.AddListener(() =>
      {
         textViewRect.gameObject.SetActive(!textViewRect.gameObject.activeSelf);
      });
      
      loadJson1Button.onClick.AddListener(() =>
      {
         Debug.Log("onClick json1");
         var msg = new NativeMessage
         {
            type = "RequestJson",
            payload = "json1"
         };
         NativeBridge.instance.PostMessageToNative(msg);
         
         jsonText.text = "json1";
      });
      
      loadJson2Button.onClick.AddListener(() =>
      {
         Debug.Log("onClick json2");
         var msg = new NativeMessage
         {
            type = "RequestJson",
            payload = "json2"
         };
         NativeBridge.instance.PostMessageToNative(msg);
         
         jsonText.text = "json2";
      });
      
      
   }
}
