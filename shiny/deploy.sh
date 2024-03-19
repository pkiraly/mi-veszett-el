#!/usr/bin/env bash

service shiny-server stop
cp -r rmny /srv/shiny-server/
service shiny-server start
