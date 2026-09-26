# Seating hero: the daybed

The first piece of the dream room: a bed that becomes the sofa during the day. This file distills five rounds of questionnaires answered in free text. Everything except the two firm decisions is a **soft rule**: a strong hint, not a requirement. Nothing here has been modelled yet.

## Firm decisions

1. **Placement:** against the left wall of the main room, long side to the wall.
2. **Use:** a bed at night, the sofa during the day.
3. **The firming layer (2026-09-26):** a flat-woven kilim, no foam, laid over the mattress and covering the top and the whole front face. Chosen: Alpina Home "Stella Jüt Hasır" (Trendyol), polypropylene, woven backing, machine-made, thin pile, no fringe, about 1,390 TL, in **beige**, size **110 x 190 cm** (the listing offers 100 x 200, so check the size before ordering: the top plus the 17 cm front face is about 107 cm across). Not bought yet.

Why a kilim: the seat is already at about 57 cm (40 cm frame plus 17 cm mattress), so there is no room for a pad. A thin stiff layer adds no height and takes away a little sinking. It will not stop the mattress compressing, so the gain is small. Backups considered: a 3 cm, 32-density foam pad (90 x 190) with a sewn cover, from a foam workshop.

## What the daybed has to do

**Morning change.** The bed goes from bed to sofa in about 15 seconds, or it will stay a bed forever. Today the routine is: move the pillow aside, wrap the bed neatly in the blanket, put the pillow on top. That takes seconds, looks tidy and is liked. How the sofa change should work is undecided ("I have no idea"). One loose idea: put something on top of the blanket. Do not build around it.

**Daytime look.** It should look like a sofa, not like a neat bed with things on top.

**Back support.** Once the bed head is gone, nothing supports the back, and sitting against the wall is not possible today. The daytime answer is something long that runs along the wall and covers about 80 percent of the bed's length. It is not yet decided what that is.

**Night.** Just a pillow. No headboard is wanted.

**Sitting comfort.** The mattress is liked but a bit too soft for sitting. The seat height is fine. Sitting depth is unknown, because nobody can sit back on it now.

## What stays and what goes

- **Mattress:** kept, 90 x 190 cm.
- **Bed head:** goes, easily.
- **Bed frame:** good as it is, with a good height. It can be got rid of, but with effort. Whether it stays as it is or is restyled is open.
- **Under the bed:** useful storage, but only for things reached about once a year (a suitcase, odds and ends). Nothing needs quick access.
- **Bookshelf:** may also stay. Not part of this piece.

## How it is used

- Sleeping, and sitting. No eating there, and probably no working.
- Up to **four people** at once, for a cozy talk about art over a glass of pinot grigio. Rough picture: two on the daybed, one in a rocking chair, one on the floor.
- The **rocking chair does not exist yet**. It is wanted, if the space allows.
- A projected movie on the wall is a "slightest of maybes".
- Where glasses and snacks go was not answered.

## Mood

A botanical, artsy place with warm light and jazz. This is the feeling for the whole room, not specific to the daybed.

## Limits

Money is not unlimited, but this is not a shoestring project. Getting the old frame out is possible but harder than the bed head. Felt pads under the legs are needed because of the vinyl floor (see PROJECT.md).

## Measurements (real)

- Mattress 90 x 190 cm, 17 cm thick. Frame legs 40 cm, so the mattress starts 40 cm off the floor and the seat is about 57 cm (about 53 once it sinks). For a 1.76 m person a comfortable seat is 42 to 47 cm, so it is a little high.
- The back support should be 45 to 50 cm deep, leaving about 45 cm of seat. Agreed split: 45 back, 45 seat.

## In the model

`tools/add_daybed.py` builds it (objects named `S_*`, safe to re-run): frame, mattress and the kilim, at real size, against the left wall in the middle of the main room. The constants at the top move it. The frame's look and colour, and the mattress colour, are placeholders. There is no back support yet. The room around it is still at the old, 13% too big scale, so the bed looks a bit small in it. The rug (`RUG_CENTER` in `main.gd`) now sits almost touching the bed's front and will need moving.

## Still open

- What the back support is, and how it stays put.
- Whether the frame stays exactly as it is, and what it looks like.
- How the 15-second sofa change works with the kilim, and whether the kilim stays on at night.
- Where drinks go, and whether the rocking chair fits.
- Colours for the cushions (sage and terracotta are the candidates).
