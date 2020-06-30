import argparse
import os
import shutil
import subprocess
import sys

FAST_EXPORT_SCRIPT = os.path.join(
    os.environ['FAST_EXPORT_REPO'], "hg-fast-export.sh")
REWRITE_HISTORY_SCRIPT = os.path.join(
    os.path.dirname(sys.argv[0]), "rewrite_history.sh")
TEMPORARY_CONVERTED_REPOSITORY = os.path.join(
    os.path.dirname(sys.argv[0]), "data", "temporary_converted_repository")


def type_mercurial_directory(arg):
    if not os.path.isdir(os.path.join(arg, ".hg")):
        raise argparse.ArgumentTypeError("Not a Mercurial repository.")
    return os.path.abspath(arg)


def type_not_exists(arg):
    if os.path.exists(arg):
        raise argparse.ArgumentTypeError("Exists already.")
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
    return call(
        ["hg", "branches", "-R", hg_repo, "--template", "{branch} "] + args
    ).split()


def remove_temporary_data():
    if os.path.exists(TEMPORARY_CONVERTED_REPOSITORY):
        shutil.rmtree(TEMPORARY_CONVERTED_REPOSITORY)


def main(options):
    remove_temporary_data()  # remove fragments of incomplete runs

    print("Rewrite history")
    call([REWRITE_HISTORY_SCRIPT,
          options.source, TEMPORARY_CONVERTED_REPOSITORY])

    print("Create {}.".format(options.destination))
    os.makedirs(options.destination)
    os.chdir(options.destination)
    try:
        print("Execute hg-fast-export.")
        call(["git", "init"])
        call([FAST_EXPORT_SCRIPT, "-r", TEMPORARY_CONVERTED_REPOSITORY])
        call(["git", "checkout", "main"])

        print("Remove closed & merged branches.")
        open_branches = get_branches(TEMPORARY_CONVERTED_REPOSITORY, [])
        unmerged_branches = call([
            "hg", "log", "-r", "head()-parents(merge())", "-R",
            TEMPORARY_CONVERTED_REPOSITORY, "--template", "{branch} "]).split()
        all_branches = get_branches(TEMPORARY_CONVERTED_REPOSITORY, ["--closed"])
        for branch in (set(all_branches) - set(open_branches) - set(unmerged_branches)):
            call(["git", "branch", "-d", branch])

    except subprocess.CalledProcessError as e:
        print("Failed: {}".format(" ".join(e.cmd)), file=sys.stderr)
        remove_temporary_data()
        sys.exit(2)
    remove_temporary_data()
    print("Conversion done.")


if __name__ == "__main__":
    main(parser.parse_args(sys.argv[1:]))
