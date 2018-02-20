using UnityEngine;
using System.Collections;

public class Atmosphere : MonoBehaviour
{
	[Tooltip("Directional light GO representing the sun.")]
	public GameObject m_sun;
	[Tooltip("Scatter material for the ground.")]
	public Material m_groundMaterial;
	[Tooltip("Scatter material for the sky.")]
	public Material m_skyMaterial;

	[Tooltip("HDR exposure constant.")]
	[Range(0f, 3f)]
	public float m_hdrExposure = 0.8f;
	[Tooltip("Sunlight wavelength (RGB).")]
	public Vector3 m_waveLength = new Vector3(0.65f, 0.57f, 0.475f); // Wave length of sun light
	[Tooltip("Sun brightness constant.")]
	public float m_ESun = 20.0f;						// Sun brightness constant
	[Tooltip("Rayleigh scattering constant, sky.")]
	public float m_kr = 0.0025f;						// Rayleigh scattering constant, sky
	//[Tooltip("Rayleigh scattering constant, ground.")]
	//public float m_kr_ground = 0.175f;					// Rayleigh scattering constant, ground
	[Tooltip("Rayleigh phase function bias.")]
	[Range(0f, 3f)]
	public float m_krPhaseBias;							// Tweaker for Rayleigh phase function calculation in shader fragment program
	[Tooltip("Mie scattering constant.")]
	public float m_km = 0.0010f;						// Mie scattering constant
	[Tooltip("Mie phase asymmetry factor.")]
	[Range(-0.99f, 0.99f)]
    public float m_g = -0.990f;                         // The Mie phase asymmetry factor, must be between 0.999 to -0.999

	public float bleed = 1f;
	public float scatter_strength = 1f;

	// Don't change these!
	private const float m_outerScaleFactor = 1.025f;	// Difference between inner and outer radius. Must be 2.5%
    private float m_innerRadius;						// Radius of the ground sphere
    private float m_outerRadius;						// Radius of the sky sphere
    private float m_scaleHeight = 0.25f;				// The scale height (i.e. the altitude at which the atmosphere's average density is found)

	private Vector3 m_invWaveLength4;
	private float m_scale;

	private void Awake()
	{
		// Pre-calculate Rayleigh wavelength-dependent scattering ratio.
		//m_invWaveLength4 = new Vector3(1.0f / Mathf.Pow(m_waveLength.x, 4.0f), 1.0f / Mathf.Pow(m_waveLength.y, 4.0f), 1.0f / Mathf.Pow(m_waveLength.z, 4.0f));
	}

	void Start()
    {
		// Get the sun gameObject via tag.
		if (m_sun == null)
			m_sun = GameObject.FindGameObjectWithTag("Sun");

		// Get the radius of the sphere. This presumes that the sphere mesh is a unit sphere (radius of 1)
		// that has been scaled uniformly on the x, y and z axis
		m_innerRadius = transform.localScale.x;

        // The outer sphere must be 2.5% larger that the inner sphere
        m_outerRadius = m_outerScaleFactor * m_innerRadius;

		// Inverse of difference between atmosphere radius and planetary radius
		m_scale = 1.0f / (m_outerRadius - m_innerRadius);

		// Push parameter values to shader globals
		UpdateMaterial(m_groundMaterial);
        UpdateMaterial(m_skyMaterial);
    }

    void Update()
    {
        UpdateMaterial(m_groundMaterial);
        UpdateMaterial(m_skyMaterial);
    }

    void UpdateMaterial(Material mat)
    {
		// Pre-calculate Rayleigh wavelength-dependent scattering ratio.
		m_invWaveLength4 = new Vector3(1.0f / Mathf.Pow(m_waveLength.x, 4.0f), 1.0f / Mathf.Pow(m_waveLength.y, 4.0f), 1.0f / Mathf.Pow(m_waveLength.z, 4.0f));

		// Hungarian notation, yuck.
		mat.SetVector("v3LightPos", m_sun.transform.forward * -1.0f);
        mat.SetVector("v3InvWavelength", m_invWaveLength4);
        mat.SetFloat("fOuterRadius", m_outerRadius);
        mat.SetFloat("fOuterRadius2", m_outerRadius * m_outerRadius);
        mat.SetFloat("fInnerRadius", m_innerRadius);
        mat.SetFloat("fInnerRadius2", m_innerRadius * m_innerRadius);
        mat.SetFloat("fKrESun", m_kr * m_ESun);
		//mat.SetFloat("fKrESun_ground", m_kr * 50f * m_ESun);
		mat.SetFloat("fKmESun", m_km * m_ESun);
        mat.SetFloat("fKr4PI", m_kr * 4.0f * Mathf.PI);
		//mat.SetFloat("fKr4PI_ground", m_kr * 50f * 4.0f * Mathf.PI);
		mat.SetFloat("fKm4PI", m_km * 4.0f * Mathf.PI);
        mat.SetFloat("fScale", m_scale);
        mat.SetFloat("fScaleHeight", m_scaleHeight);
        mat.SetFloat("fScaleOverScaleDepth", m_scale / m_scaleHeight);
        mat.SetFloat("fHdrExposure", m_hdrExposure);
        mat.SetFloat("g", m_g);
        mat.SetFloat("g2", m_g * m_g);
        mat.SetVector("v3LightPos", m_sun.transform.forward * -1.0f);
        mat.SetVector("v3Translate", transform.localPosition);
		mat.SetFloat("krPhaseBias", m_krPhaseBias);
		mat.SetFloat("bleeding", bleed);
		mat.SetFloat("scatter_strength", scatter_strength);
	}
}