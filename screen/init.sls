# -*- coding: utf-8 -*-
# vim: ft=salt

{% from "screen/map.jinja" import screen with context %}

screen_main_pkgs:
  pkg.installed:
    - name: {{ screen.pkgs|json }}

screen_lib_pkgs:
  pkg.installed:
    - pkgs: {{ screen.pkgs_libs|json }}


screen_extra_pkgs:
  pkg.installed:
    - pkgs: {{ screen.pkgs_extra|json }}

