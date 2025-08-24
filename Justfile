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
build-iso:
    mkdir -p ./build_out
    sudo bluebuild generate-iso --iso-name ./build_out/gregos-kde.iso image ghcr.io/gregdomzalski/gregos-desktop-kde:latest

[group('ISO')]
build-kickstart:
    mkdir -p ./iso_contents
    mkdir -p ./build_out
    cp ./kickstart/greg-vm.ks ./iso_contents/ks.cfg
    xorriso -as mkisofs -V "OEMDRV" -J -r -o ./build_out/kickstart.iso ./iso_contents
    rm -rf ./iso_contents

# Utils

[private]
GIT_ROOT := justfile_dir()
[private]
BUILD_DIR := repo_image_name + "_build"
[private]
just := just_executable() + " -f " + justfile()
[private]
CI := env('CI', '')
