using UnityEngine;
using System.Collections;

public class AtmosphereController : MonoBehaviour
{
	public GameObject m_sun;
	public Material m_skyMaterial;

	public float m_hdrExposure = 0.6f;
	public Vector3 m_atmoColor = new Vector3(0.8f,0.7f,0.45f); // Wave length of sun light
	public float m_ESun = 20.0f; 			// Sun brightness constant
	private float m_kr = 0.0025f; 			// Rayleigh scattering constant
	private float m_km = 0.0010f; 			// Mie scattering constant
	private float m_g = -0.995f;			// The Mie phase asymmetry factor, must be between 0.999 to -0.999
	public float bleed = 1f;
	public float scatter_strength = 1f;

	//Don't change these
	private const float m_outerScaleFactor = 1.025f; // Difference between inner and outer radius. Must be 2.5%
	private float m_innerRadius;		 	// Radius of the ground sphere
	private float m_outerRadius;		 	// Radius of the sky sphere
	private float m_scaleDepth = 0.25f;     // The scale depth (i.e. the altitude at which the atmosphere's average density is found)
	private float m_scale;

	void Start ()
	{
		// Get the sun gameObject via tag.
		m_sun = GameObject.FindGameObjectWithTag("Sun");

		// Get the radius of the sphere. This presumes that the sphere mesh is a unit sphere (radius of 1)
		// that has been scaled uniformly on the x, y and z axis
		m_innerRadius = transform.localScale.x;

		// The outer sphere must be 2.5% larger that the inner sphere
		m_outerRadius = m_outerScaleFactor * m_innerRadius;

		m_scale = 1.0f / (m_outerRadius - m_innerRadius);
		InitMaterial(m_skyMaterial);
	}

	void Update ()
	{
		InitMaterial(m_skyMaterial);
	}

	void InitMaterial(Material mat)
	{
		Vector3 invWaveLength4 = new Vector3(1.0f / Mathf.Pow(m_atmoColor.x, 4.0f), 1.0f / Mathf.Pow(m_atmoColor.y, 4.0f), 1.0f / Mathf.Pow(m_atmoColor.z, 4.0f));

		mat.SetVector("v3LightPos", m_sun.transform.forward * -1.0f);
		mat.SetVector("v3InvWavelength", invWaveLength4);
		mat.SetFloat("fOuterRadius", m_outerRadius);
		mat.SetFloat("fOuterRadius2", m_outerRadius * m_outerRadius);
		mat.SetFloat("fInnerRadius", m_innerRadius);
		mat.SetFloat("fInnerRadius2", m_innerRadius * m_innerRadius);
		mat.SetFloat("fKrESun", m_kr*m_ESun);
		mat.SetFloat("fKmESun", m_km*m_ESun);
		mat.SetFloat("fKr4PI", m_kr * 4.0f * Mathf.PI);
		mat.SetFloat("fKm4PI", m_km * 4.0f * Mathf.PI);
		mat.SetFloat("fScale", m_scale);
		mat.SetFloat("fScaleDepth", m_scaleDepth);
		mat.SetFloat("fScaleOverScaleDepth", m_scale / m_scaleDepth);
		mat.SetFloat("fHdrExposure", m_hdrExposure);
		mat.SetFloat("g", m_g);
		mat.SetFloat("g2", m_g*m_g);
		mat.SetFloat("bleeding", bleed);
		mat.SetFloat("scatter_strength",scatter_strength);
		mat.SetVector("v3LightPos", m_sun.transform.forward*-1.0f);
		mat.SetVector("v3Translate", transform.localPosition);
	}
}