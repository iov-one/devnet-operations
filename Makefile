VARIABLES := gcloud/variables.tf gcloud/export_variables.sh

variables:
	@for file in $(VARIABLES); do \
		if	[ ! -f $$file ]; then \
			cp $$file"_example" $$file ; \
		fi \
	done

setup_cluster: 
	@cd gcloud && ./project_setup.sh

deps: 
	# this only gets kustomize as other dependencies
	# are better installed in a platform-specific way
	go get -u github.com/kubernetes-sigs/kustomize