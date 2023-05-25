//
// Author: ZhaoNan	
// DateTime: 2021/12/13
// NPR character shader alpha write
//
#ifndef CUSTOM_ALPHAWRITE_INCLUDED
#define CUSTOM_ALPHAWRITE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "CustomInput.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
};
struct Varyings
{
    float4 positionCS               : SV_POSITION;
};
			
Varyings vert_alpha_write(Attributes input)
{
    Varyings output = (Varyings)0;

	output.positionCS = TransformWorldToHClip(TransformObjectToWorld(input.positionOS.xyz));

	return output;
}
	
half4 frag_alpha_write(Varyings input) : SV_Target
{
	half bloomAtten = max(0, _BloomFactor);
	return half4(0,0,0,bloomAtten);
}

#endif
