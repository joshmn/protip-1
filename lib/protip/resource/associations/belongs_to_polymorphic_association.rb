require 'protip/resource/associations/association'
require 'protip/resource/associations/belongs_to_association'

module Protip
  module Resource
    module Associations
      class BelongsToPolymorphicAssociation

        include Protip::Resource::Associations::Association
        attr_reader :resource_class, :association_name, :id_field, :belongs_to_associations

        # Define a polymorphic association based on a one-of field. The options for the oneof must all be IDs with
        # an associated +Protip::Resource::Associations::BelongsToAssociation+ that's already been created.
        #
        # @param [Class] resource_class The +Protip::Resource+ class that holds a reference to an associated object.
        # @param [String] association_name The name to use when defining accessors for the associated object.
        # @param [Enumerable<Protip::Resource::Associations::BelongsToAssociation>] belongs_to_associations The
        #   individual associations corresponding to the fields within the `oneof`.
        # @param [Symbol|String] id_field The name of the `oneof` field that holds the association ID. Defaults to
        #   `#{association_name}_id`.
        def initialize(resource_class, association_name, belongs_to_associations, id_field: nil)
          # The class where accessors will be defined
          @resource_class = resource_class

          # The name of the accessor methods
          @association_name = association_name.to_sym

          # The oneof field that holds the ID of the foreign resource
          @id_field  = (id_field ||
            Protip::Resource::Associations::BelongsToAssociation.default_id_field(association_name)).to_sym
          @_oneof = @resource_class.message.descriptor.lookup_oneof(@id_field.to_s)
          raise "Invalid field name for polymorphic association: #{@id_field}" unless @_oneof


          # Internally, keep the nested associations indexed by ID field
          @_indexed_belongs_to_associations = {}
          belongs_to_associations.each do |association|
            if @_indexed_belongs_to_associations.has_key? association.id_field.to_sym
              raise ArgumentError.new("Duplicate association for #{id_field}")
            end
            @_indexed_belongs_to_associations[association.id_field.to_sym] = association
          end
          field_names = @_oneof.map{|desc| desc.name.to_sym}
          unless (field_names.length == @_indexed_belongs_to_associations.length &&
            @_indexed_belongs_to_associations.keys.all?{|id_field| field_names.include? id_field})
            raise ArgumentError.new(
              'Polymorphic association requires an association to be defined for all nested fields'
            )
          end
          @belongs_to_associations = Set.new(belongs_to_associations)
        end

        def read(resource)
          field = resource.message.public_send(id_field)
          if field
            @_indexed_belongs_to_associations[field].read(resource)
          else
            nil
          end
        end

        def write(resource, value)
          if value == nil
            @_oneof.each do |field_descriptor|
              resource.public_send(:"#{field_descriptor.name}=", nil)
            end
            nil
          else
            # Find the nested reference matching this association type
            matching_associations = belongs_to_associations.select do |association|
              value.is_a? association.associated_resource_class
            end

            # Make sure we found exactly one
            if matching_associations.empty?
              raise ArgumentError.new("Could not find matching reference for value of type #{value.class}")
            end
            if matching_associations.length > 1
              raise ArgumentError.new(
                      "Value of type #{value.class} matched with #{matching_references.keys.map(&:to_s).join(', ')}"
                    )
            end

            # And forward the write operation
            matching_associations.first.write(resource, value)
          end
        end
      end
    end
  end
end