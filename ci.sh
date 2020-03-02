#! /usr/bin/env sh
​
userName=armanaaquib
repoName=ci-cd
​
touch lastCommitSha.txt

while :
do
  curl -H "Authorization: token OAUTH-TOKEN" https://api.github.com/repos/$userName/$repoName/commits/master > latestCommit.txt

  latestCommitSha=$(cat latestCommit.txt | grep sha | head -1 | cut -d\" -f4)
  latestCommitterName=$(cat latestCommit.txt | grep login | head -1 | cut -d\" -f4)
  lastCommitSha=$(cat lastCommitSha.txt)
​
  if [ "$latestCommitSha" != "$lastCommitSha" ]
  then
    cd ../$repoName
    git pull
    npm install
    npm test
    if [ $? -ne 0 ]
    then
      cd ../ci-cd
      echo "tests are failing"
      sed -e 's/__status-color__/red/g' -e s/__committer-name__/$latestCommitterName/g -e s/__commit-sha__/$latestCommitSha/g -e 's/__status__/failing/g' template.html > ci.html
    else
      cd ../ci-cd
      echo "tests are passing"
      sed -e 's/__status-color__/green/g' -e s/__committer-name__/$latestCommitterName/g -e s/__commit-sha__/$latestCommitSha/g -e 's/__status__/passing/g' template.html > ci.html
      echo $latestCommitSha > lastCommitSha.txt
    fi
  else
    echo "no latest commit"
  fi
  rm latestCommit.txt
  sleep 1s
done