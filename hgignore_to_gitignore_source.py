import hgext.convert.convcmd
from hgext.convert.hg import mercurial_source as basesource

import re

REGEX_SYNTAX_GLOB = re.compile(r"syntax:\s*glob")
REGEX_SYNTAX_REGEXP = re.compile(r"syntax:\s*regexp")
REGEX_PLAIN_PATH = re.compile(r"^\^?([a-zA-Z0-9/\-.~_]|(\\\.)|(\.\*)|(\[0-9\]\*)|(\[124\]))+\$?$")
# Map how to convert .hgignore entries in regexp syntax to entries for .gitignore
IGNORE_MAP = {
#    "^src/search-implicit-abstractions/(release-)?search(_svs)?(_hca)?$": ???
}

def convert_hg_ignore(data):
    converted_lines = ["# This file was automatically converted. Check all lines for mistakes."]
    glob_syntax = False

    for line in data.splitlines():
        line = line.decode("ascii").strip()
        if line == "" or line.startswith("#"):
            converted_lines.append(line)
        elif REGEX_SYNTAX_GLOB.match(line):
            glob_syntax = True
        elif REGEX_SYNTAX_REGEXP.match(line):
            glob_syntax = False
        elif glob_syntax:
            converted_lines.append(line)
        else:
            # Convert line to glob syntax:
            # use user defined mapping
            if line in IGNORE_MAP:
                converted_lines.append(IGNORE_MAP[line])
            # simple paths
            elif REGEX_PLAIN_PATH.match(line):
                if line.startswith("^"):
                    line = line[1:]
                else:
                    line = "*{}".format(line)
                if line.endswith("$"):
                    line = line[:-1]
                else:
                    line = "{}*".format(line)
                line = re.sub(r"([^\\])\.", r"\1?", line)
                line = re.sub(r"(\[0-9\]\*)", r"*", line)
                line = re.sub(r"(\[124\])", r"?", line)
                line.replace("\\.", ".")
                line.replace(".*", "*")
                converted_lines.append(line)
            # unable to do any mapping
            else:
                converted_lines.append("# Failed to automatically convert, please fix manually:")
                converted_lines.append(line)
                print("Failed to automatically convert line in .hgignore: {}".format(line))

    return ('\n'.join(converted_lines)).encode()


class hgignore_to_gitignore_source(basesource):
    def getfile(self, name, rev):
        if name == b".gitignore":
            name = b".hgignore"
        data, flags = super(hgignore_to_gitignore_source, self).getfile(name, rev)
        if name == b".hgignore":
            data = convert_hg_ignore(data)
        return data, flags

    def getchanges(self, version, full):
        files, copies, cleanp2 = super(hgignore_to_gitignore_source, self).getchanges(version, full)
        new_files = []
        for filename, file_id in files:
            if filename == b".hgignore":
                filename = b".gitignore"
            new_files.append((filename, file_id))
        new_files.sort()
        return new_files, copies, cleanp2

hgext.convert.convcmd.source_converters.append((b"hgignore_to_gitignore_source", hgignore_to_gitignore_source, b"sourcesort"))
