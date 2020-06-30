import argparse
import os
import shutil
import subprocess
import sys

FAST_EXPORT_SCRIPT = os.path.join(
    os.environ['FAST_EXPORT_REPO'], "hg-fast-export.sh")


def type_mercurial_directory(arg):
    if not os.path.isdir(os.path.join(arg, ".hg")):
        raise argparse.ArgumentTypeError("Not a Mercurial repository.")
    return os.path.abspath(arg)


def type_not_exists(arg):
    if os.path.exists(arg):
        raise argparse.ArgumentTypeError("Exists already.")
    return os.path.abspath(arg)


def type_is_dir(arg):
    if not os.path.isdir(arg):
        raise argparse.ArgumentTypeError("Is not a directory.")
    return os.path.abspath(arg)


parser = argparse.ArgumentParser()
parser.add_argument(
    "source", type=type_mercurial_directory,
    help="Path to the Mercurial repository to convert."
)
parser.add_argument(
    "destination", type=type_not_exists,
    help="Destination directory for the converted repository. The destination"
         "may NOT exist."
)


def call(args):
    return subprocess.check_output(args).decode()


def get_branches(hg_repo, args):
    branches = call(
        ["hg", "branches", "-R", hg_repo, "--template", "{branch} "] + args
    ).split()
    return ["master" if b == "default" else b for b in branches]


def main(options):
    print("Create {}.".format(options.destination))
    os.makedirs(options.destination)
    os.chdir(options.destination)
    try:
        print("Execute hg-fast-export.")
        call(["git", "init"])
        call([FAST_EXPORT_SCRIPT, "-r", options.source])
        call(["git", "checkout"])

        # TODO: convert hgignore to gitignore

        print("Remove closed branches.")
        open_branches = get_branches(options.source, [])
        all_branches = get_branches(options.source, ["--closed"])
        for branch in (set(all_branches) - set(open_branches)):
            call(["git", "branch", "-d", branch])

    except subprocess.CalledProcessError as e:
        print("Failed: {}".format(" ".join(e.cmd)), file=sys.stderr)
        sys.exit(2)
    print("Conversion done.")


if __name__ == "__main__":
    main(parser.parse_args(sys.argv[1:]))
