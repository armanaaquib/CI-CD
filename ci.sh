#! /usr/bin/env sh
echo 'Enter User-Name:'
read userName
echo 'Enter Repo-Name:'
read repoName

lastCommitSha=none

updateDisplayPage(){
  sed -e "s/__repo-name__/$repoName/g" -e "s/__status-color__/$1/g" -e "s/__committer-name__/$2/g" -e "s/__commit-msg__/$3/g" -e "s/__commit-sha__/$4/g" -e "s/__status__/$5/g" template.html > ci.html
}

updateDisplayPage yellow "loading..." "loading..." "loading..." "starting ci"
open ci.html

oauthToken=$(cat OAUTH-TOKEN.txt)
while :
do
  curl -H "Authorization: token $oauthToken" https://api.github.com/repos/$userName/$repoName/commits/master > latestCommit.json

  latestCommitSha=$(node -p 'require("./latestCommit.json").sha;')
  latestCommitterName=$(node -p 'require("./latestCommit.json").commit.committer.name;')
  latestCommitMsg=$(node -p 'require("./latestCommit.json").commit.message.replace(/\|/g,"\\|").replace(/\//g,"\\/");')

  if [ "$latestCommitSha" != "$lastCommitSha" ]
  then
    git clone https://github.com/$userName/$repoName.git
    cd $repoName
    npm install
    npm test
    if [ $? -ne 0 ]
    then
      cd ..
      echo "tests are failing"
      updateDisplayPage red "$latestCommitterName" "$latestCommitMsg" "$latestCommitSha" "tests are failing"
    else
      cd ..
      echo "tests are passing"
      updateDisplayPage "rgb(21, 216, 21)" "$latestCommitterName" "$latestCommitMsg" "$latestCommitSha" "tests are passing"
      lastCommitSha=$(echo $latestCommitSha)
    fi
    rm -rf $repoName
  else
    echo "no latest commit"
  fi
  rm latestCommit.json
  sleep 30s
done