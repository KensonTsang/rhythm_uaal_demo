using UnityEngine;

public class RotateMe : MonoBehaviour
{

    public Vector3 axis;
    public float rotationSpeed = 100f;
    
    void Update()
    {   
        transform.RotateAround(transform.position, axis, rotationSpeed * Time.deltaTime);
    }
}
