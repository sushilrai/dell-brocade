require 'puppet/provider/brocade_fos'

Puppet::Type.type(:brocade_zone).provide(:brocade_zone, :parent => Puppet::Provider::Brocade_fos) do
  @doc = "Manage brocade zone creation, modification and deletion."

 mk_resource_methods

 def cfg_save
   @transport.command("cfgsave", :prompt => /Do/)
   @transport.command("yes", :noop => false)
 end

 def create
    Puppet.debug("Puppet::Provider::brocade_zone: A Brocade zone with zonename: #{@resource[:zonename]}, zonemember:  #{@resource[:member]} is being added.")
    response =  @transport.command("zonecreate  #{@resource[:zonename]},  #{@resource[:member]}", :noop => false)
    if !response.include? "duplicate name"
      Puppet.debug("Puppet::Provider::brocade_zone: A Brocade zone with zonename: #{@resource[:zonename]}, to zoneconfig:  #{@resource[:zoneconfig]} is being added.")
      if @resource[:zoneconfig] && @resource[:zoneconfig].length != 0
        response =  @transport.command("cfgadd #{@resource[:zoneconfig]}, #{@resource[:zonename]}", :noop => false) 
        if !response.include? "not found"
          cfg_save
        end
      else
        cfg_save
      end
    end
  end



  def destroy
    Puppet.debug("Puppet::Provider::brocade_zone: A Brocade zone with zonename: #{@resource[:zonename]} is being deleted.")
    response = ""
    if @resource[:zoneconfig] && (@resource[:zoneconfig].length != 0)
      Puppet.debug("Puppet::Provider::brocade_zone: A Brocade zone with zonename: #{@resource[:zonename]}, from zoneconfig:  #{@resource[:zoneconfig]} is being deleted.")
      response = @transport.command("cfgremove #{@resource[:zoneconfig]}, #{@resource[:zonename]}", :noop => false)
    end
    deletezone(response)
  end

  def deletezone(response)
   if !response.include? "is not in"
      response = @transport.command("zonedelete  #{@resource[:zonename]}", :noop => false)
      if !response.include? "not found"
        cfg_save
      end
    end
  end

  def exists?
    Puppet.debug("Puppet::Provider::brocade_zone: Verifying whether or not a Brocade zone with zonename: #{@resource[:zonename]} exists.")
    self.device_transport
    response =  @transport.command("zoneshow #{@resource[:zonename]}", :noop => false)
    if !response.include? "does not exist."
      true
    else
      false
    end
  end

end
