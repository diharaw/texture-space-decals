// ------------------------------------------------------------------
// INPUT VARIABLES  -------------------------------------------------
// ------------------------------------------------------------------

in vec3 FS_IN_WorldPos;

// ------------------------------------------------------------------
// OUTPUT VARIABLES  ------------------------------------------------
// ------------------------------------------------------------------

out vec4 FS_OUT_Color;

// ------------------------------------------------------------------
// UNIFORMS  --------------------------------------------------------
// ------------------------------------------------------------------

layout(std140) uniform GlobalUniforms
{
    mat4 view_proj;
    mat4 light_view_proj;
    vec4 cam_pos;
};

uniform sampler2D s_Decal;
uniform sampler2D s_Depth;

#define BIAS 0.001

// ------------------------------------------------------------------
// FUNCTIONS  -------------------------------------------------------
// ------------------------------------------------------------------

bool is_outside_decal_bounds(vec3 uv)
{
    return (uv.x > 1.0 || uv.x < 0.0 || uv.y > 1.0 || uv.y < 0.0 || uv.z > 1.0 || uv.z < 0.0);
}

// ------------------------------------------------------------------
// MAIN  ------------------------------------------------------------
// ------------------------------------------------------------------

void main(void)
{
    // We project the world space position into the Decals coordinate space
    vec4 decal_space_pos = decal_view_proj * vec4(FS_IN_WorldPos, 1.0);

    // Rescale the values to between [0.0 - 1.0]
    vec3 decal_uv        = decal_space_pos.xyz * 0.5 + 0.5;

    // Check if these coordinates are outside of UV bounds
    if (is_outside_decal_bounds(decal_uv))
        discard;

    // Sample the depth from our depth texture.
    float compare_depth = texture(s_Depth, decal_uv.xy).r;

    // Compare the depth the current fragment to the depth from the depth texture (closest point from the decal projector).
    // If it's greater, the current fragment is NOT visible to the projector and should be discarded.
    if ((decal_uv.z - BIAS) > compare_depth)
        discard;

    // Sample the decal texture using the Decal UVs.
    FS_OUT_Color = texture(s_Decal, decal_uv.xy);
}

// ------------------------------------------------------------------
