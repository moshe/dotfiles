#!/bin/bash
cd $2
if [[ $1 == "added" ]]; then
    ADDED=$(git ls-files --other --exclude-standard|wc -l | bc)
    if [[ ! -z $(git ls-files --other --exclude-standard) ]]; then
        echo "+ "
    fi
elif [[ $1 == "modified" ]]; then
    if [[ ! -z $(git diff --name-only --diff-filter=M) ]]; then
        echo "M "
    fi
elif [[ $1 == "deleted" ]]; then
    if [[ ! -z $(git ls-files --deleted) ]]; then
        echo "D "
    fi
elif [[ $1 == "staged" ]]; then
    if [[ ! -z $(git diff --cached --name-only) ]]; then
        echo "^ "
    fi
elif [[ $1 == "branch" ]]; then
    git rev-parse --abbrev-ref HEAD | sed -e "s/AMVP-\([0-9]*\)//g" -e "s/_/ /g" -e "s/moshe.//" -e "s/-feature//" -e "s/-/ /g" -e 's/^\.//g'
fi
