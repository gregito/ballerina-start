swagger:
	ballerina swagger export date_service.bal

build:
	ballerina build

deploy:
	docker run -d -p 9090:9090 gregito.project.com/date_service:v1.0.0

# terminate: \
	docker rm -f $(docker ps -aqf "ancestor=gregito.project.com/date_service:v1.0.0") \
	docker rmi gregito.project.com/date_service:v1.0.0