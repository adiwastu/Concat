<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->
<!-- SPDX-FileCopyrightText: 2026 Jareer Abdullah and Concat contributors -->

# Karaoke captions

The captions sheet has a **Karaoke** switch. On, the words of the
transcription come out as short lines - two to six words, your pick - each
carrying when every word of it is said, and wearing the **Karaoke** look: the
word being spoken highlighted, a coloured box behind it, and the word on the
box in the box's own colour. The other words keep the caption's own. There
are eight looks - `aqua` (teal box, yellow word), `ember`, `lime`, `grape`,
`emerald`, `bubblegum`, `mono`, `ink` - and their colours are the look's own
dials, so a clip's karaoke can be regraded like any effect afterwards.

The switch needs a transcription: the look is driven by when each word was
said, which a script typed into the sheet, or a SubRip file read in, does not
have. Those captions come out as they always did.

## How it works, for the curious

Whisper hands back per-token timestamps (the transcriber reads them through
`whisper-rs`'s token API and folds them into words), the caption clip carries
them on its style, and the title painter bakes them - beside each word's
layout box - into a texture a shader reads. The `concat.karaoke` effect
package holds the pixel against the clip's own clock: the word whose span the
moment falls in is the one being said, and that pixel lights. Nothing is
rasterized twice and nothing changes for a title without word times.

The words are sorted and each word's end drawn to the next word's start
before they are stored, so exactly one word is ever the one being spoken. A
line's text is its words' own - what is highlighted is what is shown - and a
line holds a quarter second past its last word where the next line leaves
room, so only one caption is ever on screen.

A caption whose words were edited after the fact (so the times no longer
match the layout), or a title that never had times, reads exactly as painted:
the look is a no-op there, never a wrong highlight.

## For scripts

`addTextClip` takes an optional `effects` list, and a style's `words` carry
the word times - `[{"start": 0.0, "end": 0.42}, ...]`, seconds of the clip's
own time, one per layout word. Place a caption with `concat.karaoke` in its
effects and the look runs on it; the MCP server's schema picks both up.
