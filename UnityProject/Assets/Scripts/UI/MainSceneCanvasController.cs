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
         jsonText.text = "json1";
      });
      
      loadJson2Button.onClick.AddListener(() =>
      {
         jsonText.text = "json2";
      });
      
      
   }
}
