# IP Monitoring

## Setup dev environment

``` sh
dip provision
```

## Run checker in console

``` ruby
Application["operations.icmp_shell_checker"].call(ip_address: '8.8.8.8')
```


## How can optimize statics calculation
- Aggregate stats by some intervals (10m, 1h, 1d - depends on usage patterns)

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

- GET IP stas
``` sh
curl 'http://localhost:3000/ips/1/stats?time_from=2023-08-16&time_to=2023-08-22'
```
