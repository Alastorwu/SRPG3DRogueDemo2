//
// Author: ZhaoNan
// DateTime: 2022/1/12
// NPR character shader core
//
#ifndef CUSTOM_CORE_BASE_INCLUDED
#define CUSTOM_CORE_BASE_INCLUDED

#include "CustomUtils.hlsl"
#include "CustomLighting.hlsl"


struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 uv           : TEXCOORD0;
    float4 color		: COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Varyings
{
    float4 uv                       : TEXCOORD0;
	float3 positionWS               : TEXCOORD1;
	float3 normalWS                 : TEXCOORD2;
#if defined(_NORMALMAP) || defined(_SHADINGMODEL_HAIR) || defined(_USEFNMAP_ON)
    float4 tangentWS                : TEXCOORD3;    // xyz: tangent, w: sign
#endif
    half4 fogFactorAndVertexLight   : TEXCOORD4; // w: fogFactor, xyz: vertex light
    float4 color		            : COLOR;
    float4 positionCS               : SV_POSITION;
#ifdef _SPECTRUM_ON
	float4 focusDir                 : TEXCOORD6;
#endif
#ifdef _MAIN_LIGHT_SHADOWS
	float4 shadowCoord              : TEXCOORD7;
#endif

#if defined(_CELENABLE_ON) && defined(_SHADINGMODEL_FACE)
	float3 litDirOS                 : TEXCOORD8;
#endif
//
#if defined(_IsFace) || defined(_IsCloth) 
	float4 positionSS               : TEXCOORD9;
	float posNDCw                   : TEXCOORD10;
	float4 positionOS               : TEXCOORD11;
#endif
//

///Anisotropy
//#if _Anisotropy
	float3 bitangentWS              : TEXCOORD12;
	float3 tangentWS2               : TEXCOORD13;//Anisotropy
	#if _Anisotropy
	float4 uv2                      : TEXCOORD14;
	float3 normal                   : NORMAL;//Anisotropy normal
	#endif
//#endif
///

	//Hatching
	float3 hatchWeights0            : TEXCOORD15;
	float3 hatchWeights1            : TEXCOORD16;
	float2 uv3                      : TEXCOORD17;
	//
	
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};
Varyings vert_base(Attributes input)
{
    Varyings output = (Varyings)0;
						
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
	
    // struct VertexPositionInputs
    // {
    //     float3 positionWS;
    //     float3 positionVS;
    //     float4 positionCS;
    //     float4 positionNDC;
    // };
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz); //获取顶点。其中包含空间转换一直到裁切空间
    // struct VertexNormalInputs
    // {
    //     real3 tangentWS;
    //     real3 bitangentWS;
    //     float3 normalWS;
    // };
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS); //获取法线输入包含法线缩放信息

    output.uv = TRANSFORM_TEX(input.uv, _BaseMap).xyxy;
	//
	#if _Anisotropy
	output.uv2 = TRANSFORM_TEX(input.uv, _NoiseAnisotropy).xyxy;
	output.normal = TransformObjectToWorldNormal(input.normalOS);//Anisotropy normal
	#endif
	//
#ifdef _UVANIDEFAULT_ON
	output.uv.zw = (output.uv*_UVAniSpeedScale.zw + _Time.y*_UVAniSpeedScale.xy);
	// output.uv.zw = fmod(output.uv.zw, _UVAniSpeedScale.zw);
#endif
	
	output.positionWS = vertexInput.positionWS;
	output.normalWS = normalInput.normalWS;	//如果启用法线贴图或者设置shader质量低返回normalws否则归一化法线
	output.bitangentWS = normalInput.bitangentWS;//各向异性双切线 tbn.bitangentWS = cross(tbn.normalWS, tbn.tangentWS) * sign;
	output.tangentWS2 = normalInput.tangentWS;//float3x3 tangnetTransform

//
#if defined(_IsFace) || defined(_IsCloth)
	output.posNDCw = vertexInput.positionNDC.w;
	output.positionSS = ComputeScreenPos(vertexInput.positionCS);
	output.positionOS = input.positionOS;
#endif
//

#if defined(_NORMALMAP) || defined(_SHADINGMODEL_HAIR) || defined(_USEFNMAP_ON)
	real sign = input.tangentOS.w * GetOddNegativeScale();
	output.tangentWS = half4(normalInput.tangentWS.xyz, sign);
#endif
	half fogFactor = 0;
#ifdef _LINEARFOGENABLE_ON
	float clipZ = UNITY_Z_0_FAR_FROM_CLIPSPACE(vertexInput.positionCS.z);
	fogFactor = saturate( max(clipZ, 0)*_LinearFogParams.x + _LinearFogParams.y );
#endif
    output.fogFactorAndVertexLight = half4(0, 0, 0, fogFactor);
    output.color = input.color;
    output.positionCS = vertexInput.positionCS;

#ifdef _SPECTRUM_ON
	float3 centerWS = float3(UNITY_MATRIX_M[0].w, UNITY_MATRIX_M[1].w, UNITY_MATRIX_M[2].w);
	float3 focusWS = SafeNormalize(_WorldSpaceCameraPos - centerWS)*_SpectrumFocusDistance + centerWS;
	output.focusDir = float4(SafeNormalize(focusWS - vertexInput.positionWS), 0);
#endif
	
#ifdef _MAIN_LIGHT_SHADOWS
	//output.shadowCoord = GetShadowCoord(vertexInput);
	output.shadowCoord = GetShadowCoord(vertexInput);
#else
	//output.shadowCoord = float4(0, 0, 0, 0);
#endif

#if defined(_CELENABLE_ON) && defined(_SHADINGMODEL_FACE)
	output.litDirOS = TransformWorldToObjectDir(_GlobalCharacterLightDir.xyz);
	 //output.litDirOS = TransformWorldToObjectDir(_MainLightPosition.xyz);
	// output.litDirOS = SafeNormalize(_MainLightPosition.xyz);
	
#endif

 #if (_RECEIVELIGHTING_ON) && defined(_CELENABLE_ON)&& defined(_SHADINGMODEL_FACE)
      output.litDirOS = TransformWorldToObjectDir(_MainLightPosition.xyz);
 #endif
 

	//Hatching
		//output.uv3 = output.positionWS * _TileFactor;//positionWS绝对世界坐标//input.uv.xy * _TileFactor;		
			///Rotation
			float2 pivot = float2(0.5,0.5);//定义旋转中心
			//Rotation Matrix
			float cosAngle = cos(0.5);//cos(_Time.w);//取时间当角度
			float sinAngle = sin(0.5);//sin(_Time.w);
			float2x2 rot = float2x2(cosAngle,-sinAngle,sinAngle,cosAngle);//构造2维旋转矩阵
			//Rotation consedering pivot
			float2 uv = (output.positionWS - pivot) * _TileFactor;//先移到中心旋转
			output.uv3 = mul(rot,uv);
			output.uv3 += pivot;//再移回来
			///	
		output.hatchWeights0 = float3(0, 0, 0);
		output.hatchWeights1 = float3(0, 0, 0);
	// 
    return output;
}

half4 frag_base(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

	float2 uv0 = input.uv.xy;
	half4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv0);
	half outAlpha = Alpha(baseTex, _BaseColor, _Cutoff);
	half4 albedo = baseTex*_BaseColor;

	half3 positionWS = input.positionWS;

