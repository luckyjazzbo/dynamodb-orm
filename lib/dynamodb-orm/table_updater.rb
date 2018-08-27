module DynamodbOrm
  class TableUpdater
    attr_reader :model_class, :logger

    def initialize(model_class, opts = {})
      @model_class = model_class
      @logger = opts[:logger] || Logger.new(STDOUT)
    end

    def update(force: false)
      raise TableDoesNotExist if current_state.nil?
      return false if current_state == new_state
      validate_changes(force)

      perform_update(provisioning_updates) if provisioning_updates
      index_changes.each { |change| perform_update global_secondary_index_updates: [change] }
      update_indices_key_schemas
    end

    private

    def provisioning_updates
      if new_state[:provisioned_throughput] != current_state[:provisioned_throughput]
        { provisioned_throughput: new_state[:provisioned_throughput] }
      end
    end

    def perform_update(change, tries_left = 3)
      wait_for_status_active
      client.update_table(
        new_state.slice(:table_name, :attribute_definitions).merge(change)
      )
    rescue Aws::DynamoDB::Errors::LimitExceededException
      raise if tries_left.zero?
      perform_update(change, tries_left - 1)
    end

    def wait_for_status_active
      until table_status_active?
        logger.info "Waiting for ACTIVE status for table #{new_state[:table_name]}"
        sleep 0.5
      end
    end

    def table_status_active?
      state = client.describe_table(table_name: new_state[:table_name]).table.to_h
      state[:table_status] == 'ACTIVE' && Array(state[:global_secondary_indexes]).all? do |index|
        index[:index_status] == 'ACTIVE'
      end
    end

    def index_changes
      @index_changes ||=
        removed_indices.map { |index| { delete: index } } +
        created_indices.map { |index| { create: index } } +
        indices_with_provisioning_updated.map { |index| { update: index } }
    end

    def indices_with_provisioning_updated
      new_indices.map do |name, index|
        next unless current_indices[name]
        if current_indices[name][:key_schema] == index[:key_schema] &&
           current_indices[name][:provisioned_throughput] != index[:provisioned_throughput]
          index.slice(:index_name, :provisioned_throughput)
        end
      end.compact
    end

    def indices_with_key_schema_updated
      new_indices.map do |name, index|
        next unless current_indices[name]
        index if current_indices[name][:key_schema] != index[:key_schema]
      end.compact
    end

    def update_indices_key_schemas
      indices_with_key_schema_updated.each do |index|
        perform_update global_secondary_index_updates: [{ delete: index.slice(:index_name) }]
        perform_update global_secondary_index_updates: [{ create: index }]
      end
    end

    def created_indices
      new_indices.map do |name, index|
        index unless current_indices[name]
      end.compact
    end

    def removed_indices
      current_indices.map do |name, index|
        index.slice(:index_name) unless new_indices[name]
      end.compact
    end

    def current_indices
      @current_indices ||= Hash[
        Array(
          current_state[:global_secondary_indexes]
        ).map { |index| [index[:index_name].to_s, index] }
      ]
    end

    def new_indices
      @new_indices ||= Hash[
        Array(
          new_state[:global_secondary_indexes]
        ).map { |index| [index[:index_name].to_s, index] }
      ]
    end

    def client
      Connection.connect
    end

    def current_state
      @current_state ||= TableDescriber.new(model_class).state
    end

    def new_state
      @new_state ||= TableCreator.new(model_class).table_settings
    end

    def validate_changes(forced)
      raise InvalidUpdateOperation, 'key_schema can not be updated' if key_schema_changed?
      if indices_with_key_schema_updated.any?
        notify_about_key_schema_changes_in_indices(
          indices_with_key_schema_updated.map { |i| i[:index_name] },
          !forced
        )
      end
    end

    def notify_about_key_schema_changes_in_indices(names, raise_error)
      if raise_error
        raise InvalidUpdateOperation,
              "Index key_schema updates detected for indices: #{names}." \
              'Use force key to recreate indices (with downtime).'
      else
        logger.info "Index key_schema updates detected for indices: #{names}." \
                    'That indices will be recreated. Downtime expected.'
      end
    end

    def key_schema_changed?
      new_state[:key_schema] != current_state[:key_schema]
    end
  end
end
