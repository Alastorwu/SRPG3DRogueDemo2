#ifndef CUSTOM_COMMON_INPUT_INCLUDED
#define CUSTOM_COMMON_INPUT_INCLUDED

half Alpha(half4 baseTex, half4 baseColor, half cutoff)
{
    // defined(_USE_ALBEDO_ALPHA_AS_MASK)
    half outAlpha = baseColor.w;
#if defined(_ALPHABLEND_ON) || defined(_ALPHATEST_ON)
    outAlpha *= baseTex.w;
#endif
#if defined(_ALPHATEST_ON)
    clip(outAlpha - cutoff);
#endif
    return outAlpha;
}

half3 SampleNormal(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), half scale = 1.0h)
{
    half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
#if BUMP_SCALE_NOT_SUPPORTED
    return UnpackNormal(n);
#else
    return UnpackNormalScale(n, scale);
#endif
}

half3 SampleEmission(float2 uv, half3 emissionColor, TEXTURE2D_PARAM(emissionMap, sampler_emissionMap))
{
    return SAMPLE_TEXTURE2D(emissionMap, sampler_emissionMap, uv).rgb * emissionColor;
}

#endif