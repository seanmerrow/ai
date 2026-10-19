# Add or update a submodule

**Usage**: `./add-submod.sh [OPTIONS]`

Script to add or update a quickstart submodule to a branch in your fork of the `ai-quickstart-pub` repository.

**INSTRUCTIONS**:
1. Create a working folder, and move into that folder
2. Run this script in the working folder with: `./add-submod.sh`

**OPTIONS**:
```
    -h, --help          Display this help message and exit
    -i, --interactive   Prompt at each step for confirmation (default: non-interactive)
```
**ASSUMPTIONS**:
1. You have already forked the `rh-ai-quickstart/ai-quickstart-pub` repo to your Github account.
2. You DO NOT already have a branch in your forked repo for this quickstart

**DESCRIPTION**:
This script automates the process of:

1. Cloning your fork of the ai-quickstart-pub repository to your local machine
2. Setting up the upstream remote (ie. `rh-ai-quickstart/ai-quickstart-pub`)
3. Syncing with the upstream repository
4. Creating a new branch for the quickstart in which you'll add the submodule
5. Adding a quickstart as a submodule in the new branch
6. Committing and pushing the changes in your local branch and on Github

By default, the script runs non-interactively after the initial confirmation. Use `-i` or `--interactive` to be prompted at each major step.

**EXAMPLES**:
```
    ./add-submod.sh                       Run non-interactively
    ./add-submod.sh -i | --interactive    Run with prompts at each step
    ./add-submod.sh -h | --help           Display this help message
```
