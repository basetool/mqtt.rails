# Copyright (c) 2016-2017 Pierre Goudet <p-goudet@ruby-dev.jp>
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# and Eclipse Distribution License v1.0 which accompany this distribution.
#
# The Eclipse Public License is available at
#    https://eclipse.org/org/documents/epl-v10.php.
# and the Eclipse Distribution License is available at
#   https://eclipse.org/org/documents/edl-v10.php.
#
# Contributors:
#    Pierre Goudet - initial committer

require "mqtt_rails/version"
require "mqtt_rails/client"
require "mqtt_rails/exception"
require "mqtt_rails/packet"

module MqttRails
  extend self

  MAX_PACKET_ID = 65535

  # Default connection setup
  DEFAULT_SSL_PORT      = 8883
  DEFAULT_PORT          = 1883
  SELECT_TIMEOUT        = 0.002

  # MAX size of queue
  MAX_SUBACK   = 10
  MAX_UNSUBACK = 10
  MAX_PUBLISH  = 1000
  MAX_QUEUE    = 1000

  # Connection states values
  MQTT_CS_NEW        = 0
  MQTT_CS_CONNECTED  = 1
  MQTT_CS_DISCONNECT = 2

  # Error values
  MQTT_ERR_SUCCESS = 0
  MQTT_ERR_FAIL    = 1

  PACKET_TYPES = [
    nil,
    MqttRails::Packet::Connect,
    MqttRails::Packet::Connack,
    MqttRails::Packet::Publish,
    MqttRails::Packet::Puback,
    MqttRails::Packet::Pubrec,
    MqttRails::Packet::Pubrel,
    MqttRails::Packet::Pubcomp,
    MqttRails::Packet::Subscribe,
    MqttRails::Packet::Suback,
    MqttRails::Packet::Unsubscribe,
    MqttRails::Packet::Unsuback,
    MqttRails::Packet::Pingreq,
    MqttRails::Packet::Pingresp,
    MqttRails::Packet::Disconnect,
    nil
  ]

  CONNACK_ERROR_MESSAGE = {
    0x02 => "Client Identifier is correct but not allowed by remote server.",
    0x03 => "Connection established but MQTT service unvailable on remote server.",
    0x04 => "User name or user password is malformed.",
    0x05 => "Client is not authorized to connect to the server."
  }

  CLIENT_ATTR_DEFAULTS = {
      :host          => "",
      :port          => nil,
      :mqtt_version  => '3.1.1',
      :clean_session => true,
      :persistent    => false,
      :blocking      => false,
      :client_id     => nil,
      :username      => nil,
      :password      => nil,
      :ssl           => false,
      :will_topic    => nil,
      :will_payload  => nil,
      :will_qos      => 0,
      :will_retain   => false,
      :keep_alive    => 60,
      :ack_timeout   => 5,
      :on_connack    => nil,
      :on_suback     => nil,
      :on_unsuback   => nil,
      :on_puback     => nil,
      :on_pubrel     => nil,
      :on_pubrec     => nil,
      :on_pubcomp    => nil,
      :on_message    => nil,
  }

  Thread.abort_on_exception = true

  def match_filter(topics, filters)
    check_topics(topics, filters)
    index = 0
    rc = false
    topic = topics.split('/')
    filter = filters.split('/')
    while index < [topic.length, filter.length].max do
      if is_end?(topic[index], filter[index])
        break
      elsif is_wildcard?(filter[index])
        rc = index == (filter.length - 1)
        break
      elsif keep_running?(filter[index], topic[index])
        index = index + 1
      else
        break
      end
    end
    is_matching?(rc, topic.length, filter.length, index)
  end

  def keep_running?(filter_part, topic_part)
    filter_part == topic_part || filter_part == '+'
  end

  def is_wildcard?(filter_part)
    filter_part == '#'
  end

  def is_end?(topic_part, filter_part)
    topic_part.nil? || filter_part.nil?
  end

  def is_matching?(rc, topic_length, filter_length, index)
    rc || index == [topic_length, filter_length].max
  end

  def check_topics(topics, filters)
    if topics.is_a?(String) && filters.is_a?(String)
    else
      Rails.logger.error("[MQTT RAILS][ERROR] Topics or Wildcards are not found as String.")
      raise ArgumentError
    end
  end
end
