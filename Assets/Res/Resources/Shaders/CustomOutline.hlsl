//
// Author: ZhaoNan
// DateTime: 2021/12/13
// NPR character shader outline
//
#ifndef CUSTOM_OUTLINE_INCLUDED
#define CUSTOM_OUTLINE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "CustomInput.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
	float2 uv0           : TEXCOORD0;
    float4 uv           : TEXCOORD3;
	float4 color		: COLOR;
};
struct Varyings
{
	float4 uv                       : TEXCOORD0;
    float clipZ                     : TEXCOORD3;
	float4 color		            : COLOR;
    float4 positionCS               : SV_POSITION;
};

//perlin_noise 控制描边粗细
	float2 hash22(float2 p) 
	{
		p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
		return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
	}

	float2 hash21(float2 p)
	{
		float h = dot(p, float2(127.1, 311.7));
		return -1.0 + 2.0 * frac(sin(h) * 43758.5453123);
	}

	//perlin
	float perlin_noise(float2 p)
	{
		float2 pi = floor(p);
		float2 pf = p - pi;
		float2 w = pf * pf * (3.0 - 2.0 * pf);
		return lerp(lerp(dot(hash22(pi + float2(0.0, 0.0)), pf - float2(0.0, 0.0)),
		dot(hash22(pi + float2(1.0, 0.0)), pf - float2(1.0, 0.0)), w.x),
		lerp(dot(hash22(pi + float2(0.0, 1.0)), pf - float2(0.0, 1.0)),
		dot(hash22(pi + float2(1.0, 1.0)), pf - float2(1.0, 1.0)), w.x), w.y);
	}
//
			
Varyings vert_outline(Attributes input)
{
    Varyings output = (Varyings)0;
		
	real sign = input.tangentOS.w * GetOddNegativeScale();
	real3 bitangentOS = cross(input.normalOS, input.tangentOS.xyz) * sign;
	real3x3 tbn = real3x3(input.tangentOS.xyz, bitangentOS, input.normalOS.xyz);

	//perlin_noise 控制描边粗细
	float3 perlinnoise = perlin_noise(input.uv.xyz);
	float3 bakedNormal = perlinnoise * 2 - 1;
	//

	//float3 bakedNormal = input.uv.xyz * 2 - 1;
	bakedNormal = SafeNormalize(mul(bakedNormal, tbn));
	float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, bakedNormal);
	normal.z = 0.001;
	normal = SafeNormalize(normal);

	float4 viewPos = mul(UNITY_MATRIX_MV, input.positionOS);
	viewPos /= viewPos.w;
	float3 viewDirPos = SafeNormalize(viewPos.xyz)*0.0015 + viewPos.xyz;
	float lineWidth = sqrt(-viewPos.z*66.67 / unity_CameraProjection[1].y)*_OutlineWidth*0.00027;
	normal.xy = normal.xy*lineWidth + viewDirPos.xy;

	float4 pos = mul(UNITY_MATRIX_P, float4(normal.xy, viewDirPos.z + _OutlineZOffset, viewPos.w));
	output.positionCS = pos;
	output.clipZ = pos.z;
	output.uv = TRANSFORM_TEX(input.uv0, _BaseMap).xyxy;

	output.color = input.color;
	
    return output;
}
	
half4 frag_outline(Varyings input) : SV_Target
{
	/* half4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy);
	half4 albedo = baseTex*_BaseColor;
	albedo.w = 1;
	float4 finalColor = albedo*_OutlineColor * _OutlineIntensity * _GlobalCharacterOutlineColor;

#if !defined(_ALPHABLEND_ON)// && !defined(_ALPHAPREMULTIPLY_ON)
	finalColor.w = _OutlineBloomFactor;
#endif

#ifdef _LINEARFOGENABLE_ON
	half fogFactor = saturate( max(input.clipZ, 0)*_LinearFogParams.x + _LinearFogParams.y );
#if defined(_ALPHABLEND_ON)// || defined(_ALPHAPREMULTIPLY_ON)
	finalColor.xyz = lerp(_LinearFogColor.xyz, finalColor.xyz, fogFactor);
#else
	finalColor = lerp(_LinearFogColor, finalColor, fogFactor);
#endif
#endif

	return finalColor; */
	return _OutlineColor;
}

#endif
