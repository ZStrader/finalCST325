//--------------------------------------------------------------------------------------
// File: Tutorial022.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------
Texture2D tex : register(t0);
SamplerState samLinear : register(s0);

cbuffer VS_CONSTANT_BUFFER : register(b0)
{
	matrix world;
	matrix view;
	matrix projection;
	float4 campos;
	float4 lightpos;
};
struct SimpleVertex
{
	float4 Pos : POSITION;
	float2 Tex : TEXCOORD0;
	float3 Norm : NORMAL;
};
struct PS_INPUT
{
	float4 Pos : SV_POSITION;
	float4 WorldPos : POSITION1;
	float2 Tex : TEXCOORD0;
	float3 Norm : NORMAL;
};
//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VShader(SimpleVertex input)
{
	PS_INPUT output;
	float4 pos = input.Pos;
	pos.w = 1;
	pos = mul(world, pos);
	output.WorldPos = pos;
	pos = mul(view, pos);
	pos = mul(projection, pos);
	matrix w = world;
	w._14 = 0;
	w._24 = 0;
	w._34 = 0;
	float4 norm;
	norm.xyz = input.Norm;
	norm.w = 1;
	norm = mul(w, norm);
	output.Norm = normalize(norm.xyz);
	output.Pos = pos;
	output.Tex = input.Tex;
	return output;
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT input) : SV_Target
{
	float4 texturecolor = tex.Sample(samLinear,input.Tex);
	float3 light_pos = lightpos.xyz;
	float3 normal = normalize(input.Norm);
	float3 camera_direction = campos;

	float ambient = .3;

	float3 light_direction = normalize(light_pos - input.WorldPos);
	float diffuse = saturate(dot(light_direction, normal)); 

	float3 reflected = reflect(-light_direction, normal);
	float specular = pow(saturate(dot(reflected, camera_direction)), 20);

	texturecolor.rgb = saturate((ambient + diffuse)*texturecolor.rgb + specular);

	return texturecolor;
}

float4 PSsky(PS_INPUT input) : SV_Target
{
	float4 color = tex.Sample(samLinear, input.Tex);
	return color;
}

