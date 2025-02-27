shader_type canvas_item;

uniform vec4 outline_color: source_color;

void fragment() {
	if (COLOR.a==1.){
		ivec2 txs = textureSize(TEXTURE, 0);
		vec2 pxs = vec2(1.0/float(txs.x), 1.0/float(txs.y));
		vec2 pxp = UV + vec2(0., -pxs.y);
		vec4 pxc = texture(TEXTURE, pxp);
		if(pxc.a==0.){COLOR = outline_color;}
		else{
			pxp = UV + vec2(0., pxs.y);
			pxc = texture(TEXTURE, pxp);
			if(pxc.a==0.){COLOR = outline_color;}
			else{
				pxp = UV + vec2(-pxs.x, 0.);
				pxc = texture(TEXTURE, pxp);
				if(pxc.a==0.){COLOR = outline_color;}
				else{
					pxp = UV + vec2(pxs.x, 0.);
					pxc = texture(TEXTURE, pxp);
					if(pxc.a==0.){COLOR = outline_color;}
				}
			}
		}
	}
}
