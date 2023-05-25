//
// Author: ZhaoNan
// DateTime: 2021/12/13
// NPR + PBR chracter shader
//
Shader "Custom/NPRCharacter"
{
    Properties
    {
        //shadow Hatching
        _TileFactor("TileFactor", float) = 1
        _Hatch0 ("Hatch 0", 2D) = "white" {}
		_Hatch1 ("Hatch 1", 2D) = "white" {}
		_Hatch2 ("Hatch 2", 2D) = "white" {}
		_Hatch3 ("Hatch 3", 2D) = "white" {}
		_Hatch4 ("Hatch 4", 2D) = "white" {}
		_Hatch5 ("Hatch 5", 2D) = "white" {}
        //
		_BaseMap ("Base Map", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)
        [Toggle] _Alphatest("ALPHATEST", int) = 0
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
		_BumpScale("Bump Scale", Range(0,10)) = 1.0
		[Normal] _BumpMap("Normal Map", 2D) = "bump" {}
        [Toggle] _UseFNMap("Use Face Normal Map", int) = 0
        _FNMap("Face Normal Map", 2D) = "bump" {}
        
        _GlobalCharacterLightDir("Global Character Light Dir", Vector) = (0, 1, -1, 0)
		_GlobalCharacterLightColor("Global Character Light Color", Color) = (1,1,1,1)
    	_GlobalCharacterAdditive("Global Character Additive", Color) = (0,0,0,0)
    	
        //BenCun Line
        [Toggle] _BenCunLine("BenCun Line", Int) = 0
        _BenCunPower("BenCun Power", Float) = 0.0
        _BenCunColor("BenCun Color", Color) = (1,1,1,1)
        _BenCunMask("BenCun Mask", 2D) = "white" {}
        //
        [Toggle] _CelEnable("Cel Enable", Int) = 0
		_CelMask("Cel Mask", 2D) = "white" {}
        [Toggle(_FaceReverse)] _FaceReverse("Face Reverse", Int) = 0
    	_FaceMask("Face Mask", 2D) = "white" {}
        //_NoseSDF
        [Toggle(_Nosehighlights)] _Nosehighlights ("Nose highlights", Float) = 0.0
        _NoseSDF("NoseSDF", 2D) = "white" {}
        //
    	_ShadowColorMask("Shadow Color Mask", 2D) = "white" {}
		_NoShadowColor("No Shadow Color", Color) = (1,1,1,1)
		_GlobalCharacterNoShadowColor("Global Character No Shadow Color", Color) = (1,1,1,1)
        //Face Shadow Smoothness
        [Toggle(_UseFaceShadowSmoothness)] _UseFaceShadowSmoothness ("Use Face Shadow Smoothness", Float) = 0.0
        _FaceShadowSmoothness("Face Shadow Smoothness", Float) = 0
        //
		_FirstShadow("First Shadow", Float) = 0.525
		_FirstShadowColor("First Shadow Color", Color) = (0.5,0.5,0.5,1)

        [Space(20)]
        [Toggle(_IsFace)] _IsFace ("IsFace", Float) = 0.0
        //[Toggle(_IsCloth)] _IsCloth ("IsCloth", Float) = 0.0
        _HairShadowDistace ("_HairShadowDistance", Float) = 1
        [Header(heightCorrectMask)]
        _HeightCorrectMax ("HeightCorrectMax", float) = 1.6
        _HeightCorrectMin ("HeightCorrectMin", float) = 1.51
        [Space(20)]

        //Render Feature Hair B
        /* [Header(Stencil)]
        _StencilRef ("_StencilRef", Range(0, 255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp ("_StencilComp", Float) = 0 */
        //
        //Edge Light//Delete
        /* _EdgeShadow("Edge Shadow", Float) = 0.525
        _EdgeShadowColor("Edge Shadow Color", Color) = (0.5,0.5,0.5,1)
        _SSSMap ("SSS Map", 2D) = "white" {} */
        //
		_GlobalCharacterFirstShadowColor("Global Character First Shadow Color", Color) = (1,1,1,1)
		_SecondShadow("Second Shadow", Float) = 0.51
		_SecondShadowColor("Second Shadow Color", Color) = (0.4,0.4,0.4,1)
		_GlobalCharacterSecondShadowColor("Global Character Second Shadow Color", Color) = (1,1,1,1)
		_GlobalCharacterShadowIntensity("Global Character Shadow Intensity", Float) = 1
		
		_SpecularGloss("Specular Gloss", Float) = 4
		_SpecularIntensity("Specular Intensity", Float) = 1.1
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_GlobalCharacterSpecularColor("Global Character Specular Color", Color) = (1,1,1,1)
		
    	_AnisoNoiseMask("Aniso Map", 2D) = "white" {}
    	_AnisoSpecularColor1("Aniso Specular Color1", Color) = (1,1,1)
    	_AnisoSpecularGloss1("Aniso Specular Gloss1", Range(0,1)) = 0.1
    	_AnisoSpecularNoise1("Aniso Specular Noise1", Range(0,10)) = 1
    	_AnisoSpecularOffset1("Aniso Specular Offset1", Range(0,10)) = 0
    	_AnisoSpecularColor2("Aniso Specular Color2", Color) = (1,1,1)
    	_AnisoSpecularGloss2("Aniso Specular Gloss2", Range(0,1)) = 0.1
    	_AnisoSpecularNoise2("Aniso Specular Noise2", Range(0,10)) = 1
    	_AnisoSpecularOffset2("Aniso Specular Offset2", Range(0,10)) = 0    	
    	
		[HideInInspector] _PBRMode("__pbrMode", Float) = 0.0
        _PBRMask("PBR Mask", 2D) = "black" {}
        [Toggle(_PBRLight)] _PBRLight("USE PBR Directional Light", Int) = 0
        [Toggle(_AdditionalLights)] _AddLights ("AddLights", Float) = 1
        _PBRRate("PBR Rate", Range(0.0,1.0)) = 0.0
        _MetallicMapScale("Metallic Map Scale", Range(0,1)) = 1.0
        _MetallicRemapMin("Metallic Remap Min", Float) = 0.0
        _MetallicRemapMax("Metallic Remap Max", Float) = 1.0
        _RoughnessMapScale("Roughness Map Scale", Range(0,1)) = 1.0
		_RoughnessRemapMin("Roughness Remap Min", Float) = 0.0
		_RoughnessRemapMax("Roughness Remap Max", Float) = 1.0
        
        _AOMapScale("AO Map Scale", Range(0,1)) = 0.619
        [HDR]_IBLMap("IBL Map", Cube) = "black" {}
        _IBLMapColor("IBL Map Color", Color) = (1,1,1,1)
        _IBLMapIntensity("IBL Map Intensity", Float) = 20
        _IBLMapRotate("IBL Map Rotate", Range(0,360)) = 0
        
    	_PBRDirectLightColor("PBR Direct Light Color", Color) = (0,0,0,1)
        _PBRDiffuseIntensity("PBR Diffuse Intensity", Float) = 1.0
    	_PBRSpecularIntensity("PBR Specular Intensity", Float) = 1.0

		_PBRIndirectLightColor("PBR Indirect Light Color", Color) = (1,1,1,1)
		_PBRIndirectLightIntensity("PBR Indirect Light Intensity", Float) = 2.75
        
        [HideInInspector] _SkinMode("__SkinMode", Int) = 0.0
        _SkinMap("Skin Map", 2D) = "white" {}
        _SkinColor("Skin Color", Color) = (1,1,1,1)
        _SkinIntensity("Skin Intensity", Float) = 1
        _SkinRate("Skin Rate", Range(0,1)) = 0
        
        [Toggle]_RimEnableA("Rim Enable A", Int) = 0
        _RimSpreadMax("Rim Spread Max", Float) = 1
        _RimSpreadMin("Rim Spread Min", Float) = 0
        _RimLightColor("Rim Light Color", Color) = (1,1,1,1)
        _RimIntensity("Rim Intensity", Float) = 1
        _RimThreshold("Rim Threshold", Float) = 0.5
        _RimDistanceMin("Rim Distance Min", Float) = 1
        _RimDistanceMax("Rim Distance Max", Float) = 100
        _DistanceRimEnable("Distance Rim Enable", Range(0,1)) = 0
        _GlobalCharacterRimLightDir("Global Character Rim Light Dir", Vector) = (0,1,1,0)
        _GlobalCharacterRimLightColor("Global Character Rim Light Color", Color) = (1,1,1,1)
        
        //EdgeLight
        [Toggle]_RimEnableB("Rim Enable B", Int) = 0
        _RimMask ("Rim Mask", 2D) = "white" {}
        _RimMin ("RimMin", Float) = 0.0
        _RimMax ("RimMax", Float) = 1.0
        _RimSmooth ("RimSmooth", Float) = 0.0
        _RimColor ("RimColor", Color) = (1, 1, 1, 1)
        //
        [Space(20)]
        [Toggle] _EnableRim("EnableRim", Int) = 0
        //[ToggleOff] _BlendRim("BlendRim",Float) = 1.0
        _RimColor2("RimColor",Color) = (1.0,1.0,1.0,1.0)
        _RimPow("RimPower",Range(0.0,10.0)) = 4
        _RimStep("RimStep",Range(0.0,1.0)) = 0.5
        _RimFeather("RimFeather",Range(0.0,1.0)) = 0
        _Shadow1Step("Shadow1 Step", Range(0.0,1.0)) = 0.0
        _Shadow2Step("Shadow2 Step", Range(0.0,1.0)) = 0.0
        _Shadow1Feather("Shadow1 Feather", Range(0.0,1.0)) = 0.0
        _Shadow2Feather("Shadow2 Feather", Range(0.0,1.0)) = 0.0
        _Shadow1Color("Shadow1Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _Shadow2Color("Shadow2Color", Color) = (0.0, 0.0, 0.0, 0.0)
        //

        //Anisotropy
        [Space(20)]
        [Toggle(_Anisotropy)] _Anisotropy("Anisotropy Hair", Int) = 0
        _BaseAnisotropy("Base Anisotropy Map",2D) = "white"{}
        _BumpAnisotropy("Normal Anisotropy Map",2D) = "bump"{}
        _NoiseAnisotropy("Noise Anisotropy Map",2D) = "white"{}
        _ShadowTex("Shadow Tex Map",2D) = "white"{}
        _SpeBgColor("SpeBgColor", Color) = (1.0,1.0,1.0,1)
        _SpeBgGloss("SpeBgGloss", Range( 8 , 256)) = 1
        _SpeBgInt("SpeBgInt", Range( 0 , 2)) = 1
        _ShiftBg("ShiftBg", float) = 0.2
        _SpeLowColor("SpeLowColor", Color) = (1.0,1.0,1.0,1)
        _SpeLowGloss("SpeLowGloss", Range( 8 , 256)) = 1
        _SpeLowInt("SpeLowInt", Range( 0 , 2)) = 1
        _ShiftLow("ShiftLow", float) = 0
        _SpeHighGloss("SpeHighGloss", Range( 8 , 18)) = 0
        _SpeHighInt("SpeHighInt", Range( 0 , 2)) = 1
        _ShiftHigh("ShiftHigh", float) = 0
        _LightDir("Light Dir", Vector) = (0, 1,-1,1)
        _v("v", Range( 0 , 1)) = 1
        /*
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _SpecularShiftMap("SpecularShiftMap",2D) = "white"{}
        _SpecularShiftIntensity("SpecularShiftIntensity",Range(0.0,3.0)) = 1.0
        _SpecularShift1("SpecularShift",Float) = 0.0
        _SpecularShift2("SpecularShiftSec",Float)= 0.0
        _Specular2Mul ("SpecularSecMul", Range (0.0,1.0) ) = 0.5 */
        //

        
    	[HideInInspector] _UVAniMode("__UVAniMode", Int) = 0
        [Space(20)]
    	_UVAniMap("UV Ani Map", 2D) = "black" {}
    	_UVAniIntensity("Intensity", Float) = 1.0
    	_UVAniSpeedScale("Speed and Scale", Vector) = (0.1,0,1,1)
    	        
        [Toggle]_SimpleRimEnable("Simple Rim Enable", Int) = 0
        _SimpleRimColor("Simple Rim Color", Color) = (0,0,0,0)
        _SimpleRimSpread("Simple Rim Spread", Float) = 0
        _SimpleRimIntensity("Simple Rim Intensity", Float) = 0
        
        [Toggle] _IridescenceEnable("Iridescence Enable", Int) = 0
        _IridescenceMap("Iridescence Map", 2D) = "white" {}
        _IridescenceIntensity("Iridescence Intensity", Range(0,1)) = 0.5
        _IridescenceUVScale("Iridescence UVScale", Range(0,10)) = 4
        _IridescenceUVOffset("Iridescence UVOffset", Range(0,1)) = 0
        _IridescenceSpread("Iridescence Spread", Range(0,1)) = 0.9
        _IridescenceF0("IridescenceF0", Range(0,1)) = 0.04
        _IridescenceRoughness("Roughness", Range(0,1)) = 0.5
        _IridescenceRoughnessScale("Roughness Scale", Range(0,1)) = 0.5

        [Toggle] _SpectrumEnable("Spectrum Enable", Int) = 0
        _SpectrumMap("Spectrum Map", 2D) = "white" {}
        _SpectrumIntensity("Spectrum Intensity", Range(0,10)) = 3.2
        _SpectrumFocusDistance("Spectrum Focus Distance", Float) = 5
        _SpectrumSpreadScale("Spectrum Range Scale", Float) = 0.96
        _SpectrumSpreadOffset("Spectrum Spread Offset", Float) = 0
		_SpectrumFresnel("Spectrum Fresnel", Vector) = (1,1,0,0)
		_SpectrumAlpha("Spectrum Alpha", Vector) = (0.7, 1, 0.9, 0)

        [Toggle]_DissolveEnable("Dissolve Enable", Int) = 0
        _DissolveTex("DissolveTex", 2D) = "white" {}
        _RampTex("DisRamp", 2D) = "white" {}
		_Dissolve("Dissolve", Range( 0.0 , 1)) = 0.0
        _EdgeWidth("Edge Width", Range(0.05, 0.2)) = 0.066
        _MinBorderY("Min Border Y", Float) = -0.0 //Y坐标
		_MaxBorderY("Max Border Y", Float) = 2.0  
        _DistanceEffect("Distance Effect", Range(0.0, 1.0)) = 0.6
        _AshWidth("Ash Width", Range(0, 0.25)) = 0.011
        
        [Toggle]_ToneMappingEnable("Tone Mapping Enable", Int) = 0
        _ToneMappingFactor("ACES ToneMapping Factor", Range(0.0,2.0)) = 1.0
    	_Exposure("Exposure", Float) = 13
    	_Contrast("Contrast", Float) = 1.8
    	_UserLut("UserLut", 2D) = "black" {}
    	_UserLutParams("UserLutParams", Vector) = (0.0009765625,0.03125,31,1)
    	
        _BloomFactor("Bloom Factor", Range(0,2)) = 1
        _EmissionBloomFactor("Emission Bloom Factor", Float) = 0
        _EmissionColor("Emission Color", Color) = (0,0,0,0)
        _EmissionScale("Emission Scale", Float) = 1
        _EmissionIntensity("Emission Intensity", Float) = 0
        
        _GlobalModColor("Global Mod Color", Color) = (1,1,1,1)
        _BloomModColor("Bloom Mod Color", Color) = (1,1,1,1)
        _BloomModIntensity("Bloom Mod Intensity", Float) = 1
        _BloomModRate("Bloom Mod Rate", Float) = 1
        _GlobalCharacterAmbientColor("Global Character Ambient Color", Color) = (1,1,1,1)
        
        [Toggle]_LinearFogEnable("Linear Fog Enable", Int) = 0
        _LinearFogColor("Linear Fog Color", Color) = (1,1,1,1)
        _LinearFogParams("Linear Fog Params", Vector) = (0,1,0,0)			
		
		[Toggle]_OutlineEnable("Outline Enable", Int) = 0
        [HideInInspector]_MaskColor("Mask Color", Color) = (0, 0, 0, 1)
		_OutlineColor("Outline Color", Color) = (0.014,0.014,0.014,0.3)
		_OutlineZOffset("Outline Z Offset", float) = 0
		//_OutlineZMaxOffset("Outline Z Max Offset", float) = 1
		//_OutlineDitanceScale("Outline Ditance Scale", float) = 0.0016
		_OutlineWidth("Outline Width", float) = 1
		_GlobalCharacterOutlineColor("Global Character Outline Color", Color) = (1,1,1,1)
		_OutlineIntensity("Outline Intensity", float) = 1
		_OutlineBloomFactor("Outline Bloom Factor", float) = 0.1

        //MShadow
        _ShadowColor("ShadowColor", Color) = (0, 0, 0, 0)
        _ShadowFalloff("_ShadowFalloff", Float) = 0.0
        //
        
        [HideInInspector] _ShadingModel("__shadingModel", Float) = 0.0
        
        // BlendMode
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("Src", Float) = 1.0
        [HideInInspector] _DstBlend("Dst", Float) = 0.0
        [HideInInspector] _ZWrite("ZWrite", Float) = 1.0
        //[HideInInspector] _Cull("__cull", Float) = 2.0

        _ReceiveLighting_ON("UseDirectionalAmbientLight", Float) = 0.0
		[Toggle(_RECEIVE_SHADOWS_OFF)]_RECEIVE_SHADOWS_OFF("Receive Shadows", Float) = 1.0
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _GlossMapScale("Smoothness", Float) = 0.0
        [HideInInspector] _Glossiness("Smoothness", Float) = 0.0
        [HideInInspector] _GlossyReflections("EnvironmentReflections", Float) = 0.0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull Mode", Float) = 1

    }
    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        LOD 300

        Pass
        {
			Name "ForwardLit"
			Tags{"LightMode" = "UniversalForward"}

            //Renderer Feature Hair
            Stencil
            {
                Ref 0
                Comp Always
                Pass replace
            }
            //
			
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]
            //ZTest GEqual//Eyebrow deep
			Cull [_Cull]
                    	
            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
			#pragma target 3.0
			#pragma shader_feature _NORMALMAP
            #pragma shader_feature _USEFNMAP_ON//face normal map
			#pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature _ALPHABLEND_ON
			#pragma shader_feature _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _UVANIDEFAULT_ON
            #pragma shader_feature _RECEIVELIGHTING_ON
           //  #pragma multi_compile _ReceiveLighting_OFF _ReceiveLighting_ON
            //#pragma shader_feature _RECEIVELIGHTING_OFF
			#pragma shader_feature _CELENABLE_ON
            #pragma shader_feature _BENCUNLINE_ON
            #pragma shader_feature _PBRMASK_ON
			#pragma shader_feature _ _PBRURP_ON _PBRAPPRO_ON _PBRUE4_ON
			#pragma shader_feature _ _SKINRAMP_ON _SKINSSS_ON
            #pragma shader_feature _UseFaceShadowSmoothness//Use Face Shadow Smoothness
            #pragma shader_feature _FaceReverse//Face Reverse
            #pragma shader_feature _Nosehighlights//Nose highlights
            #pragma shader_feature _IsFace//Hair shadow
            #pragma shader_feature _IsCloth//Self-projection
            #pragma shader_feature _Anisotropy//_Anisotropy
            #pragma shader_feature _PBRLight//PBR Light
            #pragma shader_feature _AdditionalLights//Additional Lights
			#pragma shader_feature _RIMENABLEA_ON
            #pragma shader_feature _RIMENABLEB_ON
            #pragma shader_feature _ENABLERIM_ON
			#pragma shader_feature _SIMPLERIMENABLE_ON
			#pragma shader_feature _IRIDESCENCE_ON
			#pragma shader_feature _SPECTRUM_ON
            #pragma shader_feature _TONEMAPPINGENABLE_ON
            #pragma shader_feature _LINEARFOGENABLE_ON
            #pragma shader_feature _OUTLINEENABLE_ON
            #pragma shader_feature _ _SHADINGMODEL_FACE _SHADINGMODEL_HAIR
            #pragma shader_feature _DISSOLVE_ON

            #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
			#pragma shader_feature _RECEIVE_SHADOWS_OFF
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile_instancing
            #pragma vertex vert_base
            #pragma fragment frag_base
            
            #include "CustomInput.hlsl"
            #include "CustomCoreBase.hlsl"
			
            ENDHLSL
        }
        
		Pass
		{
			Name "ForwardOutline"
			Tags{"LightMode" = "ForwardOutline"}
			Cull Front
            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
			#pragma target 3.0//4.5
			#pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature _ALPHABLEND_ON
			#pragma shader_feature _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _LINEARFOGENABLE_ON
			#pragma shader_feature _OUTLINEENABLE_ON
			#pragma vertex vert_outline
			#pragma fragment frag_outline
			
			#include "CustomOutline.hlsl"
			
			ENDHLSL
		}

        // Pass
        // {
        //     Name "Mask"
        //     Tags{"LightMode" = "Mask"}

        //     ZWrite On
        //     Cull[_Cull]

        //     HLSLPROGRAM
        //     #pragma prefer_hlslcc gles
        //     #pragma exclude_renderers d3d11_9x
        //     #pragma target 3.0//2.0
        //     #pragma vertex vert
        //     #pragma fragment frag

        //     #include "CustomInput.hlsl"
        //     #include "CustomOutlineMaskCoreBase.hlsl"

        //     ENDHLSL
        // }
		
		Pass
		{
			Name "ForwardAlphaWrite"
			Tags{"LightMode" = "ForwardAlphaWrite"}
			
			Blend One Zero
			ZTest Off
			ZWrite Off
			ColorMask A
			
            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
			#pragma target 2.0
			
			#pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature _ALPHABLEND_ON
			#pragma shader_feature _ALPHAPREMULTIPLY_ON
			
			#pragma vertex vert_alpha_write
			#pragma fragment frag_alpha_write
			
			#include "CustomAlphaWrite.hlsl"
			ENDHLSL			
		}

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

			//#include "CustomShadow.hlsl"

            #include "ShadowInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        // Pass
        // {
        //     Name "MShadowCaster"

        //     Stencil
        //     {
        //         Ref 0
        //         Comp equal
        //         Pass incrWrap
        //         Fail keep
        //         ZFail keep
        //     }

        //     Blend SrcAlpha OneMinusSrcAlpha
        //     ZWrite on
        //     Offset -1 , 0

        //     HLSLPROGRAM
        //     #pragma vertex vert
        //     #pragma fragment frag

        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        //     #include "CustomLighting.hlsl"
        //     struct appdata
        //     {
        //         float4 vertex : POSITION;
        //     };

        //     struct v2f
        //     {
        //         float4 vertex : SV_POSITION;
        //         float4 color : COLOR;
        //     };
            
        //     float4 _ShadowColor;
        //     float _ShadowFalloff;

        //     float3 ShadowProjectPos(float4 vertPos)
        //     {
        //         float3 shadowPos;

        //         float3 worldPos = mul(unity_ObjectToWorld , vertPos).xyz;

        //         float3 lightDir = normalize(_MainLightPosition.xyz);

        //         ///Additional Lights
        //         /* uint pixelLightCount = GetAdditionalLightsCount();
        //         for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++ lightIndex)
        //         {
        //             Light light = GetAdditionalLight(lightIndex, vertPos.xyz);
        //             lightDir += SafeNormalize(light.direction);
        //         } */
        //         ///

        //         shadowPos.y = min(worldPos .y , _MainLightPosition.w);
        //         shadowPos.xz = worldPos .xz - lightDir.xz * max(0 , worldPos .y - _MainLightPosition.w) / lightDir.y; 

        //         return shadowPos;
        //     }

        //     v2f vert (appdata v)
        //     {
        //         v2f o;

        //         float3 shadowPos = ShadowProjectPos(v.vertex);

        //         o.vertex = mul(UNITY_MATRIX_VP, float4(shadowPos, 1.0));

        //         float3 center =float3( unity_ObjectToWorld[0].w , _MainLightPosition.w , unity_ObjectToWorld[2].w);

        //         float falloff = 1-saturate(distance(shadowPos , center) * _ShadowFalloff);

        //         o.color = _ShadowColor; 
        //         o.color.a *= falloff;

        //         return o;
        //     }

        //     float4 frag (v2f i) : SV_Target
        //     {
        //         return i.color;
        //     }
        //     ENDHLSL
        // } 
		
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    //CustomEditor "NPRCharacterGUI"
}

