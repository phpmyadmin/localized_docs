phpMyAdmin - localized documentation
====================================

This repository contains localized documentation for phpMyAdmin. It
is based on master document placed in phpmyadmin repository.

To translate edit your language file in po directory, changes will be
propagated to generated documents. You can also translate online at
<https://hosted.weblate.org/projects/phpmyadmin/documentation/> and your changes
will be merged to Git.

.. image:: https://hosted.weblate.org/widgets/phpmyadmin/-/svg-badge.svg
    :alt: Translation status
    :target: https://hosted.weblate.org/engage/phpmyadmin/?utm_source=widget

.. image:: https://travis-ci.org/phpmyadmin/localized_docs.svg?branch=master
    :alt: Build status
    :target: https://travis-ci.org/phpmyadmin/localized_docs

.. image:: https://readthedocs.org/projects/phpmyadmin/badge/?version=latest
    :target: http://docs.phpmyadmin.net/en/latest/?badge=latest
    :alt: Documentation Status

Requirements
------------

For manipulating with translations, you need gettext and sphinx installed.

Usage
-----

To start new translation,

* Add it to the `LANGUAGES` section of the Makefile.
* Copy one of the language folders in `./docs/` to a new folder (named with the
  proper language code). This will maintain many symlinked files in that
  folder and one regular file `config.py`.
* Edit `config.py` to change the `language =` section with the correct
  language name.
* In the `./po/` folder, copy `documentation.pot` to create a new `.po`
  file. You may have to also create a .mo file, but I think that happens
  automatically on the build server.
* Copy one of the folders in `./translated/` to a new folder. This again
  creates many symlinks.

To regenerate mofiles run:

.. code-block:: sh

    make

To obtain statistics about current translations run:

.. code-block:: sh

    ./locales-stats

To update documentation run:

.. code-block:: sh

    # Force Weblate to commit changes, requires wlc to be installed
    wlc commit
    # Pull changes from Weblate
    git pull
    # Update phpMyAdmin submodule
    git submodule update --remote
    # Update po files to match current docs
    make

This automatically updates po files, generates mo files and synchronizes
sources of the documentation. Review changes and commit them using:

.. code-block:: sh

    git commit -a -m 'Update documentation to match master'

To build documentation in given language (for example Czech):

.. code-block:: sh

    make html-cs

You can also invoke sphinx-build manually:

.. code-block:: sh

    sphinx-build docs/cs/ output/cs/

You can also build all documentation at once:

.. code-block:: sh

    make html

You can also browse translated documentation online at <https://docs.phpmyadmin.net/>.
