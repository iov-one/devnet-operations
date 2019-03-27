VARIABLES := gcloud/variables.tf gcloud/export_variables.sh scripts/seed_variables.sh

variables:
	@for file in $(VARIABLES); do \
		if	[ ! -f $$file ]; then \
			cp $$file"_example" $$file ; \
		fi \
	done

setup_cluster: 
	@cd gcloud && ./project_setup.sh

seed_cluster: 
	@./scripts/seed_cluster.sh

seed_bot:
	@./scripts/seed_bot.sh

deps: 
	# this only gets kustomize and lego as other dependencies
	# are better installed in a platform-specific way
	go get -u github.com/kubernetes-sigs/kustomize
	go get -u github.com/go-acme/lego