#if defined(_NORMALMAP) || defined(_USEFNMAP_ON)
	#if defined(_USEFNMAP_ON)
    half3 normalTS = SampleNormal(uv0, TEXTURE2D_ARGS(_FNMap, sampler_FNMap), _BumpScale);
	#else
	half3 normalTS = SampleNormal(uv0, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
	#endif
	float sgn = input.tangentWS.w;      // should be either +1 or -1
	float3 bitangentWS = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
	//half3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangentWS.xyz, input.normalWS.xyz));
	half3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangentWS.xyz, input.normalWS.xyz));
#elif defined(_SHADINGMODEL_HAIR)
	float sgn = input.tangentWS.w;      // should be either +1 or -1
	float3 bitangentWS = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
	half3 normalWS = input.normalWS.xyz;
#else
    half3 normalWS = input.normalWS;

#endif



    normalWS = NormalizeNormalPerPixel(normalWS);
    
	half3 viewDirWS = SafeNormalize(_WorldSpaceCameraPos.xyz - positionWS);
	half3 litDir = SafeNormalize(_GlobalCharacterLightDir.xyz);
    litDir = SafeNormalize(_MainLightPosition.xyz);
    half3 ambient = 0;//SampleSH(normalWS);//skybox color
	half3 lightCol = _MainLightColor.rgb;
   

	///Additional Lights
	half3 litDirAdd = {0, 0, 0};
	#ifdef _AdditionalLights
	uint pixelLightCount = GetAdditionalLightsCount();
	for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++ lightIndex)
	{
		Light light = GetAdditionalLight(lightIndex, positionWS);
		half3 lightColor = light.color * light.distanceAttenuation;
		litDir += SafeNormalize(light.direction);
		lightCol += lightColor;
		litDirAdd = light.direction.xyz;
		//finalColor.xyz += lightColor * saturate(dot(normalWS, light.direction));//LightingLambert(lightColor, light.direction, normalWS);
	}
	#endif
	///
	
	half3 halfDir = SafeNormalize(viewDirWS + litDir);
	half ndl = dot(normalWS, litDir);
	half NdL = saturate(ndl);
	half ndh = dot(normalWS, halfDir);
	half NdH = saturate(ndh);
	half halfLambert = ndl*0.5 + 0.5;               
	half ndv = dot(normalWS, viewDirWS);
	half NdV = abs(ndv);
	half HdL = saturate(dot(halfDir, litDir));
	
	half4 finalColor = albedo;

	///Anisotropy
	half4 Anisotropy = 0;
	#if _Anisotropy
                float3x3 tangnetTransform = float3x3(input.tangentWS2.xyz,
                                                     input.bitangentWS.xyz,
                                                     input.normal);
	
                float3 normalMap = UnpackNormal(SAMPLE_TEXTURE2D(_BumpAnisotropy, sampler_BumpAnisotropy, input.uv));
				//half3 normalTS = SampleNormal(uv0, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
                float3 worldNormal = mul(normalMap, tangnetTransform);
                float3 WorldPosition2 = positionWS;
				/* #ifdef _MAIN_LIGHT_SHADOWS
                Light mainLight2 = GetMainLight(input.shadowCoord);//output.shadowCoord = GetShadowCoord(vertexInput);//#else shadowCoord = float4( 0, 0, 0, 0 ) 
				#endif */           
                //float4 BaseColor = SAMPLE_TEXTURE2D(_BaseAnisotropy, sampler_BaseAnisotropy, /* input. */uv0)*_BaseColor;	
                float4 ShadowColor = SAMPLE_TEXTURE2D(_ShadowTex, sampler_ShadowTex, input.uv);
                float3 light = SafeNormalize(_LightDir.xyz);
                float3 normalWS2 = normalize(worldNormal);
                //float3 normalT =normalize(input.tangentWS);
                float3 normalB =normalize(input.bitangentWS.xyz);
                float3 viewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition2 );
                //float3 halfDir = SafeNormalize(_MainLightPosition + viewDir); 
                float3 halfDir2 = SafeNormalize(light + viewDir);
                float NoH = dot(normalWS2, halfDir2);
                NoH = max(max(NoH,0),0.001);
     //         float3 AnisotropicworldNormal = normalize(lerp(normalWS + normalB, normalB, _Tangent));
     //         float LDotT = dot(AnisotropicworldNormal, _MainLightPosition);
				//float VDotT = dot(AnisotropicworldNormal, viewDir);
                float shift = SAMPLE_TEXTURE2D(_NoiseAnisotropy, sampler_NoiseAnisotropy, input.uv2).b - 0.5;
                //shift *=0.5 ;
                //return float4(normalB +shift* normalWS,1);
                float shiftBg = _ShiftBg;
                float ShiftHigh = shift - _ShiftHigh;
                float ShiftLow = shift - _ShiftLow;
                float3 worldBinormalBg = normalize(normalB + shiftBg * normalWS2);
                float3 worldBinormalLow = normalize(normalB + ShiftLow * normalWS2);
				float3 worldBinormalHigh = normalize(normalB + ShiftHigh * normalWS2);
                //backgroudspe
                float dotTHb = dot(worldBinormalBg,halfDir2);
                float sinTHb = sqrt(1.0 - dotTHb * dotTHb);
                float dirAttenb = smoothstep(-1,0,dotTHb);
                float speBg = dirAttenb * pow(sinTHb,_SpeBgGloss)*_SpeBgInt;
                //lowspe
                float dotTH1 = dot(worldBinormalLow,halfDir2);
                float sinTH1 = sqrt(1.0 - dotTH1 * dotTH1);
                float dirAtten1 = smoothstep(-1,0,dotTH1);
                float speLow = dirAtten1 * pow(sinTH1,_SpeLowGloss)*_SpeLowInt;
                //highspe
                float dotTH2 = dot(worldBinormalHigh,halfDir2);
                float sinTH2 = sqrt(1.0 - dotTH2 * dotTH2);
                float dirAtten2 = smoothstep(-1,0,dotTH2);
                float speHigh = dirAtten2 * pow(sinTH2,exp2(_SpeHighGloss));
                
                //float Anisotropic = dot(AnisotropicworldNormal, halfDir);//low
				//float Anisotropic = sqrt(1 - (LDotT * LDotT)) * sqrt(1 - (VDotT * VDotT)) - LDotT * VDotT;//mid                             
                //float3 specular =  _SpeColor.rgb * pow(max(0, sqrt(1 - (Anisotropic * Anisotropic))), _SpeLowGloss);
                float4 specular = saturate( speLow * _SpeLowColor + speBg * _SpeBgColor);
                //return float4(specular,1);
                //dif
                float NdotL = dot(normalize(light.xyz), normalWS2);
                NdotL = max((NdotL * 0.5 + 0.5),0);
                float ndv2 = dot(normalWS2,viewDir);
                float3 up = mul( UNITY_MATRIX_I_V,  float3(0,1,0) ).xyz;
                float3 viewX = normalize( cross(up,-viewDir));
                float3 viewY = normalize(cross((-viewDir),viewX));
                float3 viewZ = normalize(-viewDir );
                float3x3 viewF = float3x3(viewX,viewY,viewZ);
                float3 matcapUV = mul(viewF, normalWS2) ;              
                float2 ramUV = matcapUV.xy*0.5+0.5;
                float2 rampSample = float2(ndv2,0.25);
               float yugu = smoothstep(0.0,_v,speHigh*ShadowColor.g);
                float2 rampSample2 = float2(yugu,_v);
                float4 RameCol = 0;//SAMPLE_TEXTURE2D(_RampMap,sampler_RampMap,rampSample);
                float4 RameCol2 = 0;//SAMPLE_TEXTURE2D(_RampMap,sampler_RampMap,rampSample2)*ShadowColor.r;
                float speh = smoothstep(0,0.1,yugu) * ShadowColor.r;
                float4 RampCol = lerp(RameCol2,RameCol,RameCol.a);
                float4 specularMat = RameCol;
                //float4 dif = BaseColor * NdotL;             
                finalColor = saturate(finalColor + speh*_SpeHighInt+specular);
				Anisotropy = saturate(finalColor + speh*_SpeHighInt+specular);
				
	#endif

	///

