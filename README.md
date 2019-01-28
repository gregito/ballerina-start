# Ballerina start

Simple stretching with the Ballerina language.
Right now, it contains a date service which can be deployed to a docker container and accessible on port 9090.

example curl with body:
```curl http://localhost:9090/date/time -X GET -d '{"withMilisec":true}' -H 'Content-Type: application/json'```

without body, it returns the actual time without miliseconds

### Prerequisites:
- Ballerina installed
- Docker installed and running

Build and start with docker:
```make build```
```make deploy```