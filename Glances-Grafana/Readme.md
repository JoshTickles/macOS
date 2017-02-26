# Glances, influxDB and Grafana.

Quick write up on how I use these 3 tools to great great looking monitor graphs in a pinch. 

This is gonig to assume you have influxDB and Grafana already installed and have created your InfluxDB database. You can install these via Docker however my prefered method is to spin up a Linux VM for centeral monitoring needs on your network. 

![](http://i.imgur.com/v4cuq5f.png)


# Setup

Okay, I'm writing this for monitoring a macOS system but it's easily adaptable for Linux boxes too. 

> NOTE: If you're on a machine behind a proxy you can set the proxy for use in terminal by: `export ALL_PROXY=http://myProxy:port`

To create a InfluxDB database SSH into your server and make sure the service is started. If it is run `influx` then we can create a new DB by running `CREATE DATABASE foo`. I usually name it 'glances' or such. 

***

#### Getting started:

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

#### Confguration - glances.conf
The glances configuration file _should_ be stored in `/usr/local/etc/glances/`. 
If that folder does not exsist go ahead and make it, then create the file. 

Using the glances.conf file in this repo copy it's contents and change the section marked _InfluxDB_ under the _Export_ header. this should be all you need to get going though you can tweek other sections too but I've been fine leaving them as stock.  

An important thing to note is the use of the _prefix_ line. Entering a value here will make it easier to identify which machine data to use in Grafana. If you set a username and password for your database don't forget to enter those details also. 

Once you have the .conf file ready you need to copy it to another folder to make everything work - kinda annoying.  
`cp glances.conf /usr/local/share/doc/glances/`

***
### Starting the dataflow
Done the above so far? Cool. Lets fire off some data to our Influx database.

`--export-influxdb` is our trigger to output data via `glances`. I also like to add in a time function (to not slam the server) and also  run the command silently (no output). All together that looks like:

`glances -t 5 --export-influxdb -q`

Now this should start glances running and send your data to your influxdb server. Note for now you need to keep the terminal window open. In the future I'll add a LaunchDaemon to this so it can run in the background silently. 

### Configuring Grafana
Now it's time for the good stuff! Jump onto your Grafana instance and login. The default credentials are admin:admin.

Now, we need to add our database as a 'Data Source'. Click the logo in the top left, select 'Data Sources' then 'Add Data Source'.
Select `InfulxDB` as the type and give the Source a name. Next enter you `InfluxDB` server IP:Port. Now select your database and enter the credentials (if required). 'Access' should be left at 'Proxy'. All going well when you save you should get a success popup. 

##### Creating a dashboard
The easier way to do this is take my JSON configuration in this repo and copy it to a new Dashboard. From tehre you can go into each graph and change the source to your computer as defined by the prefix you set earlier. Simple right?

The harder way to do this is to read the Grafana manual and create your own Dashboard. It's not too hard but takes a bit of time to learn. 

***







