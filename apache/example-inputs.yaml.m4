############################################
# OCCI authentication options

occi_endpoint: 'https://carach5.ics.muni.cz:11443'
occi_auth: 'x509'
occi_username: ''
occi_password: ''
occi_user_cred: '/tmp/x509up_u0'
occi_ca_path: ''
occi_voms: True


############################################
# Contextualization

# remote user
cc_username: 'cfy'

# SSH public key
cc_public_key: 'include(`resources/ssh/id_rsa.pub')'

# SSH private key (filename or inline)
# TODO: better dettect CFM path
cc_private_key_filename: 'ifdef(`_CFM_',`/opt/manager/resources/blueprints/_CFM_BLUEPRINT_/resources/ssh/id_rsa',`resources/ssh/id_rsa')'

# Instance template/sizing
os_tpl: 'uuid_gputest_egi_centos_7_cerit_sc_188'
#os_tpl: 'uuid_egi_centos_7_fedcloud_warg_149'
#os_tpl: 'uuid_enmr_centos_7_fedcloud_warg_152'

os_availability_zone: 'uuid_fedcloud_cerit_sc_103'

resource_tpl: 'mem_small'
#resource_tpl:  'extra_large'

# vim: set syntax=yaml
