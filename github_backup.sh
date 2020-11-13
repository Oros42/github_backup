#!/bin/bash
# author Oros
# version 20201113
#
# Clone github's repositories before takedown by DMCA
#

log_file="$(pwd)/repo_list.txt"
limite_date=`date +"%Y%m%d" -d "3 days ago"`
backup_repositories="$(pwd)/repositories/"
dmca_dir="$(pwd)/dmca"
function find_and_clone_repo()
{
	pwd
	if [[ ! -f $log_file ]]; then
		echo "" > $log_file
	fi
    cd $dmca_dir
	for file in $(find -name "*.md")
	do
		# No need to clone old repositories who are allready unavailable
        cd $dmca_dir
        file_name=$(basename $file)
		if [[ "${file:0:4}" == "./20" && "$limite_date" -lt `date +"%Y%m%d" -d ${file_name:0:10}` ]]; then
			for repo in `sed "s#github\.com#\ngithub\.com#g" $file |grep -Eo "(github.com\/[a-zA-Z0-9\_\-]*\/[a-zA-Z0-9\_\.\-]*[a-zA-Z0-9\_\-])"`
			do 
				if [[ `grep "https://$repo.git" $log_file` == "" ]]; then
					echo "$file -> https://$repo.git"
					p=`wget -q https://$repo.git -O -`
					if [[ "$p" != "" ]]; then
						p=`echo "$p" |  grep "Repository unavailable due to DMCA takedown."`
						if [[ "$p" == "" ]]; then
							user=`echo $repo | grep -Eo "github.com\/[a-zA-Z0-9\_\-]*\/"`
							user=${user:11:-1}
							mkdir -p $backup_repositories$user
							cd $backup_repositories$user
							git clone https://$repo.git
							echo "$file -> https://$repo.git" >> $log_file
						fi
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
