using System;
using UnityEngine;

namespace AmplifyShaderEditor
{
	[Serializable]
	public class TemplateLocalVarData
	{
		[SerializeField]
		private WirePortDataType m_dataType = WirePortDataType.OBJECT;

		[SerializeField]
		private string m_localVarName = string.Empty;

		[SerializeField]
		private int m_idx = -1;

		public TemplateLocalVarData( WirePortDataType dataType, string localVarName, int idx )
		{
			m_dataType = dataType;
			m_localVarName = localVarName;
			m_idx = idx;
		}

		public WirePortDataType DataType { get { return m_dataType; } }
		public string LocalVarName { get { return m_localVarName; } }
		public int Idx { get { return m_idx; } }
	}
}
