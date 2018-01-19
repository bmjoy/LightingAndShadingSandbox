// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>

using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;

namespace AmplifyShaderEditor
{
	[Serializable]
	[NodeAttributes( "Function Switch", "Functions", "Function Switch allows switching options at compile time for shader function", NodeAvailabilityFlags = (int)NodeAvailability.ShaderFunction )]
	public sealed class FunctionSwitch : ParentNode
	{
		private const string InputPortNameStr = "In ";

		private const string ToggleFalseStr = "False";
		private const string ToggleTrueStr = "True";

		private const string CurrSelectedStr = "Current";
		private const string MaxAmountStr = "Max Amount";
		private const int MaxAllowedAmount = 8;

		private const int MinComboSize = 50;
		private const int MaxComboSize = 105;

		[SerializeField]
		private string m_optionLabel = "Option";

		[SerializeField]
		private string[] AvailableInputsLabels = { "In 0", "In 1" };

		[SerializeField]
		private int[] AvailableInputsValues = { 0, 1 };

		[SerializeField]
		private int m_previousSelectedInput = 0;

		[SerializeField]
		private int m_currentSelectedInput = 0;

		[SerializeField]
		private int m_maxAmountInputs = 2;

		[SerializeField]
		private bool m_toggleMode = false;

		[SerializeField]
		private string[] m_optionNames = { "In 0", "In 1", "In 2", "In 3", "In 4", "In 5", "In 6", "In 7" };

		[SerializeField]
		private int m_orderIndex = -1;

		private GUIContent m_checkContent;
		private GUIContent m_popContent;

		private const double MaxTimestamp = 1;
		private bool m_nameModified = false;
		private double m_lastTimeNameModified = 0;

		private Rect m_varRect;
		private Rect m_imgRect;
		private bool m_editing;

		private int m_cachedPropertyId = -1;

		protected override void CommonInit( int uniqueId )
		{
			base.CommonInit( uniqueId );
			for( int i = 0; i < MaxAllowedAmount; i++ )
			{
				AddInputPort( WirePortDataType.FLOAT, false, InputPortNameStr + i );
				m_inputPorts[ i ].Visible = ( i < 2 );
			}
			AddOutputPort( WirePortDataType.FLOAT, " " );

			m_checkContent = new GUIContent();
			m_checkContent.image = UIUtils.CheckmarkIcon;

			m_popContent = new GUIContent();
			m_popContent.image = UIUtils.PopupIcon;

			m_textLabelWidth = 100;
			m_autoWrapProperties = true;
			m_insideSize.Set( 80, 25 );
			m_previewShaderGUID = "a58e46feaa5e3d14383bfeac24d008bc";
		}

		public void SetCurrentSelectedInput( int newValue, int prevValue )
		{
			m_previousSelectedInput = prevValue;
			m_currentSelectedInput = newValue;
			m_outputPorts[ 0 ].ChangeType( m_inputPorts[ m_currentSelectedInput ].DataType, false );
			ChangeSignalPropagation();
		}

		public int GetCurrentSelectedInput()
		{
			return m_currentSelectedInput;
		}


		public override void SetPreviewInputs()
		{
			base.SetPreviewInputs();

			if( m_cachedPropertyId == -1 )
				m_cachedPropertyId = Shader.PropertyToID( "_Current" );

			PreviewMaterial.SetInt( m_cachedPropertyId, m_currentSelectedInput );
		}

		protected override void OnUniqueIDAssigned()
		{
			base.OnUniqueIDAssigned();
			UIUtils.RegisterFunctionSwitchNode( this );
		}

		public override void Destroy()
		{
			base.Destroy();
			UIUtils.UnregisterFunctionSwitchNode( this );
		}

		public override void OnConnectedOutputNodeChanges( int portId, int otherNodeId, int otherPortId, string name, WirePortDataType type )
		{
			base.OnConnectedOutputNodeChanges( portId, otherNodeId, otherPortId, name, type );
			m_inputPorts[ portId ].MatchPortToConnection();
			if( portId == m_currentSelectedInput )
				m_outputPorts[ 0 ].ChangeType( m_inputPorts[ portId ].DataType, false );
		}

