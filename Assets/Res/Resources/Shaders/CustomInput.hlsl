//
// Author: ZhaoNan
// DateTime: 2021/12/17
// NPR character shader input
//
#ifndef CUSTOM_INPUT_INCLUDED
#define CUSTOM_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "CustomCommonInput.hlsl"

CBUFFER_START(UnityPerMaterial)
//Hatching
float _TileFactor;
//
float4 _BaseMap_ST;
float4 _NoiseAnisotropy_ST;
half4 _BaseColor;
half _Cutoff;
//#if defined(_NORMALMAP) || defined(_USEFNMAP_ON)
half _BumpScale;
//#endif

half4 _GlobalCharacterLightDir;
half4 _GlobalCharacterLightColor;
half3 _GlobalCharacterAdditive;

//#if defined(_CELENABLE_ON)
half3 _NoShadowColor;
half3 _GlobalCharacterNoShadowColor;
//Face Shadow Smoothness
half _FaceShadowSmoothness;
//
half _FirstShadow;
half3 _FirstShadowColor;
//_Edge Light
half _EdgeShadow;
half3 _EdgeShadowColor;
//
half3 _GlobalCharacterFirstShadowColor;
half _SecondShadow;
half3 _SecondShadowColor;
half3 _GlobalCharacterSecondShadowColor;
half _GlobalCharacterShadowIntensity;

//#if defined(_SHADINGMODEL_HAIR)
half3 _AnisoSpecularColor1;
half _AnisoSpecularGloss1;
half _AnisoSpecularNoise1;
half _AnisoSpecularOffset1;
half3 _AnisoSpecularColor2;
half _AnisoSpecularGloss2;
half _AnisoSpecularNoise2;
half _AnisoSpecularOffset2;
//#else
half3 _SpecularColor;
half _SpecularGloss;
half _SpecularIntensity;
//#endif
half3 _GlobalCharacterSpecularColor;
//#endif

//#if defined(_PBRURP_ON) || defined(_PBRAPPRO_ON) || defined(_PBRUE4_ON)
half _PBRRate;
half _MetallicMapScale;
half _RoughnessMapScale;
half _AOMapScale;
//#if defined(_PBRMASK_ON)
half _MetallicRemapMin;
half _MetallicRemapMax;
half _RoughnessRemapMin;
half _RoughnessRemapMax;
//#endif
half4 _IBLMap_HDR;
half4 _IBLMapColor;
half _IBLMapIntensity;
half _IBLMapRotate;
half3 _PBRDirectLightColor;
half _PBRDiffuseIntensity;
half _PBRSpecularIntensity;
half3 _PBRIndirectLightColor;
half _PBRIndirectLightIntensity;
//#endif

//#if defined(_SKINRAMP_ON) || defined(_SKINSSS_ON)
half _SkinRate;
half3 _SkinColor;
half _SkinIntensity;
//#endif

//#ifdef _RIMENABLEA_ON
half _RimSpreadMax;
half _RimSpreadMin;
half _RimIntensity;
half3 _RimLightColor;
half _RimThreshold;
half _RimDistanceMin;
half _RimDistanceMax;
half _DistanceRimEnable;
half3 _GlobalCharacterRimLightDir;
half3 _GlobalCharacterRimLightColor;
//#endif

//BenCun Line
half  _BenCunPower;
half4 _BenCunColor;
//

//Edge Light
//#ifdef _RIMENABLEB_ON
half _RimMin;
half _RimMax;
half _RimSmooth;
half4 _RimColor;
//#endif
//
//EnableRim
half _Shadow1Step;
half _Shadow2Step;
half _Shadow1Feather;
half _Shadow2Feather;
half4 _Shadow1Color;
half4 _Shadow2Color;
//#ifdef _ENABLERIM_ON
half _RimPow;
half _RimStep;
half _RimFeather;
half4 _RimColor2;
//#endif
//

