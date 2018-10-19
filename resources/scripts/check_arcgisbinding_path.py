from __future__ import print_function
from __future__ import division
from __future__ import unicode_literals

import ctypes.wintypes
import os

# cyptes constants
CSIDL_PERSONAL = 0x05
CSIDL_APPDATA = 0x1A
CSIDL_PROFILE = 0x28
SHGFP_TYPE_CURRENT = 0


def _documents_folder():
    """ Get the users' documents folder, which is where R will place
        its default user-specific 'personal' library.

        Returns: full path of user library."""

    # Call SHGetFolderPath using ctypes.
    ctypes_buffer = ctypes.create_unicode_buffer(ctypes.wintypes.MAX_PATH)
    ctypes.windll.shell32.SHGetFolderPathW(
        0, CSIDL_PROFILE, 0, SHGFP_TYPE_CURRENT, ctypes_buffer)
    # This isn't a language-independent way, but CSIDL_PERSONAL gets
    # the wrong path.
    # TODO: Test in non-English locales.
    documents_folder = os.path.join(ctypes_buffer.value, "Documents")

    return documents_folder


def _personal_folder():
    """ Get the users' documents folder, which is where R will place
        its default user-specific 'personal' library.

        Returns: full path of user library."""

    # Call SHGetFolderPath using ctypes.
    ctypes_buffer = ctypes.create_unicode_buffer(ctypes.wintypes.MAX_PATH)
    ctypes.windll.shell32.SHGetFolderPathW(
        0, CSIDL_PERSONAL, 0, SHGFP_TYPE_CURRENT, ctypes_buffer)
    documents_folder = ctypes_buffer.value

    return documents_folder


print("CSIDL_PROFILE + Documents: {}".format(_documents_folder()))
print("CSIDL_PERSONAL: {}".format(_personal_folder()))
home = os.path.join(os.getenv("HOMEDRIVE"), os.getenv("HOMEPATH"), "Documents")
print("HOMEDRIVE + HOMEPATH + Documents: {}".format(home))