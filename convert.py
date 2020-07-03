import argparse
import os
import subprocess
import sys
import tempfile

FAST_EXPORT_SCRIPT = os.path.join(
    os.environ['FAST_EXPORT_REPO'], "hg-fast-export.sh")
REWRITE_HISTORY_SCRIPT = os.path.join(
    os.path.dirname(sys.argv[0]), "rewrite_history.sh")


def type_mercurial_directory(arg):
    if not os.path.isdir(os.path.join(arg, ".hg")):
        raise argparse.ArgumentTypeError(
            "{} is not a Mercurial repository.".format(arg))
    return os.path.abspath(arg)


def type_not_exists(arg):
    if os.path.exists(arg):
        raise argparse.ArgumentTypeError("{} exists already.".format(arg))
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


def main(options):
    with tempfile.TemporaryDirectory() as dir_tmp:
        try:
            print("Rewrite history")
            call(["/bin/bash", REWRITE_HISTORY_SCRIPT,
                  options.source, dir_tmp])

            print("Create {}.".format(options.destination))
            os.makedirs(options.destination)
            os.chdir(options.destination)

            print("Execute hg-fast-export.")
            call(["git", "init"])
            call([FAST_EXPORT_SCRIPT, "-r", dir_tmp])
            call(["git", "checkout", "main"])

            print("Remove closed & merged branches.")
            open_branches = get_branches(dir_tmp, [])
            unmerged_branches = call([
                "hg", "log", "-r", "head()-parents(merge())", "-R",
                dir_tmp, "--template", "{branch} "]).split()
            all_branches = get_branches(dir_tmp, ["--closed"])
            for branch in (set(all_branches)
                           - set(open_branches)
                           - set(unmerged_branches)):
                call(["git", "branch", "-d", branch])

            print("Remove empty commits")
            call(["git", "filter-branch", "--prune-empty", "--tag-name-filter", "cat", "--", "--all"])

            print("Cleaning up")
            call(["git", "gc", "--aggressive"])

        except subprocess.CalledProcessError as e:
            print("Failed: {}".format(" ".join(e.cmd)), file=sys.stderr)
            sys.exit(2)
    print("Conversion done.")


if __name__ == "__main__":
    main(parser.parse_args(sys.argv[1:]))
