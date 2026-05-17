using UnityEngine;
using UnityEngine.UI;

public class MainSceneCanvasController : MonoBehaviour
{
   public Button loadModelButton;


   void Start()
   {
      loadModelButton.onClick.AddListener(() =>
      {
         var rocket = Resources.Load<GameObject>("Prefabs/Rocket");
         Instantiate(rocket);
         
         loadModelButton.gameObject.SetActive(false);
      });
   }
}
