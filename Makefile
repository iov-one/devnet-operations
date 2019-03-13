VARIABLES := gcloud/variables.tf gcloud/export_variables.sh

variables:
	@for file in $(VARIABLES); do \
		if	[ ! -f $$file ]; then \
			cp $$file"_example" $$file ; \
		fi \
	done

setup_cluster: 
	@cd gcloud && ./project_setup.sh