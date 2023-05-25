//
// Author: ZhaoNan
// DateTime: 2021/12/17
//
#ifndef CUSTOM_OUTLINE_MASK_CORE_BASE_INCLUDED
#define CUSTOM_OUTLINE_MASK_CORE_BASE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

struct Attributes
{
	float4 positionOS : POSITION;
};

struct Varyings
{
	float4 vertex : SV_POSITION;
};

Varyings vert(Attributes input)
{
	Varyings output = (Varyings)0;
	VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
	output.vertex = vertexInput.positionCS;

	return output;
}

float4 frag(Varyings input) : SV_Target
{
	return _MaskColor;
}

#endif
