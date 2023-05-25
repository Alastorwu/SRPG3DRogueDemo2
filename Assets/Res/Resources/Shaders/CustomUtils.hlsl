#ifndef CUSTOM_UTILS_INCLUDED
#define CUSTOM_UTILS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//Rotate Martix
float3 rotateVectorAboutX(float angle, float3 vec)
{
	angle = radians(angle);
	float3x3 rotationMatrix = { float3(1.0,0.0,0.0),
							  float3(0.0,cos(angle),-sin(angle)),
							  float3(0.0,sin(angle),cos(angle)) };
	return mul(vec, rotationMatrix);
}
float3 rotateVectorAboutY(float angle, float3 vec)
{
	angle = radians(angle);
	float3x3 rotationMatrix = { float3(cos(angle),0.0,sin(angle)),
							  float3(0.0,1.0,0.0),
							  float3(-sin(angle),0.0,cos(angle)) };
	return mul(vec, rotationMatrix);
}
float3 rotateVectorAboutZ(float angle, float3 vec)
{
	angle = radians(angle);
	float3x3 rotationMatrix = { float3(cos(angle),0.0,sin(angle)),float3(0.0,1.0,0.0),float3(-sin(angle),0.0,cos(angle)) };
	return mul(vec, rotationMatrix);
}
//ACES ToneMapping
float3 ACESToneMapping(float3 color, float factor)
{
	const float A = 2.51f;
	const float B = 0.03f;
	const float C = 2.43f;
	const float D = 0.59f;
	const float E = 0.14f;

	color *= factor;
	return (color * (A * color + B)) / (color * (C * color + D) + E);
}

//Come from UE4 FastMath
float acosFast4(float inX)
{
	float x1 = abs(inX);
	float x2 = x1 * x1;
	float x3 = x2 * x1;
	float s;
			
	s = -0.2121144f * x1 + 1.5707288f;
	s = 0.0742610f * x2 + s;
	s = -0.0187293f * x3 + s;
	s = sqrt(1.0f - x1) * s;
				
	return s;
	//return inX >= 0.0f ? s : UNITY_PI - s;
}

/*
half3 SH(half4 n)
{
	float4 approx = c0 * 0.2821 + c1 * 0.4886*n.z + c2 * 0.4886*n.y + c3 * 0.4886*n.x + c4 * 1.0925*n.x*n.z + c5 * 1.0925*n.z*n.y + c6 * 0.3979*(2 * n.y*n.y - n.x*n.x - n.z*n.z) + c7 * 1.0925*n.y*n.x + c8 * 0.54625*(n.x*n.x - n.z*n.z);
	return approx;
}
*/
#endif