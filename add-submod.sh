#!/bin/bash

##############################################################
# add-submod.sh
#
# Script to add a quickstart submodule to a branch, or to update an
# existing submodule to the latest commit of the quickstart's repo
#
# Usage: ./add-submod.sh [-i|--interactive] [-u|--update]
#
# -i, --interactive - Optional switch to prompt at each step
# -u, --update      - Optional switch to update an existing submodule
#
##############################################################

# Function to display usage
show_usage() {
    cat << EOF

Usage: ./add-submod.sh [OPTIONS]

Script to add a quickstart submodule to a branch in your fork of the ai-quickstart-pub repository,
or to update an existing quickstart submodule to point to the latest commit of its repository.

INSTRUCTIONS:
    1. Create a working folder, and move into that folder
    2. Run this script in the working folder with: ./add-submod.sh

OPTIONS:
    -h, --help          Display this help message and exit
    -i, --interactive   Prompt at each step for confirmation (default: non-interactive)
    -u, --update        Update an existing submodule to the latest commit of the quickstart's
                        repo instead of adding a new submodule

ASSUMPTIONS:
    1. You have already forked the rh-ai-quickstart/ai-quickstart-pub repo to your Github account.
    2. When using -u or --update, the quickstart is ALREADY a submodule of the ai-quickstart-pub repo

DESCRIPTION:
    This script automates the process of:
    1. Cloning your fork of the ai-quickstart-pub repository to your local machine
    2. Setting up the upstream remote (ie. rh-ai-quickstart/ai-quickstart-pub)
    3. Syncing with the upstream repository
    4. Creating a new branch for the quickstart in which you'll add or update the submodule
    5. Adding a quickstart as a submodule in the new branch, or, with -u or --update, pointing
       an existing submodule at the latest commit of the quickstart's repo
    6. Committing and pushing the changes in your local branch and on Github

    If the branch you name in step 4 already exists, locally or in your Github fork, the script
    tells you so and asks whether to delete it first. Answer Y to delete both the local and the
    Github copy of that branch and start it over from main, or n to keep the existing branch and
    add your changes on top of it.

    By default, the script runs non-interactively after the initial confirmation.
    Use -i or --interactive to be prompted at each major step.

EXAMPLES:
    ./add-submod.sh                       Add a new submodule, non-interactively
    ./add-submod.sh -i | --interactive    Run with prompts at each step
    ./add-submod.sh -u | --update         Update an existing submodule to its latest commit
    ./add-submod.sh -u -i                 Update an existing submodule, with prompts at each step
    ./add-submod.sh -h | --help           Display this help message

EOF
    exit 0
}

# Parse command-line arguments
INTERACTIVE=false
UPDATE=false
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_usage
            ;;
        -i|--interactive)
            INTERACTIVE=true
            ;;
        -u|--update)
            UPDATE=true
            ;;
        *)
            echo
            echo "Unknown option: $1"
            show_usage
            ;;
    esac
    shift
done

echo
echo "This assumes you have already created a fork of the rh-ai-quickstart/ai-quickstart-pub repo."

echo
read -p "Ready to proceed(Y/n): " ready
if [ $ready != "Y" ]; then
    echo "Quitting!" && exit 0
else
    echo "Let's get to it then!"
fi
echo

# Clone, via SSH, the ai-quickstart-pub repo (main branch) from your own fork
if [ "$INTERACTIVE" == "true" ]; then
    read -p "Proceed with cloning your fork's repo? (Y/n): " ready
    if [ $ready != "Y" ]; then echo "Qutting!" && exit 0; else echo; fi
fi

read -p "Enter your Github org (typically this is your Github username): " githuborg
echo
echo "Cloning the main branch of $githuborg/ai-quickstart-pub"
echo
git clone git@github.com:$githuborg/ai-quickstart-pub.git
echo
echo "Moving into project ai-quickstart-pub"
cd ai-quickstart-pub
echo

# Add the original pub repo as the 'upstream' repo
echo "Setting the upstream repo so we can make sure we're up to date"
echo
git remote add upstream git@github.com:rh-ai-quickstart/ai-quickstart-pub
git remote -v
git branch
echo

# Pull upstream main branch changes and merge into your local main branch
if [ "$INTERACTIVE" == "true" ]; then
    read -p "Proceed with updating your fork's local repo from upstream repo? (Y/n): " ready
    if [ $ready != "Y" ]; then echo "Qutting!" && exit 0; else echo; fi
fi

echo "Fetching the latest content from the upstream repo"
echo
git fetch upstream
echo
git merge upstream/main
echo

# Push updated local main branch to your github fork's main branch
if [ "$INTERACTIVE" == "true" ]; then
    read -p "Proceed with pushing the changes to your fork's Github repo? (Y/n): " ready
    if [ $ready != "Y" ]; then echo "Qutting!" && exit 0; else echo; fi
fi

echo "Updating our fork's main branch to be in sycn with Red Hat's repo"
echo
git push origin main
echo

# Create a new branch for your partner quickstart publication
if [ "$INTERACTIVE" == "true" ]; then
    read -p "Proceed with creating a new branch for the quickstart in your repo? (Y/n): " ready
    if [ $ready != "Y" ]; then echo "Qutting!" && exit 0; else echo; fi
fi

if [ "$UPDATE" == "true" ]; then
    read -p "What will be your new branch name (ie. partner_name-update): " branch_name
else
    read -p "What will be your new branch name (ie. partner_name-pub): " branch_name
