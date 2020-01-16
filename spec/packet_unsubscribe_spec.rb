$:.unshift(File.dirname(__FILE__))

require 'spec_helper'

describe MqttRails::Packet::Unsubscribe do
  context "Create a simple unsubscribe packet" do
    it "Successfully create unsubscribe packet from header" do
      packet = MqttRails::Packet::Base.create_from_header(0xA0)
      expect(packet.inspect).to eq("#<MqttRails::Packet::Unsubscribe: 0x00, >")
    end
    it "Set up flags for unsubscribe packet" do
      packet = MqttRails::Packet::Unsubscribe.new
      expect(packet.validate_flags).to be nil
      packet = MqttRails::Packet:: Unsubscribe.new
    end
  end

  context "Encode ununsubscribe packet with topics" do
    packet = MqttRails::Packet:: Unsubscribe.new
    it "initialize with single topic" do
      packet.topics = "test/topic"
      expect(packet.topics).to eq(["test/topic"])
    end
    it "initialize with multiple topics in array" do
      packet.topics = [["test/topic", 0], ["test/topictopic", 1]]
      expect(packet.topics).to eq([["test/topic", 0], ["test/topictopic", 1]])
    end
    it "initialize with multiple topics in hash" do
      packet.topics = {"test/topic" => 0, "test/topictopic" => 1}
      expect(packet.topics).to eq([{"test/topic" => 0, "test/topictopic" => 1}])
    end
    it "Encode body for unsubscribe packet" do
      packet.id = 4
      packet.topics = "test/topic"
      expect(packet.encode_body.bytes).to eq("\x00\x04\x00\ntest/topic".bytes)
    end

  end
  context "Parse body for unsubscribe packet" do
    it "Fill in all fields with right value" do
      packet = MqttRails::Packet:: Unsubscribe.new
      packet.body_length = 14
      body = "\x00\x04\x00\ntest/topic"
      packet.parse_body(body)
      expect(packet.id).to eq(4)
      expect(packet.topics).to eq(["test/topic"])
    end
  end

   context "Raising execption" do
     it "Fail to validate header flags" do
       packet = MqttRails::Packet::Unsubscribe.new(flags: [false, false, false, false])
       expect { packet.validate_flags }.to raise_error(MqttRails::PacketFormatException, "Invalid flags in UNSUBSCRIBE packet header")
     end

     it "Fail to encode body for empty topics" do
       packet = MqttRails::Packet::Unsubscribe.new
       expect { packet.encode_body }.to raise_error(MqttRails::PacketFormatException, "No topics given when serialising packet")
     end
   end
end
