#!/bin/bash
# author Oros
# version 20141018
#
# Clone github's repositories before takedown by DMCA
#
log_file="repo_list.txt"
limite_date=`date +"%Y%m%d" -d "2 days ago"`
backup_repositories="./repositories/"

function find_and_clone_repo()
{
	pwd
	if [[ ! -f $log_file ]]; then
		echo "" > $log_file
	fi
	for file in dmca/20*.md
	do
		# No need to clone old repositories who are allready unavailable
		if [[ "$limite_date" -lt `date +"%Y%m%d" -d ${file:5:10}` ]]; then
			for repo in `sed "s#github\.com#\ngithub\.com#g" $file |grep -Eo "(github.com\/[a-zA-Z0-9\_\-]*\/[a-zA-Z0-9\_\.\-]*[a-zA-Z0-9\_\-])"`
			do 
				if [[ `grep "https://$repo.git" $log_file` == "" ]]; then
					echo "$file -> https://$repo.git"
					p=`wget -q https://$repo.git -O - | grep "Repository unavailable due to DMCA takedown."`
					echo "$p"
					if [[ "$p" == "" ]]; then
						user=`echo $repo | grep -Eo "github.com\/[a-zA-Z0-9\_\-]*\/"`
						user=${user:11:-1}
						mkdir -p $backup_repositories$user
						cd $backup_repositories$user
						git clone https://$repo.git
						cd ../..
						echo "$file -> https://$repo.git" >> $log_file
					fi
				fi
			done
		fi
	done
}

if [[ ! -d "dmca" ]]; then
	git clone https://github.com/github/dmca.git
	find_and_clone_repo
else
	a=`cd dmca && git pull`
	if [[ "$a" != "Already up-to-date. " ]]; then
		echo "New DMCA"
		find_and_clone_repo
	else
		echo "No new DMCA"
	fi
fi
