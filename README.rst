screen
======
Manage the screen application.

TOFS Pattern
============
The Template Override and File Switch Pattern is extremely useful design pattern
for salt. This enables the use of static and dynamic templates, static
defaults and pillar data for configuration; as well as minion specific custom
template configuration. Though it may be a bit complicated to start with, it
will quickly become a goto pattern for your salt formulae.

Read the original `TOFS pattern <TOFS_pattern.md>`.

Layering Configuration Data
---------------------------
Configuration data is layered with the following precedence

::
Pillar > os (grain) > os_family (grain) > defaults
::

Pillar: `screen`. Use `lookup` dictionary override default values in formula.
os (grain): screen/os_map.yaml
os_family (grain): screen/os_family_map.yaml
defaults: screen/defaults.yaml

See :ref:`Config Attributes` for specific key:value information.

Layering Templates
------------------
Static file templates should be added to the formula in the `files` directory.
This is laid out in the following way:

::
files > [match] > [full target system path to file] > [template]
::

Match:
All template paths are generated and the first match is used. This is done in
order of precedence:

#. Pillar: `screen:files_match`. Ordered List of custom grains to match. Default: `None`.
#. id (grain) match. e.g. `myhost.domain.com`
#. os (grain) match. e.g. `Ubuntu`
#. os_family (grain) match. e.g. `Debian`
#. default match. `default`

Target System Path:
The full minion path to the file should be added in `files`:

./files/myhost.domain.com/etc/screenrc
./files/CrazyDistro/usr/local/etc/screenrc.jinja

myhost.domain.com match would modify `/etc/screenrc` using a static file.
CrazyDistro match would modify `/usr/local/etc/screenrc` using a template.

Templates:
Templates are applied on first existing [template] match found in the 
`files_switch <screen/macros.jinja>` macro. See the specific salt state for
template precedence that you are using. This is typically:

#. Static file
#. Template file

screen.conf as an Example
-------------------------
The current precedence for `screen.conf` is:

#. salt://screen/files/[pillar custom grain match]/etc/screenrc
#. salt://screen/files/[pillar custom grain match]/etc/screenrc.jinja
#. salt://screen/files/myhost.domain.com/etc/screenrc
#. salt://screen/files/myhost.domain.com/etc/screenrc.jinja
#. salt://screen/files/Ubuntu/etc/screenrc
#. salt://screen/files/Ubuntu/etc/screenrc.jinja
#. salt://screen/files/Debian/etc/screenrc
#. salt://screen/files/Debian/etc/screenrc.jinja
#. salt://screen/files/default/etc/screenrc
#. salt://screen/files/default/etc/screenrc.jinja

Assuming `config` is set to `/etc/screenrc`.

Remember, the first existing match will be used -- if you have pillar data
defined but the minion matches a static template first, the static template will
be used (as it is considered more accurate).

Config Attributes
-----------------
These are the explicit vars used in the formula. These should be used in the
pillar `lookup` table.

pkg          List of core packages required.
lib_pkgs     List of additional (typically desired) libraries.
extra_pkgs   List of extra (typically optional) libraries.
config       Location of system screen config file to write.
files_switch Ordered List of custom grains to match. Default: None.
system       List of key:value pairs matching system screen config parameters.

These may be overidden via any configuration layer.

system::

Keys are automatically copied into the config, using those values as config
parameters. Using a List for a value will generate multiple keys. These are
sorted by keyname then rendered to the config file.

.. code-block:: yaml
   screen:
     system:
       startup_message: off
       defflow: True
       vbell_msg: '"   Wuff  ----  Wuff!!  "'
       termcap:
         - facit|vt100|xterm LP:G0
       bind:
         - ^k
         - ^\
         - \\ quit
         - K kill
         - I login on
         - O login off
         - '} history'

This will result in the following screenrc file

.. code-block:: screenrc
   bind ^k
   bind ^\
   bind \\ quit
   bind k kill
   bind I login on
   bind O login off
   bind } history

   defflow True

   termcap facit|vt100|xterm LP:G0

   startup_messages off

   vbell_msg "   Wuff  ----  Wuff!!  "



Available states
================

.. contents::
    :local:

 ``screen``
 ----------
 Installs screen packages and libraries (pkgs, lib_pkgs, extra_pkgs).

 ``screen.config``
 -----------------
 Installs system-wide screen config; automatically install ``screen``.
