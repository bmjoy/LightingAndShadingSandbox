using UnityEngine;
using System.Linq;

//[ExecuteInEditMode]
public class ReverseNormalsAlt : MonoBehaviour
{
	// Use this for initialization
	void Start ()
	{
		Mesh mesh = GetComponent<MeshFilter>().sharedMesh;
		mesh.triangles = mesh.triangles.Reverse().ToArray();
	}
}
