```
 ____        _   _____ _ _          
|  _ \  ___ | |_|  ___(_| | ___ ___ 
| | | |/ _ \| __| |_  | | |/ _ / __|
| |_| | (_) | |_|  _| | | |  __\__ \
|____/ \___/ \__|_|   |_|_|\___|___/
```

<!-- Waffle! -->
<!-- {{{1 -->
[![GitHub license](https://img.shields.io/github/license/jimcornmell/dotfiles)](https://github.com/jimcornmell/dotfiles/blob/master/LICENSE)
[![Open Source? Yes!](https://badgen.net/badge/Open%20Source%20%3F/Yes%21/blue?icon=github)](https://github.com/jimcornmell/dotfiles)
<!-- }}}1 -->

<!-- Intro -->
<!-- {{{1 -->

Here is my Linux command line setup.  I have various tools which are setup and
ready to use.  Feel fee to plagiarize my configuration (I have!).

![LunarVim](./media/demoScreen.png)

<!-- }}}1 -->

# Zsh, oh-my-zsh and Powerlevel 10k
<!-- {{{1 -->

I use zsh and most of my configuration is in [`.zshrc`](https://github.com/jimcornmell/dotfiles/blob/main/.zshrc).

Like many others I tailor the look and feel of zsh
using [Oh My Zsh](https://ohmyz.sh), also using
[Powerlevel10k](https://github.com/romkatv/powerlevel10k).

<!-- }}}1 -->

# Editor Neovim/LunarVim
<!-- {{{1 -->

See my fork of [LunarVim](https://github.com/jimcornmell/LunarVim)
which is based on the brilliant
[LunarVim](https://github.com/ChristianChiarulli/LunarVim)

<!-- }}}1 -->

# Theming - Zenburn
<!-- {{{1 -->

I've used [Zenburn](https://github.com/jnurmine/Zenburn) for years now. One of
the reasons I like it, is that it has been ported to most tools that support
theming. So in the list that follows I've setup zenburn to be the theme used.

<!-- }}}1 -->

# Tools
<!-- {{{1 -->

Name                 | Description
-------------------- | -------------------------------------
Kitty                | Command terminal, very powerful and configurable.
Terminal Multiplexer | I used tmux for a while but when I moved over to kitty this became redundant.
Ranger               | File browser.
Bat                  | Cat with wings!
prettyping           | Ping but nicer!
ncdu                 | Disc usage, but nice!
Exa                  | ls on steroids

<!-- }}}1 -->

# Key bindings
<!-- {{{1 -->

Key                  | Action
-------------------- | ---------------------------------------------------------------------------------------
`<Shift+F1>`         | Toggle highlighting in Red of error, fatal, failed and exception.
`<Shift+F2>`         | Toggle highlighting in Orange or warn and warning.
`<Shift+F3>`         | Toggle highlighting in Green of info and information.
`<Shift+F4>`         | All 3 groups above are highlighted.
`<Alt+\>`            | Split the terminal vertically.
`<Alt+->`            | Split the terminal horizontally.
`<F5>`               | Open file under cursor, e.g. if any command outputs a file name, point at it in the terminal and hit `<F5>`.
`<F10>`              | Open a new terminal in a tab below.
`<Ctrl+Shift+Left>`  | Move to left terminal tab.
`<Ctrl+Shift+Right>` | Move to right terminal tab.

<!-- }}}1 -->
