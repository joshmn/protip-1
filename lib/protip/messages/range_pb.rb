# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: protip/messages/range.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("protip/messages/range.proto", :syntax => :proto3) do
    add_message "protip.messages.Range" do
      optional :begin, :int64, 1
      optional :end, :int64, 2
    end
  end
end

module Protip
  module Messages
    Range = Google::Protobuf::DescriptorPool.generated_pool.lookup("protip.messages.Range").msgclass
  end
end
