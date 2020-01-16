$:.unshift(File.dirname(__FILE__))

require 'spec_helper'

describe MqttRails::Packet::Pubcomp do
  context "Create a simple pubcomp packet" do
    it "Successfully create pubcomp packet from header" do
      packet = MqttRails::Packet::Base.create_from_header(0x70)
      expect(packet.inspect).to eq("#<MqttRails::Packet::Pubcomp: 0x00>")
      expect(packet.parse_body("")).to be nil
    end
    it "Encode packet id" do
      packet = MqttRails::Packet::Pubcomp.new({id: 4})
      expect(packet.encode_body.bytes).to eq("\x00\x04".bytes)
    end
  end

  context "Raising execption" do
    it "Fail for payload in pubcomp packet" do
      packet = MqttRails::Packet::Pubcomp.new
      packet.body_length = 3
      expect { packet.parse_body("\x01\x00\x00") }.to raise_error(MqttRails::PacketFormatException, "Extra bytes at end of Publish Complete packet")
    end
  end
end
