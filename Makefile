cluster:
	@kind create cluster \
		--name kong \
		--config kind.yaml

# TODO/HACK: simple for now...logic to handle creation of resources better
cluster-config:
	@kubectl apply -f manifests/metallb.yaml || true
	@sleep 45
	@kubectl apply -f manifests/metallb.yaml

kong:
	@cd terraform test && terraform init -upgrade && terraform apply