//Anisotropy
//#ifdef _Anisotropy
float4 _LightDir;
float _ShiftBg;
float _ShiftHigh;
float _ShiftLow;
float _SpeBgGloss;
float _SpeBgInt;
float _SpeLowGloss;
float _SpeLowInt;
float _SpeHighGloss;
half4 _SpeHighColor;
half4 _SpeLowColor;
half4 _SpeBgColor;
float _SpeHighInt;
float _v;
//#endif
/* half _Smoothness;
float4 _SpecularShiftMap_ST;
half _SpecularShiftIntensity;
half _SpecularShift1;
half _SpecularShift2;
half _Specular2Mul; */
//
//
//#if defined(_IsFace) || defined(_IsCloth)
float _HairShadowDistace;
float _HeightCorrectMax;
float _HeightCorrectMin;
//#endif
//
//#ifdef _SIMPLERIMENABLE_ON
half4 _SimpleRimColor;
half _SimpleRimSpread;
half _SimpleRimIntensity;
//#endif

//#ifdef _IRIDESCENCE_ON
half _IridescenceIntensity;
half _IridescenceSpread;
half _IridescenceF0;
half _IridescenceRoughness;
half _IridescenceRoughnessScale;
half _IridescenceUVScale;
half _IridescenceUVOffset;
//#endif

//#ifdef _SPECTRUM_ON
half _SpectrumFocusDistance;
half _SpectrumSpreadScale;
half _SpectrumSpreadOffset;
half _SpectrumIntensity;
half4 _SpectrumFresnel;
half4 _SpectrumAlpha;
//#endif

//#ifdef _TONEMAPPINGENABLE_ON
half _ToneMappingFactor;
half _Exposure;
half _Contrast;
half4 _UserLutParams;
//#endif

half _BloomFactor;
half _EmissionBloomFactor;
half3 _EmissionColor;
half _EmissionScale;
half _EmissionIntensity;
half3 _GlobalModColor;
half3 _BloomModColor;
half _BloomModIntensity;
half _BloomModRate;
half3 _GlobalCharacterAmbientColor;

//#ifdef _LINEARFOGENABLE_ON
half4 _LinearFogColor;
half4 _LinearFogParams;

half _OutlineZOffset;
//half _OutlineZMaxOffset;
//half _OutlineDitanceScale;
half _OutlineWidth;
half4 _GlobalCharacterOutlineColor;
half4 _OutlineColor;
half _OutlineIntensity;
half _OutlineBloomFactor;
float4 _MaskColor;
//#endif
///shadow caster
float4 _DetailAlbedoMap_ST;
half4 _SpecColor;
//half4 _EmissionColor;
//half _Cutoff;
half _Smoothness;
half _Metallic;
half _Parallax;
half _OcclusionStrength;
half _ClearCoatMask;
half _ClearCoatSmoothness;
half _DetailAlbedoMapScale;
half _DetailNormalMapScale;
half _Surface;
///

//MShadow
// float4 _ShadowColor;
// float _ShadowFalloff;
//
CBUFFER_END

//shadow Hatching
TEXTURE2D(_Hatch0);    SAMPLER(sampler_Hatch0);
TEXTURE2D(_Hatch1);    SAMPLER(sampler_Hatch1);
TEXTURE2D(_Hatch2);    SAMPLER(sampler_Hatch2);
TEXTURE2D(_Hatch3);    SAMPLER(sampler_Hatch3);
TEXTURE2D(_Hatch4);    SAMPLER(sampler_Hatch4);
TEXTURE2D(_Hatch5);    SAMPLER(sampler_Hatch5);

//

TEXTURE2D(_BaseMap);    SAMPLER(sampler_BaseMap);
TEXTURE2D(_CelMask);    SAMPLER(sampler_CelMask);
TEXTURE2D(_ShadowColorMask);    SAMPLER(sampler_ShadowColorMask);
TEXTURE2D(_SSSMap);     SAMPLER(sampler_SSSMap);
TEXTURE2D(_SkinMap);    SAMPLER(sampler_SkinMap);

//BenCun Line
TEXTURE2D(_BenCunMask); SAMPLER(sampler_BenCunMask);
//

//Edge Light
TEXTURE2D(_RimMask);    SAMPLER(sampler_RimMask);
//

