using UnityEngine;

public class ServiceBootstrapper : MonoBehaviour
{
    [SerializeField] private NativeMessageDispatcher _dispatcher;

    private void Awake()
    {
        INativeBridge bridge;

#if UNITY_EDITOR
        bridge = new MockNativeBridge(coroutineRunner: this);
#else
        bridge = GetComponent<NativeBridge>();
#endif

        _dispatcher.Bridge = bridge;

        ServiceLocator.Register<INativeBridge>(bridge);
        ServiceLocator.Register<IMessageDispatcher>(_dispatcher);
    }

    private void OnDestroy()
    {
        ServiceLocator.Clear();
    }
}
