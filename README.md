# Add or update a submodule

**Usage**: `./add-submod.sh [OPTIONS]`

Script to add a quickstart submodule to a branch in your fork of the `ai-quickstart-pub` repository, or to update an existing quickstart submodule to point to the latest commit of its repository.

## Instructions
1. Create a working folder, and move into that folder
2. Run this script in the working folder with: `./add-submod.sh`

## Options
```
    -h, --help          Display this help message and exit
    -i, --interactive   Prompt at each step for confirmation (default: non-interactive)
    -u, --update        Update an existing submodule to the latest commit of the quickstart's
                        repo instead of adding a new submodule
```
## Assumptions
1. You have already forked the `rh-ai-quickstart/ai-quickstart-pub` repo to your Github account.
2. When using `-u` or `--update`, the quickstart is ALREADY a submodule of the `ai-quickstart-pub` repo

## What it does
This script automates the process of:

1. Cloning your fork of the ai-quickstart-pub repository to your local machine
2. Setting up the upstream remote (ie. `rh-ai-quickstart/ai-quickstart-pub`)
3. Syncing with the upstream repository
4. Creating a new branch for the quickstart in which you'll add or update the submodule
5. Adding a quickstart as a submodule in the new branch, or, with `-u` or `--update`, pointing an existing submodule at the latest commit of the quickstart's repo
6. Committing and pushing the changes in your local branch and on Github

By default, the script runs non-interactively after the initial confirmation. Use `-i` or `--interactive` to be prompted at each major step.

## If the branch already exists
If the branch you name in step 4 already exists, locally or in your Github fork, the script tells you so and asks whether to delete it first:

- Answer `Y` to delete both the local and the Github copy of that branch, then start it over from your freshly synced main branch
- Answer `n` to keep the existing branch, switch to it, and add your submodule change on top of it

## Updating an existing submodule
With `-u` or `--update`, steps 1 through 4 are exactly the same. At step 5, instead of asking for a repo URL, the script:

1. Lists the quickstarts currently in the repo, then asks which one to update by its short name (ie. `redis_llm_cost_savings`)
2. Checks out that submodule and fetches the latest commits from the quickstart's repo
3. Points the submodule at the latest commit on the default branch of the quickstart's repo
4. Commits and pushes the change, or tells you there is nothing to do if the submodule already points at the latest commit

## Examples
```
    ./add-submod.sh                       Add a new submodule, non-interactively
    ./add-submod.sh -i | --interactive    Run with prompts at each step
    ./add-submod.sh -u | --update         Update an existing submodule to its latest commit
    ./add-submod.sh -u -i                 Update an existing submodule, with prompts at each step
    ./add-submod.sh -h | --help           Display this help message
```