#if defined(_PBRAPPRO_ON)
	//pbr appro begin
	half metallic, perceptualRoughness, roughness, occlusion, pbrRatio;
	#if defined(_PBRMASK_ON)
	SamplePBRMap(uv0, metallic, perceptualRoughness, occlusion, pbrRatio);
	#else
	metallic = _MetallicMapScale;
	perceptualRoughness = _RoughnessMapScale;
	occlusion = _AOMapScale;
	pbrRatio = _PBRRate;
	#endif
	roughness = max(perceptualRoughness*perceptualRoughness, HALF_MIN);
	
	half3 reflectVector = reflect(-viewDirWS, normalWS);
	reflectVector = rotateVectorAboutY(_IBLMapRotate, reflectVector);
	half3 reflectColor = CustomGetIndirectSpec(TEXTURECUBE_ARGS(_IBLMap, sampler_IBLMap), perceptualRoughness, reflectVector);
	
	half3 specColor;half oneMinusReflectivity;
	half3 diffColor = DiffSpecFromMetallic(albedo.xyz, metallic, specColor, oneMinusReflectivity);
	
	half3 envBRDF = EnvBRDFApprox(specColor, perceptualRoughness, saturate(ndv));
	half3 cubeMapColor = reflectColor.xyz*envBRDF*_IBLMapColor.xyz*_IBLMapIntensity*6;
	
	float ggxTerm = GGXTermAppro(NdH, roughness);
	half3 pbrDirectColor = (ggxTerm*envBRDF*_PBRSpecularIntensity + cubeMapColor)*_PBRDirectLightColor*saturate(ndl);
	half3 pbrIndirectColor = diffColor*_PBRIndirectLightColor*_PBRIndirectLightIntensity + cubeMapColor;
	pbrIndirectColor *= occlusion;
	//pbrIndirectColor=saturate(pbrIndirectColor);//之前没有对颜色saturate 所以得到的最好数值是不对的需要 saturate一下不然会导致最后结果错误
	finalColor.xyz = lerp(albedo.xyz, pbrDirectColor + pbrIndirectColor, pbrRatio) + Anisotropy.xyz;//finalColor = Anisotropy;
	///PBR Light
	#if _PBRLight
	//litDir = SafeNormalize(_MainLightPosition.xyz);
    //half3 ambient = SampleSH(normalWS);
	//half3 lightCol = _MainLightColor.rgb;
	finalColor.xyz = (finalColor.xyz/* +ambient */)*lightCol;//pbr
	#endif
	///
	/* #if _RECEIVELIGHTING_ON //Use the above method
	//return 1 ;
	finalColor.xyz = (finalColor.xyz+ambient)*lightCol;
    #endif */

#elif defined(_PBRURP_ON)//pbr urp begin
	half metallic, perceptualRoughness, roughness, roughness2, occlusion, pbrRatio;
	#if defined(_PBRMASK_ON)
	SamplePBRMap(uv0, metallic, perceptualRoughness, occlusion, pbrRatio);
	#else
	metallic = _MetallicMapScale;
	perceptualRoughness = _RoughnessMapScale;
	occlusion = _AOMapScale;
	pbrRatio = _PBRRate;
	#endif
	
	roughness = max(perceptualRoughness*perceptualRoughness, HALF_MIN);
	roughness2 = roughness*roughness;

	half3 bakedGI = half3(0,0,0);
	
	half3 specColor;half oneMinusReflectivity;
	half3 diffColor = DiffSpecFromMetallic(albedo.xyz, metallic, specColor, oneMinusReflectivity);

#ifdef _ALPHAPREMULTIPLY_ON
	diffColor *= outAlpha;
	outAlpha = outAlpha * oneMinusReflectivity + 1 - oneMinusReflectivity;
#endif
	
	half3 reflectVector = reflect(-viewDirWS, normalWS);
	reflectVector = rotateVectorAboutY(_IBLMapRotate, reflectVector);
	half fresnelTerm = Pow4(1.0 - saturate(dot(normalWS, viewDirWS)));
	half3 indirectDiff = bakedGI * occlusion;
	half3 indirectSpec = GetIndirectSpec(TEXTURECUBE_ARGS(_IBLMap, sampler_IBLMap), _IBLMap_HDR, reflectVector, perceptualRoughness, occlusion);
	indirectSpec *= _IBLMapColor.xyz*_IBLMapIntensity;
	half grazingTerm = saturate(1 - perceptualRoughness + 1 - oneMinusReflectivity);
	half3 indirectColor = IndirectBRDF(diffColor, specColor, indirectDiff, indirectSpec, roughness2, grazingTerm, fresnelTerm);

	Light mainLight;
	mainLight.direction = litDir;
	mainLight.color = _PBRDirectLightColor.xyz;
	mainLight.distanceAttenuation = 0;
	mainLight.shadowAttenuation = 1;
	half3 directColor = DirectBRDF(mainLight, normalWS, viewDirWS, roughness, roughness2, diffColor, specColor);

	finalColor.xyz = lerp(albedo.xyz, directColor + indirectColor, pbrRatio);

#endif
	
#if defined(_SKINRAMP_ON)
	half3 skinTex = SAMPLE_TEXTURE2D(_SkinMap, sampler_SkinMap, half2(halfLambert, 0.5)).xyz;
	half3 skinColor = finalColor.xyz*skinTex*_SkinColor*_SkinIntensity;
	finalColor.xyz = lerp(finalColor.xyz, skinColor, _SkinRate);
#elif defined(_SKINSSS_ON)
	half3 skinColor = GetSSSColor(halfLambert, _SkinIntensity, TEXTURE2D_ARGS(_SkinMap, sampler_SkinMap), normalWS, positionWS);
	skinColor *= _SkinColor;
	finalColor.xyz = lerp(finalColor.xyz, skinColor, _SkinRate);
#endif

/*#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
	inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
	inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
	inputData.shadowCoord = float4(0, 0, 0, 0);
#endif*/
	half shadowAtten = 1;
#ifdef _MAIN_LIGHT_SHADOWS
	shadowAtten = GetMainLight(input.shadowCoord).shadowAttenuation;
	
#endif

	half4 maskTex = half4(0,0,0,1);
	half faceMaskTex = 0.5;
