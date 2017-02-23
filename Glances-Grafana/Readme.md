# Glances, influxDB and Grafana.

Quick write up on how I use these 3 tools to great great looking moonitor graphs in a pinch. This is gonig to assume you have a VM with influxDB and Grafana already installed and have created your InfluxDB database.



# Setup

Okay, I'm writing this for monitoring a macOS system but it's easily adaptable for Linux boxes too. 

> NOTE: If you're on a machine behind a proxy you can set the proxy for use in terminal by: `export ALL_PROXY=http://myProxy:port`

***

#### First:

* Install brew if you have not already. https://brew.sh/ 

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

* Once installed we need to grab Python. 

`brew install python`

* Now lets use `pip` to grab `glances`. 

`pip install glances`

* Finally we need the Influxdb module

`pip install influx`

Great! That is pretty much it! Now lets create / edit a config file for `Glances` then start collecting data and piping to Influxdb

***

#### glances.conf
The glances configuration file _should_ be stored in `/usr/local/etc/glances/`. 
If that folder does not exsist go ahead and make it, then create the file. 

Using the glances.conf file in this repo copy it's contents and change the section marked _InfluxDB_ under the _Export_ header. this should be all you need to get going though you can tweek other sections too but I've been fine leaving them as stock.  

Once you have the .conf file ready you need to copy it to another folder to make everything work - kinda annoying.  
`cp glances.conf /usr/local/share/doc/glances/`

***
### Starting the dataflow
Done the above so far? Cool. Lets fire off some data to our Influx database.

`--export-influxdb` is our trigger to output data via `glances`. I also like to add in a time fucntion and also to run the command silently (no output). All toghether that looks like:
`glances -t 5 --export-influxdb -q`
Now this should start running and send your data to your influxdb server. Note for now you need to keep the terminal window open. In the future I'll add a LaunchDaemon to this so it can run in the background silently. 



