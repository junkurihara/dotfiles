#!/usr/bin/env bash
# test_dotlink.sh - Test suite for dotlink.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTLINK="${SCRIPT_DIR}/dotlink.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${GREEN}[INFO]${NC} $*"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $*"
}

log_test() {
  echo -e "${YELLOW}[TEST]${NC} $*"
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="${3:-Assertion failed}"

  TESTS_RUN=$((TESTS_RUN + 1))
  if [ "$expected" = "$actual" ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_info "✓ $message"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_error "✗ $message"
    log_error "  Expected: $expected"
    log_error "  Actual:   $actual"
    return 1
  fi
}

assert_true() {
  local condition="$1"
  local message="${2:-Assertion failed}"

  TESTS_RUN=$((TESTS_RUN + 1))
  if eval "$condition"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_info "✓ $message"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_error "✗ $message"
    log_error "  Condition failed: $condition"
    return 1
  fi
}

assert_false() {
  local condition="$1"
  local message="${2:-Assertion failed}"

  TESTS_RUN=$((TESTS_RUN + 1))
  if ! eval "$condition"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_info "✓ $message"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_error "✗ $message"
    log_error "  Condition should have failed: $condition"
    return 1
  fi
}

# Setup test environment
setup_test_env() {
  TEST_DIR="$(mktemp -d)"
  REPO_DIR="${TEST_DIR}/repo"
  HOME_DIR="${TEST_DIR}/home"

  mkdir -p "$REPO_DIR" "$HOME_DIR"
  cp "$DOTLINK" "$REPO_DIR/dotlink.sh"
  chmod +x "$REPO_DIR/dotlink.sh"

  log_info "Test environment created at $TEST_DIR"
}

# Cleanup test environment
cleanup_test_env() {
  if [ -n "${TEST_DIR:-}" ] && [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
    log_info "Test environment cleaned up"
  fi
}

# Test 1: Basic linking
test_basic_linking() {
  log_test "Test 1: Basic linking"

  setup_test_env

  # Create test package
  mkdir -p "$REPO_DIR/testpkg/.config/test"
  echo "test content" > "$REPO_DIR/testpkg/.config/test/config.txt"

  # Run dotlink
  cd "$REPO_DIR"
  bash ./dotlink.sh --target "$HOME_DIR" testpkg

  # Verify
  assert_true "[ -L '$HOME_DIR/.config/test/config.txt' ]" "Symlink should be created"
  local expected_target="$REPO_DIR/testpkg/.config/test/config.txt"
  local actual_target="$(readlink "$HOME_DIR/.config/test/config.txt" || echo "")"
  assert_eq "$expected_target" "$actual_target" "Symlink should point to correct location"

  cleanup_test_env
}

# Test 2: Unlink without cleanup
test_unlink_without_cleanup() {
  log_test "Test 2: Unlink without cleanup"

  setup_test_env

  # Create and link
  mkdir -p "$REPO_DIR/testpkg/.config/test"
  echo "test content" > "$REPO_DIR/testpkg/.config/test/config.txt"
  cd "$REPO_DIR"
  bash ./dotlink.sh --target "$HOME_DIR" testpkg

  # Unlink
  bash ./dotlink.sh --unlink --target "$HOME_DIR" testpkg

  # Verify
  assert_false "[ -L '$HOME_DIR/.config/test/config.txt' ]" "Symlink should be removed"
  assert_true "[ -d '$HOME_DIR/.config/test' ]" "Empty directory should remain"
  assert_true "[ -d '$HOME_DIR/.config' ]" "Parent empty directory should remain"

  cleanup_test_env
}

# Test 3: Unlink with cleanup
test_unlink_with_cleanup() {
  log_test "Test 3: Unlink with cleanup"

  setup_test_env

  # Create and link
  mkdir -p "$REPO_DIR/testpkg/.config/test"
  echo "test content" > "$REPO_DIR/testpkg/.config/test/config.txt"
  cd "$REPO_DIR"
  bash ./dotlink.sh --target "$HOME_DIR" testpkg

  # Unlink with cleanup
  bash ./dotlink.sh --unlink --cleanup-empty-dirs --target "$HOME_DIR" testpkg

  # Verify
  assert_false "[ -L '$HOME_DIR/.config/test/config.txt' ]" "Symlink should be removed"
  assert_false "[ -d '$HOME_DIR/.config/test' ]" "Empty directory should be removed"
  assert_false "[ -d '$HOME_DIR/.config' ]" "Parent empty directory should be removed"
  assert_true "[ -d '$HOME_DIR' ]" "Target directory should remain"

  cleanup_test_env
}

# Test 4: Platform-specific packages
test_platform_specific() {
  log_test "Test 4: Platform-specific packages"

  setup_test_env

  # Determine platform
  case "$(uname -s)" in
    Darwin) PLATFORM="macos" ;;
    Linux) PLATFORM="linux" ;;
    *) log_error "Unsupported platform"; cleanup_test_env; return 1 ;;
  esac

  # Create base and platform-specific packages
  mkdir -p "$REPO_DIR/testpkg/.config"
  echo "base" > "$REPO_DIR/testpkg/.config/base.txt"

  mkdir -p "$REPO_DIR/testpkg-${PLATFORM}/.config"
  echo "platform" > "$REPO_DIR/testpkg-${PLATFORM}/.config/platform.txt"

  # Run dotlink
  cd "$REPO_DIR"
  bash ./dotlink.sh --target "$HOME_DIR" testpkg

  # Verify
  assert_true "[ -L '$HOME_DIR/.config/base.txt' ]" "Base package file should be linked"
  assert_true "[ -L '$HOME_DIR/.config/platform.txt' ]" "Platform-specific file should be linked"

  cleanup_test_env
}