		public override void OnInputPortConnected( int portId, int otherNodeId, int otherPortId, bool activateNode = true )
		{
			InputPort port = GetInputPortByUniqueId( portId );
			int arrayPos = m_inputPorts.IndexOf( port );
			if( activateNode && m_connStatus == NodeConnectionStatus.Connected && arrayPos == m_currentSelectedInput )
			{
				port.GetOutputNode().ActivateNode( m_activeNode, m_activePort, m_activeType );
			}

			OnNodeChange();
			SetSaveIsDirty();

			m_inputPorts[ portId ].MatchPortToConnection();
			if( arrayPos == m_currentSelectedInput )
				m_outputPorts[ 0 ].ChangeType( m_inputPorts[ portId ].DataType, false );
		}

		public override void ActivateNode( int signalGenNodeId, int signalGenPortId, Type signalGenNodeType )
		{
			if( m_selfPowered )
				return;

			ConnStatus = m_restrictions.GetRestiction( signalGenNodeType, signalGenPortId ) ? NodeConnectionStatus.Error : NodeConnectionStatus.Connected;
			m_activeConnections += 1;

			m_activeType = signalGenNodeType;
			m_activeNode = signalGenNodeId;
			m_activePort = signalGenPortId;
			if( m_activeConnections == 1 )
				if( m_inputPorts[ m_currentSelectedInput ].IsConnected )
					m_inputPorts[ m_currentSelectedInput ].GetOutputNode().ActivateNode( signalGenNodeId, signalGenPortId, signalGenNodeType );

			SetSaveIsDirty();
		}

		public override void DeactivateInputPortNode( int deactivatedPort, bool forceComplete )
		{
			InputPort port = GetInputPortByUniqueId( deactivatedPort );
			if( deactivatedPort == m_currentSelectedInput )
				port.GetOutputNode().DeactivateNode( deactivatedPort, false );
		}

		public override void DeactivateNode( int deactivatedPort, bool forceComplete )
		{
			if( m_selfPowered )
				return;

			SetSaveIsDirty();
			m_activeConnections -= 1;

			if( ( forceComplete || m_activeConnections <= 0 ) )
			{
				m_activeConnections = 0;
				ConnStatus = NodeConnectionStatus.Not_Connected;
				for( int i = 0; i < m_inputPorts.Count; i++ )
				{
					if( m_inputPorts[ i ].IsConnected && i == m_currentSelectedInput )
					{
						m_inputPorts[ i ].GetOutputNode().DeactivateNode( deactivatedPort == -1 ? m_inputPorts[ i ].PortId : deactivatedPort, false );
					}
				}
			}
		}

		public void ChangeSignalPropagation()
		{
			if( m_previousSelectedInput != m_currentSelectedInput && ConnStatus == NodeConnectionStatus.Connected )
			{
				if( m_inputPorts[ m_previousSelectedInput ].IsConnected )
					m_inputPorts[ m_previousSelectedInput ].GetOutputNode().DeactivateNode( m_inputPorts[ m_previousSelectedInput ].PortId, false );

				if( m_inputPorts[ m_currentSelectedInput ].IsConnected )
					m_inputPorts[ m_currentSelectedInput ].GetOutputNode().ActivateNode( UniqueId, m_inputPorts[ m_currentSelectedInput ].PortId, m_activeType );
			}
		}

