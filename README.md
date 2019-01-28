# Ballerina start

Simple stretching with the Ballerina language.
Right now, it contains a date service which can be deployed to a docker container and accessible on port 9090.

example curl:
```curl http://localhost:9090/date/time -X GET -d '{"withMilisec":false}' -H 'Content-Type: application/json'```