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
    vec4 decal_space_pos = light_view_proj * vec4(FS_IN_WorldPos, 1.0);
    vec3 decal_uv = decal_space_pos.xyz * 0.5 + 0.5;

    if (is_outside_decal_bounds(decal_uv))
        discard;

    float compare_depth = texture(s_Depth, decal_uv.xy).r;
    
    if ((decal_uv.z - BIAS) > compare_depth)
        discard;
    
    FS_OUT_Color = texture(s_Decal, decal_uv.xy);
}

// ------------------------------------------------------------------