# Test 5: Multiple files in nested directories
test_nested_directories() {
  log_test "Test 5: Multiple files in nested directories"

  setup_test_env

  # Create nested structure
  mkdir -p "$REPO_DIR/testpkg/.config/nvim/lua/plugins"
  echo "init" > "$REPO_DIR/testpkg/.config/nvim/init.lua"
  echo "plugin1" > "$REPO_DIR/testpkg/.config/nvim/lua/plugins/plugin1.lua"
  echo "plugin2" > "$REPO_DIR/testpkg/.config/nvim/lua/plugins/plugin2.lua"

  # Run dotlink
  cd "$REPO_DIR"
  bash ./dotlink.sh --target "$HOME_DIR" testpkg

  # Verify
  assert_true "[ -L '$HOME_DIR/.config/nvim/init.lua' ]" "Root file should be linked"
  assert_true "[ -L '$HOME_DIR/.config/nvim/lua/plugins/plugin1.lua' ]" "Nested file 1 should be linked"
  assert_true "[ -L '$HOME_DIR/.config/nvim/lua/plugins/plugin2.lua' ]" "Nested file 2 should be linked"

  cleanup_test_env
}

# Test 6: Partial cleanup (some directories remain)
test_partial_cleanup() {
  log_test "Test 6: Partial cleanup (some directories remain)"

  setup_test_env

  # Create structure with multiple files
  mkdir -p "$REPO_DIR/testpkg/.config/test"
  echo "test1" > "$REPO_DIR/testpkg/.config/test/config1.txt"
  echo "test2" > "$REPO_DIR/testpkg/.config/test/config2.txt"

  # Link
  cd "$REPO_DIR"
  bash ./dotlink.sh --target "$HOME_DIR" testpkg

  # Manually remove one symlink to simulate partial removal
  rm "$HOME_DIR/.config/test/config2.txt"

  # Unlink with cleanup
  bash ./dotlink.sh --unlink --cleanup-empty-dirs --target "$HOME_DIR" testpkg

  # Verify
  assert_false "[ -L '$HOME_DIR/.config/test/config1.txt' ]" "First symlink should be removed"
  assert_false "[ -d '$HOME_DIR/.config/test' ]" "Directory should be removed (now empty)"
  assert_false "[ -d '$HOME_DIR/.config' ]" "Parent directory should be removed (now empty)"

  cleanup_test_env
}

