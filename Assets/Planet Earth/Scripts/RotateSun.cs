using UnityEngine;
using System.Collections;


public class RotateSun : MonoBehaviour
{
	[SerializeField]
	private Transform _rotationOrient;
	public Transform rotationOrient
	{
		get { return _rotationOrient; }
		set
		{
			_rotationOrient = value;
		}
	}
	private float mouseXAmount;

	private void Start()
	{
		transform.SetPositionAndRotation(transform.position, rotationOrient.localRotation);
	}


	void Update ()
	{
		if(Input.GetMouseButton(0))
		{
			mouseXAmount = -Input.GetAxis("Mouse X") * 3f;
			transform.Rotate(Vector3.up * mouseXAmount);
		}

		if(Input.GetKey(KeyCode.Delete))
		{
			transform.Rotate(0,0.2f,0);
		}

		if(Input.GetKey(KeyCode.PageDown))
		{
			transform.Rotate(0,-0.2f,0);
		}

		if(Input.GetKey(KeyCode.Home))
		{
			transform.Rotate(0.2f,0,0);
		}

		if(Input.GetKey(KeyCode.End))
		{
			transform.Rotate(-0.2f,0,0);
		}
	}
}
