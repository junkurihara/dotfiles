# dotfiles

![Test](https://github.com/jun/dotfiles_public/workflows/Test%20dotlink.sh/badge.svg)

My dot files for Linux and macOS

## dotlink.sh

A GNU Stow-style symlink installer for managing dotfiles.

### Features

- Package-based management
- Platform-specific support (macOS/Linux)
- Safe unlinking (only removes links created by this script)
- Empty directory cleanup option
- Dry-run mode
- Backup existing files

### Usage

```bash
# Link packages
./dotlink.sh zsh git nvim

# Unlink packages
./dotlink.sh --unlink zsh

# Unlink with empty directory cleanup
./dotlink.sh --unlink --cleanup-empty-dirs zsh

# Dry run
./dotlink.sh --dry-run nvim
```

### Testing

Run the test suite:

```bash
./test_dotlink.sh
```
