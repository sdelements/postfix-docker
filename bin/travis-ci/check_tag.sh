#!/bin/bash
#
# Copyright (c) 2018 SD Elements Inc.
#
#  All Rights Reserved.
#
# NOTICE:  All information contained herein is, and remains
# the property of SD Elements Incorporated and its suppliers,
# if any.  The intellectual and technical concepts contained
# herein are proprietary to SD Elements Incorporated
# and its suppliers and may be covered by U.S., Canadian and other Patents,
# patents in process, and are protected by trade secret or copyright law.
# Dissemination of this information or reproduction of this material
# is strictly forbidden unless prior written permission is obtained
# from SD Elements Inc..
# Version

set -eo pipefail

echo "Installing shtdlib"
shtdlib_local_path="/usr/local/bin/shtdlib.sh"
sudo curl -s -L -o "${shtdlib_local_path}" https://github.com/sdelements/shtdlib/raw/master/shtdlib.sh
sudo chmod 775 "${shtdlib_local_path}"
# shellcheck disable=SC1091,SC1090
source "${shtdlib_local_path}"
color_echo green "shtdlib.sh installed successfully"

version_pattern='v\d+\.\d+\.\d+(?:qa)?'
version_pattern_line="^${version_pattern}$"

# Get the latest tag from GitHub
latest_tag="$(git fetch -t && git tag -l | sort --version-sort | tail -n1)"
color_echo green "Latest Git tag from repo: '${latest_tag}'"

# Get the latest tag from the CHANGELOG
changelog_ver="$(grep -oP "\[${version_pattern}\]" CHANGELOG.md | tr -d '[]' | sort --version-sort -r | head -n1)"
color_echo green "CHANGELOG version: '${changelog_ver}'"

# Validate version strings
echo "${latest_tag}" | grep -qP "${version_pattern_line}" || ( color_echo red "Invalid tag from repo: '${latest_tag}'" && exit 1 )
echo "${changelog_ver}" | grep -qP "${version_pattern_line}" || ( color_echo red "Invalid tag from CHANGELOG: '${changelog_ver}'" && exit 1 )

# Check if a tag triggered the build
if [[ -z "${TRAVIS_TAG}" ]]; then
    # Ensure tags in CHANGELOG and iteration are greater than highest repo tag
    if [ "${latest_tag}" = "${changelog_ver}" ] \
       || ! compare_versions "${latest_tag}" "${changelog_ver}"; then
        color_echo red "Error: Incorrect version update. CHANGELOG.md (${changelog_ver}) not updated"
        exit 1
    else
        color_echo green "Version bumps PASS!"
    fi
else
    color_echo green "Newly created tag: '${TRAVIS_TAG}'"
    # Validate version strings
    echo "${TRAVIS_TAG}" | grep -qP "${version_pattern_line}" || ( color_echo red "Invalid tag name created: '${TRAVIS_TAG}'" && exit 1 )

    # Ensure all the tags match up
    if [ ! "${TRAVIS_TAG}" = "${changelog_ver}" ]; then
        color_echo red "Error: tag version (${TRAVIS_TAG}) should match CHANGELOG.md (${changelog_ver})"
        exit 1
    else
        color_echo green "Version bumps PASS!"
    fi
fi
