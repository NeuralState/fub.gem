#!/bin/sh

gem build fub.gemspec
gem uninstall fub
gem i ./fub-0.0.3.gem

