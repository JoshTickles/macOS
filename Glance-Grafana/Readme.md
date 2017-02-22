# Glances, influxDB and Grafana.

Quick write up on how I use these 3 tools to great great looking moonitor graphs in a pinch. This is gonig to assume you have a VM with influxDB and Grafana already installed.


# Setup

Okay I'm writing this up for monitoring a macOS system but it's easily adaptable for Linux boxes too. 

NOTE! If you're on a machine behing a proxy you can set the proxy for use in terminal using: 

`export ALL_PROXY=http:myProxy:port`

***

First:

* Install brew if you have not already. https://brew.sh/ 

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

* Once installed we need to grab Python. 

`brew install python`

* Now lets use `pip` to grab `glances`

`pip install glances`

* Finally we need the Influxdb module

`pip install influx`
