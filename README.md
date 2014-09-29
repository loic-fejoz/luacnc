LuaCNC - A programmers CNC modeller and G-code generator
========================================================

## Description

LuaCNC is a (programming) language based on [Lua](http://www.lua.org/) used to model works for 3 axes [CNC mill/router](http://en.wikipedia.org/wiki/CNC_router):
Program it in 2D, view it in 3D, build it for real.

It is inspired from [IceSL](http://webloria.loria.fr/~slefebvr/icesl/), [Easel](http://www.easel.com/), and [OpenSCAD](http://www.openscad.org)  but dedicated to CNC mill.

The main idea is to explore the use of a programming language to easily use a CNC router.
Technically, it uses a GPU (graphical card) to compute the design that has been expressed in Lua.
The intermediate format of all utilities will probably be a heightmap.

As of 29th Septembre 2014, it is possible to view a grey-scale heightmap generated from simple Lua code.


## System Requirements

As of 29th Septembre 2014, LuaCNC require:

- an OpenGL 2.0 compatible GPU-Card.
- Linux OS

## Installation

As of 29th September 2014, one need to compile LuaCNC from sources.

1. `git clone https://github.com/loic-fejoz/luacnc.git`
2. `cd luacnc`
3. `make luacnc-view`
5. `make test1` to test it.

## Contribute

If you would like to hack on LuaCNC, start by forking the repo on GitHub:

https://github.com/loic-fejoz/luacnc

The best way to contribute is probably one of the following:

* Clone the repo and follow [GitHub Workflow](https://guides.github.com/introduction/flow/index.html).
* Contact [Me <loic@fejoz.net>](mailto:loic@fejoz.net).
* Visit Me.

What needs to be done:

* Update examples and illustrate them with screenshots
* Add dependencies retrieval from within Makefile
* Add rotation/scaling
* Add rounded union
* Build it for MS/Windows
* Build it for Mac/OS
* Work on [all issues](https://github.com/loic-fejoz/luacnc/issues)


## Changes

TO BE DONE

## Authors

# This is a list of people who have contributed code or ideas to ronn -- for
# copyright purposes or whatever.

* Loïc Fejoz <loic@fejoz.net> <https://github.com/loic-fejoz/>