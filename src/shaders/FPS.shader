shader_type canvas_item;
void fragment() {
    // Get rgb values from screen.
    vec3 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
    // Invert them.
    c.rgb = 1.0 - c.rgb;
    // Asign them to the cursor.
    COLOR.rgb = c;
    // Asign the original alpha value.
    COLOR.a = texture(TEXTURE, UV).a;
}