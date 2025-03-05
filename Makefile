cluster:
	@kind create cluster \
		--name kong \
		--config kind.yaml

cluster-clean:
	@kind delete cluster \
		--name kong

# TODO/HACK: simple for now...logic to handle creation of resources better
cluster-config:
	@kubectl apply -f manifests/metallb.yaml || true
	@sleep 45
	@kubectl apply -f manifests/metallb.yaml

kong:
	@cd terraform/test && terraform init -upgrade && terraform apply

kong-clean:
	@cd terraform/test && terraform init -upgrade && terraform apply -destroy

demo-rate-limit:
	@scripts/demo-rate-limit.sh

demo-prompt-guard:
	@scripts/demo-guard.sh

ui:
	@open http://localhost:3000
