We need to create a SHELL script named `git-dl`. It should have following versions:

1. `git-dl`: usable in `ZSH` SHELL (MacOS) and `BASH` SHELL (Linux)
2. `git-dl.bat`: usable in `CMD` SHELL (Windows) **NOT REQUIRED RIGHT NOW, WILL ADD IN FUTURE**

Following are features of this script:

1. Usage: `git-dl.sh <github-url>`
2. Used to quickly download a GitHub repo contents, without cloning the full repo.
3. Can be used to download the complete repo, single folder or single file (read next points).
4. Can be used to download content from master branch, any other branch, or any tag.
5. The content should always be downloaded in the current working directory (CWD) from where the script is executed.
    1. If the complete repo is being downloaded: the script should download contents in a folder named same as repo name.
    2. If a single folder is being downloaded: the script should download contents in a folder named same as repo folder name.
    3. If a single file is being downloaded: the script should just download the file in CWD.

Following are the usecases and examples:

1. To download the top level repo. Example: `git-dl.sh https://github.com/motdotla/dotenv`
1. To download a specific folder within the repo. Example: `git-dl.sh https://github.com/motdotla/dotenv/tree/master/skills/dotenv`
1. To download a specific file. Example: `git-dl.sh https://github.com/motdotla/dotenv/blob/master/skills/dotenv/SKILL.md`
