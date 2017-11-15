using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

[RequireComponent(typeof(MeshFilter))]
public class DisplayNormals : MonoBehaviour
{
#if UNITY_EDITOR
	[SerializeField]
	private MeshFilter _meshFilter = null;
	[SerializeField]
	private bool _displayWireframe = false;
	[SerializeField]
	private Color _wireframeColor = new Color(0f, 0.04f, 0.25f, 0.1f);
	[SerializeField]
	private NormalsDrawData _faceNormals = new NormalsDrawData(new Color32(34, 221, 221, 155), false);
	[SerializeField]
	private NormalsDrawData _vertexNormals = new NormalsDrawData(new Color32(200, 255, 195, 127), true);

	[System.Serializable]
	private class NormalsDrawData
	{
		[Range(1, 10)]
		public int _drawEvery = 2;

		protected enum DrawType { Never, Selected, Always }
		[SerializeField]
		protected DrawType _draw = DrawType.Selected;
		[SerializeField]
		protected float _length = 0.3f;
		[SerializeField]
		protected Color _normalColor;

		private Color _baseColor = new Color32(255, 133, 0, 255);
		private const float _baseSize = 0.0125f;

		public NormalsDrawData(Color normalColor, bool draw)
		{
			_normalColor = normalColor;
			_draw = draw ? DrawType.Selected : DrawType.Never;
		}

		public bool CanDraw(bool isSelected)
		{
			return (_draw == DrawType.Always) || (_draw == DrawType.Selected && isSelected);
		}

		public void Draw(Vector3 from, Vector3 direction)
		{
			if (Camera.current.transform.InverseTransformDirection(direction).z < 0f)
			{
				Gizmos.color = _baseColor;
				Gizmos.DrawWireSphere(from, _baseSize);

				Gizmos.color = _normalColor;
				Gizmos.DrawRay(from, direction * _length);
			}
		}
	}

	/// <summary>
	/// Draw a gizmo if the object is selected. Gizmos are not pick-able.
	/// </summary>
	/// <returns></returns>
	void OnDrawGizmosSelected()
	{
		if (_meshFilter == null)
		{
			_meshFilter = GetComponent<MeshFilter>();
			if (_meshFilter == null)
				return;
		}
		Mesh mesh = _meshFilter.sharedMesh;
		Gizmos.color = _wireframeColor;
		if (_displayWireframe)
			Gizmos.DrawWireMesh(mesh);

		OnDrawNormals(true, mesh);
	}

	/// <summary>
	/// Draw gizmos on all objects (selected or not). Gizmos ARE pick-able.
	/// </summary>
	/// <returns></returns>
	void OnDrawGizmos()
	{
		if (_meshFilter == null)
		{
			_meshFilter = GetComponent<MeshFilter>();
			if (_meshFilter == null)
				return;
		}
		Mesh mesh = _meshFilter.sharedMesh;
		if (!Selection.Contains(this))
			OnDrawNormals(false, mesh);
	}

	private void OnDrawNormals(bool isSelected, Mesh mesh)
	{
		//Draw Face Normals
		if (_faceNormals.CanDraw(isSelected))
		{
			int[] triangles = mesh.triangles;
			Vector3[] vertices = mesh.vertices;

			for (int i = 0; i < triangles.Length; i += (3 * _faceNormals._drawEvery))
			{
				Vector3 v0 = transform.TransformPoint(vertices[triangles[i]]);
				Vector3 v1 = transform.TransformPoint(vertices[triangles[i + 1]]);
				Vector3 v2 = transform.TransformPoint(vertices[triangles[i + 2]]);
				Vector3 center = (v0 + v1 + v2) / 3;

				Vector3 dir = Vector3.Cross(v1 - v0, v2 - v0);
				dir /= dir.magnitude;

				_faceNormals.Draw(center, dir);
			}
		}

		//Draw Vertex Normals
		if (_vertexNormals.CanDraw(isSelected))
		{
			Vector3[] vertices = mesh.vertices;
			Vector3[] normals = mesh.normals;
			for (int i = 0; i < vertices.Length; i+=_vertexNormals._drawEvery)
			{
				_vertexNormals.Draw(transform.TransformPoint(vertices[i]), transform.TransformVector(normals[i]));
			}
		}
	}
#endif
}