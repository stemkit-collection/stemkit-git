# Workspace facility with convenient Git customization

This facility makes it possible to create a local git repository for working
with multiple branches, possibly tracking multiple remote repositories. You
will have all branches checked out at the same time, everyone in a dedicated
folder. No more constant `git checkout ...` to switch between branches, just
`cd`-ing into a branch directory will do the job.

You do not even have to remember the exact path to a branch directory. With
just a branch name you may use provided utilities and shell customization
snippets to quickly move between all branches you may have.

It is based on the great `git worktree ...` feature, hiding from you all
percieved complexity people sometimes complain about when first getting
to know it.

This also comes with a set of customizations in the form of Git aliases and
a small number of shell utilities. And all you need is to include a path to
provided config file into your `~/.gitconfig`. Additionally, you may inclue
the facility's script folder into your `PATH` variable for even more value.

First thing first, let's create a workspace. All the examples here assume
that folder `~/projects` exists, otherwise please create it manually or use
another location for your local repository before trying the commands below.

### Quick workspace creation

To create a workspace in `~/projects/workspace`, use the following commands
that would invoke the workspace creation script directly from GitHub:

    SPOT=https://raw.github.com/stemkit-collection/stemkit-git/master/scripts
    curl -sL "${SPOT}/make-workspace" | sh -s -- -f ~/projects/workspace

Or for easier copy-paste:

> `echo https://raw.github.com/stemkit-collection/stemkit-git | xargs -I% curl
> -sL %/master/scripts/make-workspace | sh -s -- -f ~/projects/workspace`

> > ##### _NOTE_: To simply print what commands would be executed without actually executing them, please omit option `-f` from the command line above.

This command will create a local Git repository in the specified folder with
one remote named `remote-gh-stm-git` referencing repository
`https://github.com/stemkit-collection/stemkit-git.git`. This repository
area will have a single branch named `workspace` tracking remote branch
`remote-gh-stm-git/master`. This is amost equivalent to what command
`git clone -o remote-gh-stm-git ...` would do, the only difference
being the local branch called `workspace` instead of `master`.

> ##### _FYI_: You may pick any other folder name for the locaiton of your repository instead of `~/projects/workspace`, the main branch will still be named `workspace` (you may rename it later if desired)

The last step in setup is to modify your `~/.gitconfig` file to make your Git
aware of the features provided by this facility (unless you've already done it
for another workspace).

The easiest way to achieve this would be to issue the following command:

    git config --global --add include.path projects/workspace/config/dot-gitconfig

You are done! To make sure that everything works as expected please run the
following command and observe its output:

    $ git check-stm-master && echo SUCCESS
    Master workspace: <your-home-folder>/projects/workspace
    SUCCESS

Any other outcome would mean that something went wrong, in which case please
check the troubleshooting section (when available) or contact the author.
