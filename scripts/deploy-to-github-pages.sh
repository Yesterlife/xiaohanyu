#!/bin/bash

set -o errexit
rm -rf output

# install the latest pandoc
sudo apt-get update && sudo apt-get -y install jq
# Get the latest .deb released.
wget `curl https://api.github.com/repos/jgm/pandoc/releases/latest | jq -r '.assets[] | .browser_download_url | select(endswith("deb"))'` -O pandoc.deb
sudo dpkg -i pandoc.deb

# config
git config --global user.email "xiaohanyu1988@gmail.com"
git config --global user.name "Xiao Hanyu"

# build
bundle install

git_rev=$(git rev-parse HEAD)

git clone https://github.com/${GITHUB_PAGES_REPO}.git output
cd output
git checkout master

cd ..
bundle exec nanoc compile

cd output

# deploy
if [ -z "$(git status --porcelain)" ]; then
    echo "There are no changes, exit with 0";
    exit 0;
else
    git add .
    git commit -F- <<EOF
Auto deployed by travis-ci.

Projects used for this deployment:
- https://github.com/xiaohanyu/xiaohanyu.github.io/commit/${git_rev}
EOF

    git push -f "https://${GITHUB_TOKEN}@github.com/${GITHUB_PAGES_REPO}.git" master:master
fi