#if defined(_CELENABLE_ON) && defined(_SHADINGMODEL_FACE)

	half3 front = half3(0,1,0);
	half3 right = half3(0,0,-1);
	/* half3 front = half3(1,0,0);
	half3 right = half3(0,0,1); */
	half3 left = -right;
	half3 litDirOS = SafeNormalize(input.litDirOS);
	half fdl = dot(front, litDirOS);
	half ldl = dot(left, litDirOS);
	half rdl = dot(right, litDirOS);
	half2 faceMaskUv;
	half faceLightAtten;
	if (dot(litDirOS,left) > 0)
	{
		faceMaskUv = uv0;
		faceLightAtten = ldl;
	}
	else
	{
		faceMaskUv = half2(1 - uv0.x, uv0.y);
		faceLightAtten = rdl;
	}
	faceMaskTex = SAMPLE_TEXTURE2D(_FaceMask, sampler_FaceMask, faceMaskUv).r;
	maskTex = SAMPLE_TEXTURE2D(_CelMask, sampler_CelMask, faceMaskUv);

	half3 noShadowColor = finalColor.xyz*_NoShadowColor*_GlobalCharacterNoShadowColor;
	half3 firstShadowColor = finalColor.xyz*_FirstShadowColor*_GlobalCharacterFirstShadowColor;

	float faceShadowCorr = (fdl > 0) * min((faceMaskTex.x + _FirstShadow + maskTex.g - 1 > faceLightAtten), 1);

	finalColor.xyz = lerp(firstShadowColor, noShadowColor, faceShadowCorr) * _GlobalCharacterShadowIntensity;
#else
	maskTex = SAMPLE_TEXTURE2D(_CelMask, sampler_CelMask, uv0);
#endif


//定义接受直光脸部阴影算法
#if (_RECEIVELIGHTING_ON) && defined(_CELENABLE_ON) && defined(_SHADINGMODEL_FACE)

   float4 ShadowCoords = float4( 0, 0, 0, 0 );
   ShadowCoords = TransformWorldToShadowCoord( positionWS );
   Light mainLight = GetMainLight(ShadowCoords);
   // 计算光照旋转偏移
	float sinx = sin(0.0);
	float cosx = cos(0.0);
	float2x2 rotationOffset = float2x2(cosx, -sinx, sinx, cosx);
                    
	 front = unity_ObjectToWorld._12_22_32;
	float3 Right = unity_ObjectToWorld._13_23_33;
	float2 lightDir = mul(rotationOffset, mainLight.direction.xz + litDirAdd.xz);
	half3 litDirAddSafe = SafeNormalize(litDirAdd);//light add

	//计算xz平面下的光照角度
	#if _FaceReverse
	float FrontL = dot(normalize(Right.xz), normalize(lightDir.xy /* + litDirAddSafe.xy */));
	float RightL = dot(normalize(front.xz), normalize(lightDir.xy /* + litDirAddSafe.xy */));
	#else 
	float FrontL = dot(normalize(front.xz), normalize(lightDir.xy /* + litDirAddSafe.xy */));
	float RightL = dot(normalize(Right.xz), normalize(lightDir.xy /* + litDirAddSafe.xy */));
	#endif
	RightL = - (acos(RightL) / PI - 0.5) * 2 ;
	
	
	//左右各采样一次FaceLightMap的阴影数据存于lightData
	#if _FaceReverse
	float2 lightData = float2(SAMPLE_TEXTURE2D(_FaceMask, sampler_FaceMask, float2(-uv0.x, uv0.y)).r,
	SAMPLE_TEXTURE2D(_FaceMask, sampler_FaceMask, float2(uv0.x, uv0.y)).r);
	#else
	float2 lightData = float2(SAMPLE_TEXTURE2D(_FaceMask, sampler_FaceMask, float2(uv0.x, uv0.y)).r,
	SAMPLE_TEXTURE2D(_FaceMask, sampler_FaceMask, float2(-uv0.x, uv0.y)).r);
	#endif
	//return lightData.y;
	//修改lightData的变化曲线，使中间大部分变化速度趋于平缓。
	lightData = pow(abs(lightData), 0.14);
	//return floor((halfLambert + lightData.x)*0.5+ 1 - _FirstShadow);
	//return floor((halfLambert + lightData.x)*0.5+0.5 - _FirstShadow);
	//return   min(step(RightL, lightData.x), step(-RightL, lightData.y));
	//根据光照角度判断是否处于背光，使用正向还是反向的lightData。
	//RightL = step(-0.0, RightL+0.5);
	// faceShadowCorr = step(-0.0, FrontL+0.5) * min(step(RightL, lightData.x + _FirstShadow ), step(-RightL, lightData.y+ _FirstShadow));
	 
	 //half fresnelTerm = Pow4(1.0 - saturate(dot(normalWS, viewDirWS)));
	 //fresnelTerm = step(0.2,fresnelTerm)*NdL;
	 half Rend = RightL;//预存最后的右边 做最后的if
	 half Lend = -RightL;//预存最后的左边 做最后的if
	 half ifleft = -RightL;//预存 左边为了做最后结果保留一丝光明
	 half iffront = step(-0.0, FrontL);//根据前面 来计算 左边和右边的最大值
	 if (iffront <= 0)
	{
		RightL=0.96;
		ifleft=0.96;
	}
	  if (RightL >= 0.96)
	{
		RightL=0.96;
	}
	  if (ifleft >= 0.96)
	{
		ifleft=0.96;
	}
	 
	  if (Rend > 0.0) //当光在右边时
	{
		
		// #if _UseFaceShadowSmoothness
		// faceShadowCorr = smoothstep(0, RightL, pow(lightData.x + _FirstShadow, _FaceShadowSmoothness));//Face Shadow Smoothness = _FaceShadowSmoothness
		// #else
		faceShadowCorr = step(RightL, lightData.x + _FirstShadow );
		// #endif
	}
	  if (Lend > 0.0) //当光在左边时
	{
		// #if _UseFaceShadowSmoothness
		// faceShadowCorr = smoothstep(0, ifleft, pow(lightData.y + _FirstShadow, _FaceShadowSmoothness));//Face Shadow Smoothness = _FaceShadowSmoothness
		// #else
		faceShadowCorr = step(ifleft, lightData.y + _FirstShadow);
		// #endif
	}
	//return faceShadowCorr;
	// return  min(step(RightL, lightData.x + _FirstShadow ), step(ifleft, lightData.y+ _FirstShadow));
	 
     //return step(RightL.x, lightData.x + _FirstShadow );               
   // faceMaskTex = SAMPLE_TEXTURE2D(_FaceMask, sampler_FaceMask, uv0).r;
    


	///Nose highlights
	/* #if _Nosehighlights
 	float3 lightDirH = normalize(float3(mainLight.direction.x, 0, mainLight.direction.z));
	float filpU = saturate(sign(dot(lightDirH, right)));//right/left 控制方向 
	float cutU = step(0.5, input.uv.x);
	float uvMask = lerp(cutU, 1 - cutU, filpU);

	
	float lightAtten = abs(RightL * 0.5 + 0.5 - 0.5) * 2;
	

	float3 noseSDF = SAMPLE_TEXTURE2D(_NoseSDF, sampler_NoseSDF, uv0).xyz;
	float noseSpecular = step(lightAtten, uvMask * noseSDF.r);

	faceShadowCorr +=  noseSpecular;
	#endif */
	///
	

   //is Face
	
	//face shadow
	#if _IsFace
		//"heightCorrect" is a easy mask which used to deal with some extreme view angles,
		//you can delete it if you think it's unnecessary.
		//you also can use it to adjust the shadow length, if you want.
		float heightCorrect = smoothstep(_HeightCorrectMax, _HeightCorrectMin, input.positionWS.y);
		
		//In DirectX, z/w from [0, 1], and use reversed Z
		//So, it means we aren't adapt the sample for OpenGL platform
		float depth = (input.positionCS.z / input.positionCS.w);//depth = z // LinearEyeDepth = 1.0 / (_ZBufferParams.z * z + _ZBufferParams.w);

		//get linearEyeDepth which we can using easily
		float linearEyeDepth = LinearEyeDepth(depth, _ZBufferParams);
		float2 scrPos = input.positionSS.xy / input.positionSS.w;
		
		//"min(1, 5/linearEyeDepth)" is a curve to adjust viewLightDir.length by distance
		float3 viewLightDir = normalize(TransformWorldToViewDir(mainLight.direction + litDirAdd)) * /* (1 / input.posNDCw); */(1 / min(input.posNDCw, 1)) * min(1, 5 / linearEyeDepth);
		
		//get the final sample point
		float2 samplingPoint = scrPos + _HairShadowDistace * viewLightDir.xy;
		
		float hairDepth = SAMPLE_TEXTURE2D(_HairSoildColor, sampler_HairSoildColor, samplingPoint).g;
		hairDepth = LinearEyeDepth(hairDepth, _ZBufferParams);
		
		//0.01 is bias
		float depthContrast = linearEyeDepth  > hairDepth * heightCorrect - 0.01 ? 0: 1;
		
		//deprecated
		//float hairShadow = 1 - SAMPLE_TEXTURE2D(_HairSoildColor, sampler_HairSoildColor, samplingPoint).r;
		
		//0 is shadow part, 1 is bright part
		faceShadowCorr *= depthContrast;
	#else
		
		//ramp *= shadow;
		
	#endif


	//
	finalColor.xyz = lerp(firstShadowColor, noShadowColor, faceShadowCorr*shadowAtten) * _GlobalCharacterShadowIntensity;
	
	#if _RECEIVELIGHTING_ON
	finalColor.xyz = saturate((finalColor.xyz+ambient)*lightCol);//face
    #endif
