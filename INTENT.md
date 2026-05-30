We need to create a SHELL script named `git-dl.sh`. It should have following versions for specific environments:

1. `git-dl.sh`: usable in MacOS and Linux/Unix
2. `git-dl.bat`: usable in Windows `CMD` SHELL

Following are features of this script:

1. Usage: `git-dl.sh <github-url>`
2. Used to quickly download a GitHub repo contents, without cloning the full repo.
3. Can be used to download the complete repo, single folder or single file (read next points).
4. Can be used to download content from the default branch (main/master), any other branch, or any tag.
5. The content should always be downloaded in the current working directory (CWD) from where the script is executed.
    1. If the complete repo is being downloaded: the script should download contents in a folder named same as repo name.
    2. If a single folder is being downloaded: the script should download contents in a folder named same as repo folder name.
    3. If a single file is being downloaded: the script should just download the file in CWD.
6. Script should NOT contain any "rm" (or equivalent) commands, so safeguard data.

Following are the usecases and examples:

1. To download the top level repo. Example: `git-dl.sh https://github.com/motdotla/dotenv`
2. To download a specific folder within the repo. Example: `git-dl.sh https://github.com/motdotla/dotenv/tree/master/skills/dotenv`
3. To download a specific file. Example: `git-dl.sh https://github.com/motdotla/dotenv/blob/master/skills/dotenv/SKILL.md`

Following are the system dependencies required to run this script:

1. Use `git` for the downloads. Needs `git` to be pre-installed.
1. If `git` is not installed. use the built-in CLI utilities for the environment. **WILL ADD IN FUTURE**

Following are the conflict handling rules (when target already exists in CWD):

1. Always fail with a clear error message. The user must remove the conflicting file/folder manually before re-running.