//is Face
TEXTURE2D(_HairSoildColor);     SAMPLER(sampler_HairSoildColor);
//

//Anisotropy
#if _Anisotropy
TEXTURE2D(_BumpAnisotropy);     SAMPLER(sampler_BumpAnisotropy);
//TEXTURE2D(_SpecularShiftMap);   SAMPLER(sampler_SpecularShiftMap);
TEXTURE2D(_BaseAnisotropy);     SAMPLER(sampler_BaseAnisotropy);
TEXTURE2D(_NoiseAnisotropy);    SAMPLER(sampler_NoiseAnisotropy);
TEXTURE2D(_ShadowTex);          SAMPLER(sampler_ShadowTex);
#endif
//

#if defined(_CELENABLE_ON) && defined(_SHADINGMODEL_FACE)
TEXTURE2D(_FaceMask);   SAMPLER(sampler_FaceMask);
//
#if defined(_Nosehighlights)
TEXTURE2D(_NoseSDF);    SAMPLER(sampler_NoseSDF);
#endif
//
#endif

#if defined(_DISSOLVE_ON)
TEXTURE2D(_DissolveTex); SAMPLER(sampler_DissolveTex);
TEXTURE2D(_RampTex);     SAMPLER(sampler_RampTex);
half _Dissolve;
float _AshWidth;
float _DistanceEffect;
float _EdgeWidth;
float _MinBorderY;
float _MaxBorderY;
#endif

#if defined(_CELENABLE_ON) && defined(_SHADINGMODEL_HAIR)
TEXTURE2D(_AnisoNoiseMask); SAMPLER(sampler_AnisoNoiseMask);
#endif

#if defined(_PBRURP_ON) || defined(_PBRAPPRO_ON) || defined(_PBRUE4_ON)
#if defined(_PBRMASK_ON)
TEXTURE2D(_PBRMask);    SAMPLER(sampler_PBRMask);
#endif
TEXTURECUBE(_IBLMap); SAMPLER(sampler_IBLMap);
#endif

#ifdef _UVANIDEFAULT_ON
TEXTURE2D(_UVAniMap);SAMPLER(sampler_UVAniMap);
half _UVAniIntensity;
half4 _UVAniSpeedScale;
#endif

#ifdef _IRIDESCENCE_ON
TEXTURE2D(_IridescenceMap);SAMPLER(sampler_IridescenceMap);
#endif

#ifdef _SPECTRUM_ON
TEXTURE2D(_SpectrumMap);SAMPLER(sampler_SpectrumMap);
#endif

#ifdef _NORMALMAP
TEXTURE2D(_BumpMap);    SAMPLER(sampler_BumpMap);
#endif

#ifdef _USEFNMAP_ON//Face Normal Map
TEXTURE2D(_FNMap);    SAMPLER(sampler_FNMap);
#endif

#ifdef _TONEMAPPINGENABLE_ON
TEXTURE2D(_UserLut);    SAMPLER(sampler_UserLut);
half4 _UserLut_ST;
#endif

#if defined(_PBRURP_ON) || defined(_PBRAPPRO_ON) || defined(_PBRUE4_ON)
#if defined(_PBRMASK_ON)
half4 SamplePBRMap(float2 uv, out half metallic, out half perceptualRoughness, out half occlusion, out half pbrRatio)
{
    half4 maskTex = SAMPLE_TEXTURE2D(_PBRMask, sampler_PBRMask, uv);
    metallic = lerp(_MetallicRemapMin, _MetallicRemapMax, maskTex.x*_MetallicMapScale);
    perceptualRoughness = 1 - maskTex.y;
    perceptualRoughness = lerp(_RoughnessRemapMin, _RoughnessRemapMax, perceptualRoughness*_RoughnessMapScale);
    occlusion = maskTex.z;
#if defined(SHADER_API_GLES)
    occlusion = LerpWhiteTo(occlusion, _AOMapScale);
#endif
    pbrRatio = maskTex.w*_PBRRate;
    return maskTex;
}
#endif
#endif

#endif