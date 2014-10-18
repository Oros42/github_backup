github_backup
=============

Clone github's repositories found on https://github.com/github/dmca before takedown by DMCA.


Who to use ?
============

```
crontab -e
```

And put  
```
42 */6 * * * <path_to_github_backup>/github_backup.sh
```

Every 6 hours github_backup.sh will update dmca's local repository and backup new repositories found.
