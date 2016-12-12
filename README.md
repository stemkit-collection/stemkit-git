# Workspaces

This branch is convenient for managing multiple Git work trees (workspaces) in
subfolders. Using work trees makes it possible to work simultaneously with
different product branches checking them out in dedictated subfolders.

## Using the branch

To have multiple workspaces in subfolders, create local branch `workspaces`
tracking remote `users/bystrg/workspaces` and check it out:

    $ git checkout -b workspaces origin/users/bystrg/workspaces

> **Note**: *The above command assumes a remote named `origin`. Use the name of your own remote if different.*

This will be your top level branch. For other branches you will be creating
separate workspaces in subfolders using `git worktree` command. Those
workspaces have their own current branch notion, so just changing current
directory to a particular subfolder will allow you to work with a branch
independent from other areas.

It is beneficial to name subfolders after branches so that it is easy to
remember which one is for what branch. Also it may come in handy to have a
second level subfolder, like `src`. This way you may have untracked files
and folders (generaged compilation artifacts, temporary files, etc.) so that
they do not polute your workspace.

### Making work trees for existing local branches

Let's start with `master`. The obvious choice for a corresponding subfolder
name would be `master/src`. The following command will do the job:

    $ git worktree add master/src master

This will create work tree folder `master/src` and make branch `master`
current for that area.

Now suppose your have branch `feature/john/better-networking`. The subfolder
name might be just `better-networking`. Let's run:

    $ git worktree add better-networking/src feature/john/better-networking

This will create work tree folder `better-networking/src` and make brnach
`feature/john/better-networking` current for that area.

### Making work trees for new local branches

In cases you do not yet have local branches for your remote ones you want to
track or you want to create a new branch off an existing one, one invocation
of `git worktree add` command will help you to both create the branch and
make a worktree subfolder for it.

Suppose we have the following remote branches for user *john*:

    $ git branch --remotes --list '*john*'
      origin/feature/john/better-networking
      origin/feature/john/performance

However branch `feature/john/performance` is not yet locally tracked:

    $ git branch --list "*john*"
      feature/john/better-networking

To create new local branch `feature/john/performance` and make a work tree in
subfolder `performance/src` for it, just issue the following command:

    $ git worktree add -b feature/john/performance performance/src origin/feature/john/performance

> Note that if the last parameter in the above command happens to be a local branch
> name or a commit object, the command will create a branch specified for option
> `-b`, however no remote tracking will be established and you will have to do
> it manually as you normally do when you first push a branch.

### Example

You can see your work trees with git command `git worktree list`. All of this
can be demonstrated by the following shell session.

Look at our top level workspace:

    $ pwd
    /Users/john/projects/emc/ecdm/lennon/server
    $ ls -aCF
    ./                      .git/                   README.md               master/
    ../                     .gitignore              better-networking/      performance/

    $ git branch -vv
      feature/john/better-networking e4b7a83 [origin/feature/john/better-networking] 264707: Merged Ramone change //IDP/main/...@=690935
      feature/john/performance       e4b7a83 [origin/feature/john/performance] 264707: Merged Ramone change //IDP/main/...@=690935
      master                         08f1863 [origin/master] Merge pull request #491 in ECDM/ecdm from liangs2/ecdm to master
    * workspaces                     b14488a [origin/users/bystrg/workspaces] Updated instructions.

Here're our work trees:

    $ git worktree list
    /Users/john/projects/emc/ecdm/lennon/server                        b14488a [workspaces]
    /Users/john/projects/emc/ecdm/lennon/server/master/src             08f1863 [master]
    /Users/john/projects/emc/ecdm/lennon/server/better-networking/src  e4b7a83 [feature/john/better-networking]
    /Users/john/projects/emc/ecdm/lennon/server/performance/src        e4b7a83 [feature/john/performance]

Changing current directory to master work tree, making sure curren branch is
`master`:

    $ cd master/src
    $ git branch
      feature/john/better-networking
      feature/john/performance
    * master
      workspaces

Now switching to better networking subfolder to see the current branch is
`feature/john/better-networking`:

    $ cd ../../better-networking/src
    $ git branch
    * feature/john/better-networking
      feature/john/performance
      master
      workspaces

And now back to the top, where current branch is still `workspaces`:

    $ cd ../../
    $ git branch
      feature/john/better-networking
      feature/john/performance
      master
    * workspaces
    $

> ## Please notice that those git branch changes were without `git checkout`, just via simple current directory change.

## Related Git commands

`git worktree add`
  > Adds a folder for a work tree and associates it with a branch

`git worktree list`
  > Lists details about availabe work trees

`git worktree prune`
  > Cleans up the work tree list after a folder removal

## Limitations

Git sets up work trees with absolute path info in their config files. This
makes it more difficult to rename or move local Git repositories. After move
you need to prune and recreate worktrees.
