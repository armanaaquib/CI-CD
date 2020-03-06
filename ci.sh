#! /usr/bin/env sh
echo 'Enter User-Name:'
read userName
echo 'Enter Repo-Name:'
read repoName

lastCommitSha=none

updateDisplayPage(){
  sed -e "s/__repo-name__/$repoName/g" -e "s/__status-color__/$1/g" -e "s/__committer-name__/$2/g" -e "s/__commit-sha__/$3/g" -e "s/__status__/$4/g" template.html > ci.html
}

updateDisplayPage yellow "loading..." "loading..." "starting ci"
open ci.html

oauthToken=$(cat OAUTH-TOKEN.txt)
while :
do
  curl -H "Authorization: token $oauthToken" https://api.github.com/repos/$userName/$repoName/commits/master > latestCommit.txt

  latestCommitSha=$(cat latestCommit.txt | grep sha | head -1 | cut -d\" -f4)
  latestCommitterName=$(cat latestCommit.txt | grep name | head -1 | cut -d\" -f4)

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
      updateDisplayPage red "$latestCommitterName" "$latestCommitSha" "tests are failing"
    else
      cd ..
      echo "tests are passing"
      updateDisplayPage "rgb(21, 216, 21)" "$latestCommitterName" "$latestCommitSha" "tests are passing"
      lastCommitSha=$(echo $latestCommitSha)
    fi
    rm -rf $repoName
  else
    echo "no latest commit"
  fi
  rm latestCommit.txt
  sleep 30s
done