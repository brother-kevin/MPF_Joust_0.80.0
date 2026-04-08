import re
import glob

replacements = [
    (r'\bhunter_complete\b', 'HunterComplete'),
    (r'\bhunter\b(?!\.yaml|\.tres)', 'Hunter'),
    (r'\bflipper_flap\b', 'FlipperFlap'),
    (r'\bl_sling\b', 'LeftSling'),
    (r'\br_sling\b', 'RightSling'),
    (r'\bball_drain_trough\b', 'BallDrainIntoTrough')
]

paths = glob.glob('modes/*/config/*.yaml')

for path in paths:
    with open(path, 'r') as f:
        content = f.read()

    orig_content = content
    # process replacements
    for old, new in replacements:
        # replace only inside sound_player section?
        if 'sound_player:' in content:
            content = re.sub(old, new, content)

    if content != orig_content:
        with open(path, 'w') as f:
            f.write(content)
        print(f"Fixed sounds in {path}")

