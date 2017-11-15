using UnityEngine;

/// <summary>
/// This behavior is a helper utility which, when applied
/// to the Main Camera in a scene and supplied with the
/// accompanying VisualizeDeptHBuffer shader, shows
/// the camera's depth buffer contents.
/// </summary>
[ExecuteInEditMode]
public class VisualizeDepthBuffer: MonoBehaviour
{
	public Shader depthVizShader;

	Material depthVizMaterial = null;
	Camera effectCamera = null;

	void Start()
	{
		effectCamera = this.GetComponent<Camera>();
		if (effectCamera == null)
		{
			Debug.LogWarning(string.Format("{0}: No camera effect specified. Disabling image effect.", gameObject.name), this.gameObject);
			enabled = false;
		}
		else
			effectCamera.depthTextureMode = DepthTextureMode.Depth;

		if (depthVizShader != null)
		{
			depthVizMaterial = new Material(depthVizShader);
			if (depthVizMaterial == null)
			{
				Debug.LogWarning(string.Format("{0}: Can't create material from {1}. Disabling image effect.", gameObject.name, depthVizShader.name), this.gameObject);
				enabled = false;
			}
		}
		else
		{
			Debug.LogWarning(string.Format("{0}: Depth Viz Shader is not specified. Disabling image effect.", gameObject.name), this.gameObject);
			enabled = false;
		}
	}

	void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if (depthVizMaterial == null)
			depthVizMaterial = new Material(depthVizShader);

		Graphics.Blit(source, destination, depthVizMaterial);
	}

	void OnDisable()
	{
		if (depthVizMaterial != null)
		{
			DestroyImmediate(depthVizMaterial);
		}
	}
}