///////////////////////////////////////////////////////////////////////////////
//
//	GlobeMaterialGenerator.cs
//
//	Copyright (c) 2016-2017, Pipeworks Inc.
//	All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////
using UnityEngine;
using System.Collections;
#if UNITY_EDITOR
using UnityEditor;

public class GlobeMaterialGenerator : EditorWindow
{
	const string USAGE_INSTRUCTIONS = "For use generating cut-up globe materials from a series of textures.";
	const string NAME_CONVENTION = "Expected naming convention for all files: [A-P][1-32].\nEx: A1, H12, P32, D6";
	const string FOLDER_STRUCTURE = "Texture folders should be children of the \"Materials Root\"folder.";

	const string DEFAULT_SHADER_NAME = "Pipeworks_Custom/JCOR Planetary Terrain";

	string MaterialsRootFolder = "Assets/GlobeRender/Meshes/materials/";
	string DiffuseMapsFolder = "Textures/color/";
	string SpecularMapsFolder = "Textures/spec";
	string NormalMapsFolder = "Textures/normal/";
	string DisplacementMapsFolder = "Textures/DEM/";
	string NightlightsMapFolder = "Textures/Night";

	string TextureExtention = "psd";
	int NumVerticalIndices = 5;			//Starts at 1 ('A' - this is a letter)
	int NumHorizontalIndices = 10;		//Starts at 1

	static GUILayoutOption FieldTitleStyle = GUILayout.Width(150f);
	static GUILayoutOption IndiceStyle = GUILayout.Width(30f);

	Shader GlobeShader = null;
	Transform GlobeRoot;

	//---------------------------------------------------------------------------
	#region Initialization

	[MenuItem("Pipeworks/Globe Material Generator")]
	static void Init()
	{
		GlobeMaterialGenerator window = GetWindow<GlobeMaterialGenerator>();

		VerifyGlobeShader(window);

		window.titleContent = new GUIContent("Globe-inator");
		window.Show();
	}

	static void VerifyGlobeShader(GlobeMaterialGenerator window)
	{
		if (window.GlobeShader == null)
			window.GlobeShader = Shader.Find(DEFAULT_SHADER_NAME);
	}

	#endregion
	//---------------------------------------------------------------------------
	#region Editor Window

	void OnGUI()
	{
		GUILayout.Label(USAGE_INSTRUCTIONS, EditorStyles.boldLabel);
		GUILayout.Label(NAME_CONVENTION);

		DrawSeperator();

		GUILayout.Label(FOLDER_STRUCTURE);
		StringField("Materials Root Folder", ref MaterialsRootFolder);
		StringField("Diffuse Maps", ref DiffuseMapsFolder);
		StringField("Specular Maps", ref SpecularMapsFolder);
		StringField("Normal Maps", ref NormalMapsFolder);
		StringField("Displacement Maps", ref DisplacementMapsFolder);
		StringField("Night Lights", ref NightlightsMapFolder);

		GUILayout.Space(10);

		ObjectField<Shader>("Shader", ref GlobeShader);
		ObjectField<Transform>("Prefab Root", ref GlobeRoot);

		GUILayout.Space(10);

		StringField("Texture Extension", ref TextureExtention);
		DrawIndexFields();

		DrawSeperator();
		DrawSeperator();

		EditorGUI.BeginDisabledGroup(GlobeRoot == null);
		{
			if (GUILayout.Button("Generate"))
				GenerateMaterialsAndPrefab();
		}
		EditorGUI.EndDisabledGroup();

		DrawSeperator();

		GUILayout.Label("Refresh Specific Textures:");
		EditorGUILayout.BeginHorizontal();
		{
			if (GUILayout.Button("Diffuse Maps"))
				RefreshColorMaps();
			if (GUILayout.Button("Specular Maps"))
				RefreshSpecularMaps();
			if (GUILayout.Button("Displacement Maps"))
				RefreshDisplacementMaps();
			if (GUILayout.Button("Normal Maps"))
				RefreshNormalMaps();
			if (GUILayout.Button("Nightlights Maps"))
				RefreshNightlightsMaps();
		}
		EditorGUILayout.EndHorizontal();

		DrawSeperator();

		GUILayout.Label("NOTE: Normal maps are named as A1_N.  This \"_N\" has \nbeen hard-coded in and will need to be removed if desired.");
	}


	/// <summary>
	/// Encapsulate string edit field.
	/// </summary>
	/// <param name="name"></param>
	/// <param name="str"></param>
	/// <returns></returns>
	void StringField(string name, ref string str)
	{
		EditorGUILayout.BeginHorizontal();
		{
			EditorGUILayout.LabelField(name, FieldTitleStyle);
			str = EditorGUILayout.TextField(str);
		}
		EditorGUILayout.EndHorizontal();
	}

	/// <summary>
	/// Encapsulate object reference field.
	/// </summary>
	/// <param name="name"></param>
	/// <param name="obj"></param>
	/// <returns></returns>
	void ObjectField<T>(string name, ref T obj) where T:Object
	{
		obj = (T)EditorGUILayout.ObjectField(name, obj, typeof(T), true);
	}

