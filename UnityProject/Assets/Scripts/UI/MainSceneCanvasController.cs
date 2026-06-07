using UnityEngine;
using UnityEngine.UI;

public class MainSceneCanvasController : MonoBehaviour
{
   
   private const string REQUEST_JSON_ID = "RequestJson";
   
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
            type = REQUEST_JSON_ID,
            payload = "json1"
         };
         NativeBridge.instance.PostMessageToNative(msg);
      });
      
      loadJson2Button.onClick.AddListener(() =>
      {
         Debug.Log("onClick json2");
         var msg = new NativeMessage
         {
            type = REQUEST_JSON_ID,
            payload = "json2"
         };
         NativeBridge.instance.PostMessageToNative(msg);
      });


      NativeMessageDispatcher.instance.onMessageDispatched += UpdateJsonTextFromNative;

   }

   void OnDestroy()
   {
      NativeMessageDispatcher.instance.onMessageDispatched -= UpdateJsonTextFromNative;
   }


   private void UpdateJsonTextFromNative(string id, string json)
   {
      if (id != REQUEST_JSON_ID) return;
      
      var jsonSubString = json.Substring(0, 200) + "\n...\n" + json.Substring(json.Length - 200);
      jsonText.text = jsonSubString;
   }
   
}
