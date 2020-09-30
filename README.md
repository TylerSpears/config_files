# Configuration Files

Repository for my commonly-used configuration files, including dotfiles, 
(non-sensitive) system files, configurations, and more.

## Installation

Requirements:
* unix shell (only tested on bash)
* root privileges
* git
* python3
* pip3

To install:

```bash
mkdir ~/dotfiles
git clone --recurse-submodules -j2 \
    https://github.com/TylerSpears/config_files.git ~/dotfiles
cd ~/dotfiles
/usr/bin/pip3 install -r dotdrop/requirements.txt --user
./dotdrop/bootstrap.sh
# for now, installation requires an env var
# DOTDROP_PROFILE to be set to 'debian'
DOTDROP_PROFILE=debian ./dotdrop.sh install
```

## Special Thanks

These configurations were largely taken from or based on the work of others,
and I will do my best to give credit where credit is due. So, special thanks
to:

* [dotdrop](https://github.com/deadc0de6/dotdrop)
* [direnv](https://direnv.net/)
* [jrnl](https://github.com/jrnl-org/jrnl) 

bash:
* <https://unix.stackexchange.com/a/36874>
* <https://unix.stackexchange.com/a/541352>
* <https://serverfault.com/a/204320> and <http://psung.blogspot.com/2008/05/copying-directory-trees-with-rsync.html>
for `copydirstruct` rsync trick.

konsole:
* <https://superuser.com/a/1292459/764678> for instructions on setting up Ctrl+Backspace
in Konsole

conda:
* <https://gist.github.com/ocefpaf/863fc5df6ed8444378fbb1211ad8feb1>
* <https://www.anaconda.com/understanding-and-improving-condas-performance/>
* <https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-channels.html>

git:
* <https://github.com/so-fancy/diff-so-fancy>
* <https://github.com/alexkaratarakis/gitattributes>
* <https://www.davidlaing.com/2012/09/19/customise-your-gitattributes-to-become-a-git-ninja/>
* <https://github.com/github/gitignore>
* <https://gist.github.com/octocat/9257657>
* <https://dev.to/michi/handy-git-aliases-5ag3>
* <https://stackoverflow.com/a/18782415>
* <https://github.com/direnv/direnv/wiki/Git>

vim:
* <https://github.com/nickjj/dotfiles/blob/master/.vimrc>
* <https://github.com/plasticboy/vim-markdown#syntax-extensions>
* <http://ethanschoonover.com/solarized>
* <https://vim.fandom.com/wiki/All_folds_open_when_opening_a_file>

tmux:
* <https://github.com/tmux-plugins/tpm>
* <https://github.com/tmux-plugins/tmux-sensible>
* <https://github.com/tmux-plugins/tmux-prefix-highlight>
* <https://github.com/tmux-plugins/tmux-pain-control>
* <https://github.com/tmux-plugins/tmux-copycat>
* <https://github.com/tmux-plugins/tmux-yank>
* <https://github.com/tmux-plugins/vim-tmux-focus-events>
* <https://github.com/roxma/vim-tmux-clipboard>
* <https://www.hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/>
* <https://unix.stackexchange.com/a/320496>

direnv:
* <https://dreisbach.us/articles/a-favorite-development-tool-direnv/>
* <https://github.com/direnv/direnv/issues/73>
* <https://github.com/direnv/direnv/wiki/Python#anaconda>

python:
* <https://ljvmiranda921.github.io/notebook/2018/06/21/precommits-using-black-and-flake8/>
for `pyproject.toml` and `.flake8` config files.

