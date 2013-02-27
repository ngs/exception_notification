class ExceptionNotifier
  class AsanaNotifier
    cattr_accessor :asana_available do true end

    attr_accessor :workspace_id
    attr_accessor :api_key

    class << self
      attr_writer :default_name_prefix

      def default_name_prefix
        @default_name_prefix || "[ERROR] "
      end

      def default_options
        {
          :name_prefix => default_name_prefix
        }
      end

    end

    def initialize(options)
      begin
        return unless asana_available

        workspace_id = options.delete(:workspace_id)
        api_key      = options.delete(:api_key)

        Asana.configure do |client|
          client.api_key = api_key
        end
        @workspace = Asana::Workspace.find(workspace_id)
        @options   = options.reverse_merge(self.class.default_options)
      rescue
        @workspace = nil
      end
    end

    def exception_notification(exception)
      if active?
        @workspace.create_task({
          :name  => "#{@options[:name_prefix]} #{exception.message}",
          :notes => exception.backtrace.join("\n")
        }.reverse_merge(@options))
      end
    end

    private

    def active?
      !@workspace.nil?
    end
  end
end

ExceptionNotifier::AsanaNotifier.asana_available = Gem.loaded_specs.keys.include? 'asana'
