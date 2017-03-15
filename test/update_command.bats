#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/update.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/reshim.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/install.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/uninstall.sh

setup() {
  setup_asdf_dir
  install_dummy_plugin

  # Copy over git repo so we have something to test with
  cp -r .git $ASDF_DIR

  PROJECT_DIR=$HOME/project
  mkdir $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "update_command --head should checkout the master branch" {
  run update_command --head
  [ "$status" -eq 0 ]
  cd $ASDF_DIR
  [ $(git rev-parse --abbrev-ref HEAD) = "master" ]
}

@test "update_command should not remove plugin versions" {
  run install_command dummy 1.1
  [ "$status" -eq 0 ]
  [ $(cat $ASDF_DIR/installs/dummy/1.1/version) = "1.1" ]
  run update_command
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/installs/dummy/1.1/version ]
  run update_command --head
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/installs/dummy/1.1/version ]
}

@test "update_command should not remove plugins" {
  # dummy plugin is already installed
  run update_command
  [ "$status" -eq 0 ]
  [ -d $ASDF_DIR/plugins/dummy ]
  run update_command --head
  [ "$status" -eq 0 ]
  [ -d $ASDF_DIR/plugins/dummy ]
}

@test "update_command should not remove shims" {
  run install_command dummy 1.1
  [ -f $ASDF_DIR/shims/dummy ]
  run update_command
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/shims/dummy ]
  run update_command --head
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/shims/dummy ]
}
