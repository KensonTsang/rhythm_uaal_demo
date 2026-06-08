using UnityEngine;
using UnityEngine.UI;

public class MainSceneCanvasController : MonoBehaviour
{
   private const string REQUEST_JSON_TYPE = "RequestJson";

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

   private INativeBridge _bridge;
   private IMessageDispatcher _dispatcher;
   private readonly System.Collections.Generic.HashSet<string> _pendingJsonIds =
       new System.Collections.Generic.HashSet<string>();

   void Start()
   {
      _bridge = ServiceLocator.Get<INativeBridge>();
      _dispatcher = ServiceLocator.Get<IMessageDispatcher>();

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
         _bridge.PostMessageToNative(msg);
      });

      toggleTextViewButton.onClick.AddListener(() =>
      {
         textViewRect.gameObject.SetActive(!textViewRect.gameObject.activeSelf);
      });

      loadJson1Button.onClick.AddListener(() =>
      {
         jsonText.text = "loading json from native side...";
         Debug.Log("onClick json1");
         var msgId = System.Guid.NewGuid().ToString();
         _pendingJsonIds.Add(msgId);
         var msg = new NativeMessage { type = REQUEST_JSON_TYPE, payload = "json1", messageId = msgId };
         _bridge.PostMessageToNative(msg);
      });

      loadJson2Button.onClick.AddListener(() =>
      {
         jsonText.text = "loading json from native side...";
         Debug.Log("onClick json2");
         var msgId = System.Guid.NewGuid().ToString();
         _pendingJsonIds.Add(msgId);
         var msg = new NativeMessage { type = REQUEST_JSON_TYPE, payload = "json2", messageId = msgId };
         _bridge.PostMessageToNative(msg);
      });

      _dispatcher.onMessageDispatched += UpdateJsonTextFromNative;
   }

   void OnDestroy()
   {
      if (_dispatcher != null)
         _dispatcher.onMessageDispatched -= UpdateJsonTextFromNative;
   }

   private void UpdateJsonTextFromNative(string id, string json)
   {
      if (!_pendingJsonIds.Remove(id)) return;

      var jsonSubString = json.Substring(0, 200) + "\n...\n" + json.Substring(json.Length - 200);
      jsonText.text = jsonSubString;
   }
}
