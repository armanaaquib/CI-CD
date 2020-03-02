#! /usr/bin/env sh
​
userName=step-batch-7
repoName=softwareSamurai-settlers
​
lastCommitSha=""

while :
do
  curl -H "Authorization: token ebb34770dd011e4d3e8a2c6155ccf5ea3cbf35ea" https://api.github.com/repos/$userName/$repoName/commits/master > latestCommit.txt

  latestCommitSha=$(cat latestCommit.txt | grep sha | head -1 | cut -d\" -f4)
  latestCommitterName=$(cat latestCommit.txt | grep login | head -1 | cut -d\" -f4)
​
  if [ "$latestCommitSha" != "$lastCommitSha" ]
  then
    cd ../$repoName
    git pull
    npm install
    npm test
    if [ $? -ne 0 ]
    then
      cd ../CI-Tool
      echo "tests are failing"
      sed -e 's/__status-color__/red/g' -e s/__committer-name__/$latestCommitterName/g -e s/__commit-sha__/$latestCommitSha/g -e 's/__status__/failing/g' template.html > ci.html
    else
      cd ../CI-Tool
      echo "tests are passing"
      sed -e 's/__status-color__/green/g' -e s/__committer-name__/$latestCommitterName/g -e s/__commit-sha__/$latestCommitSha/g -e 's/__status__/passing/g' template.html > ci.html
      lastCommitSha=$(echo $latestCommitSha)
    fi
  else
    echo "no latest commit"
  fi
  rm latestCommit.txt
  sleep 1s
done