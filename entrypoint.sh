#!/bin/bash

echo "Container Started"

# Format YYYY.M.Increment

# Configuration
default_bump=${DEFAULT_BUMP:-increment}
default_branch=${DEFAULT_BRANCH:-$GITHUB_BASE_REF}
calver_string_token=${CALVER_STRING_TOKEN:-#calver}
source=${SOURCE:-.}
calver_date_format=${CALVER_DATE_FORMAT:-%Y.%m.%d}
branch_history=${BRANCH_HISTORY:-compare}
initial_increment=${INITIAL_INCREMENT:-0}
release_branches=${CALVER_BRANCHES:-master,main,release}
custom_tag=${CUSTOM_TAG:-}

git config --global --add safe.directory /github/workspace

echo "*** CONFIGURATION ***"
echo -e "\tDEFAULT_BUMP: ${default_bump}"
echo -e "\tDEFAULT_BRANCH: ${default_branch}"
echo -e "\tCALVER_STRING_TOKEN: ${calver_string_token}"
echo -e "\tSOURCE: ${source}"
echo -e "\tCALVER_DATE_FORMAT: ${calver_date_format}"
echo -e "\tBRANCH_HISTORY: ${branch_history}"
echo -e "\INITIAL_INCREMENT: ${initial_increment}"
echo -e "\tCALVER_BRANCHES: ${release_branches}"
echo -e "\tCUSTOM_TAG: ${custom_tag}"

setOutput() {
  echo "${1}=${2}" >>"${GITHUB_OUTPUT}"
}

if [ "$commit_hash_for_tag" == "$latest_commit_hash" ]; then
  echo "Skipped since no new commits"
  setOutput "new_tag" "$old_tag"
  exit 0
fi


# Get current year (eg. 2023)
current_year=$(date -u +%Y)

# Get current month (eg. 5)
current_month=$(date -u +%-m)

# Gets name of current branch
#current_branch=$(git rev-parse --abbrev-ref HEAD)

# Get the latest tags from remote
git fetch --tags
git_refs=$(git for-each-ref --sort=-v:refname --format '%(refname:lstrip=2)')
#git_refs=$(git tag --list --merged HEAD --sort=-committerdate)

# Skip tagging if commit message starts with 'skip:'
last_commit_message="$(git show -s --format=%B)"
if [[ "$last_commit_message" == "skip:"* ]]; then
  echo "Skipped due to commit message"
  setOutput "new_tag" "$old_tag"
  exit 0
fi

# calver_format 20<any 2 digit number>.<number from 1 to 12 inclusive>.<any number of any length>
calver_format="^20\d{2}\.(0?[1-9]|1[0-2])\.\d+$"

# Get a matching tag
matching_tag_refs=$( (grep -E "$calver_format" <<<"$git_refs") || true)
old_tag=$(head -n 1 <<<"$matching_tag_refs")

# exit script if there are no new commits
commit_hash_for_tag=$(git rev-list -n 1 "$old_tag" || true)
latest_commit_hash=$(git rev-parse HEAD)
if [ "$commit_hash_for_tag" == "$latest_commit_hash" ]; then
  echo "Skipped since no new commits"
  setOutput "new_tag" "$old_tag"
  exit 0
fi

# If no previous tag found, use initial version
if [ -z "$old_tag" ]; then
  # if tag not found, create it
  new_tag="$current_year.$current_month.$initial_increment"
else
  # if tag is found then do the checks
  # extract its components
  IFS='.' read -ra tag_components <<<"$old_tag"
  #  check there are the correct number of parts to the tag
  if [ ${#tag_components[@]} -eq 3 ]; then
    old_tag_year="${tag_components[0]}"
    old_tag_month="${tag_components[1]}"
    old_tag_increment="${tag_components[2]}"

    new_year=$current_year
    new_month=$current_month

    if [ "$old_tag_month" -ne "$current_month" ] || [ "$old_tag_year" -ne "$current_year" ]; then
      # since the month/year has changed, the increment is reset
      new_increment=0
    else
      new_increment=$((old_tag_increment + 1))
    fi

    new_tag="$current_year.$current_month.$new_increment"

    setOutput "new_tag" "$new_tag"

  fi
fi

# Tag locally
git tag -f "$new_tag" || exit 1

# User the git API to push tag
date_time=$(date '+%Y-%m-%dT%H:%M:%SZ')
github_repo_name=$GITHUB_REPOSITORY
git_refs_url=$(jq .repository.git_refs_url "$GITHUB_EVENT_PATH" | tr -d '"' | sed 's/{\/sha}//g')

echo "$date_time: NEW TAG: $new_tag -> REPO: $github_repo_name"

push_tag_response=$(
  curl -s -X POST "$git_refs_url" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -d @- <<EOF
{
    "ref": "refs/tags/$new_tag",
    "sha": "$latest_commit_hash"
}
EOF
)

git_ref_posted=$(echo "${push_tag_response}" | jq .ref | tr -d '"')

if [ "${git_ref_posted}" = "refs/tags/${new_tag}" ]; then
  exit 0
else
  echo "Error Tagging"
  exit 1
fi
#Also can use CLI to push but disabled for now
#else
#git push -f origin "new_tag" || exit 1