#else
	maskTex = SAMPLE_TEXTURE2D(_CelMask, sampler_CelMask, uv0);
#endif

#if defined(_CELENABLE_ON) && !defined(_SHADINGMODEL_FACE)
	//normal - shadow
	normalWS = input.normalWS.xyz;
	ndl = dot(normalWS, litDir);
	NdL = saturate(ndl);
	halfLambert = ndl*0.5 + 0.5;
	//

	half3 shadowColorTex = SAMPLE_TEXTURE2D(_ShadowColorMask, sampler_ShadowColorMask, uv0).xyz + finalColor.xyz - albedo.xyz;
	half3 noShadowColor = finalColor.xyz*_NoShadowColor*_GlobalCharacterNoShadowColor;
	half3 firstShadowColor = _FirstShadowColor*_GlobalCharacterFirstShadowColor*shadowColorTex;
	//Edge Light
	//
	//half3 EdgeShadowColor = _EdgeShadowColor*shadowColorTex;
	//
	half3 secondShadowColor = _SecondShadowColor*_GlobalCharacterSecondShadowColor*shadowColorTex;

	half shadowMask = maskTex.y + faceMaskTex*2 - 1;
	
	half2 shadowCorrXY = shadowMask*half2(1.2,1.25) + half2(-0.1, -0.120);
	half shadowCorr = shadowMask > 0.5 ? shadowCorrXY.x : shadowCorrXY.y;
	//return floor((halfLambert + shadowCorr)*0.5+ 1 - _FirstShadow);
	//is Cloth
	
	//cloth shadow
	#if _IsCloth
		//"heightCorrect" is a easy mask which used to deal with some extreme view angles,
		//you can delete it if you think it's unnecessary.
		//you also can use it to adjust the shadow length, if you want.
		float heightCorrect = smoothstep(_HeightCorrectMax, _HeightCorrectMin, input.positionWS.y);
		
		//In DirectX, z/w from [0, 1], and use reversed Z
		//So, it means we aren't adapt the sample for OpenGL platform
		float depth = (input.positionCS.z / input.positionCS.w);
		
		//get linearEyeDepth which we can using easily
		float linearEyeDepth = LinearEyeDepth(depth, _ZBufferParams);
		float2 scrPos = input.positionSS.xy / input.positionSS.w;
		
		//"min(1, 5/linearEyeDepth)" is a curve to adjust viewLightDir.length by distance
		float3 viewLightDir = normalize(TransformWorldToViewDir(_MainLightPosition.xyz)) * (1 / min(input.posNDCw, 1)) * min(1, 5 / linearEyeDepth) /** heightCorrect*/;
		
		//get the final sample point
		float2 samplingPoint = scrPos + _HairShadowDistace * viewLightDir.xy;
		
		float hairDepth = SAMPLE_TEXTURE2D(_HairSoildColor, sampler_HairSoildColor, samplingPoint).g;
		hairDepth = LinearEyeDepth(hairDepth, _ZBufferParams);
		
		//0.01 is bias
		float depthContrast = linearEyeDepth  > hairDepth * heightCorrect - 0.01 ? 0: 1;
		
		//deprecated
		//float hairShadow = 1 - SAMPLE_TEXTURE2D(_HairSoildColor, sampler_HairSoildColor, samplingPoint).r;
		
		//0 is shadow part, 1 is bright part
		shadowCorr *= depthContrast;		
	#endif
	//
	// half firstShadowCorr = ( (halfLambert + shadowCorr)*0.5 > _FirstShadow ) ? 0:_GlobalCharacterShadowIntensity;
	//half firstShadowCorr = ( 1 - floor((halfLambert + shadowCorr)*0.5 + 1 - _FirstShadow)*shadowAtten )*_GlobalCharacterShadowIntensity;//shadow shadowAtten = _RECEIVE_SHADOWS_ON
	half firstShadowCorr = ( 1 - floor((halfLambert + shadowCorr)*shadowAtten*0.5 + 1 - _FirstShadow) )*_GlobalCharacterShadowIntensity;//cel shadow shadowAtten = _RECEIVE_SHADOWS_ON
	
	half3 firstShadowTest = (firstShadowColor - noShadowColor)*firstShadowCorr + noShadowColor;
	
	half secondShadowCorr = ( (halfLambert + shadowMask)*0.5 > _SecondShadow ) ? 0:_GlobalCharacterShadowIntensity;
	half3 secondShadowTest = (secondShadowColor - firstShadowColor)*secondShadowCorr + firstShadowColor;
	//return float4(secondShadowCorr,secondShadowCorr,secondShadowCorr,1);
	// smoothstep()
	half finalShadowCorr = shadowMask > 0.1 ? 0:_GlobalCharacterShadowIntensity;
	half3 finalShadowTest = (secondShadowTest - firstShadowTest)*finalShadowCorr + firstShadowTest;

