# IP Monitoring

Service for monitoring ip addresses (v4, v6) availability and aggregating stats. 

# Description

Service sends icmp packet every 1 minutes and saves result, success or not, to the ip_addresses table. Additionally, we can enable stats collection - after that we save rtt result to the ip_checks table. If rtt takes more than 1s - we drop request and save info about dropped packet to ip_checks table also. Info about active stats monitoring periods keeps in ip_monitoring_periods table.
Additional project goal - research dry.rb, rom.rb and grape gems.

## TODO

- [X] check ipv4/ipv6 address
- [X] add api for control ip address and collecting stats
- [X] use dry-system
- [X] use dry-monads
- [X] use rom.rb / sequel
- [X] use grape
- [X] use docker-compose
- [X] add github actions
- [ ] add native ip checker

## Dev environment

### Prepare and run project

``` sh
dip provision
dip web
```

### Run rspec

``` sh
dip rspec
```

### Run rubocop

``` sh
dip rubocop
```

### IPv6 

For working with ipv6 inside docker check that you enable v6 support - https://docs.docker.com/config/daemon/ipv6/

## API Requests

- Create IP

``` sh
curl -X POST http://localhost:3000/ips \
   -H 'Content-Type: application/json' \
   -d '{"ip":"2a00:1450:4001:82b::200e","enable":true}'
   
curl -X POST http://localhost:3000/ips \
   -H 'Content-Type: application/json' \
   -d '{"ip":"8.8.8.8","enable":true}'

```

- Enable/disable stats collection

``` sh
curl -X POST http://localhost:3000/ips/:id/enable
curl -X POST http://localhost:3000/ips/:id/disable
```

- Get ip stat 

``` sh
curl 'http://localhost:3000/ips/1/stats?time_from=2023-08-16&time_to=2023-08-22'
```

- Delete ip (soft) and disable stats collection

``` sh
curl -X DELETE http://localhost:3000/ips/:id
```


