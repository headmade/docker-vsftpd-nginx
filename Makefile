TAG = headmadepro/docker-vsftpd-nginx:latest

dockerize:
	docker build -t $(TAG) .

push:
	docker push $(TAG)