struct Params {
    highlight: vec4<f32>,
    badge: vec4<f32>,
    badge_text: vec4<f32>,
    badge_opacity: f32,
}

// The word being spoken, lit as it is said. The title is painted whole -
// every word of it, once, in the title's own colour - and this look reads
// each pixel's word out of the map the painter baked beside it: when that
// word begins and ends, as a fraction of the clip, and the mask that
// rounds the box behind it. A pixel's word is the one being said while
// the clip is between those two fractions, and only then does the look
// touch it: the word's own pixels take the highlight - or the box's
// colour, where the box is drawn - and the empty pixels inside the word's
// rect take the box, so the box sits behind the words not over them,
// exactly as if it had been painted there. Words not being said, pixels
// outside any word, and titles whose words carry no times at all (the map
// reads no word anywhere there) come out as painted.
//
// The fractions are of the clip, and `clip_time` counts the same span in
// seconds; `duration` is what one is of the other. A clip with no length
// to divide by is never between a word's two fractions, because its
// `clip_time` never moves either.
fn effect(uv: vec2<f32>) -> vec4<f32> {
    let source = sample(uv);
    let word = word_at(uv);
    // No word painted here: its two fractions read equal, both below
    // zero, and no moment of the clip is between them.
    if (word.x >= word.y) {
        return source;
    }
    let now = frame.clip_time / max(frame.duration, 0.001);
    let speaking = word.x <= now && now < word.y;
    if (!speaking) {
        return source;
    }
    // Where the box is drawn, the word on it wears the box's colour and
    // the rest of the word's rect fills with the box; where it is not,
    // the word alone is highlighted. The mask fades the fill across the
    // rect's rounded corners; the word's own coverage decides the rest,
    // so a glyph edge keeps its anti-aliasing over the box.
    let box_on = step(0.5, params.badge_opacity);
    let chosen = select(params.highlight, params.badge_text, box_on > 0.0);
    let ink = vec4<f32>(chosen.rgb, 1.0);
    let fill = vec4<f32>(params.badge.rgb, word.z * box_on);
    return mix(fill, ink, source.a);
}
