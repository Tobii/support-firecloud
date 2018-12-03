# Bootstrap

## Generate an SSH Key & add it to your Github account
Repositories are by default accessed via SSH so you need to set up an SSH key and add it to your github account:

- [Generate a new SSH Key and Add it to the ssh-agent](https://help.github.com/enterprise/2.15/user/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
- [Add the new SSH key to your Github account](https://help.github.com/enterprise/2.15/user/articles/adding-a-new-ssh-key-to-your-github-account/)


## `git`

We assume that you keep all firecloud-related `git` repositories under `~/git/firecloud`.

*Failing to do so, hell won't break loose, but you are on your own.
As long as you store the firecloud-related `git` repositories in one folder e.g. `~/Documents/Firecloud`,
you can easily create a symlink `ln -s ~/Documents/Firecloud ~/git/firecloud` and keep everyone happy.*


```shell
cd # make sure that you are at home dir (~)
git clone git@github.com:tobiipro/support-firecloud.git ~/git/firecloud/support-firecloud
ln -s {~/git/firecloud/support-firecloud/generic/dot,}.gitignore_global
ln -s {~/git/firecloud/support-firecloud/generic/dot,}.gitattributes_global
```

If you have `git` 2.13+ and you'd like to restrict the `git` config to firecloud-related repos,
in your `~/.gitconfig` prepend AT THE TOP

```
[includeIf "gitdir:~/git/firecloud/"]
    path = ~/git/firecloud/support-firecloud/generic/dot.gitconfig
```

Alternatively, either for earlier `git` versions or if you'd like to use the `git` config globally,
in your `~/.gitconfig` prepend AT THE TOP

```
[include]
    path = ~/git/firecloud/support-firecloud/generic/dot.gitconfig
```

## System

We support Darwin (OSX) and Linux (Ubuntu) architectures.
The former is the development architecture, while the latter is the CI/CD architecture.

**NOTE** In order to [simplify our ~scripts~ lives](https://ponderthebits.com/2017/01/know-your-tools-linux-gnu-vs-mac-bsd-command-line-utilities-grep-strings-sed-and-find/),
we expect GNU binaries (even on Darwin).

All system-wide dependencies can be installed by running

```shell
~/git/firecloud/support-firecloud/dev/darwin/bootstrap # for Darwin
# ~/git/firecloud/support-firecloud/dev/linux/bootstrap # for Linux
```

## Editor

Next, [bootstrap your editor](bootstrap-your-editor.md).
