$:.unshift(File.dirname(__FILE__))

require 'spec_helper'

describe MqttRails::Packet::Pingreq do
  context "Create a simple pingreq packet" do
    it "Successfully create disconnect packet from header" do
      packet = MqttRails::Packet::Base.create_from_header(0xC0)
      expect(packet.inspect).to eq("#<MqttRails::Packet::Pingreq>")
    end
  end
end
