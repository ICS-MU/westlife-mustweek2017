$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..",".."))
require 'facter'
require 'puppet/property/list'

Puppet::Type.newtype(:torque_node) do
  @doc = "Manage Torque nodes"

  feature :target_file, "The provider can specify node configuration file"
  feature :node_notes,  "The provider can modify node's notes"

  ensurable

  newparam(:name) do
    desc <<-EOT
      Torque node hostname. This is a network hostname
      of server running pbs_mom daemon.
    EOT

    isnamevar
  end

  newparam(:server_name) do
    desc <<-EOT
      Server FQDN
    EOT

    isrequired
  end

  newproperty(:np) do
    desc <<-EOT
      Processors count. Number of processors available for
      computation. Defaults to $::processorcount fact.
    EOT

    defaultto {
      Facter.value('processorcount')
    }

    validate do |value|
      unless Integer(value)>0
        raise ArgumentError, "Unsupported number of processors: #{value}"
      end
    end

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:note, :required_features => :node_notes) do
    desc "Node note"
    #TODO: note to neustale premazava, kdyz je zmena i jinde
  end

  newproperty(:ntype) do
    desc <<-EOT
      Torque node type
    EOT

    defaultto 'cluster'
    newvalues('cluster','cloud','virtual','time-shared')
  end

  newproperty(:properties, :parent => Puppet::Property::List, :array_matching => :all) do
    defaultto []
    desc "Node properties"

    def membership
      :membership
    end
  end

  newproperty(:machine_spec) do
    desc <<-EOT
      SPECfp2006 base rate of _single CPU core_.
    EOT

    defaultto 10.0000

    validate do |value|
      unless Float(value)>0
        raise ArgumentError, "Invalid machine_spec"
      end
    end

    munge do |value|
      sprintf('%.4f', value)
    end
  end

  newproperty(:priority) do
    desc <<-EOT
      Node priority
    EOT

    defaultto 100

    validate do |value|
      if Float(value)<1
        raise ArgumentError, "Invalid priority"
      end
    end

    munge do |value|
      sprintf('%.0f', value)
    end
  end

  newproperty(:room) do
    desc <<-EOT
      Node server room
    EOT
  end

  newproperty(:city) do
    desc <<-EOT
      Node city
    EOT
  end

  newproperty(:infiniband) do
    desc <<-EOT
      Node Infiniband segment
    EOT
  end

  newproperty(:home) do
    desc <<-EOT
      Node primary home
    EOT
  end

  newproperty(:target, :required_features => :target_file) do
    desc <<-EOT
      The file in which to store nodes information. Only used by those providers
      that write to disk. Usually defaults to `/var/spool/torque/server_priv/nodes`.
    EOT

    defaultto {
      if @resource.class.defaultprovider.ancestors.include?(Puppet::Provider::ParsedFile)
        @resource.class.defaultprovider.default_target
      else
        nil
      end
    }
  end

  newparam(:membership) do
    newvalues(:inclusive)
    defaultto :inclusive

    # "Minimum" membership doesn't work (don't know why),
    # if nodes aren't already in configuration files:
    # Error: /Stage[main]//Torque_node[test1.cerit-sc.cz]: Could not evaluate: stack level too deep
    # Error: /Stage[main]//Torque_node[test3.cerit-sc.cz]: Could not evaluate: stack level too deep
    # Error: /Stage[main]//Torque_node[test4.cerit-sc.cz]: Could not evaluate: stack level too deep
    # Error: /Stage[main]//Torque_node[test2.cerit-sc.cz]: Could not evaluate: stack level too deep
    # Error: /Stage[main]//Torque_node[test5.cerit-sc.cz]: Could not evaluate: stack level too deep
    #...
    #
    #newvalues(:inclusive, :minimum)
    #defaultto :minimum
  end


  #####

#?  # The 'query' method returns a hash of info if the package
#?  # exists and returns nil if it does not.
#?  def exists?
#?    @provider.get(:ensure) != :absent
#?  end

#   validate do |value|
#     validate_fqdn(value)
#   end 

  private

#  def validate_fqdn(value)
#    # Taken from Puppet's host.rb
#    # LAK:NOTE See http://snurl.com/21zf8  [groups_google_com]
#    x = value.split('.').each do |hostpart|
#      unless hostpart =~ /^([\d\w]+|[\d\w][\d\w\-]+[\d\w])$/
#        raise Puppet::Error, "Invalid host name"
#      end 
#    end 
#  end
end
