using UnityEngine;

public class RotateMe : MonoBehaviour
{
    
    public float rotationSpeed = 100f;
    
    void Update()
    {   
        transform.RotateAround(transform.position, Vector3.forward, rotationSpeed * Time.deltaTime);
    }
}