	/// <summary>
	/// Encapsulate vertical/horizontal index specification composite field.
	/// </summary>
	/// <returns></returns>
	void DrawIndexFields()
	{
		EditorGUILayout.BeginHorizontal();
		{
			EditorGUILayout.LabelField("Indices", FieldTitleStyle);
			NumVerticalIndices = EditorGUILayout.IntField(NumVerticalIndices, IndiceStyle);
			EditorGUILayout.LabelField("x", GUILayout.Width(12));
			NumHorizontalIndices = EditorGUILayout.IntField(NumHorizontalIndices, IndiceStyle);

			string example = string.Format("   [A-{0}][1-{1}]", (char)('A' + NumVerticalIndices - 1), NumHorizontalIndices);
			EditorGUILayout.LabelField(example);
		}
		EditorGUILayout.EndHorizontal();
	}

	void DrawSeperator()
	{
		GUILayout.Space(5);
		GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(1) });
		GUILayout.Space(5);
	}

	#endregion
	//---------------------------------------------------------------------------
	#region Generation

	void GenerateMaterialsAndPrefab()
	{
		char lastChar = (char)('A' - 1 + NumVerticalIndices);

		for (char letter = 'A'; letter <= lastChar; letter++)
			for (int num = 1; num <= NumHorizontalIndices; num++)
			{
				string baseName = letter + num.ToString();
				Material mat = GenerateMaterial(baseName);
				BindMaterialToPrefab(baseName, mat);
			}
	}

	Material GenerateMaterial(string baseName)
	{
		Material mat = new Material(GlobeShader);

		string newMaterialFile = MaterialsRootFolder + baseName + ".mat";
		string diffuseMapFile = MaterialsRootFolder + DiffuseMapsFolder + baseName + "." + TextureExtention;
		string specularMapFile = MaterialsRootFolder + SpecularMapsFolder + baseName + "." + TextureExtention;
		string displacementFile = MaterialsRootFolder + DisplacementMapsFolder + baseName + "." + TextureExtention;
		string normalMapFile = MaterialsRootFolder + NormalMapsFolder + baseName + "_N." + TextureExtention;
		string nightlightsMapFile = MaterialsRootFolder + NightlightsMapFolder + baseName + "." + TextureExtention;

		Texture diffuseMap = AssetDatabase.LoadAssetAtPath<Texture>(diffuseMapFile);
		Texture specularMap = AssetDatabase.LoadAssetAtPath<Texture>(specularMapFile);
		Texture displacementTexture = AssetDatabase.LoadAssetAtPath<Texture>(displacementFile);
		Texture normalMap = AssetDatabase.LoadAssetAtPath<Texture>(normalMapFile);
		Texture nightlightsMap = AssetDatabase.LoadAssetAtPath<Texture>(nightlightsMapFile);

		mat.SetTexture("_MainTex", diffuseMap);
		mat.SetTexture("_SpecMap", specularMap);
		mat.SetTexture("_DispTex", displacementTexture);
		mat.SetTexture("_NormalMap", normalMap);
		mat.SetTexture("_NightLights", nightlightsMap);

		//Material is set up - Save in materials folder.

		AssetDatabase.CreateAsset(mat, newMaterialFile);
		return mat;
	}

	void BindMaterialToPrefab(string baseName, Material mat)
	{
		Transform trans = GlobeRoot.Find(baseName);
		trans.GetComponent<MeshRenderer>().material = mat;
	}

	#endregion
	//---------------------------------------------------------------------------
	#region Texture Refresh

	void RefreshColorMaps()
	{
		string fileName = MaterialsRootFolder + DiffuseMapsFolder + "{0}." + TextureExtention;
		RefreshTextureByType(fileName, "_MainTex");
	}

	void RefreshSpecularMaps()
	{
		string fileName = MaterialsRootFolder + SpecularMapsFolder + "{0}." + TextureExtention;
		RefreshTextureByType(fileName, "_SpecMap");
	}

	void RefreshDisplacementMaps()
	{
		string fileName = MaterialsRootFolder + DisplacementMapsFolder + "{0}." + TextureExtention;
		RefreshTextureByType(fileName, "_DispTex");
	}

	void RefreshNormalMaps()
	{
		string fileName = MaterialsRootFolder + NormalMapsFolder + "{0}_N." + TextureExtention;
		RefreshTextureByType(fileName, "_NormalMap");
	}

	void RefreshNightlightsMaps()
	{
		string fileName = MaterialsRootFolder + NightlightsMapFolder + "{0}." + TextureExtention;
		RefreshTextureByType(fileName, "_NightLights");
	}

	void RefreshTextureByType(string folderPreformatted, string textureProperty)
	{
		char lastChar = (char)('A' - 1 + NumVerticalIndices);

		for (char letter = 'A'; letter <= lastChar; letter++)
			for (int num = 1; num <= NumHorizontalIndices; num++)
			{
				string baseName = letter + num.ToString();
				string texturePath = string.Format(folderPreformatted, baseName);
				string materialPath = MaterialsRootFolder + baseName + ".mat";

				Texture texture = AssetDatabase.LoadAssetAtPath<Texture>(texturePath);
				Material mat = AssetDatabase.LoadAssetAtPath<Material>(materialPath);
				mat.SetTexture(textureProperty, texture);
			}
	}

	#endregion
	//---------------------------------------------------------------------------
}
#endif