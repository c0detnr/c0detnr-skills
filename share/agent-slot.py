import errno
import hashlib
import os
import subprocess
import sys
import time
from pathlib import Path

if os.name == "nt":
    import msvcrt

    def lock(file):
        msvcrt.locking(file.fileno(), msvcrt.LK_NBLCK, 1)
else:
    import fcntl

    def lock(file):
        fcntl.flock(file, fcntl.LOCK_EX | fcntl.LOCK_NB)


def main():
    state, project, limit, bash, command = sys.argv[1:]
    project_key = os.path.normcase(os.path.realpath(project))
    slots = Path(state) / hashlib.sha256(os.fsencode(project_key)).hexdigest()
    slots.mkdir(parents=True, exist_ok=True)

    while True:
        for index in range(int(limit)):
            with (slots / str(index)).open("a+b") as slot:
                try:
                    lock(slot)
                except OSError as error:
                    if error.errno not in (errno.EACCES, errno.EAGAIN):
                        raise
                    continue
                return subprocess.call([bash, command])
        time.sleep(0.2)


if __name__ == "__main__":
    sys.exit(main())
