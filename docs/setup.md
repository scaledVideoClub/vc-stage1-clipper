# Setup Guide — Stage 1: Clipper 5.2

This guide covers how to set up the DOSBox + Clipper 5.2 environment to compile and run this project.

---

## Prerequisites

| Tool | Version | Download |
|---|---|---|
| DOSBox | 0.74-3 | https://www.dosbox.com/download.php?main=1 |
| Clipper 5.2 | 5.2 | https://winworldpc.com/download/e2809875-c39e-c3aa-5ae2-809811c3a5ef |
| EDIT.COM | MS-DOS Editor | https://archive.org/details/ms-dos-editor |

---

## Directory structure (host machine)

```
C:\DOSBOXFS\
  DISCOC\               ← mounted as C: inside DOSBox
    CLIPPER5\           ← Clipper 5.2 installation
    EDIT.COM            ← MS-DOS editor
    vc-stage1-clipper\  ← project directory (or mount as D:, see below)
```

---

## Installing Clipper 5.2

Clipper 5.2 ships as floppy disk images. The `imgmount` + disk swap approach (Ctrl+F4) can be unreliable in DOSBox 0.74-3. The recommended workaround:

1. Mount a working directory as `C:` in DOSBox (your `DISCOC` folder).
2. Mount the Clipper disk images one at a time as drive `A:` using `imgmount`.
3. Copy the contents of each disk to a staging directory on `C:` (e.g. `C:\CLIPPER5`).
4. Run the installer from the staging directory.

**Important files during installation:**
- `DISK.ID` — leave the one from **disk 1** in place.
- `INSTALL.DAT` — leave the one from **disk 2** in place.
- These two files do not need to match disks — this is expected and the installer accepts it.

After installation, Clipper binaries will be in `C:\CLIPPER5\BIN`.

---

## DOSBox configuration

DOSBox configuration file location:

```
C:\Program Files (x86)\DOSBox-0.74-3\dosbox-0.74-3.conf
```

Add the following to the `[autoexec]` section. **The `MOUNT` line must come first** — Clipper will not function correctly if environment variables are set before the drive is mounted.

```ini
[autoexec]
# Lines in this section will be run at startup.
MOUNT C C:\DOSBOXFS\DISCOC
SET INCLUDE=C:\CLIPPER5\INCLUDE
SET LIB=C:\CLIPPER5\LIB
SET OBJ=C:\CLIPPER5\OBJ
SET PLL=C:\CLIPPER5\PLL
PATH=C:\CLIPPER5\BIN;C:\NG;%path%
```

---

## Mounting the project directory

The project lives on your host machine at `C:\Projects\scaledvideoclub\vc-stage1-clipper`. Mount it as drive `D:` inside DOSBox:

**Option A — add to `[autoexec]`** (mounts automatically on DOSBox startup):
```ini
MOUNT D C:\Projects\scaledvideoclub\vc-stage1-clipper
```

**Option B — mount manually** each session from the DOSBox prompt:
```
MOUNT D C:\Projects\scaledvideoclub\vc-stage1-clipper
D:
```

---

## Important: editing files from outside DOSBox

DOSBox does not detect changes made to mounted files by external tools (VSCode, Windows Explorer, etc.) in real time. If you edit `VIDEOCLUB.PRG` in VSCode and then try to compile inside DOSBox, DOSBox may still see the old version.

**To refresh:**
```
RESCAN
```
Type `RESCAN` at the DOSBox prompt after making changes from outside. This forces DOSBox to re-read the mounted directory from the host filesystem.

**Alternative — edit from inside DOSBox with EDIT.COM:**
If you use `EDIT.COM` to make changes directly inside DOSBox, no rescan is needed — changes are written directly to the host filesystem and DOSBox sees them immediately.

```
D:
EDIT VIDEOCLUB.PRG
```

For larger editing sessions, VSCode is more comfortable. For quick fixes during a compile-test cycle inside DOSBox, EDIT.COM avoids the rescan step.

---

## Compiling the project

From inside DOSBox with drive `D:` mounted:

```
D:
CLIPPER VIDEOCLUB /N /W
```

- `/N` — enables line numbers in error messages
- `/W` — enables warnings

If compilation succeeds, link with RTLink:

```
RTLINK FI VIDEOCLUB LIB CLIPPER
```

This produces `VIDEOCLUB.EXE`. The compiled executable and intermediate files (`.OBJ`, `.MAP`) should be moved to or output directly into the `BUILD\` directory. These are excluded from version control via `.gitignore`.

---

## Running the application

```
D:
VIDEOCLUB
```

The application expects a `DATA\` subdirectory for `.DBF` files and a `VIDEOCLUB.CFG` in the same directory as the executable. See `docs/run.md` for first-run setup and core flow walkthroughs.

---

## Notes

- EDIT.COM must be in a directory on the `PATH` or in the current directory to launch it by name. Placing it in `C:\` (root of DISCOC) and ensuring `C:\` is on the path is the simplest setup.
- Norton Guides (`C:\NG`) is referenced in the PATH above — remove that entry if you do not have it installed.
- DOSBox 0.74-3 runs well on Windows 10/11 without additional configuration beyond the `[autoexec]` section above. (meaning NO config.sys setup)
