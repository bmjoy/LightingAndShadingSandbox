using UnityEngine;
using System;

/********************************************************************
	created:	2017/05/19
	created:	19:5:2017   14:54
	filename: 	e:\my documents\github\radarspherescsg\assets\jcorcam\scripts\jcororbitcam.cs
	file path:	e:\my documents\github\radarspherescsg\assets\jcorcam\scripts
	file base:	jcororbitcam
	file ext:	cs
	author:		Bryan Safarik @Pipeworks ©2017

	purpose:
    This behavior implements an orbit camera, with panning, zooming, and
    click-able look-at target setting functionality.  It also allows the user
    to limit both altitude and azimuth angles, as well as tweak the orbit and
    zoom speed.
*********************************************************************/
public class JCOROrbitCam : MonoBehaviour
{
    const string INPUT_MOUSE_SCROLLWHEEL = "Mouse ScrollWheel";
    const string INPUT_MOUSE_X = "Mouse X";
    const string INPUT_MOUSE_Y = "Mouse Y";
    const int LEFT_MOUSE_BUTTON = 0;
    const int RIGHT_MOUSE_BUTTON = 1;
    const int MIDDLE_MOUSE_BUTTON = 2;

    [ReadOnly]
    [Tooltip("Azimuth angle of camera orbit, in radians.")]
    public float azimuthAngle = 0.0f;
    [ReadOnly]
    [Tooltip("Altitude angle of camera orbit, in radians.")]
    public float altitudeAngle = 0.0f;

    [Tooltip("A reference to the camera look-at target game object.")]
    public Transform target;
    [Tooltip("Orbit speed scalar.")]
    [Range(1f, 100f)]
    public float orbitSpeed = 5f;
    [Tooltip("Zoom speed scalar.")]
    [Range(100f, 1500f)]
    public float zoomSpeed = 2f;
    [Tooltip("The closest distance the camera can get to the target.")]
    [Range(1f, 7000f)]
    public float zoomMinDist = 6480f;
    [Tooltip("The furthest distance the camera can get from the target.")]
    [Range(7000f, 25000f)]
    public float zoomMaxDist = 13000f;
    [Tooltip("The angle, in degrees, above the target that the camera can orbit to.")]
    [Range(1f, 89f)]
    public float altitudeAngleMax = 80f;
    [Tooltip("The angle, in degrees, below the target that the camera can orbit to.")]
    [Range(-89f, -1f)]
    public float altitudeAngleMin = -40f;
    [Tooltip("Should the following azimuth angle limits be used?")]
    public Boolean useAzimuthLimits = false;
    [Tooltip("The angle, in degrees, the camera can yaw to the left.")]
    [Range(0f, 180f)]
    public float azimuthAngleMax = 175f;
    [Tooltip("The angle, in degrees, the camera can yaw to the right.")]
    [Range(-180f, 0f)]
    public float azimuthAngleMin = -175f;

    private Vector3 cameraPosn;
    private GameObject transientTarget = null;
    private float zoomDistance = 13000;
    private float panWeight = 100f;

    void OnEnable()
    {
        // Register click-able target setting method with delegate/event
        // defined in ClickableTarget behavior.
        ClickableTarget.OnTargetClicked += SetTarget;
    }

    void OnDisable()
    {
        // Unregister method with delegate/event.
        ClickableTarget.OnTargetClicked -= SetTarget;
    }

	private void Start()
	{
		zoomDistance = Mathf.Abs(transform.position.z);
		if (target != null)
			Camera.main.transform.LookAt(target.position);
	}

	/// <summary>
	/// Update the camera position.
	/// </summary>
	void LateUpdate()
    {
        Vector2 orbitAdjust = Vector2.zero;
        Vector2 targetAdjust = Vector2.zero;

        // Set initial camera position.
        cameraPosn = this.transform.position;

        // Orbit via left mouse button
        if (Input.GetMouseButton(RIGHT_MOUSE_BUTTON))
        {
            orbitAdjust.x = Input.GetAxis(INPUT_MOUSE_X) * orbitSpeed;
            orbitAdjust.y = Input.GetAxis(INPUT_MOUSE_Y) * orbitSpeed;
        }
        // Zoom via scroll wheel
        else if (Input.GetAxis(INPUT_MOUSE_SCROLLWHEEL) != 0f)
        {
            zoomDistance -= Input.GetAxis(INPUT_MOUSE_SCROLLWHEEL) * zoomSpeed;
            zoomDistance = Mathf.Clamp(zoomDistance, zoomMinDist, zoomMaxDist);
        }
        // Pan via middle mouse button
        else if (Input.GetMouseButton(MIDDLE_MOUSE_BUTTON))
        {
            targetAdjust.x = -Input.GetAxis(INPUT_MOUSE_X) * panWeight;
            targetAdjust.y = -Input.GetAxis(INPUT_MOUSE_Y) * panWeight;
        }

        // Position camera in its orbit.
        azimuthAngle += orbitAdjust.x;
        if (useAzimuthLimits)
            azimuthAngle = ClampAngle(azimuthAngle, azimuthAngleMin, azimuthAngleMax);
        altitudeAngle -= orbitAdjust.y;
        altitudeAngle = ClampAngle(altitudeAngle, altitudeAngleMin, altitudeAngleMax);
        cameraPosn.x = zoomDistance * Mathf.Sin(Mathf.Deg2Rad * azimuthAngle) * Mathf.Sin(-Mathf.Deg2Rad * altitudeAngle + Mathf.PI / 2);
        cameraPosn.z = zoomDistance * Mathf.Cos(Mathf.Deg2Rad * azimuthAngle) * Mathf.Sin(-Mathf.Deg2Rad * altitudeAngle + Mathf.PI / 2);
        cameraPosn.y = zoomDistance * Mathf.Cos(-Mathf.Deg2Rad * altitudeAngle + Mathf.PI / 2);
        this.transform.position = cameraPosn;

		// Pan the target object, and have the camera track the panning
		if (target != null)
        {
            target.transform.Translate(Camera.main.transform.up * targetAdjust.y + Camera.main.transform.right * targetAdjust.x, Space.World);
            this.transform.position += target.position;
			Camera.main.transform.LookAt(target.position);
		}
	}

    /// <summary>
    /// This method is registered with the OnTargetClicked event defined
    /// in the ClickableTarget behavior.  The behavior can be attached to any
    /// GameObject in the scene to enable it to be clicked and set as the
    /// lookAt target of the orbit camera. Note that the click-able object MUST
    /// have a collider component as well, so that the OnMouseDown() event
    /// is available.
    /// </summary>
    private void SetTarget(Transform t)
    {
        // Destroy preexisting transient target object, if any.
        if (transientTarget != null)
        {
            Destroy(transientTarget);
        }

        // Instantiate a new transient target empty GameObject and assign to target
        transientTarget = new GameObject("TransientTarget");
        transientTarget.transform.position = t.position;
        transientTarget.transform.rotation = t.rotation;
        target = transientTarget.transform;
    }

    /// <summary>
    /// Clamps an angle between min and max degrees.
    /// </summary>
    /// <param name="angle">The angle to clamp, in degreese.</param>
    /// <param name="min">Low limit of clamp.</param>
    /// <param name="max">High limit of clamp.</param>
    /// <returns></returns>
    public static float ClampAngle(float angle, float min, float max)
    {
        // Keep angle param between 0 and 360 degrees
        if (angle < -360f)
            angle += 360f;
        if (angle > 360f)
            angle -= 360f;

        // Clamp angle to min and max params
        return Mathf.Clamp(angle, min, max);
    }
}