# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: protip/messages/array.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "protip.messages.Array" do
    repeated :messages, :bytes, 1
  end
end

module Protip
  module Messages
    Array = Google::Protobuf::DescriptorPool.generated_pool.lookup("protip.messages.Array").msgclass
  end
end
