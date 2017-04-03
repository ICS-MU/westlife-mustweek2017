require 'puppet/provider/parsedfile'
require 'pp'

# http://www.clusterresources.com/torquedocs21/1.2basicconfig.shtml#nodes
Puppet::Type.type(:torque_node).provide(
  :parsed,
  :parent         => Puppet::Provider::ParsedFile,
  :filetype       => :flat,
  :default_target => '/var/lib/torque/server_priv/nodes'
  #:default_target => '/var/spool/torque/server_priv/nodes'
  #:default_target => '/tmp/nodes'
) do
  has_feature :target_file

  #confine :exists => nodes

  text_line :comment, :match => /^#/
  text_line :blank,   :match => /^\s*$/

  NODE_MAP = {
    'np'                         => 'np',
#    'node_priority'              => 'priority',
#    'machine_spec'               => 'machine_spec',
#    'resources_total.room'       => 'room', # RT #84539
#    'resources_total.city'       => 'city',
#    'resources_total.infiniband' => 'infiniband',
#    'resources_total.home'       => 'home'
  }

  NODE_TYPE = {
    ''    => 'cluster',
    ':cl' => 'cloud',
    ':vi' => 'virtual',
    ':ts' => 'time-shared'
  }

  record_line :parsed,
    :fields     => %w{name ntype options},
    :optional   => %w{ntype options},
    :match      => /^([^\s:]+)(:[\S]+)?\s*(.*?)?$/,
    :post_parse => proc { |hash|
      # convert ntype short name to long name
      hash[:ntype] = '' if hash[:ntype].nil? or hash[:ntype] == :absent
      hash[:ntype] = NODE_TYPE[ hash[:ntype] ]
      if hash[:ntype].nil?
        raise Puppet::Error, "Invalid node type"
      end

      # read all node metadata (each separated by space)
      # - take known options (x=y)
      # - remember unknown options (x=y)
      # - take properties (z)
      properties = []
      misc_options = []

      if hash.include? :options and !hash[:options].nil? and hash[:options] != :absent
        hash[:options].split.each do |o|
          k,v = o.split('=')
          if v.nil?
            # found node property,
            properties << k
          elsif ! k.nil?
            if NODE_MAP.include? k
              # found known node option, make
              # a separate type property :x=>y
              hash[NODE_MAP[k].intern] = v
            else
              # found unknown node option,
              # remember for node flush
              misc_options << o
            end
          end
        end
      end

      hash[:properties]=properties.join(',')
      hash[:misc_options]=misc_options.join(' ')

      # assign :absent into missing unknown options
      NODE_MAP.values.each do |o|
        if ! hash.include? o.intern
          hash[o.intern] = :absent
        end
      end
    },

    :to_line => proc { |hash|
      def hash.ok?(name)
        self.include? name and
          ! self[name].nil? and
          ! self[name].to_s.empty? and
          self[name] != :absent
      end

      str = "#{hash[:name]}#{NODE_TYPE.invert[hash[:ntype].to_s]}"

      NODE_MAP.each_pair { |k_o,k_p|
        if hash.ok?(k_p.intern)
          str += " #{k_o}=#{hash[k_p.intern]}"
        end
      }

      if hash.ok? :misc_options
        str += " #{hash[:misc_options]}"
      end

      if hash.ok? :properties
        str += ' '+hash[:properties].split(',').join(' ')
      end

      str.strip
    }

  def self.to_file(records)
    super records.sort{ |x,y| x[:name] <=> y[:name] }
  end
end
