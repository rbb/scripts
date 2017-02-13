#!/bin/sh

old_email=${1:-"incorrect@email"}

curr_email=`git config --get user.email`
curr_name=`git config --get user.name`

new_email=${2:-"$curr_email"}
new_name=${3:-"$curr_name"}


if [ "$old_email" = "-h" ]; then
   echo ""
   echo "usage: git-reauthor.sh -h"
   echo "       git-reauthor.sh -d"
   echo "       git-reauthor.sh user@email_host.com"
   echo ""
   echo "-h    This help message"
   echo "-d    Delete the original/refs/ branches"
   echo ""
   echo "This script will rename all commits authored by 'user@email_host.com', if either the"
   echo "author name, or author email address matches the string provided. Once the results"
   echo "have been verify (manually, with something like gitk --all), then run git-reauthor -d"
   echo "to delete of the origin/refs branches that are created"
   echo ""

   #
   # NOTE: Changing the authors changes the SHA1 of each commit changed! So, it 
   #       re-writes history. USE WITH CAUTION!
   #
elif [ "$old_email" != "-d" ]; then

   echo "new_email = $new_email"
   echo "new_name = $new_name"

   # From http://stackoverflow.com/questions/4981126/how-to-amend-several-commits-in-git-to-change-author
   git filter-branch --env-filter "if [ \"\$GIT_AUTHOR_EMAIL\" = \"$old_email\" ] || [ \"\$GIT_AUTHOR_NAME\" = \"$old_email\"]; then
      export GIT_AUTHOR_EMAIL=$new_email;
      export GIT_AUTHOR_NAME=\"$new_name\";
      export GIT_COMMITTER_EMAIL=\"\$GIT_AUTHOR_EMAIL\";
      export GIT_COMMITTER_NAME=\"\$GIT_AUTHOR_NAME\"; fi" -- --all 

   # From http://stackoverflow.com/questions/4981126/how-to-amend-several-commits-in-git-to-change-author
   #git rebase -i HEAD~19 -x "git commit --amend --author 'Russell Brinkmann<russell_brinkmann@trimble.com>' --no-edit"


   # From https://www.git-tower.com/learn/git/faq/change-author-name-email
   #$ git filter-branch --env-filter '
   #WRONG_EMAIL="wrong@example.com"
   #NEW_NAME="New Name Value"
   #NEW_EMAIL="correct@example.com"
   #
   #if [ "$GIT_COMMITTER_EMAIL" = "$WRONG_EMAIL" ]
   #then
   #    export GIT_COMMITTER_NAME="$NEW_NAME"
   #    export GIT_COMMITTER_EMAIL="$NEW_EMAIL"
   #fi
   #if [ "$GIT_AUTHOR_EMAIL" = "$WRONG_EMAIL" ]
   #then
   #    export GIT_AUTHOR_NAME="$NEW_NAME"
   #    export GIT_AUTHOR_EMAIL="$NEW_EMAIL"
   #fi
   #' --tag-name-filter cat -- --branches --tags


else
   # Once complete, the refs/original branch can be deleted:
   # http://stackoverflow.com/questions/7654822/remove-refs-original-heads-master-from-git-repo-after-filter-branch-tree-filte
   git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
fi