		public bool DrawOption( ParentNode owner )
		{
			if( !IsConnected )
				return false;

			int prev = m_currentSelectedInput;
			if( m_toggleMode )
			{
				m_currentSelectedInput = owner.EditorGUILayoutToggle( m_optionLabel, ( m_currentSelectedInput != 0 ? true : false ) ) ? 1 : 0;

				if( m_currentSelectedInput != prev )
				{
					SetCurrentSelectedInput( m_currentSelectedInput, prev );
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				m_currentSelectedInput = owner.EditorGUILayoutIntPopup( m_optionLabel, m_currentSelectedInput, AvailableInputsLabels, AvailableInputsValues );

				if( m_currentSelectedInput != prev )
				{
					SetCurrentSelectedInput( m_currentSelectedInput, prev );
					return true;
				}
				else
				{
					return false;
				}
			}
		}

		public override void DrawProperties()
		{
			base.DrawProperties();
			EditorGUI.BeginChangeCheck();
			m_optionLabel = EditorGUILayoutTextField( "Option Label", m_optionLabel );
			if( EditorGUI.EndChangeCheck() )
			{
				m_optionLabel = UIUtils.RemoveInvalidEnumCharacters( m_optionLabel );
				if( string.IsNullOrEmpty( m_optionLabel ) )
				{
					m_optionLabel = "Option";
				}
			}

			EditorGUI.BeginChangeCheck();
			m_toggleMode = EditorGUILayoutToggle( "Toggle Mode", m_toggleMode );
			if( EditorGUI.EndChangeCheck() )
			{
				if( m_toggleMode )
				{
					m_inputPorts[ 0 ].Name = ToggleFalseStr;
					m_inputPorts[ 1 ].Name = ToggleTrueStr;

					for( int i = 0; i < MaxAllowedAmount; i++ )
					{
						m_inputPorts[ i ].Visible = ( i < 2 );
					}

					if( m_currentSelectedInput >= 2 )
					{
						m_currentSelectedInput = 1;
					}
					UpdateLabels();
					m_sizeIsDirty = true;
				}
				else
				{
					m_inputPorts[ 0 ].Name = m_optionNames[ 0 ];
					m_inputPorts[ 1 ].Name = m_optionNames[ 1 ];

					for( int i = 0; i < MaxAllowedAmount; i++ )
					{
						m_inputPorts[ i ].Visible = ( i < m_maxAmountInputs );
					}

					if( m_currentSelectedInput >= m_maxAmountInputs )
					{
						m_currentSelectedInput = m_maxAmountInputs - 1;
					}

					UpdateLabels();
					m_sizeIsDirty = true;
				}
			}

			if( !m_toggleMode )
			{
				EditorGUI.BeginChangeCheck();
				m_maxAmountInputs = EditorGUILayoutIntSlider( MaxAmountStr, m_maxAmountInputs, 2, MaxAllowedAmount );
				if( EditorGUI.EndChangeCheck() )
				{
					for( int i = 0; i < MaxAllowedAmount; i++ )
					{
						m_inputPorts[ i ].Visible = ( i < m_maxAmountInputs );
					}

					if( m_currentSelectedInput >= m_maxAmountInputs )
					{
						m_currentSelectedInput = m_maxAmountInputs - 1;
					}

					UpdateLabels();
					m_sizeIsDirty = true;
				}

				EditorGUI.indentLevel++;
				for( int i = 0; i < m_maxAmountInputs; i++ )
				{
					EditorGUI.BeginChangeCheck();
					m_inputPorts[ i ].Name = EditorGUILayoutTextField( "Item " + i, m_inputPorts[ i ].Name );
					if( EditorGUI.EndChangeCheck() )
					{
						m_nameModified = true;
						m_lastTimeNameModified = EditorApplication.timeSinceStartup;
						m_inputPorts[ i ].Name = UIUtils.RemoveInvalidEnumCharacters( m_inputPorts[ i ].Name );
						m_optionNames[ i ] = m_inputPorts[ i ].Name;
						if( string.IsNullOrEmpty( m_inputPorts[ i ].Name ) )
						{
							m_inputPorts[ i ].Name = InputPortNameStr + i;
						}
						m_sizeIsDirty = true;
					}
				}
				EditorGUI.indentLevel--;

				if( m_nameModified )
				{
					UpdateLabels();
				}
			}

			if( m_toggleMode )
			{
				EditorGUI.BeginChangeCheck();
				int prevVal = m_currentSelectedInput;
				m_currentSelectedInput = EditorGUILayoutToggle( CurrSelectedStr, ( m_currentSelectedInput != 0 ? true : false ) ) ? 1 : 0;
				if( EditorGUI.EndChangeCheck() )
					SetCurrentSelectedInput( m_currentSelectedInput, prevVal );
			}
			else
			{
				EditorGUI.BeginChangeCheck();
				int prevVal = m_currentSelectedInput;
				m_currentSelectedInput = EditorGUILayoutIntPopup( CurrSelectedStr, m_currentSelectedInput, AvailableInputsLabels, AvailableInputsValues );
				if( EditorGUI.EndChangeCheck() )
				{
					SetCurrentSelectedInput( m_currentSelectedInput, prevVal );
				}
			}
		}

		public override void RefreshExternalReferences()
		{
			base.RefreshExternalReferences();

			SetCurrentSelectedInput( m_currentSelectedInput, m_previousSelectedInput );
		}

		public void UpdateLabels()
		{
			AvailableInputsLabels = new string[ m_maxAmountInputs ];
			AvailableInputsValues = new int[ m_maxAmountInputs ];

			for( int i = 0; i < m_maxAmountInputs; i++ )
			{
				AvailableInputsLabels[ i ] = m_optionNames[ i ];
				AvailableInputsValues[ i ] = i;
			}
		}

		public override void OnNodeLayout( DrawInfo drawInfo )
		{
			float finalSize = 0;
			if( !m_toggleMode )
			{
				GUIContent dropdown = new GUIContent( m_inputPorts[ m_currentSelectedInput ].Name );
				int cacheSize = UIUtils.GraphDropDown.fontSize;
				UIUtils.GraphDropDown.fontSize = 10;
				Vector2 calcSize = UIUtils.GraphDropDown.CalcSize( dropdown );
				UIUtils.GraphDropDown.fontSize = cacheSize;
				finalSize = Mathf.Clamp( calcSize.x, MinComboSize, MaxComboSize );
				if( m_insideSize.x != finalSize )
				{
					m_insideSize.Set( finalSize, 25 );
					m_sizeIsDirty = true;
				}
			}

			base.OnNodeLayout( drawInfo );
			if( m_toggleMode )
			{
				m_varRect = m_remainingBox;
				m_varRect.size = Vector2.one * 22 * drawInfo.InvertedZoom;
				m_varRect.center = m_remainingBox.center;
				if( m_showPreview )
					m_varRect.y = m_remainingBox.y;
			}
			else
			{
				m_varRect = m_remainingBox;
				m_varRect.width = finalSize * drawInfo.InvertedZoom;
				m_varRect.height = 16 * drawInfo.InvertedZoom;
				m_varRect.x = m_remainingBox.xMax - m_varRect.width;
				m_varRect.y += 1 * drawInfo.InvertedZoom;

				m_imgRect = m_varRect;
				m_imgRect.x = m_varRect.xMax - 16 * drawInfo.InvertedZoom;
				m_imgRect.width = 16 * drawInfo.InvertedZoom;
				m_imgRect.height = m_imgRect.width;
			}
		}

		public override void DrawGUIControls( DrawInfo drawInfo )
		{
			base.DrawGUIControls( drawInfo );

			if( drawInfo.CurrentEventType != EventType.MouseDown )
				return;

			if( m_varRect.Contains( drawInfo.MousePosition ) )
			{
				m_editing = true;
			}
			else if( m_editing )
			{
				m_editing = false;
			}
		}

		public override void Draw( DrawInfo drawInfo )
		{
			base.Draw( drawInfo );

			if( m_nameModified )
			{
				if( ( EditorApplication.timeSinceStartup - m_lastTimeNameModified ) > MaxTimestamp )
				{
					m_nameModified = false;
					//m_repopulateNameDictionary = true;
				}
			}

			SetAdditonalTitleTextOnCallback( m_optionLabel, ( instance, newSubTitle ) => instance.AdditonalTitleContent.text = string.Format( Constants.SubTitleValueFormatStr, newSubTitle ) );

			if( m_editing )
			{
				if( m_toggleMode )
				{
					if( GUI.Button( m_varRect, GUIContent.none, UIUtils.GraphButton ) )
					{
						int prevVal = m_currentSelectedInput;
						m_currentSelectedInput = m_currentSelectedInput == 1 ? 0 : 1;
						if( m_currentSelectedInput != prevVal )
							SetCurrentSelectedInput( m_currentSelectedInput, prevVal );
						m_editing = false;
					}

					if( m_currentSelectedInput == 1 )
					{
						GUI.Label( m_varRect, m_checkContent, UIUtils.GraphButtonIcon );
					}
				}
				else
				{
					EditorGUI.BeginChangeCheck();
					int prevVal = m_currentSelectedInput;
					m_currentSelectedInput = EditorGUIIntPopup( m_varRect, m_currentSelectedInput, AvailableInputsLabels, AvailableInputsValues, UIUtils.GraphDropDown );
					if( EditorGUI.EndChangeCheck() )
					{
						SetCurrentSelectedInput( m_currentSelectedInput, prevVal );
						m_editing = false;
					}
				}
			}
		}

		public override void OnNodeRepaint( DrawInfo drawInfo )
		{
			base.OnNodeRepaint( drawInfo );

			if( !m_isVisible )
				return;

			if( ContainerGraph.LodLevel <= ParentGraph.NodeLOD.LOD2 )
			{
				if( !m_editing )
				{
					if( m_toggleMode )
					{
						GUI.Label( m_varRect, GUIContent.none, UIUtils.GraphButton );

						if( m_currentSelectedInput == 1 )
						{
							GUI.Label( m_varRect, m_checkContent, UIUtils.GraphButtonIcon );
						}
					}
					else
					{
						GUI.Label( m_varRect, AvailableInputsLabels[ m_currentSelectedInput ], UIUtils.GraphDropDown );
						GUI.Label( m_imgRect, m_popContent, UIUtils.GraphButtonIcon );
					}
				}
			}
		}

		public override string GenerateShaderForOutput( int outputId, ref MasterNodeDataCollector dataCollector, bool ignoreLocalvar )
		{
			return m_inputPorts[ m_currentSelectedInput ].GeneratePortInstructions( ref dataCollector );
		}

		public override void ReadFromString( ref string[] nodeParams )
		{
			base.ReadFromString( ref nodeParams );
			m_optionLabel = GetCurrentParam( ref nodeParams );
			m_toggleMode = Convert.ToBoolean( GetCurrentParam( ref nodeParams ) );
			m_currentSelectedInput = Convert.ToInt32( GetCurrentParam( ref nodeParams ) );
			m_previousSelectedInput = m_currentSelectedInput;
			m_maxAmountInputs = Convert.ToInt32( GetCurrentParam( ref nodeParams ) );
			m_orderIndex = Convert.ToInt32( GetCurrentParam( ref nodeParams ) );

			for( int i = 0; i < MaxAllowedAmount; i++ )
			{
				m_inputPorts[ i ].Visible = ( i < m_maxAmountInputs );
			}

			if( m_currentSelectedInput >= m_maxAmountInputs )
			{
				m_currentSelectedInput = m_maxAmountInputs - 1;
			}

			for( int i = 0; i < m_maxAmountInputs; i++ )
			{
				m_optionNames[ i ] = GetCurrentParam( ref nodeParams );// m_inputPorts[ i ].Name;
				m_inputPorts[ i ].Name = m_optionNames[ i ];
			}

			if( m_toggleMode )
			{
				m_inputPorts[ 0 ].Name = ToggleFalseStr;
				m_inputPorts[ 1 ].Name = ToggleTrueStr;
			}

			UpdateLabels();
			m_sizeIsDirty = true;
		}

		public override void WriteToString( ref string nodeInfo, ref string connectionsInfo )
		{
			base.WriteToString( ref nodeInfo, ref connectionsInfo );
			IOUtils.AddFieldValueToString( ref nodeInfo, m_optionLabel );
			IOUtils.AddFieldValueToString( ref nodeInfo, m_toggleMode );
			IOUtils.AddFieldValueToString( ref nodeInfo, m_currentSelectedInput );
			IOUtils.AddFieldValueToString( ref nodeInfo, m_maxAmountInputs );
			IOUtils.AddFieldValueToString( ref nodeInfo, m_orderIndex );

			for( int i = 0; i < m_maxAmountInputs; i++ )
			{
				IOUtils.AddFieldValueToString( ref nodeInfo, m_optionNames[ i ]/*m_inputPorts[ i ].Name*/ );
			}
		}

		public int OrderIndex
		{
			get { return m_orderIndex; }
			set { m_orderIndex = value; }
		}

		public string OptionLabel
		{
			get { return m_optionLabel; }
			set { m_optionLabel = value; }
		}
	}
}
