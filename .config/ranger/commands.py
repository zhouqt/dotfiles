# encoding: utf-8
# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import *

# A simple command for demonstration purposes follows.
# -----------------------------------------------------------------------------

# You can import any python module as needed.
import os

class rename_images(Command):
    # The so-called doc-string of the class will be visible in the built-in
    # help that is accessible by typing "?c" inside ranger.
    """:rename_images

    Batch renaming images based on filename order
    """

    # The execute method is called when you run this command in ranger.
    def execute(self):
        d = self.fm.thisfile
        
        if d.is_directory:
            renamecmd = [ os.path.expanduser("~/.config/ranger/rename_images.zsh"), str(d) ]
            self.fm.run( renamecmd )
        else:
            self.fm.notify("Not a directory!")

class grename(Command):
    """:grename

    Rename gallery directory
    """

    def execute(self):
        from ranger import MACRO_DELIMITER, MACRO_DELIMITER_ESC

        d = self.fm.thisfile

        if d.is_directory:
            basename = d.basename.replace(MACRO_DELIMITER, MACRO_DELIMITER_ESC)
            new_name = "-".join(basename.split("–")[-1].strip().split()[0:-1]).lower()
            self.fm.open_console("rename " + new_name)
        else:
            self.fm.notify("Not a directory")