#if defined(_SHADINGMODEL_HAIR)
	half anisoNoiseTex = SAMPLE_TEXTURE2D(_AnisoNoiseMask, sampler_AnisoNoiseMask, uv0).x-0.5;
	half tdh = dot(input.tangentWS, halfDir);
	float anisoScale = 1;

	float3 noiseOffset1 = normalWS*(anisoNoiseTex*_AnisoSpecularNoise1 + _AnisoSpecularOffset1);
	float3 bitangent1 = SafeNormalize(bitangentWS + noiseOffset1);
	float bdh1 = dot(halfDir, bitangent1)/_AnisoSpecularGloss1;
	float3 anisoSpecTerm1 = exp(-(tdh*tdh + bdh1*bdh1)/(1.0 + ndh));
	float3 anisoSpecColor1 = anisoSpecTerm1*anisoScale*_AnisoSpecularColor1*finalColor.xyz;

	float3 noiseOffset2 = normalWS*(anisoNoiseTex*_AnisoSpecularNoise2 + _AnisoSpecularOffset2);
	float3 bitangent2 = SafeNormalize(bitangentWS + noiseOffset2);
	float bdh2 = dot(halfDir, bitangent2)/_AnisoSpecularGloss2;
	float3 anisoSpecTerm2 = exp(-(tdh*tdh + bdh2*bdh2)/(1.0 + ndh));
	float3 anisoSpecColor2 = anisoSpecTerm2*anisoScale*_AnisoSpecularColor2*finalColor.xyz;

	// See GDC 2004
	/*
	float3 noiseOffset1 = normalWS*(anisoNoiseTex*_AnisoSpecularNoise1 + _AnisoSpecularOffset1);
	float3 tangent1 = SafeNormalize(bitangentWS + noiseOffset1);
	half tdh1 = dot(tangent1, halfDir);
	float sinTH1 = sqrt(1.0 - tdh1*tdh1);
	float atten1 = pow(sinTH1, _AnisoSpecularGloss1)*smoothstep(-1.0,0.0,tdh1);
	float3 anisoSpecColor1 = _AnisoSpecularColor1*atten1*finalColor.xyz;

	float3 noiseOffset2 = normalWS*(anisoNoiseTex*_AnisoSpecularNoise2 + _AnisoSpecularOffset2);
	float3 tangent2 = SafeNormalize(bitangentWS + noiseOffset2);
	half tdh2 = dot(tangent2, halfDir);
	float sinTH2 = sqrt(1.0 - tdh2*tdh2);
	float atten2 = pow(sinTH2, _AnisoSpecularGloss2)*smoothstep(-1.0,0.0,tdh2);
	float3 anisoSpecColor2 = _AnisoSpecularColor2*atten2*finalColor.xyz;
	*/
	
	half3 celSpecColor = anisoSpecColor1 + anisoSpecColor2;
#else
	half celSpec = step( 1, maskTex.r + pow(max(NdH, 0.0001), _SpecularGloss) );//hair highlight
	half3 celSpecColor = celSpec*maskTex.z*_SpecularIntensity*finalColor.xyz*_SpecularColor;
#endif
	finalColor.xyz = celSpecColor*_GlobalCharacterSpecularColor.xyz + finalShadowTest;
	#if _RECEIVELIGHTING_ON
	//return 1 ;
	finalColor.xyz = (finalColor.xyz+ambient)*lightCol;//unface
    #endif
#endif

#ifdef _RIMENABLEA_ON
	half rimDir = saturate(dot(normalWS, /* _MainLightPosition.xyz */_GlobalCharacterRimLightDir));
	half rimDist = dot(_WorldSpaceCameraPos.xyz - positionWS, _WorldSpaceCameraPos.xyz - positionWS);
	half rimDistAtten = (1 - smoothstep(_RimDistanceMin, _RimDistanceMax, rimDist)*_DistanceRimEnable)*rimDir;
	half rimAtten = smoothstep(_RimSpreadMin, _RimSpreadMax, 1 - saturate(ndv))*_RimIntensity;
	half3 rimColor = step(0, ndv + _RimThreshold)*rimAtten*_RimLightColor*_GlobalCharacterRimLightColor*input.color.w;
	rimColor = (rimColor*rimDistAtten + finalColor.xyz);
	finalColor.xyz = rimColor.xyz;	
#endif
	
	finalColor.xyz = finalColor.xyz * _GlobalCharacterLightColor.xyz * (input.fogFactorAndVertexLight.xyz + _GlobalCharacterAdditive + 1);
	//#if _RECEIVELIGHTING_ON
	////return finalColor ;
	//finalColor.xyz = saturate((finalColor.xyz+ambient)*lightCol);
 //   #endif

#ifdef _RIMENABLEB_ON
	//Edge Light C
	half f =  1.0 - saturate(dot(viewDirWS, normalWS));
	half rim = smoothstep(_RimMin, _RimMax, f);
	rim = smoothstep(0, _RimSmooth * SAMPLE_TEXTURE2D (_RimMask, sampler_RimMask, uv0).rgb, rim);
	half3 rimColor = rim * _RimColor.rgb * _RimColor.a + finalColor.xyz;
	finalColor.xyz = rimColor.xyz;
	//
#endif

///EnableRim
	//Edge Light D
	//RadianceToon
	//half3 lightDirectionWS = SafeNormalize(_MainLightPosition.xyz - positionWS);
	//half3 lightDirectionWS = halfDir = SafeNormalize(SafeNormalize(_MainLightPosition.xyz) + SafeNormalize(_WorldSpaceCameraPos.xyz - positionWS));
	half2 radiance;
	//half3 lightAttenuation = unity_LightData.z * shadowAtten;
	half H_Lambert = 0.5*dot(normalWS, halfDir)+0.5;
	radiance.x = saturate((H_Lambert-_Shadow1Step+_Shadow1Feather)/_Shadow1Feather)/* *lightAttenuation */;//half DiffuseRadianceToon(half value,half step,half feather){return saturate((H_Lambert-_Shadow1Step+_Shadow1Feather)/_Shadow1Feather);}
	radiance.y = saturate((H_Lambert-_Shadow2Step+_Shadow2Feather)/_Shadow2Feather);
	//
		half3 shadow1 = baseTex.rgb *_Shadow1Color.rgb;
        half3 shadow2 = baseTex.rgb *_Shadow2Color.rgb;
		finalColor.x = lerp(lerp(shadow2,shadow1,radiance.y),finalColor.xyz,radiance.x).x;
	//
#ifdef _ENABLERIM_ON
	//RimLight
    half fresnel = pow((1.0 - saturate(dot(normalWS, viewDirWS))),_RimPow);
    fresnel *= radiance.x;
    half3 rimColor = lerp(finalColor.xyz,_RimColor2.rgb * lightCol.rgb, fresnel);
    fresnel = saturate((fresnel/1 -_RimStep)/_RimFeather)*1;//*1为亮度倍率//inline half StepFeatherToon(half Term,half maxTerm,half step,half feather){ return saturate((Term/maxTerm-step)/feather)*maxTerm;}
    finalColor.xyz += fresnel*rimColor/* *lightCol */;//color += RimLight(brdfData,normalWS,viewDirectionWS,radiance.x);
#endif
///

///Granblue Fantasy Plan
//相机空间法线外扩描边
//float3 posVS = UnityObjectToViewPos(v.vertex).xyz;      //将顶点位置转换到相机空间
//float3 ndirWS = UnityObjectToWorldNormal(v.normal);     //将法线从模型空间转到世界空间
//float3 ndirVS = mul((float3x3)UNITY_MATRIX_V, ndirWS);  //将法线从世界空间转到相机空间
//ndirVS.z = _OutLineBias * (1.0 - v.color.b);            //利用顶点色的B通道陷入深度
//posVS += ndirVS * _OutLineWidth * 0.001 * v.color.a;    //法线外扩的控制,用顶点色A通道控制描边的宽度
//o.pos = mul(UNITY_MATRIX_P, float4(posVS, 1.0));        //将顶点位置从相机空间转到裁剪空间

