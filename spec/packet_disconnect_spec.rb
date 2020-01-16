$:.unshift(File.dirname(__FILE__))

require 'spec_helper'

describe MqttRails::Packet::Disconnect do
  context "Create a simple disconnect packet" do
    it "Successfully create disconnect packet from header" do
      packet = MqttRails::Packet::Base.create_from_header(0xE0)
      expect(packet.inspect).to eq("#<MqttRails::Packet::Disconnect>")
      expect(packet.parse_body("")).to be nil
    end

    context "Raising execption" do
      it "Fail for payload in disconnect packet" do
        packet = MqttRails::Packet::Disconnect.new
        packet.body_length = 1
        expect { packet.parse_body("\x00") }.to raise_error(MqttRails::PacketFormatException, "Extra bytes at the end of Disconnect packet")
      end
    end
  end
end
