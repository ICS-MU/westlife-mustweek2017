#!/bin/bash

# install agent
function install_pc1_agent() {
    if ! [ -x /opt/puppetlabs/bin/puppet ]; then
        ctx logger info 'Installing Puppet Agent'
        PC_REPO=$(ctx ${CTX_SIDE} node properties 'puppet_config.repo')
        if [ "x${PC_REPO}" != 'x' ]; then
            sudo rpm -i "${PC_REPO}" 
        fi

        PC_PACKAGE=$(ctx ${CTX_SIDE} node properties 'puppet_config.package')
        if [ "x${PC_PACKAGE}" != 'x' ]; then
            sudo yum -y -q install "${PC_PACKAGE}"
        fi
        ctx logger info 'Puppet Agent installed.' #TODO
    fi

    if ! [ -x /opt/puppetlabs/puppet/bin/r10k ]; then
        ctx logger info 'Installing r10k'
        sudo /opt/puppetlabs/puppet/bin/gem install --quiet r10k
        ctx logger info 'r10k installed.'
    fi
}

# get recipes and modules
function puppet_recipes() {
    if ! [ -d "${1}" ]; then
        # download and extract manifests
        mkdir -p "${1}"
        PC_DOWNLOAD=$(ctx ${CTX_SIDE} node properties 'puppet_config.download')
        MANIFESTS_FILE=$(ctx download-resource ${PC_DOWNLOAD})
        tar -xvf ${MANIFESTS_FILE} -C ${1}

        # install modules
        cd ${1}
        PUPPETFILE="${1}/Puppetfile"
        test -f ${PUPPETFILE} && \
            sudo /opt/puppetlabs/puppet/bin/r10k puppetfile install ${PUPPETFILE}
    fi
}

# generate hiera configuration
function puppet_hiera() {
    cat >>"${1}/hiera.yaml" <<EOF
---
:backends:
  - json
:json:
  :datadir: "${1}"
:hierarchy:
  - 'common'
EOF

    HIERA_DATA=$(ctx --json-output ${CTX_SIDE} node properties 'puppet_config.hiera' 2>/dev/null)
    if [ "x${HIERA_DATA}" != 'x' ]; then
        echo "${HIERA_DATA}" >"${1}/common.json"
    fi
}

# generate external facts
function puppet_facts() {
    export FACTER_CLOUDIFY_CTX_TYPE=${CTX_TYPE}
    export FACTER_CLOUDIFY_CTX_SIDE=${CTX_SIDE}
    export FACTER_CLOUDIFY_CTX_INSTANCE_ID=${CTX_INSTANCE_ID}
    export FACTER_CLOUDIFY_CTX_INSTANCE_HOST_IP=${CTX_INSTANCE_HOST_IP}
    export FACTER_CLOUDIFY_CTX_NODE_ID=${CTX_NODE_ID}
    export FACTER_CLOUDIFY_CTX_NODE_NAME=${CTX_NODE_NAME}
    export FACTER_CLOUDIFY_CTX_BLUEPRINT_ID=${CTX_BLUEPRINT_ID}
    export FACTER_CLOUDIFY_CTX_WORKFLOW_ID=${CTX_WORKFLOW_ID}
    export FACTER_CLOUDIFY_CTX_EXECUTION_ID=${CTX_EXEC_ID}

    FACTSD="${1}/cloudify_facts_modules/facts.d/"
    mkdir -p ${FACTSD}
    echo "${CTX_INSTANCE_RUNTIME_PROPS}" >"${FACTSD}/runtime_properties.json"
    echo "${CTX_NODE_PROPS}" >"${FACTSD}/node_properties.json"
}


#############################

CTX_SIDE="${relationship_side:-$1}"

# install Puppet on very first run
install_pc1_agent

CTX_TYPE=$(ctx type)
CTX_OPERATION_NAME=$(ctx operation name | rev | cut -d. -f1 | rev)
MANIFEST="${manifest:-$(ctx ${CTX_SIDE} node properties "puppet_config.manifests.${CTX_OPERATION_NAME}" 2>/dev/null)}"
if [ "x${MANIFEST}" = 'x' ]; then
    ctx logger info 'Skipping lifecycle operation, no Puppet manifest'
    exit
fi

# context variables
CTX_TYPE=$(ctx type)
CTX_INSTANCE_ID=$(ctx ${CTX_SIDE} instance id)
CTX_INSTANCE_RUNTIME_PROPS=$(ctx --json-output ${CTX_SIDE} instance runtime_properties)
CTX_INSTANCE_HOST_IP=$(ctx ${CTX_SIDE} instance host_ip)
CTX_NODE_ID=$(ctx ${CTX_SIDE} node id)
CTX_NODE_NAME=$(ctx ${CTX_SIDE} node name)
CTX_NODE_PROPS=$(ctx --json-output ${CTX_SIDE} node properties)
CTX_BLUEPRINT_ID=$(ctx blueprint id)
CTX_DEPLOYMENT_ID=$(ctx deployment id)
CTX_WORKFLOW_ID=$(ctx workflow_id)
CTX_EXEC_ID=$(ctx execution_id)
CTX_CAPS=$(ctx --json-output capabilities get_all)

MANIFESTS="/tmp/cloudify-ctx/puppet/${CTX_EXEC_ID}"
puppet_recipes "${MANIFESTS}"
HIERA_DIR=$(mktemp -d "${MANIFESTS}/hiera.XXXXXX")
puppet_hiera "${HIERA_DIR}"
FACTS_DIR=$(mktemp -d "${MANIFESTS}/facts.XXXXXX")
puppet_facts "${FACTS_DIR}"

cd ${MANIFESTS}

# run Puppet
sudo -E /opt/puppetlabs/bin/puppet apply \
    --hiera_config="${HIERA_DIR}/hiera.yaml" \
    --modulepath="${MANIFESTS}/modules:${MANIFESTS}/site:${FACTS_DIR}" \
    --verbose ${MANIFEST}
