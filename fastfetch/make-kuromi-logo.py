#!/usr/bin/env python3
# Renders the Kuromi pixel art below into ANSI half-blocks (kuromi.ans) for fastfetch.
import os

ART = [
    "OO......................OO",
    "OHO....................OHO",
    "OHHO..................OHHO",
    ".OHHO................OHHO.",
    ".OHHHO..OOOOOOOOOO..OHHHO.",
    "..OHHHOOHHHHHHHHHHOOHHHO..",
    "..OHHHHHHHHHSSHHHHHHHHHO..",
    "..OHHHHHHHHSSSSHHHHHHHHO..",
    "..OHHHHHHHSDSSDSHHHHHHHO..",
    "..OHHHHHHHHSSSSHHHHHHHHO..",
    "..OHHHHHHHHHSSHHHHHHHHHO..",
    "..OHHHWHHHWWHHWWHHHWHHHO..",
    "..OHHWWWHWWWWWWWWHWWWHHO..",
    "..OHWWWWWWWWWWWWWWWWWWHO..",
    "..OHWWEEEWWWWWWWWEEEWWHO..",
    "..OHWWWEEWWWWWWWWEEWWWHO..",
    "..OHWBBWWWWWNNWWWWWBBWHO..",
    "...OWWWWWWWWWWWWWWWWWWO...",
    "....OWWWWWWWWWWWWWWWWO....",
    ".....OOWWWWWWWWWWWWOO.....",
    "......OPPPPPOOPPPPPO......",
    ".......OOOOO..OOOOO.......",
]

COLORS = {
    "O": (195, 166, 247),  # outline (lavender)
    "H": (59, 51, 82),     # hood
    "S": (245, 154, 184),  # skull
    "D": (28, 26, 43),     # skull eyes
    "W": (241, 235, 255),  # face
    "E": (28, 26, 43),     # eyes
    "B": (255, 179, 204),  # blush
    "N": (245, 154, 184),  # nose
    "P": (245, 154, 184),  # bow
}

out = []
for top, bottom in zip(ART[0::2], ART[1::2]):
    line = ""
    for a, b in zip(top, bottom):
        ca, cb = COLORS.get(a), COLORS.get(b)
        if ca and cb:
            line += "\x1b[38;2;%d;%d;%dm\x1b[48;2;%d;%d;%dm▀\x1b[0m" % (*ca, *cb)
        elif ca:
            line += "\x1b[38;2;%d;%d;%dm▀\x1b[0m" % ca
        elif cb:
            line += "\x1b[38;2;%d;%d;%dm▄\x1b[0m" % cb
        else:
            line += " "
    out.append(line)

path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "kuromi.ans")
with open(path, "w") as f:
    f.write("\n".join(out) + "\n")
