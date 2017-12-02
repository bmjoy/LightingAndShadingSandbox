// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#define SHOW_TEMPLATE_HELP_BOX
#define TEMPLATE_MODULES

using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace AmplifyShaderEditor
{
    [Serializable]
    [NodeAttributes( "Template Master Node", "Master", "Shader Generated according to template rules", null, KeyCode.None, false )]
    public sealed class TemplateMasterNode : MasterNode
    {
        private const string WarningMessage = "Templates is a feature that is still heavily under development and users may experience some problems.\nPlease email support@amplify.pt if any issue occurs.";
        private const string CurrentTemplateLabel = "Current Template";
        private const string OpenTemplateStr = "Edit Template";

        //protected const string SnippetsFoldoutStr = " Snippets";
        //[SerializeField]
        //private bool m_snippetsFoldout = true;

        [NonSerialized]
        private TemplateData m_currentTemplate = null;

        private bool m_fireTemplateChange = false;
        private bool m_fetchMasterNodeCategory = false;
        private bool m_reRegisterTemplateData = false;

        [SerializeField]
        private string m_templateGUID = string.Empty;

        [SerializeField]
        private string m_templateName = string.Empty;
#if TEMPLATE_MODULES
        [SerializeField]
        private TemplatesBlendModule m_blendOpHelper = new TemplatesBlendModule();

        [SerializeField]
        private TemplateCullModeModule m_cullModeHelper = new TemplateCullModeModule();

        [SerializeField]
        private TemplateColorMaskModule m_colorMaskHelper = new TemplateColorMaskModule();

        [SerializeField]
        private TemplatesStencilBufferModule m_stencilBufferHelper = new TemplatesStencilBufferModule();
#endif
        protected override void CommonInit( int uniqueId )
        {
            base.CommonInit( uniqueId );
            m_masterNodeCategory = 1;// First Template
            m_marginPreviewLeft = 20;
            m_insideSize.y = 60;
        }

        public override void ReleaseResources()
        {
            if( m_currentTemplate != null && m_currentTemplate.AvailableShaderProperties != null )
            {
                // Unregister old template properties
                int oldPropertyCount = m_currentTemplate.AvailableShaderProperties.Count;
                for( int i = 0; i < oldPropertyCount; i++ )
                {
                    UIUtils.ReleaseUniformName( UniqueId, m_currentTemplate.AvailableShaderProperties[ i ].PropertyName );
                }
            }
        }

        public override void OnEnable()
        {
            base.OnEnable();
            m_reRegisterTemplateData = true;
        }

        void FetchInfoFromTemplate()
        {
#if TEMPLATE_MODULES
            if( m_currentTemplate.BlendData.DataCheck == TemplateDataCheck.Valid )
                m_blendOpHelper.ConfigureFromTemplateData( m_currentTemplate.BlendData );

            if( m_currentTemplate.CullModeData.DataCheck == TemplateDataCheck.Valid )
                m_cullModeHelper.ConfigureFromTemplateData( m_currentTemplate.CullModeData );

            if( m_currentTemplate.ColorMaskData.DataCheck == TemplateDataCheck.Valid )
                m_colorMaskHelper.ConfigureFromTemplateData( m_currentTemplate.ColorMaskData );

            if( m_currentTemplate.StencilData.DataCheck == TemplateDataCheck.Valid )
                m_stencilBufferHelper.ConfigureFromTemplateData( m_currentTemplate.StencilData );
#endif
        }

        void FetchCurrentTemplate()
        {
            m_currentTemplate = TemplatesManager.GetTemplate( m_templateGUID );
            if( m_currentTemplate == null )
            {
                m_currentTemplate = TemplatesManager.GetTemplate( m_templateName );
            }

            if( m_currentTemplate != null )
            {
                if( m_inputPorts.Count != m_currentTemplate.InputDataList.Count )
                {
                    DeleteAllInputConnections( true );

                    List<TemplateInputData> inputDataList = m_currentTemplate.InputDataList;
                    int count = inputDataList.Count;
                    for( int i = 0; i < count; i++ )
                    {
                        AddInputPort( inputDataList[ i ].DataType, false, inputDataList[ i ].PortName, inputDataList[ i ].OrderId, inputDataList[ i ].PortCategory, inputDataList[ i ].PortUniqueId );
                    }
                    FetchInfoFromTemplate();
                }
                else
                {
                    List<TemplateInputData> inputDataList = m_currentTemplate.InputDataList;
                    int count = inputDataList.Count;
                    for( int i = 0; i < count; i++ )
                    {
                        m_inputPorts[ i ].ChangeProperties( inputDataList[ i ].PortName, inputDataList[ i ].DataType, false );
                    }
                }
            }
        }

        public override void RefreshAvailableCategories()
        {
            FetchCurrentTemplate();

            int templateCount = TemplatesManager.TemplateCount;
            m_availableCategories = new MasterNodeCategoriesData[ templateCount + 1 ];
            m_availableCategoryLabels = new GUIContent[ templateCount + 1 ];

            m_availableCategories[ 0 ] = new MasterNodeCategoriesData( AvailableShaderTypes.SurfaceShader, string.Empty );
            m_availableCategoryLabels[ 0 ] = new GUIContent( "Surface Shader" );
            if( m_currentTemplate == null )
            {
                m_masterNodeCategory = -1;
            }

            for( int i = 0; i < templateCount; i++ )
            {
                int idx = i + 1;
                TemplateData templateData = TemplatesManager.GetTemplate( i );

                if( m_currentTemplate != null && m_currentTemplate.GUID.Equals( templateData.GUID ) )
                    m_masterNodeCategory = idx;

                m_availableCategories[ idx ] = new MasterNodeCategoriesData( AvailableShaderTypes.Template, templateData.GUID );
                m_availableCategoryLabels[ idx ] = new GUIContent( templateData.Name );
            }
        }

        void SetCategoryIdxFromTemplate()
        {
            int templateCount = TemplatesManager.TemplateCount;
            for( int i = 0; i < templateCount; i++ )
            {
                int idx = i + 1;
                TemplateData templateData = TemplatesManager.GetTemplate( i );
                if( templateData != null && m_currentTemplate != null && m_currentTemplate.GUID.Equals( templateData.GUID ) )
                    m_masterNodeCategory = idx;
            }
        }

        public void SetTemplate( TemplateData newTemplate, bool writeDefaultData, bool fetchMasterNodeCategory )
        {
            ReleaseResources();

            if( newTemplate == null || newTemplate.InputDataList == null )
                return;

            m_fetchMasterNodeCategory = fetchMasterNodeCategory;

            DeleteAllInputConnections( true );
            m_currentTemplate = newTemplate;
            m_currentShaderData = newTemplate.Name;

            List<TemplateInputData> inputDataList = newTemplate.InputDataList;
            int count = inputDataList.Count;
            for( int i = 0; i < count; i++ )
            {
                AddInputPort( inputDataList[ i ].DataType, false, inputDataList[ i ].PortName, inputDataList[ i ].OrderId, inputDataList[ i ].PortCategory, inputDataList[ i ].PortUniqueId );
            }

            if( writeDefaultData )
            {
                ShaderName = newTemplate.DefaultShaderName;
            }

            RegisterProperties();
            m_fireTemplateChange = true;
            m_templateGUID = newTemplate.GUID;
            m_templateName = newTemplate.DefaultShaderName;
            FetchInfoFromTemplate();
        }

        void RegisterProperties()
        {
            if( m_currentTemplate != null )
            {
                m_reRegisterTemplateData = false;
                // Register old template properties
                int newPropertyCount = m_currentTemplate.AvailableShaderProperties.Count;
                for( int i = 0; i < newPropertyCount; i++ )
                {
                    int nodeId = UIUtils.CheckUniformNameOwner( m_currentTemplate.AvailableShaderProperties[ i ].PropertyName );
                    if( nodeId > -1 )
                    {
                        ParentNode node = m_containerGraph.GetNode( nodeId );
                        if( node != null )
                        {
                            UIUtils.ShowMessage( string.Format( "Template requires property name {0} which is currently being used by {1}. Please rename it and reload template.", m_currentTemplate.AvailableShaderProperties[ i ].PropertyName, node.Attributes.Name ) );
                        }
                        else
                        {
                            UIUtils.ShowMessage( string.Format( "Template requires property name {0} which is currently being on your graph. Please rename it and reload template.", m_currentTemplate.AvailableShaderProperties[ i ].PropertyName ) );
                        }
                    }
                    else
                    {
                        UIUtils.RegisterUniformName( UniqueId, m_currentTemplate.AvailableShaderProperties[ i ].PropertyName );
                    }
                }
            }
        }

        public override void DrawProperties()
        {
            if( m_currentTemplate == null )
                return;

            base.DrawProperties();
            bool generalIsVisible = EditorVariablesManager.ExpandedGeneralShaderOptions.Value;
            NodeUtils.DrawPropertyGroup( ref generalIsVisible, GeneralFoldoutStr, DrawGeneralOptions );
            EditorVariablesManager.ExpandedGeneralShaderOptions.Value = generalIsVisible;
#if TEMPLATE_MODULES
            switch( m_currentTemplate.BlendData.DataCheck )
            {
                case TemplateDataCheck.Valid: m_blendOpHelper.Draw( this ); break;
                case TemplateDataCheck.Unreadable: m_blendOpHelper.ShowUnreadableDataMessage(); break;
            }

            switch( m_currentTemplate.StencilData.DataCheck )
            {
                case TemplateDataCheck.Valid:
                {
                    CullMode cullMode = ( m_currentTemplate.CullModeData.DataCheck == TemplateDataCheck.Valid ) ? m_cullModeHelper.CurrentCullMode : CullMode.Back;
                    m_stencilBufferHelper.Draw( this, cullMode );
                }
                break;
                case TemplateDataCheck.Unreadable:
                {
                    m_stencilBufferHelper.ShowUnreadableDataMessage();
                }
                break;
            }

#endif


            DrawMaterialInputs( UIUtils.MenuItemToolbarStyle );

            //	NodeUtils.DrawPropertyGroup( ref m_snippetsFoldout, SnippetsFoldoutStr, DrawSnippetOptions );
            if( GUILayout.Button( OpenTemplateStr ) && m_currentTemplate != null )
            {
                AssetDatabase.OpenAsset( AssetDatabase.LoadAssetAtPath<Shader>( AssetDatabase.GUIDToAssetPath( m_currentTemplate.GUID ) ), 1 );
            }

#if SHOW_TEMPLATE_HELP_BOX
            EditorGUILayout.HelpBox( WarningMessage, MessageType.Warning );
#endif

        }

        public void DrawGeneralOptions()
        {
            DrawShaderName();
            DrawCurrentShaderType();
#if TEMPLATE_MODULES
            switch( m_currentTemplate.CullModeData.DataCheck )
            {
                case TemplateDataCheck.Valid: m_cullModeHelper.Draw( this ); break;
                case TemplateDataCheck.Unreadable: m_cullModeHelper.ShowUnreadableDataMessage(); break;
            }

            switch( m_currentTemplate.ColorMaskData.DataCheck )
            {
                case TemplateDataCheck.Valid: m_colorMaskHelper.Draw( this ); break;
                case TemplateDataCheck.Unreadable: m_colorMaskHelper.ShowUnreadableDataMessage(); break;
            }
#endif
        }

        public void DrawSnippetOptions()
        {
            m_currentTemplate.DrawSnippetProperties( this );
        }

        bool CreateInstructionsForList( ref List<InputPort> ports, ref string shaderBody, ref List<string> vertexInstructions, ref List<string> fragmentInstructions )
        {
            if( ports.Count == 0 )
                return true;

            bool isValid = true;
            UIUtils.CurrentWindow.CurrentGraph.ResetNodesLocalVariables();
            for( int i = 0; i < ports.Count; i++ )
            {
                TemplateInputData inputData = m_currentTemplate.InputDataFromId( ports[ i ].PortId );
                if( ports[ i ].IsConnected )
                {
                    m_currentDataCollector.ResetInstructions();
                    m_currentDataCollector.ResetVertexInstructions();

                    m_currentDataCollector.PortCategory = ports[ i ].Category;
                    string newPortInstruction = ports[ i ].GeneratePortInstructions( ref m_currentDataCollector );


                    if( m_currentDataCollector.DirtySpecialLocalVariables )
                    {
                        string cleanVariables = m_currentDataCollector.SpecialLocalVariables.Replace( "\t", string.Empty );
                        m_currentDataCollector.AddInstructions( cleanVariables, false );
                        m_currentDataCollector.ClearSpecialLocalVariables();
                    }

                    if( m_currentDataCollector.DirtyVertexVariables )
                    {
                        string cleanVariables = m_currentDataCollector.VertexLocalVariables.Replace( "\t", string.Empty );
                        m_currentDataCollector.AddVertexInstruction( cleanVariables, UniqueId, false );
                        m_currentDataCollector.ClearVertexLocalVariables();
                    }

                    // fill functions 
                    for( int j = 0; j < m_currentDataCollector.InstructionsList.Count; j++ )
                    {
                        fragmentInstructions.Add( m_currentDataCollector.InstructionsList[ j ].PropertyName );
                    }

                    for( int j = 0; j < m_currentDataCollector.VertexDataList.Count; j++ )
                    {
                        vertexInstructions.Add( m_currentDataCollector.VertexDataList[ j ].PropertyName );
                    }

                    isValid = m_currentTemplate.FillTemplateBody( inputData.TagId, ref shaderBody, newPortInstruction ) && isValid;
                }
                else
                {
                    isValid = m_currentTemplate.FillTemplateBody( inputData.TagId, ref shaderBody, inputData.DefaultValue ) && isValid;
                }
            }
            return isValid;
        }

        public override void Draw( DrawInfo drawInfo )
        {
            base.Draw( drawInfo );

            if( m_currentTemplate == null )
            {
                FetchCurrentTemplate();
            }

            if( m_reRegisterTemplateData )
            {
                RegisterProperties();
            }

            if( m_containerGraph.IsInstancedShader )
            {
                DrawInstancedIcon( drawInfo );
            }

            if( m_fetchMasterNodeCategory )
            {
                if( m_availableCategories != null )
                {
                    m_fetchMasterNodeCategory = false;
                    SetCategoryIdxFromTemplate();
                }
            }

            if( m_fireTemplateChange )
            {
                m_fireTemplateChange = false;
                m_containerGraph.FireMasterNodeReplacedEvent();
            }
        }

        public override void UpdateFromShader( Shader newShader )
        {
            if( m_currentMaterial != null )
            {
                m_currentMaterial.shader = newShader;
            }
            CurrentShader = newShader;
        }

        public override void UpdateMasterNodeMaterial( Material material )
        {
            m_currentMaterial = material;
            FireMaterialChangedEvt();
        }

        public override Shader Execute( string pathname, bool isFullPath )
        {
            if( m_currentTemplate == null )
                return m_currentShader;

            //Create data collector
            base.Execute( pathname, isFullPath );

            m_currentDataCollector.TemplateDataCollectorInstance.BuildFromTemplateData( m_currentDataCollector, m_currentTemplate );
            int shaderPropertiesAmount = m_currentTemplate.AvailableShaderProperties.Count;
            for( int i = 0; i < shaderPropertiesAmount; i++ )
            {
                m_currentDataCollector.SoftRegisterUniform( m_currentTemplate.AvailableShaderProperties[ i ].PropertyName );
            }

            //Sort ports by both 
            List<InputPort> fragmentPorts = new List<InputPort>();
            List<InputPort> vertexPorts = new List<InputPort>();
            SortInputPorts( ref vertexPorts, ref fragmentPorts );

            string shaderBody = m_currentTemplate.TemplateBody;

            List<string> vertexInstructions = new List<string>();
            List<string> fragmentInstructions = new List<string>();

            bool validBody = true;

            validBody = CreateInstructionsForList( ref fragmentPorts, ref shaderBody, ref vertexInstructions, ref fragmentInstructions ) && validBody;
            validBody = CreateInstructionsForList( ref vertexPorts, ref shaderBody, ref vertexInstructions, ref fragmentInstructions ) && validBody;

            m_currentTemplate.ResetTemplateUsageData();

            // Fill vertex interpolators assignment
            for( int i = 0; i < m_currentDataCollector.VertexInterpDeclList.Count; i++ )
            {
                vertexInstructions.Add( m_currentDataCollector.VertexInterpDeclList[ i ] );
            }

            vertexInstructions.AddRange( m_currentDataCollector.TemplateDataCollectorInstance.GetInterpUnusedChannels() );
            //Fill common local variables and operations

            validBody = m_currentTemplate.FillVertexInstructions( ref shaderBody, vertexInstructions.ToArray() ) && validBody;
            validBody = m_currentTemplate.FillFragmentInstructions( ref shaderBody, fragmentInstructions.ToArray() ) && validBody;

            // Add Instanced Properties
            if( m_containerGraph.IsInstancedShader )
            {
                m_currentDataCollector.TabifyInstancedVars();
                m_currentDataCollector.InstancedPropertiesList.Insert( 0, new PropertyDataCollector( -1, string.Format( IOUtils.InstancedPropertiesBegin, UIUtils.RemoveInvalidCharacters( m_shaderName ) ) ) );
                m_currentDataCollector.InstancedPropertiesList.Add( new PropertyDataCollector( -1, IOUtils.InstancedPropertiesEnd ) );
                m_currentDataCollector.UniformsList.AddRange( m_currentDataCollector.InstancedPropertiesList );
            }

            //Add Functions
            m_currentDataCollector.UniformsList.AddRange( m_currentDataCollector.FunctionsList );

            // Fill common tags
            m_currentDataCollector.IncludesList.AddRange( m_currentDataCollector.PragmasList );

            validBody = m_currentTemplate.FillTemplateBody( m_currentTemplate.ShaderNameId, ref shaderBody, string.Format( TemplatesManager.NameFormatter, m_shaderName ) ) && validBody;
            validBody = m_currentTemplate.FillTemplateBody( TemplatesManager.TemplatePassTag, ref shaderBody, m_currentDataCollector.GrabPassList ) && validBody;
            validBody = m_currentTemplate.FillTemplateBody( TemplatesManager.TemplatePragmaTag, ref shaderBody, m_currentDataCollector.IncludesList ) && validBody;
            validBody = m_currentTemplate.FillTemplateBody( TemplatesManager.TemplateTagsTag, ref shaderBody, m_currentDataCollector.TagsList ) && validBody;
            validBody = m_currentTemplate.FillTemplateBody( TemplatesManager.TemplatePropertyTag, ref shaderBody, m_currentDataCollector.BuildUnformatedPropertiesStringArr() ) && validBody;
            validBody = m_currentTemplate.FillTemplateBody( TemplatesManager.TemplateGlobalsTag, ref shaderBody, m_currentDataCollector.UniformsList ) && validBody;
            validBody = m_currentTemplate.FillTemplateBody( m_currentTemplate.VertexDataId, ref shaderBody, m_currentDataCollector.VertexInputList.ToArray() ) && validBody;
            validBody = m_currentTemplate.FillTemplateBody( m_currentTemplate.InterpDataId, ref shaderBody, m_currentDataCollector.InterpolatorList.ToArray() ) && validBody;
#if TEMPLATE_MODULES
            if( m_currentTemplate.BlendData.ValidBlendMode )
            {
                validBody = m_currentTemplate.FillTemplateBody( m_currentTemplate.BlendData.BlendModeId, ref shaderBody, m_blendOpHelper.CurrentBlendFactor ) && validBody;
            }

            if( m_currentTemplate.BlendData.ValidBlendOp )
            {
                validBody = m_currentTemplate.FillTemplateBody( m_currentTemplate.BlendData.BlendOpId, ref shaderBody, m_blendOpHelper.CurrentBlendOp ) && validBody;
            }

            if( m_currentTemplate.CullModeData.DataCheck == TemplateDataCheck.Valid )
            {
                validBody = m_currentTemplate.FillTemplateBody( m_currentTemplate.CullModeData.CullModeId, ref shaderBody, m_cullModeHelper.GenerateShaderData() ) && validBody;
            }

            if( m_currentTemplate.ColorMaskData.DataCheck == TemplateDataCheck.Valid )
            {
                validBody = m_currentTemplate.FillTemplateBody( m_currentTemplate.ColorMaskData.ColorMaskId, ref shaderBody, m_colorMaskHelper.GenerateShaderData() ) && validBody;
            }

            if( m_currentTemplate.StencilData.DataCheck == TemplateDataCheck.Valid )
            {
                CullMode cullMode = ( m_currentTemplate.CullModeData.DataCheck == TemplateDataCheck.Valid ) ? m_cullModeHelper.CurrentCullMode : CullMode.Back;
                validBody = m_currentTemplate.FillTemplateBody( m_currentTemplate.StencilData.StencilBufferId, ref shaderBody, m_stencilBufferHelper.CreateStencilOp( cullMode ) ) && validBody;
            }
#endif
            if( m_currentDataCollector.TemplateDataCollectorInstance.HasVertexInputParams )
            {
                validBody = m_currentTemplate.FillTemplateBody( TemplatesManager.TemplateInputsVertParamsTag, ref shaderBody, m_currentDataCollector.TemplateDataCollectorInstance.VertexInputParamsStr ) && validBody;
            }

            if( m_currentDataCollector.TemplateDataCollectorInstance.HasFragmentInputParams )
            {
                validBody = m_currentTemplate.FillTemplateBody( TemplatesManager.TemplateInputsFragParamsTag, ref shaderBody, m_currentDataCollector.TemplateDataCollectorInstance.FragInputParamsStr ) && validBody;
            }

            m_currentTemplate.FillEmptyTags( ref shaderBody );

            m_currentTemplate.InsertSnippets( ref shaderBody );

            vertexInstructions.Clear();
            vertexInstructions = null;

            fragmentInstructions.Clear();
            fragmentInstructions = null;
            if( validBody )
            {
                UpdateShaderAsset( ref pathname, ref shaderBody, isFullPath );
            }

            return m_currentShader;
        }

        public override void ReadFromString( ref string[] nodeParams )
        {
            base.ReadFromString( ref nodeParams );
            try
            {
                ShaderName = GetCurrentParam( ref nodeParams );
                if( m_shaderName.Length > 0 )
                    ShaderName = UIUtils.RemoveShaderInvalidCharacters( ShaderName );

                string templateGUID = GetCurrentParam( ref nodeParams );
                string templateShaderName = string.Empty;
                if( UIUtils.CurrentShaderVersion() > 13601 )
                {
                    templateShaderName = GetCurrentParam( ref nodeParams );
                }

                TemplateData template = TemplatesManager.GetTemplate( templateGUID );
                if( template != null )
                {
                    SetTemplate( template, false, true );
                }
                else
                {
                    template = TemplatesManager.GetTemplateByName( templateShaderName );
                    if( template != null )
                    {
                        SetTemplate( template, false, true );
                    }
                    else
                    {
                        m_masterNodeCategory = -1;
                    }
                }
#if TEMPLATE_MODULES
                if( UIUtils.CurrentShaderVersion() > 13902 )
                {
                    //BLEND MODULE
                    if( m_currentTemplate.BlendData.ValidBlendMode )
                    {
                        m_blendOpHelper.ReadBlendModeFromString( ref m_currentReadParamIdx, ref nodeParams );
                    }

                    if( m_currentTemplate.BlendData.ValidBlendOp )
                    {
                        m_blendOpHelper.ReadBlendOpFromString( ref m_currentReadParamIdx, ref nodeParams );
                    }

                    //CULL MODE
                    if( m_currentTemplate.CullModeData.DataCheck == TemplateDataCheck.Valid )
                    {
                        m_cullModeHelper.ReadFromString( ref m_currentReadParamIdx, ref nodeParams );
                    }

                    //COLOR MASK
                    if( m_currentTemplate.ColorMaskData.DataCheck == TemplateDataCheck.Valid )
                    {
                        m_colorMaskHelper.ReadFromString( ref m_currentReadParamIdx, ref nodeParams );
                    }

                    //STENCIL BUFFER
                    if( m_currentTemplate.StencilData.DataCheck == TemplateDataCheck.Valid )
                    {
                        m_stencilBufferHelper.ReadFromString( ref m_currentReadParamIdx, ref nodeParams );
                    }
                }
#endif
            }
            catch( Exception e )
            {
                Debug.LogException( e, this );
            }
            m_containerGraph.CurrentCanvasMode = NodeAvailability.TemplateShader;
        }

        public override void WriteToString( ref string nodeInfo, ref string connectionsInfo )
        {
            base.WriteToString( ref nodeInfo, ref connectionsInfo );
            IOUtils.AddFieldValueToString( ref nodeInfo, m_shaderName );
            IOUtils.AddFieldValueToString( ref nodeInfo, ( m_currentTemplate != null ) ? m_currentTemplate.GUID : string.Empty );
            IOUtils.AddFieldValueToString( ref nodeInfo, ( m_currentTemplate != null ) ? m_currentTemplate.DefaultShaderName : string.Empty );
#if TEMPLATE_MODULES
            //BLEND MODULE
            if( m_currentTemplate.BlendData.ValidBlendMode )
            {
                m_blendOpHelper.WriteBlendModeToString( ref nodeInfo );
            }

            if( m_currentTemplate.BlendData.ValidBlendOp )
            {
                m_blendOpHelper.WriteBlendOpToString( ref nodeInfo );
            }

            //CULL MODULE
            if( m_currentTemplate.CullModeData.DataCheck == TemplateDataCheck.Valid )
            {
                m_cullModeHelper.WriteToString( ref nodeInfo );
            }

            //COLOR MASK MODULE
            if( m_currentTemplate.ColorMaskData.DataCheck == TemplateDataCheck.Valid )
            {
                m_colorMaskHelper.WriteToString( ref nodeInfo );
            }

            //STENCIL BUFFER MODULE
            if( m_currentTemplate.StencilData.DataCheck == TemplateDataCheck.Valid )
            {
                m_stencilBufferHelper.WriteToString( ref nodeInfo );
            }
#endif
        }

        public override void Destroy()
        {
            base.Destroy();
            m_currentTemplate = null;
#if TEMPLATE_MODULES
            m_blendOpHelper = null;
            m_cullModeHelper = null;
            m_colorMaskHelper.Destroy();
            m_colorMaskHelper = null;
            m_stencilBufferHelper.Destroy();
            m_stencilBufferHelper = null;
#endif
        }

        public TemplateData CurrentTemplate { get { return m_currentTemplate; } }
    }
}
