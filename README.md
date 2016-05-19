Tools for Patch Management
==========================


This repository is designed to gather different tools related to Patch Management and Security Updates

----------

Security Upgrades
-------------

Script **securityUpdate.sh**

Compliant with :
- Debian
- CentOS (Minor features)

> Installation
```
wget https://raw.githubusercontent.com/maximiliend/patch-management/master/securityUpdate.sh -O /usr/local/bin/securityUpdate.sh && chmod +x /usr/local/bin/securityUpdate.sh
```

This script can apply security updates available in repository.
Use it to apply updates for security or simply download them.

To avoid problem with applications that should not be restarted like SQL servers in productions you can specify (-i) to ignore some packages. So they will not be upgraded.

This script can be called manualy or using cron with the desired frequency.

The performed actions are recorded in a log file, by default /var/log/securityUpgrades.log.

In order to provide safety auto-upgrades, the script can be invoked with the option (-s). With this parameter the script ask a server with telnet before upgrading.

If the server is unreachable or responds 1 (OK) then updates are performed. If it the server answer 0 upgrades will be canceld.

Use it to prevent updates on all servers using this script without making any action on your servers.

The script provide the following options :

```
Usage: /usr/local/bin/securityUpdate.sh [options]
OPTIONS:
    -h      Display help
    -v      Be verbose
    -u      Update & Download only Security updates
    -f      Force Security Upgrade
    -s      Safe Security Upgrade (ask host server before, need to define --host and --port)
    -i      Ignore package during upgrade whose name contains one of this param, separated with ',' or '|' or ' '. Example : "mysql,apache"
    -l      Log file (Default : /var/log/securityUpgrades.log)
    -r      Host asked for sage upgrade
    -p      Remote host's port
```

Examples of cron that can be used :

```
# Download only updates every week on thursday at 5am
0 5 * * 4 /usr/local/bin/securityUpdate.sh -u >/dev/null 2>&1
# Force upgrades with ignored packages every day 6am
0 6 * * * /usr/local/bin/securityUpdate.sh -f -i mysql,postgresql >/dev/null 2>&1
# Force upgrades every monday of even week at 8am
0 8 * * 1 [ $(expr `date +%U` % 2) -eq 0 ] && /usr/local/bin/securityUpdate.sh -f >/dev/null 2>&1
```


PM Server
-------------

A simple pm server is available in docker-pm-server/
