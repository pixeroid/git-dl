# git-dl

Download from GitHub a specific repository folder, single file, or the reposiroty snapshot — without cloning the whole thing. The motivation is to be able to download the codebase for quick usage, without the full baggage.

Works on MacOS, Linux, and Windows.

## Setup

### MacOS / Linux

**Install:**

```bash
cd posix
bash install.sh
```

This copies `git-dl` into the first writable directory on your local `PATH`, making it available system-wide.

**Uninstall:**

```bash
cd posix
bash uninstall.sh
```

### Windows

**Install:**

```bat
cd windows
install.bat
```

Scans your `PATH` for a writable directory and copies `git-dl.bat` there.

**Uninstall:**

```bat
cd windows
uninstall.bat
```

### Running Tests (Optional)

To verify everything works on your system before using the tool:

**macOS / Linux:**

```bash
cd posix
bash tests.sh
```

**Windows:**

```bat
cd windows
tests.bat
```

## Usage

Pass any GitHub URL directly to `git-dl`, as you see it in your browser urlbar. It figures out what to download from the URL structure.

**Notes:**

* After installation, the command is simply `git-dl` — no `.sh` or `.bat` suffix needed.
* `git-dl` will not overwrite an existing file or folder. If the target already exists, it exits with an error — user should remove the existing folder/file first. This is a safeguard adainst accidental deletion. We even have test cases written that no `rm` or `del` command should go into the script source.

### Download a specific folder

```bash
git-dl https://github.com/motdotla/dotenv/tree/master/skills/
```

Creates a `skills/` folder containing only that directory's contents.

### Download a specific file

```bash
git-dl https://github.com/motdotla/dotenv/blob/master/README.md
```

Downloads `README.md` to the current directory.

### Download a full repository

```bash
git-dl https://github.com/motdotla/dotenv
```

Creates a `dotenv/` folder in the current directory.

### Download from a branch or tag

Any of the above works with a specific branch or tag — just use the GitHub URL for that ref:

```bash
git-dl https://github.com/owner/repo/tree/feature-branch
git-dl https://github.com/owner/repo/tree/v2.1.0
```

## AI Disclosure

This project was built with an AI agent used for pair programming, with a human in the loop throughout — reviewing, directing, and approving every step. Development followed a Test Driven Development (TDD) approach, with tests written before implementation. All design decisions were human-driven and final output were human-validated. The core project intent used to guide the AI is retained in [INTENT.md](INTENT.md).