fi
echo

# Check whether that branch already exists, either locally or in your Github fork
git fetch origin > /dev/null 2>&1
local_branch_exists=false
remote_branch_exists=false
if git show-ref --verify --quiet refs/heads/$branch_name; then local_branch_exists=true; fi
if git show-ref --verify --quiet refs/remotes/origin/$branch_name; then remote_branch_exists=true; fi

if [ "$local_branch_exists" == "true" ] || [ "$remote_branch_exists" == "true" ]; then

    echo "A branch named $branch_name already exists in your fork."
    echo
    read -p "Delete the existing $branch_name branch, locally and on Github, and start it over from main? (Y/n): " delete_branch
    echo

    if [ "$delete_branch" == "Y" ]; then
        echo "Deleting the existing $branch_name branch"
        echo
        if [ "$local_branch_exists" == "true" ]; then
            git switch main
            git branch -D $branch_name
        fi
        if [ "$remote_branch_exists" == "true" ]; then
            git push origin --delete $branch_name
        fi
        echo
        echo "Creating the $branch_name branch from main"
        echo
        git switch -c $branch_name
    else
        echo "Keeping the existing $branch_name branch and switching to it"
        echo
        git switch $branch_name
    fi

else
    git switch -c $branch_name
fi
echo

# Add the sub-module, or update an existing one to the latest commit of its repo
if [ "$UPDATE" == "true" ]; then

    if [ "$INTERACTIVE" == "true" ]; then
        read -p "Proceed with updating the submodule in your local branch? (Y/n): " ready
        if [ $ready != "Y" ]; then echo "Qutting!" && exit 0; else echo; fi
    fi

    echo
    echo "Here are the quickstarts currently in this repo:"
    echo
    git submodule status
    echo
    read -p "Enter the short name, with no spaces, of the quickstart to update (ie. redis_llm_cost_savings): " new_quickstart_name
    echo

    if [ ! -f .gitmodules ] || ! git config --file .gitmodules --get "submodule.quickstart/$new_quickstart_name.url" > /dev/null; then
        echo "There is no submodule at quickstart/$new_quickstart_name in this repo. Quitting!"
        exit 1
    fi

    echo "Checking out the quickstart/$new_quickstart_name submodule"
    echo
    git submodule update --init quickstart/$new_quickstart_name
    echo

    echo "Fetching the latest commits of the quickstart's repo"
    echo
    cd quickstart/$new_quickstart_name || { echo "Could not move into quickstart/$new_quickstart_name. Quitting!"; exit 1; }
    git fetch origin
    echo

    # Figure out the default branch of the quickstart's repo so we know which commit is the latest
    git remote set-head origin --auto > /dev/null 2>&1
    default_branch=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2> /dev/null | sed 's#^origin/##')
    if [ -z "$default_branch" ]; then
        echo "Could not determine the default branch of the quickstart's repo. Quitting!"
        exit 1
    fi

    echo "Pointing the submodule at the latest commit on the $default_branch branch of the quickstart's repo"
    echo
    git checkout --detach origin/$default_branch
    echo
    cd ../..

    # Verify the updated sub-module. It will be the one with a + at the front of the line
    echo "You should see your updated quickstart below. It will be the one with a + at the beginning of the line."
    echo
    git submodule status
    echo

    if git diff --quiet -- quickstart/$new_quickstart_name; then
        echo "The quickstart/$new_quickstart_name submodule already points at the latest commit, so there is nothing to commit."
        echo
        echo "Done! No changes were pushed."
        exit 0
    fi

    # Commmit and push the changes to your github repository quickstart branch
    if [ "$INTERACTIVE" == "true" ]; then
        read -p "If you see the updated submodule above, shall we proceed with committing and pushing the change to your branch? (Y/n): " ready
        if [ $ready != "Y" ]; then echo "Qutting!" && exit 0; else echo; fi
    fi

    echo "Committing and pushing the changes to your $branch_name branch"
    git add quickstart/$new_quickstart_name
    git commit -m "Updated submodule for $new_quickstart_name quickstart to the latest commit"
    echo

else

    if [ "$INTERACTIVE" == "true" ]; then
        read -p "Proceed with adding the submodule to your local branch? (Y/n): " ready
        if [ $ready != "Y" ]; then echo "Qutting!" && exit 0; else echo; fi
    fi

    echo
    read -p "Enter the URL of the new quickstart's repo: " new_quickstart_url
    echo
    read -p "Enter a short name, with no spaces, for the quickstart (ie. redis_llm_cost_savings): " new_quickstart_name
    echo
    git submodule add $new_quickstart_url quickstart/$new_quickstart_name
    echo

    # Verify the added sub-module. It will be the one without a - at the front of the line
    echo "You should see your new quickstart below. It will be the one without a - at the beginning of the line."
    echo
    git submodule
    echo

    # Commmit and push the changes to your github repository quickstart branch
    if [ "$INTERACTIVE" == "true" ]; then
        read -p "If you see the submodule above, shall we proceed with committing and pushing the change to your branch? (Y/n): " ready
        if [ $ready != "Y" ]; then echo "Qutting!" && exit 0; else echo; fi
    fi

    echo "Committing and pushing the changes to your $branch_name branch"
    git commit -m "Added submodule for $new_quickstart_name quickstart"
    echo

fi
git push -u origin $branch_name
echo

echo "Done! Now you can submit a PR to merge your updated submodules to the official repo from your $branch_name branch."
