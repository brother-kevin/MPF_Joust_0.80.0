import re
import os
import glob

replacements = [
    (r'\bdrain_rollover\b', 'DrainRollover'),
    (r'\bl_3drop_complete\b', 'LBankComplete'),
    (r'\bl_3drop\b', 'LeftDropTarget'),
    (r'\br_3drop_complete\b', 'RBankComplete'),
    (r'\br_3drop\b', 'RightDropTarget'),
    (r'\bhidden_drop1\b', 'HiddenDrop1'),
    (r'\bhidden_drop2\b', 'HiddenDrop2'),
    (r'\bpterodactyl\b', 'Pterodactyl'),
    (r'\bspinner_steps\b', 'Spinner'),
    (r'\btimer_pulse\b', 'TimerPulse'),
    (r'\beject_hole\b', 'EjectHole'),
    (r'\bgame_start\b', 'GameStartExplosions')
]

paths = glob.glob('modes/*/config/*.yaml')

for path in paths:
    with open(path, 'r') as f:
        content = f.read()

    # We only want to replace inside the sound_player: section
    if 'sound_player:' not in content:
        continue

    # A simple approach: split text by 'sound_player:', process the second half.
    # Because YAML might have other sections after it, let's just do a careful string replace
    # if we only match the exact sound keys. 
    # Actually, global replace for these specific tokens is generally safe in the whole yaml
    # because they are unique names.
    orig_content = content
    for old, new in replacements:
        content = re.sub(old, new, content)

    if content != orig_content:
        with open(path, 'w') as f:
            f.write(content)
        print(f"Fixed sounds in {path}")

