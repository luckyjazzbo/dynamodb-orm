module DynamodbOrm
  class Model
    module Callbacks
      def before_create(&block)
        store_callback(:before_create, block)
      end

      def before_update(&block)
        store_callback(:before_update, block)
      end

      def before_delete(&block)
        store_callback(:before_delete, block)
      end

      def before_save(&block)
        store_callback(:before_save, block)
      end

      def after_save(&block)
        store_callback(:after_save, block)
      end

      def after_initialize(&block)
        store_callback(:after_initialize, block)
      end

      def store_callback(stage, block)
        callbacks_for(stage) << block
      end

      def run_callbacks(instance, stage)
        callbacks_for(stage).each do |block|
          instance.instance_eval(&block)
        end
      end

      private

      def callbacks_for(stage)
        @callbacks ||= {}
        @callbacks[stage.to_sym] ||= []
      end
    end
  end
end
