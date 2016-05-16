phpMyAdmin - localized documentation
====================================

This repository contains localized documentation for phpMyAdmin. It
is based on master document placed in phpmyadmin repository.

To translate edit your language file in po directory, changes will be
propagated to generated documents. You can also translate online at
<https://hosted.weblate.org/projects/phpmyadmin/documentation/> and your changes
will be merged to Git.

.. image:: http://hosted.weblate.org/widgets/phpmyadmin-status-badge.png
    :alt: Translation status
    :target: https://hosted.weblate.org/engage/phpmyadmin/?utm_source=widget

Requirements
------------

For manipulating with translations, you need gettext and sphinx installed.

Usage
-----

To start new translation just add it to the Makefile.

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

.. code-block::

    git commit -a -m 'Update documentation to match master'
