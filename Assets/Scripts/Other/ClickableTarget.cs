using UnityEngine;

/********************************************************************
	created:	2017/05/19
	created:	19:5:2017   15:09
	filename: 	E:\My Documents\GitHub\RadarSpheresCSG\Assets\JCORCam\Scripts\ClickableTarget.cs
	file path:	E:\My Documents\GitHub\RadarSpheresCSG\Assets\JCORCam\Scripts
	file base:	ClickableTarget
	file ext:	cs
	author:		Bryan Safarik @Pipeworks ©2017

	purpose: This behavior implements a delegate/event system that
    allows the JCOR orbit camera behavior to set its look-at target
    when an object hosting this behavior is clicked on.
    The script responds in response to an OnMouseDown() event, generated
    by way of a Collider component that MUST also be applied to this GameObject
    The event broadcasts to a subscribed method in the orbit camera behavior which
    handles the specifics.
*********************************************************************/
[RequireComponent(typeof(Collider))]
public class ClickableTarget : MonoBehaviour
{
    // Define a delegate and event that allows setting the orbit cam's
    // target via a mouse click.
    public delegate void TargetClicked(Transform t);
    public static event TargetClicked OnTargetClicked;

    /// <summary>
    /// This event handler method is fired by the collider object assigned to this
    /// GameObject which, in turn, broadcasts to any methods subscribed to the
    /// OnTargetClicked event.
    /// </summary>
	void OnMouseDown ()
    {
        // If there is one or more event subscribers, then fire OnTargetClicked event,
        // passing the transform of this GameOject along as a parameter.
        if (OnTargetClicked != null)
        {
            OnTargetClicked(this.transform);
        }
	}
}
