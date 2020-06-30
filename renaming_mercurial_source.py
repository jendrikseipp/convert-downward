import hgext.convert.convcmd
from hgext.convert.hg import mercurial_source
from hgext.convert.common import mapfile

import os

class renaming_mercurial_source(mercurial_source):
    def __init__(self, ui, repotype, path, revs=None):
        super(renaming_mercurial_source, self).__init__(ui, repotype, path, revs)
        file_dir = os.path.dirname(__file__)
        # No easy way to get this from the options here, unfortunately.
        branchmap_filename = os.path.join(file_dir, "data", "downward_branchmap.txt")
        self.branchmap = mapfile(ui, branchmap_filename)

    def getcommit(self, rev):
        commit = super(renaming_mercurial_source, self).getcommit(rev)
        branch = self.branchmap.get(commit.branch, commit.branch)
        # join is used here to avoid issues when decoding bytes to strings.
        commit.desc = b"".join([b"[", branch, b"] ", commit.desc])
        return commit

hgext.convert.convcmd.source_converters.append((b"renaming_mercurial_source", renaming_mercurial_source, b"sourcesort"))
