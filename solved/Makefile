INPUTS=example-inputs.yaml
M4INPUTS=$(INPUTS).m4
BLUEPRINT=example-blueprint.yaml
M4BLUEPRINT=$(BLUEPRINT).m4
CFM_BLUEPRINT=example
CFM_DEPLOYMENT=example
RETRIES=10
VIRTUAL_ENV?=~/cfy

.PHONY: blueprints inputs validate test clean

# blueprints
blueprints: cfy-$(BLUEPRINT) cfm-$(BLUEPRINT)

cfy-$(BLUEPRINT): $(M4BLUEPRINT)
	m4 $? >".$@"
	mv ".$@" $@

cfm-$(BLUEPRINT): $(M4BLUEPRINT)
	m4 -D_CFM_ $? >".$@"
	mv ".$@" $@

# inputs
inputs: cfy-$(INPUTS) cfm-$(INPUTS)

cfy-$(INPUTS): $(M4INPUTS) resources/ssh/id_rsa
	m4 $(M4INPUTS) >".$@"
	mv ".$@" $@

cfm-$(INPUTS): $(M4INPUTS) resources/ssh/id_rsa
	m4 -D_CFM_ -D_CFM_BLUEPRINT_=$(CFM_BLUEPRINT) $(M4INPUTS) >".$@"
	mv ".$@" $@

validate: cfy-$(BLUEPRINT) cfm-$(BLUEPRINT)
	cfy blueprints validate -p cfy-$(BLUEPRINT)
	cfy blueprints validate -p cfm-$(BLUEPRINT)

test: validate inputs cfy-init clean

clean:
	-rm -rf cfy-$(INPUTS) .cfy-$(INPUTS) cfm-$(INPUTS) .cfm-$(INPUTS) cfy-$(BLUEPRINT) .cfy-$(BLUEPRINT) cfm-$(BLUEPRINT) .cfm-$(BLUEPRINT) resources/puppet.tar.gz resources/ssh/ local-storage/

cfy-deploy: cfy-init cfy-exec-install

cfy-undeploy: cfy-exec-uninstall

cfy-test: cfy-deploy cfy-undeploy

cfm-deploy: cfm-init cfm-exec-install

cfm-test: cfm-deploy cfm-exec-uninstall cfm-clean


### Resources ####################################

resources/ssh/id_rsa:
	mkdir -p resources/ssh/
	ssh-keygen -N '' -f resources/ssh/id_rsa

resources/puppet.tar.gz: resources/puppet/
	tar -czvf $@ -C $? .


### Standalone deployment ########################

cfy-init: cfy-$(BLUEPRINT) cfy-$(INPUTS) resources/puppet.tar.gz
	cfy local init -p cfy-$(BLUEPRINT) -i cfy-$(INPUTS) --install-plugins

# execute deployment
cfy-exec-%:
	cfy local execute -w $* --task-retries $(RETRIES)


### Cloudify Manager managed deployment ##########

cfm-init: cfm-$(BLUEPRINT) cfm-$(INPUTS) resources/puppet.tar.gz
	cfy blueprints upload -b $(CFM_BLUEPRINT) -p cfm-$(BLUEPRINT)
	cfy deployments create -b $(CFM_BLUEPRINT) -d $(CFM_DEPLOYMENT) -i cfm-$(INPUTS)

cfm-exec-%:
	cfy executions start -d $(CFM_DEPLOYMENT) -w $*
	sleep 10

cfm-clean:
	cfy deployments delete -d $(CFM_DEPLOYMENT)
	cfy blueprints delete -b $(CFM_BLUEPRINT)


### Bootstrap cfy ################################

bootstrap:
	test -f get-cloudify.py && unlink get-cloudify.py || /bin/true
	which virtualenv || ( yum install -y python-virtualenv || apt-get install -y python-virtualenv )
	which pip || ( yum install -y python-pip || apt-get install -y python-pip )
	wget -O get-cloudify.py 'http://repository.cloudifysource.org/org/cloudify3/get-cloudify.py'
	python get-cloudify.py -e $(VIRTUAL_ENV)
	unlink get-cloudify.py
