# host-banner

Prints the short hostname (`uname -n` up to the first dot) in block letters
between two full-width bars, with a red-to-purple gradient from left to right.
If the block letters don't fit the terminal, the name is printed as centered
plain text instead. Nothing is printed unless the output is a terminal.

Needs bash 3.2 or later and a UTF-8 terminal.

## Install

```bash
mkdir -p ~/.local/bin
install -m 755 host-banner.sh ~/.local/bin/host-banner.sh
```

Add to `~/.bash_profile`:

```bash
if [[ $- == *i* && -x ~/.local/bin/host-banner.sh ]]; then
    ~/.local/bin/host-banner.sh
fi
```

### Debian and Ubuntu

These normally have `~/.profile` and no `~/.bash_profile`. Creating
`~/.bash_profile` makes bash ignore `~/.profile`, so either start the new file
with:

```bash
[[ -f ~/.profile ]] && . ~/.profile
```

or leave `~/.bash_profile` out and add this to `~/.profile`:

```sh
case $- in
    *i*) [ -x ~/.local/bin/host-banner.sh ] && ~/.local/bin/host-banner.sh ;;
esac
```

## Color

The script uses 24-bit color if `COLORTERM` is `truecolor` or `24bit`, then 256
colors if the terminal supports them, then 16. SSH doesn't normally forward
`COLORTERM`, so remote logins usually get 256. To override, set this before the
hook:

```bash
export HOST_BANNER_COLOR=truecolor   # or 256, 16, none
```

`NO_COLOR=1` also turns color off.

## Uninstall

Remove the hook from your profile and delete `~/.local/bin/host-banner.sh`.