//边缘光
//float3 rimlight_dir = normalize(mul(UNITY_MATRIX_V, _RimLightDir.xyz));//转换到相机空间
//half rim_lambert = (dot(Ndir, rimlight_dir) + 1.0) * 0.5;//从-1.0-1.0映射到0.0-1.0                 
//half rimlight_term = half_lambert * ao + shadow_control;//边缘光因子
//half toon_rim = saturate((rim_lambert - _ShadowThreshold) * 20);
//half3 rim_color = (_RimLightColor + base_col) * 0.5 * sss_mask;//sss_mask区分边缘光区域的强度
//half3 final_rim = toon_rim * rim_color * base_mask * toon_diffuse;//base_mask区分皮肤与非皮肤区域，看自己喜欢选择乘不乘
///

///Anisotropy//bitangentWS erro Can't solve
//#ifdef//收放用，无实际意义
	//DirectSpecularHairToon
	/* half perceptualRoughness2 = 1.0 - _Smoothness;//half perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(smoothness);
	half roughness2 = max(perceptualRoughness2 * perceptualRoughness2, HALF_MIN_SQRT);//half roughness = max(PerceptualRoughnessToRoughness(perceptualRoughness), HALF_MIN_SQRT);
	half specularExponent = clamp(2 * rcp(roughness2 * roughness2) - 2, FLT_EPS, rcp(FLT_EPS));////Use for HairSpecular,Roughness To BlinnPhong//half specularExponent = RoughnessToBlinnPhongSpecularExponent(roughness2);

		//SampleSpecularShift
		half specularShift1 = SAMPLE_TEXTURE2D(_SpecularShiftMap,sampler_SpecularShiftMap,uv0*_SpecularShiftMap_ST.xy+_SpecularShiftMap_ST.zw).r*_SpecularShiftIntensity+_SpecularShift1;
		half specularShift2 = SAMPLE_TEXTURE2D(_SpecularShiftMap,sampler_SpecularShiftMap,uv0*_SpecularShiftMap_ST.xy+_SpecularShiftMap_ST.zw).r*_SpecularShiftIntensity+_SpecularShift2; */
	
	/* float3 shiftedT1 = bitangentWS + (specularShift1 * normalWS);
	float3 shiftedT2 = bitangentWS + (specularShift2 * normalWS);
    half3 t1 = normalize(shiftedT1);
    half3 t2 = normalize(shiftedT2); */
	/* float3 ShiftTangent(float3 T, float3 N, float shift)
	{
		float3 shiftedT = T + (shift * N);
		return normalize(shiftedT);
	} */
    /* half LdotV = dot(lightDirectionWS,viewDirWS);
    float invLenLV = rsqrt(max(2.0 * LdotV + 2.0,FLT_EPS));
    half3 H = (lightDirectionWS+viewDirWS) * invLenLV;
    half spec1 = D_KajiyaKay(t1,H,specularExponent);
    half spec2 = D_KajiyaKay(t2,H,specularExponent);
    half maxSpec = (specularExponent + 2) * rcp(2 * PI);
    half s1 = StepFeatherToon(spec1,maxSpec,_SpecularStep,_SpecularFeather);
    half s2 = StepFeatherToon(spec2,maxSpec,_SpecularStep,_SpecularFeather)*_Specular2Mul;

	inline half StepFeatherToon(half Term,half maxTerm,half step,half feather)
	{
		return saturate((Term/maxTerm-step)/feather)*maxTerm;
	}

    half DirectSpecularHair = s1+s2;
	//

    half specularTerm = DirectSpecularHair;
	//#if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
		specularTerm = specularTerm - HALF_MIN;
		specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
	//#endif
		half3 specularColor = specularTerm * _SpecColor.rgb * radiance;
		finalColor.xyz += specularColor; */
//#endif
///

#ifdef _UVANIDEFAULT_ON
	half4 uvAniColor = SAMPLE_TEXTURE2D(_UVAniMap, sampler_UVAniMap, input.uv.zw);
	uvAniColor.xyz *= uvAniColor.w;
	finalColor.xyz += uvAniColor.xyz * _UVAniIntensity;
#endif
	
#ifdef _SIMPLERIMENABLE_ON
	half3 effectRimColor = pow(max(1-abs(ndv),0.001), _SimpleRimSpread)*_SimpleRimColor;
	effectRimColor = effectRimColor*_SimpleRimIntensity;
	finalColor.xyz += effectRimColor;
#endif
	
#ifdef _IRIDESCENCE_ON
	half fresnelTerm = saturate(ndv);
	
	fresnelTerm = pow(abs(1-fresnelTerm), _IridescenceSpread);
	
	fresnelTerm = fresnelTerm*(1-_IridescenceF0) + _IridescenceF0;//InputBaseReflectionFraction
	
	half fresnelResult = fresnelTerm*lerp(1, _IridescenceRoughness, _IridescenceRoughnessScale);//FresnelTerm * lerp(1, (1 - TexRoughness), InputRoughness)
	//return half4(fresnelResult,fresnelResult,fresnelResult,1);
	half4 iriColor = SAMPLE_TEXTURE2D(_IridescenceMap, sampler_IridescenceMap, float2(fresnelResult*_IridescenceUVScale + _IridescenceUVOffset, 0));
	iriColor.xyz = (1-fresnelResult)*finalColor.xyz + fresnelResult*iriColor.xyz;
	iriColor.xyz = lerp( finalColor.xyz, iriColor.xyz, _IridescenceIntensity );
	finalColor.xyz = iriColor.xyz;
#endif
	
#ifdef _SPECTRUM_ON
	half ndf = dot(normalWS, input.focusDir);
	half angle = acosFast4(ndf);
	angle = angle*_SpectrumSpreadScale + _SpectrumSpreadOffset;
	half spectrumAtten = pow(1-abs(ndf), _SpectrumFresnel.x)*_SpectrumFresnel.y + _SpectrumFresnel.z;
	half3 spectrumColor = SAMPLE_TEXTURE2D(_SpectrumMap, sampler_SpectrumMap, float2(angle,angle)).xyz;
	spectrumColor *= outAlpha*spectrumAtten*_SpectrumIntensity;
	spectrumColor = lerp(albedo, 1, spectrumColor);
	finalColor.xyz = spectrumColor;
	outAlpha = max(_SpectrumAlpha.x, min(_SpectrumAlpha.y, _SpectrumAlpha.z*spectrumAtten));
#endif

// && !defined(_ALPHAPREMULTIPLY_ON)
#if !defined(_ALPHABLEND_ON)
#if defined(_ALPHATEST_ON)
	// outAlpha = max(0, _BloomFactor);
	outAlpha = max(0, baseTex.w*_BloomFactor + lerp(_BloomFactor, _EmissionBloomFactor, maskTex.w));
#else
	outAlpha = max(0, baseTex.w*_BloomFactor + lerp(_BloomFactor, _EmissionBloomFactor, maskTex.w));
#endif
#endif
	finalColor.w = outAlpha;
	
	half3 emissionColor = maskTex.w*albedo.xyz*_EmissionIntensity*_EmissionColor;

