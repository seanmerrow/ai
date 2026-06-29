#!/bin/bash

##############################################################
# add-submod.sh
#
# Script to add quickstart submodule to branch
#
# Usage: ./add-submod.sh [-i|--interactive]
#
# -i, --interactive - Optional switch to prompt at each step
#
##############################################################

# Function to display usage
show_usage() {
    cat << EOF

Usage: ./add-submod.sh [OPTIONS]

Script to add a quickstart submodule to a branch in your fork of the ai-quickstart-pub repository.

INSTRUCTIONS:
    1. Create a working folder, and move into that folder
    2. Run this script in the working folder with: ./add-submod.sh

OPTIONS:
    -h, --help          Display this help message and exit
    -i, --interactive   Prompt at each step for confirmation (default: non-interactive)

ASSUMPTIONS:
    1. You have already forked the rh-ai-quickstart/ai-quickstart-pub repo to your Github account.
    2. You DO NOT already have a branch in your forked repo for this quickstart

DESCRIPTION:
    This script automates the process of:
    1. Cloning your fork of the ai-quickstart-pub repository to your local machine
    2. Setting up the upstream remote (ie. rh-ai-quickstart/ai-quickstart-pub)
    3. Syncing with the upstream repository
    4. Creating a new branch for the quickstart in which you'll add the submodule
    5. Adding a quickstart as a submodule in the new branch
    6. Committing and pushing the changes in your local branch and on Github

    By default, the script runs non-interactively after the initial confirmation.
    Use -i or --interactive to be prompted at each major step.

EXAMPLES:
    ./add-submod.sh                       Run non-interactively
    ./add-submod.sh -i | --interactive    Run with prompts at each step
    ./add-submod.sh -h | --help           Display this help message

EOF
    exit 0
}

# Parse command-line arguments
INTERACTIVE=false
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_usage
elif [ "$1" == "-i" ] || [ "$1" == "--interactive" ]; then
    INTERACTIVE=true
fi

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

read -p "What will be your new branch name (ie. partner_name-pub): " branch_name
echo
git switch -c $branch_name
echo

# Add the sub-module
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
git commit -m "Added submodule for $new_quicstart_name quickstart"
echo
git push -u origin $branch_name
echo

echo "Done! Now you can submit a PR to merge your updated submodules to the official repo from your $branch_name branch."
