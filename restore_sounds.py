import re
import subprocess
import os

commit = "543cc2f31fe661e093c05717ce3a4e03d9ed39cf"
diff_output = subprocess.check_output(['git', 'show', commit]).decode('utf-8')

current_file = None
in_sound_player = False
restorations = {}

for line in diff_output.split('\n'):
    if line.startswith('diff --git'):
        match = re.search(r'a/(modes/.*?\.yaml)', line)
        if match:
            current_file = match.group(1)
            restorations[current_file] = []
        in_sound_player = False
    elif current_file and line.startswith('-sound_player:'):
        in_sound_player = True
        restorations[current_file].append('sound_player:')
    elif current_file and in_sound_player:
        if line.startswith('-') and not line.startswith('---'):
            if line.strip() == '-':
                continue
            restorations[current_file].append(line[1:])
        elif line.startswith(' '):
            # It's an unchanged line, meaning we exited the deleted block section?
            # Actually, diff context usually includes unchanged lines if within the chunk.
            # Usually sound_player is at the very end of the file.
            pass
        elif not line.startswith('-') and not line.startswith('+') and line.strip() != '' and line != '\\ No newline at end of file':
            in_sound_player = False

for f, lines in restorations.items():
    if lines and os.path.exists(f):
        with open(f, 'a') as out:
            out.write('\n\n')
            for l in lines:
                out.write(l + '\n')
        print(f"Restored {len(lines)} lines to {f}")

