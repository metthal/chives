lint:
	@black chive
	@mypy chive

integration_tests: PYTEST_ARGS += -vvv
integration_tests:
	@pytest $(PYTEST_ARGS) tests/integration || docker-compose -f tests/integration/docker-compose.yml down

integration_tests_debug: PYTEST_ARGS += --log-cli-level debug
integration_tests_debug: integration_tests

services:
	docker-compose -p chive -f dev/docker-compose.yml up -d --force-recreate

services_down:
	docker-compose -p chive -f dev/docker-compose.yml down

generate_cert:
	cd dev && \
		openssl genrsa -out private.key 4096 && \
		openssl req -x509 -new -nodes -key private.key -sha256 -days 365 -out cacert.pem -subj "/CN=Project Chive Dev CA Certificate" && \
		openssl req -new -key private.key -out cert.csr -subj "/CN=Project Chive Dev Certificate"  && \
		echo -e "basicConstraints=CA:FALSE\nkeyUsage = digitalSignature, nonRepudiation\nsubjectAltName = @alt_names\n\n[alt_names]\nDNS.1 = localhost" > cert.cfn && \
		openssl x509 -req -in cert.csr -CA cacert.pem -CAkey private.key -CAcreateserial -sha256 -days 365 -out cert.pem -extfile cert.cfn && \
		cd -
