set unstable := true

mod? titanoboa

# Constants

repo_image_name := lowercase("gregos-desktop-kde")
repo_name := lowercase("GregDomzalski")
IMAGE_REGISTRY := "ghcr.io" / repo_name
FQ_IMAGE_NAME := IMAGE_REGISTRY / repo_image_name

[private]
default:
    @{{ just }} --list

# Check Just Syntax
[group('Just')]
check:
    {{ just }} --unstable --fmt --check

# Fix Just Syntax
[group('Just')]
fix:
    {{ just }} --unstable --fmt

# Build ISO
[group('ISO')]
build-iso flavor="kdbn" version="latest":
    #!/usr/bin/env bash
    mkdir -p ./build_out
    sudo bluebuild generate-iso --iso-name "./build_out/gregos-{{ flavor }}.iso" image "ghcr.io/gregdomzalski/gregos-{{ flavor }}:{{ version }}"

[group('ISO')]
build-kickstart hostname config flavor="kdbn" version="latest":
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p ./build_out
    TEMP_DIR=$(mktemp -d)

    function cleanup {
        rm -rf "$TEMP_DIR"
    }

    trap cleanup EXIT
    cp "./kickstart/{{ config }}.ks" "$TEMP_DIR/ks.cfg"
    sed -i 's/KS_OS_IMAGE_NAME/gregos-{{ flavor }}/g' "$TEMP_DIR/ks.cfg"
    sed -i 's/KS_OS_IMAGE_TAG/{{ version }}/g' "$TEMP_DIR/ks.cfg"
    sed -i 's/KS_HOSTNAME/{{ hostname }}/g' "$TEMP_DIR/ks.cfg"
    cat "$TEMP_DIR/ks.cfg"
    xorriso -as mkisofs -V "OEMDRV" -J -r -o ./build_out/kickstart.iso "$TEMP_DIR"

# Utils

[private]
GIT_ROOT := justfile_dir()
[private]
BUILD_DIR := repo_image_name + "_build"
[private]
just := just_executable() + " -f " + justfile()
[private]
CI := env('CI', '')