//BenCun Line
#ifdef _BENCUNLINE_ON
	half4 BCMask = SAMPLE_TEXTURE2D(_BenCunMask, sampler_BenCunMask, uv0);
	half3 bencunColor = BCMask.w * _BenCunColor.rgb;
	finalColor.xyz = lerp(finalColor.xyz*_EmissionScale + emissionColor, _BenCunPower, bencunColor) ;
	#else
	finalColor.xyz = finalColor.xyz*_EmissionScale + emissionColor;
#endif
//
	
#ifdef _DISSOLVE_ON
    float3 WorldPosition = (positionWS);
    half4 Dissolution = SAMPLE_TEXTURE2D(_DissolveTex,sampler_DissolveTex,input.uv.xy);
    half4 Ramtex = SAMPLE_TEXTURE2D(_RampTex,sampler_RampTex,input.uv.xy);
    float edgeCutout = GetCutout(Dissolution,WorldPosition,_Dissolve,_DistanceEffect,_MaxBorderY,_MinBorderY);
	clip (edgeCutout + _AshWidth-0.001);
               
    float degree = saturate(edgeCutout / _EdgeWidth);;
                
    float4 edgeColor = SAMPLE_TEXTURE2D(_RampTex,sampler_RampTex,float2(degree, degree))*1.6;
               
	finalColor.xyz = lerp(edgeColor.xyz, finalColor.xyz, degree);
#endif

#ifdef _TONEMAPPINGENABLE_ON
	//finalColor.xyz = ACESToneMapping(finalColor.xyz, _ToneMappingFactor);
	finalColor.xyz = LinearToSRGB(finalColor.xyz);
	finalColor.xyz = pow(1 - exp2(-finalColor.xyz*_Exposure), _Contrast + 0.01);
	finalColor.xyz = SRGBToLinear(finalColor.xyz);
	finalColor.xyz = saturate(finalColor.xyz);

	half3 lutColor = LinearToSRGB(finalColor.xyz);
	lutColor = ApplyLut2D(TEXTURE2D_ARGS(_UserLut, sampler_UserLut), lutColor.xyz, _UserLutParams.xyz);
	lutColor = SRGBToLinear(lutColor);
	finalColor.xyz = lerp(finalColor.xyz, lutColor, _UserLutParams.w);
#endif
	
	finalColor.xyz *= _GlobalCharacterAmbientColor * _GlobalModColor;
	finalColor.xyz *= lerp(1, _BloomModColor*_BloomModIntensity, _BloomModRate);
	
#ifdef _LINEARFOGENABLE_ON
	half fogFactor = input.fogFactorAndVertexLight.w;
#if defined(_ALPHABLEND_ON)// || defined(_ALPHAPREMULTIPLY_ON)
	finalColor.xyz = lerp( _LinearFogColor.xyz, finalColor.xyz, fogFactor);
#else
	finalColor = lerp( _LinearFogColor, finalColor, fogFactor);
#endif
#endif
	//UNITY_APPLY_FOG(input.fogCoord, effectRimColor);
	//baseTex.w = Alpha(baseTex.w, _BaseColor, _Cutoff);
	///Additional Lights
	/* #ifdef _AdditionalLights
		uint pixelLightCount = GetAdditionalLightsCount();
		for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++ lightIndex)
		{
			// 获取其他光源
			Light light = GetAdditionalLight(lightIndex, positionWS);
			half3 lightColor = light.color * light.distanceAttenuation;
			finalColor.xyz += LightingLambert(lightColor, light.direction, normalWS);
		}
	#endif */
	///
	///
	/* float4 shadowCoordadd = TransformWorldToShadowCoord(input.positionWS.xyz);
	Light mainLightadd = GetMainLight(shadowCoordadd);
	half3 radiance2 = mainLightadd.shadowAttenuation;
	finalColor.xyz *= radiance2; */
	///

	///Hatching
        //float3 litDir = SafeNormalize(_MainLightPosition.xyz);

        float diff = max(0, ndl);
        float hatchFactor = diff * 7.0;
        
        if (hatchFactor > 6.0) {
            // Pure white, do nothing
        } else if (hatchFactor > 5.0) {
            input.hatchWeights0.x = hatchFactor - 5.0;
        } else if (hatchFactor > 4.0) {
            input.hatchWeights0.x = hatchFactor - 4.0;
            input.hatchWeights0.y = 1.0 - input.hatchWeights0.x;
        } else if (hatchFactor > 3.0) {
            input.hatchWeights0.y = hatchFactor - 3.0;
            input.hatchWeights0.z = 1.0 - input.hatchWeights0.y;
        } else if (hatchFactor > 2.0) {
            input.hatchWeights0.z = hatchFactor - 2.0;
            input.hatchWeights1.x = 1.0 - input.hatchWeights0.z;
        } else if (hatchFactor > 1.0) {
            input.hatchWeights1.x = hatchFactor - 1.0;
            input.hatchWeights1.y = 1.0 - input.hatchWeights1.x;
        } else {
            input.hatchWeights1.y = hatchFactor;
            input.hatchWeights1.z = 1.0 - input.hatchWeights1.y;
        }

        float4 hatchTex0 = SAMPLE_TEXTURE2D(_Hatch0, sampler_Hatch0, input.uv3) * input.hatchWeights0.x;
        float4 hatchTex1 = SAMPLE_TEXTURE2D(_Hatch1, sampler_Hatch1, input.uv3) * input.hatchWeights0.y;
        float4 hatchTex2 = SAMPLE_TEXTURE2D(_Hatch2, sampler_Hatch2, input.uv3) * input.hatchWeights0.z;
        float4 hatchTex3 = SAMPLE_TEXTURE2D(_Hatch3, sampler_Hatch3, input.uv3) * input.hatchWeights1.x;
        float4 hatchTex4 = SAMPLE_TEXTURE2D(_Hatch4, sampler_Hatch4, input.uv3) * input.hatchWeights1.y;
        float4 hatchTex5 = SAMPLE_TEXTURE2D(_Hatch5, sampler_Hatch5, input.uv3) * input.hatchWeights1.z;
        float4 whiteColor = float4(1, 1, 1, 1) * (1 - input.hatchWeights0.x - input.hatchWeights0.y - input.hatchWeights0.z - 
                    input.hatchWeights1.x - input.hatchWeights1.y - input.hatchWeights1.z);
        
        float4 hatchColor = hatchTex0 + hatchTex1 + hatchTex2 + hatchTex3 + hatchTex4 + hatchTex5 + whiteColor;
		//finalColor *= saturate(0.3 + hatchColor);
    ///
	return finalColor;
}

#endif

/* float3 NormalBlend_MatcapUV_Detail = viewNormal.rgb * float3(-1,-1,1);
float3 NormalBlend_MatcapUV_Base = (mul( UNITY_MATRIX_V, float4(viewDirection,0)).rgb*float3(-1,-1,1)) + float3(0,0,1);
float3 noSknewViewNormal = NormalBlend_MatcapUV_Base*dot(NormalBlend_MatcapUV_Base, NormalBlend_MatcapUV_Detail)/NormalBlend_MatcapUV_Base.b - NormalBlend_MatcapUV_Detail;                
float2 ViewNormalAsMatCapUV = noSknewViewNormal.rg * 0.5 + 0.5; */