# Test 7: Ignore patterns
test_ignore_patterns() {
  log_test "Test 7: Ignore patterns"

  setup_test_env

  # Create package with ignored files
  mkdir -p "$REPO_DIR/testpkg/.config"
  echo "should link" > "$REPO_DIR/testpkg/.config/config.txt"
  echo "readme" > "$REPO_DIR/testpkg/README.md"
  echo "license" > "$REPO_DIR/testpkg/LICENSE"
  mkdir -p "$REPO_DIR/testpkg/.git"
  echo "git" > "$REPO_DIR/testpkg/.git/config"

  # Run dotlink
  cd "$REPO_DIR"
  bash ./dotlink.sh --target "$HOME_DIR" testpkg

  # Verify
  assert_true "[ -L '$HOME_DIR/.config/config.txt' ]" "Regular file should be linked"
  assert_false "[ -e '$HOME_DIR/README.md' ]" "README should be ignored"
  assert_false "[ -e '$HOME_DIR/LICENSE' ]" "LICENSE should be ignored"
  assert_false "[ -e '$HOME_DIR/.git' ]" ".git should be ignored"

  cleanup_test_env
}

# Test 8: Dry run mode
test_dry_run() {
  log_test "Test 8: Dry run mode"

  setup_test_env

  # Create test package
  mkdir -p "$REPO_DIR/testpkg/.config"
  echo "test" > "$REPO_DIR/testpkg/.config/config.txt"

  # Run in dry-run mode
  cd "$REPO_DIR"
  bash ./dotlink.sh --dry-run --target "$HOME_DIR" testpkg

  # Verify nothing was created
  assert_false "[ -e '$HOME_DIR/.config' ]" "No files should be created in dry-run mode"

  cleanup_test_env
}

# Test 9: Backup existing files
test_backup() {
  log_test "Test 9: Backup existing files"

  setup_test_env

  # Create existing file
  mkdir -p "$HOME_DIR/.config"
  echo "existing content" > "$HOME_DIR/.config/config.txt"

  # Create package
  mkdir -p "$REPO_DIR/testpkg/.config"
  echo "new content" > "$REPO_DIR/testpkg/.config/config.txt"

  # Run with backup
  cd "$REPO_DIR"
  bash ./dotlink.sh --backup --target "$HOME_DIR" testpkg

  # Verify
  assert_true "[ -L '$HOME_DIR/.config/config.txt' ]" "File should be a symlink now"
  assert_true "ls '$HOME_DIR/.config'/config.txt.bak.* &>/dev/null" "Backup file should exist"

  cleanup_test_env
}

# Test 10: Do not unlink other symlinks
test_preserve_other_symlinks() {
  log_test "Test 10: Do not unlink other symlinks"

  setup_test_env

  # Create test package
  mkdir -p "$REPO_DIR/testpkg/.config"
  echo "test" > "$REPO_DIR/testpkg/.config/config.txt"

  # Create another symlink manually
  mkdir -p "$HOME_DIR/.config"
  echo "other" > "$TEST_DIR/other.txt"
  ln -s "$TEST_DIR/other.txt" "$HOME_DIR/.config/other.txt"

  # Link and then unlink
  cd "$REPO_DIR"
  bash ./dotlink.sh --target "$HOME_DIR" testpkg
  bash ./dotlink.sh --unlink --target "$HOME_DIR" testpkg

  # Verify
  assert_false "[ -L '$HOME_DIR/.config/config.txt' ]" "Our symlink should be removed"
  assert_true "[ -L '$HOME_DIR/.config/other.txt' ]" "Other symlink should be preserved"

  cleanup_test_env
}

# Run all tests
run_all_tests() {
  log_info "Starting dotlink.sh test suite"
  echo

  test_basic_linking || true
  echo
  test_unlink_without_cleanup || true
  echo
  test_unlink_with_cleanup || true
  echo
  test_platform_specific || true
  echo
  test_nested_directories || true
  echo
  test_partial_cleanup || true
  echo
  test_ignore_patterns || true
  echo
  test_dry_run || true
  echo
  test_backup || true
  echo
  test_preserve_other_symlinks || true
  echo

  # Summary
  echo "========================================"
  log_info "Test Summary"
  echo "========================================"
  echo "Tests run:    $TESTS_RUN"
  echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
  echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
  echo "========================================"

  if [ "$TESTS_FAILED" -eq 0 ]; then
    log_info "All tests passed!"
    return 0
  else
    log_error "Some tests failed!"
    return 1
  fi
}

# Trap to ensure cleanup
trap cleanup_test_env EXIT

# Run tests
run_all_tests
